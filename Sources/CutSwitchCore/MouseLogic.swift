public enum ZoomAction: Equatable { case zoomIn, zoomOut, zoomToFit }

public enum MenuShortcut {
    /// AX modifier bits: Shift 1, Option 2, Control 4, NoCommand 8.
    public static func action(character: String, modifiers: Int) -> ZoomAction? {
        switch (character.lowercased(), modifiers) {
        case ("=", 0), ("+", 0): return .zoomIn
        case ("-", 0): return .zoomOut
        case ("z", 9): return .zoomToFit
        default: return nil
        }
    }

    /// CutSwitch Premiere setindeki tuşlar (Command'sız =, -, \). Yalnız varsayılan
    /// ⌘ kısayolları menüde yoksa kullanılır; varsayılan sette bu tuşlar başka işlere ait.
    public static func premiereAction(character: String, modifiers: Int) -> ZoomAction? {
        switch (character.lowercased(), modifiers) {
        case ("=", 8), ("+", 8): return .zoomIn
        case ("-", 8): return .zoomOut
        case ("\\", 8): return .zoomToFit
        default: return nil
        }
    }
}

public enum WheelDecision: Equatable { case pass, consume, zoom(ZoomAction) }

public struct WheelState {
    private var lastZoom: Double?
    public init() {}

    public mutating func decide(lineDelta: Double, pointDelta: Double, momentum: Bool,
                                enabled: Bool, modifierPressed: Bool, invert: Bool,
                                throttleMs: Double, now: Double) -> WheelDecision {
        guard enabled && modifierPressed else { return .pass }
        guard !momentum else { return .consume }
        let delta = lineDelta != 0 ? lineDelta : pointDelta
        guard delta != 0 else { return .consume }
        if let lastZoom, now - lastZoom < max(0, throttleMs) / 1000 { return .consume }
        lastZoom = now
        return .zoom((delta > 0) != invert ? .zoomIn : .zoomOut)
    }
}

public enum MiddleDecision: Equatable { case pass, consume, fit, pan }

public struct MiddleButtonState {
    private var start: (x: Double, y: Double)?
    private var dragged = false
    public init() {}
    public mutating func reset() { start = nil; dragged = false }

    public mutating func down(x: Double, y: Double, fitEnabled: Bool, panEnabled: Bool) -> MiddleDecision {
        reset()
        guard fitEnabled || panEnabled else { return .pass }
        start = (x, y)
        return .consume
    }

    public mutating func drag(x: Double, y: Double, panEnabled: Bool) -> MiddleDecision {
        guard let start else { return .pass }
        let dx = x - start.x, dy = y - start.y
        if dx * dx + dy * dy >= 16 { dragged = true }
        return dragged && panEnabled ? .pan : .consume
    }

    public mutating func up(active: Bool, fitEnabled: Bool) -> MiddleDecision {
        defer { reset() }
        guard start != nil, active else { return .pass }
        return !dragged && fitEnabled ? .fit : .consume
    }
}
