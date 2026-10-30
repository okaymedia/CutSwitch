import AppKit
import Combine

/// Zoom için basılı tutulacak tuş.
enum ZoomModifier: String, CaseIterable, Identifiable {
    case option, command, control

    var id: String { rawValue }

    var flag: CGEventFlags {
        switch self {
        case .option:  return .maskAlternate
        case .command: return .maskCommand
        case .control: return .maskControl
        }
    }

    var label: String {
        switch self {
        case .option:  return UIStrings.option
        case .command: return UIStrings.command
        case .control: return UIStrings.control
        }
    }
}

/// Kullanıcı ayarları (UserDefaults'ta saklanır).
final class Settings: ObservableObject {
    static let shared = Settings()
    private let d = UserDefaults.standard

    @Published var zoomEnabled: Bool     { didSet { d.set(zoomEnabled, forKey: Keys.zoomEnabled) } }
    @Published var zoomModifier: ZoomModifier { didSet { d.set(zoomModifier.rawValue, forKey: Keys.zoomModifier) } }
    @Published var invertZoom: Bool      { didSet { d.set(invertZoom, forKey: Keys.invertZoom) } }
    @Published var zoomThrottleMs: Double { didSet { d.set(zoomThrottleMs, forKey: Keys.zoomThrottleMs) } }
    @Published var middleClickFit: Bool  { didSet { d.set(middleClickFit, forKey: Keys.middleClickFit) } }
    @Published var middleDragPan: Bool   { didSet { d.set(middleDragPan, forKey: Keys.middleDragPan) } }
    @Published var invertPan: Bool       { didSet { d.set(invertPan, forKey: Keys.invertPan) } }
    @Published var onboarded: Bool       { didSet { d.set(onboarded, forKey: Keys.onboarded) } }

    /// Erişilebilirlik izni durumu (saklanmaz, canlı kontrol edilir).
    @Published var isTrusted = false

    private enum Keys {
        static let zoomEnabled = "zoomEnabled"
        static let zoomModifier = "zoomModifier"
        static let invertZoom = "invertZoom"
        static let zoomThrottleMs = "zoomThrottleMs"
        static let middleClickFit = "middleClickFit"
        static let middleDragPan = "middleDragPan"
        static let invertPan = "invertPan"
        static let onboarded = "onboarded"
    }

    private init() {
        d.register(defaults: [
            Keys.zoomEnabled: true,
            Keys.zoomModifier: ZoomModifier.option.rawValue,
            Keys.invertZoom: false,
            Keys.zoomThrottleMs: 40.0,
            Keys.middleClickFit: true,
            Keys.middleDragPan: true,
            Keys.invertPan: false,
            Keys.onboarded: false,
        ])
        zoomEnabled    = d.bool(forKey: Keys.zoomEnabled)
        zoomModifier   = ZoomModifier(rawValue: d.string(forKey: Keys.zoomModifier) ?? "") ?? .option
        invertZoom     = d.bool(forKey: Keys.invertZoom)
        zoomThrottleMs = d.double(forKey: Keys.zoomThrottleMs)
        middleClickFit = d.bool(forKey: Keys.middleClickFit)
        middleDragPan  = d.bool(forKey: Keys.middleDragPan)
        invertPan      = d.bool(forKey: Keys.invertPan)
        onboarded      = d.bool(forKey: Keys.onboarded)
    }
}
