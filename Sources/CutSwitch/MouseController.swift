import AppKit
import CutSwitchCore

/// Mouse olaylarını yakalar ve Final Cut Pro öndeyken Premiere tarzı davranışa çevirir.
///
///  ⌥ + tekerlek        → timeline zoom in / out
///  Orta tuş tıklama    → Zoom to Fit
///  Orta tuşla sürükleme → timeline'ı kaydırma (el aracı gibi)
///
/// Final Cut önde değilse hiçbir olaya dokunmaz.
final class MouseController {
    static let shared = MouseController()

    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let menu = FCPMenuActions()

    private let fcpBundleIDs: Set<String> = [
        "com.apple.FinalCut",       // tek seferlik satın alma
        "com.apple.FinalCutApp",    // Creator Studio (abonelik)
        "com.apple.FinalCutTrial",  // deneme sürümü
    ]

    /// Kendi gönderdiğimiz kaydırma olaylarını tanımak için işaret.
    private let syntheticMarker: Int64 = 0x4355_5453 // "CUTS"

    private var wheel = WheelState()
    private var middle = MiddleButtonState()
    private var activePID: pid_t?
    private var workspaceObservers: [NSObjectProtocol] = []
    private var menuTimer: Timer?

    private init() {
        let center = NSWorkspace.shared.notificationCenter
        workspaceObservers.append(center.addObserver(forName: NSWorkspace.didActivateApplicationNotification,
                                                     object: nil, queue: .main) { [weak self] note in
            self?.activate(note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)
        })
        workspaceObservers.append(center.addObserver(forName: NSWorkspace.didTerminateApplicationNotification,
                                                     object: nil, queue: .main) { [weak self] note in
            guard let self, let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                  let id = app.bundleIdentifier, self.fcpBundleIDs.contains(id) else { return }
            self.menu.clear()
            if self.activePID == app.processIdentifier { self.activePID = nil; self.middle.reset() }
        })
        activate(NSWorkspace.shared.frontmostApplication)
        // Menü değişiklikleri callback dışında önbelleğe alınır.
        menuTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self, let pid = self.activePID else { return }
            self.menu.refresh(pid: pid)
        }
    }

    private func activate(_ app: NSRunningApplication?) {
        middle.reset()
        wheel = WheelState()
        guard let app, let id = app.bundleIdentifier, fcpBundleIDs.contains(id) else {
            activePID = nil
            return
        }
        activePID = app.processIdentifier
        menu.refresh(pid: app.processIdentifier)
    }

    var isRunning: Bool { tap != nil }

    @discardableResult
    func start() -> Bool {
        guard tap == nil else { return true }

        let mask: CGEventMask =
            (CGEventMask(1) << CGEventType.scrollWheel.rawValue) |
            (CGEventMask(1) << CGEventType.otherMouseDown.rawValue) |
            (CGEventMask(1) << CGEventType.otherMouseUp.rawValue) |
            (CGEventMask(1) << CGEventType.otherMouseDragged.rawValue)

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let me = Unmanaged<MouseController>.fromOpaque(refcon).takeUnretainedValue()
            return me.handle(type, event)
        }

        guard let newTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return false // Genelde Erişilebilirlik izni yok demektir.
        }

        tap = newTap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, newTap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: newTap, enable: true)
        return true
    }

    func stop() {
        if let tap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes) }
        tap = nil
        runLoopSource = nil
        middle.reset()
        wheel = WheelState()
    }

    // MARK: - Olay işleme

    private func handle(_ type: CGEventType, _ event: CGEvent) -> Unmanaged<CGEvent>? {
        let pass = Unmanaged.passUnretained(event)

        // macOS tap'i yavaşlık yüzünden kapatırsa yeniden aç.
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return pass
        }

        // Kendi ürettiğimiz kaydırma olaylarına dokunma.
        if event.getIntegerValueField(.eventSourceUserData) == syntheticMarker {
            return pass
        }

        let s = Settings.shared
        let isMiddle = event.getIntegerValueField(.mouseEventButtonNumber) == 2

        // Bırakma, ön uygulamadan bağımsız olarak durumu temizler.
        if type == .otherMouseUp && isMiddle {
            let decision = middle.up(active: activePID != nil, fitEnabled: s.middleClickFit)
            if decision == .fit, let pid = activePID { menu.perform(.zoomToFit, pid: pid) }
            return decision == .pass ? pass : nil
        }
        guard let pid = activePID else { return pass }

        switch type {

        case .scrollWheel:
            let decision = wheel.decide(
                lineDelta: Double(event.getIntegerValueField(.scrollWheelEventDeltaAxis1)),
                pointDelta: event.getDoubleValueField(.scrollWheelEventPointDeltaAxis1),
                momentum: event.getIntegerValueField(.scrollWheelEventMomentumPhase) != 0,
                enabled: s.zoomEnabled, modifierPressed: event.flags.contains(s.zoomModifier.flag),
                invert: s.invertZoom, throttleMs: s.zoomThrottleMs,
                now: ProcessInfo.processInfo.systemUptime)
            switch decision {
            case .pass: return pass
            case .consume: return nil
            case .zoom(let action): return menu.perform(action, pid: pid) ? nil : pass
            }

        case .otherMouseDown where isMiddle:
            return middle.down(x: event.location.x, y: event.location.y,
                               fitEnabled: s.middleClickFit, panEnabled: s.middleDragPan) == .pass ? pass : nil

        case .otherMouseDragged where isMiddle:
            let decision = middle.drag(x: event.location.x, y: event.location.y, panEnabled: s.middleDragPan)
            if decision == .pan {
                var dx = Int32(clamping: event.getIntegerValueField(.mouseEventDeltaX))
                var dy = Int32(clamping: event.getIntegerValueField(.mouseEventDeltaY))
                if s.invertPan { dx = dx == .min ? .max : -dx; dy = dy == .min ? .max : -dy }
                postScroll(dx: dx, dy: dy)
            }
            return decision == .pass ? pass : nil

        default:
            return pass
        }
    }

    private func postScroll(dx: Int32, dy: Int32) {
        guard let e = CGEvent(scrollWheelEvent2Source: nil, units: .pixel,
                              wheelCount: 2, wheel1: dy, wheel2: dx, wheel3: 0) else { return }
        e.setIntegerValueField(.eventSourceUserData, value: syntheticMarker)
        e.post(tap: .cgSessionEventTap)
    }
}
