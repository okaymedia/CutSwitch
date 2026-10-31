import AppKit
import CutSwitchCore
import ApplicationServices

/// Final Cut Pro'nun menü komutlarını Erişilebilirlik (AX) API'si ile tetikler.
///
/// Klavye kısayolu göndermek yerine menü öğesine "bas" diyoruz. Böylece:
///  - Türkçe Q / F klavyede de doğru çalışır (tuş konumuna bağlı değil),
///  - Final Cut'ın arayüz dili ne olursa olsun çalışır (menü adına değil,
///    menü öğesinin kısayol karakterine bakıyoruz).
final class FCPMenuActions {

    typealias Action = ZoomAction

    private var cachedPID: pid_t = 0
    private var zoomIn: AXUIElement?
    private var zoomOut: AXUIElement?
    private var zoomToFit: AXUIElement?
    private var fallback: [ZoomAction: AXUIElement] = [:]

    /// Komutu çalıştırır. Başarılıysa true döner.
    @discardableResult
    func perform(_ action: Action, pid: pid_t) -> Bool {
        guard pid == cachedPID, let el = element(for: action) else { return false }
        let success = AXUIElementPerformAction(el, kAXPressAction as CFString) == .success
        if !success {
            // Yenileme callback tamamlandıktan sonra ana döngüde yapılır.
            DispatchQueue.main.async { [weak self] in
                guard let self, self.cachedPID == pid else { return }
                self.rebuild(pid: pid)
            }
        }
        return success
    }

    func clear() {
        cachedPID = 0
        zoomIn = nil; zoomOut = nil; zoomToFit = nil
    }

    func refresh(pid: pid_t) { rebuild(pid: pid) }

    private func element(for action: Action) -> AXUIElement? {
        switch action {
        case .zoomIn:    return zoomIn
        case .zoomOut:   return zoomOut
        case .zoomToFit: return zoomToFit
        }
    }

    private func rebuild(pid: pid_t) {
        cachedPID = pid
        zoomIn = nil; zoomOut = nil; zoomToFit = nil

        let app = AXUIElementCreateApplication(pid)
        guard let menuBar: AXUIElement = attribute(app, kAXMenuBarAttribute) else { return }
        fallback = [:]
        walk(menuBar, depth: 0)
        zoomIn = zoomIn ?? fallback[.zoomIn]
        zoomOut = zoomOut ?? fallback[.zoomOut]
        zoomToFit = zoomToFit ?? fallback[.zoomToFit]
        fallback = [:]
    }

    /// Menüleri dolaşıp kısayol karakterine göre ilgili öğeleri bulur.
    ///  ⌘+ / ⌘=  → Zoom In
    ///  ⌘-       → Zoom Out
    ///  ⇧Z       → Zoom to Fit  (Command'sız, sadece Shift)
    ///  Bulunamazsa Premiere setindeki =, -, \ (Command'sız) yedek olarak kullanılır.
    private func walk(_ el: AXUIElement, depth: Int) {
        guard depth < 6 else { return }

        if let char: String = attribute(el, kAXMenuItemCmdCharAttribute) {
            let mods: Int = attribute(el, kAXMenuItemCmdModifiersAttribute) ?? 0
            switch MenuShortcut.action(character: char, modifiers: mods) {
            case .zoomIn where zoomIn == nil: zoomIn = el
            case .zoomOut where zoomOut == nil: zoomOut = el
            case .zoomToFit where zoomToFit == nil: zoomToFit = el
            default:
                if let action = MenuShortcut.premiereAction(character: char, modifiers: mods),
                   fallback[action] == nil { fallback[action] = el }
            }
        }

        guard let children: [AXUIElement] = attribute(el, kAXChildrenAttribute) else { return }
        for child in children {
            walk(child, depth: depth + 1)
        }
    }

    private func attribute<T>(_ el: AXUIElement, _ name: String) -> T? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(el, name as CFString, &value) == .success,
              let value else { return nil }
        return value as? T
    }
}
