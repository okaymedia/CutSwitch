import XCTest
@testable import CutSwitchCore

final class MouseLogicTests: XCTestCase {
    func testZoomInShortcuts() {
        XCTAssertEqual(MenuShortcut.action(character: "=", modifiers: 0), .zoomIn)
        XCTAssertEqual(MenuShortcut.action(character: "+", modifiers: 0), .zoomIn)
    }
    func testZoomOutShortcut() { XCTAssertEqual(MenuShortcut.action(character: "-", modifiers: 0), .zoomOut) }
    func testPremiereShortcuts() {
        XCTAssertEqual(MenuShortcut.premiereAction(character: "=", modifiers: 8), .zoomIn)
        XCTAssertEqual(MenuShortcut.premiereAction(character: "-", modifiers: 8), .zoomOut)
        XCTAssertEqual(MenuShortcut.premiereAction(character: "\\", modifiers: 8), .zoomToFit)
        XCTAssertNil(MenuShortcut.premiereAction(character: "=", modifiers: 0))
        XCTAssertNil(MenuShortcut.premiereAction(character: "z", modifiers: 9))
    }
    func testFitShortcut() { XCTAssertEqual(MenuShortcut.action(character: "Z", modifiers: 9), .zoomToFit) }
    func testRejectOtherModifiers() {
        for modifiers in [1, 2, 4, 8, 16] { XCTAssertNil(MenuShortcut.action(character: "=", modifiers: modifiers)) }
        XCTAssertNil(MenuShortcut.action(character: "z", modifiers: 1))
    }
    private func wheel(line: Double = 1, point: Double = 0, momentum: Bool = false,
                       enabled: Bool = true, modifier: Bool = true, invert: Bool = false) -> WheelDecision {
        var state = WheelState()
        return state.decide(lineDelta: line, pointDelta: point, momentum: momentum, enabled: enabled,
                            modifierPressed: modifier, invert: invert, throttleMs: 40, now: 0)
    }
    func testFirstWheelAndDirection() {
        XCTAssertEqual(wheel(), .zoom(.zoomIn))
        XCTAssertEqual(wheel(line: -1), .zoom(.zoomOut))
        XCTAssertEqual(wheel(invert: true), .zoom(.zoomOut))
    }
    func testPointDeltaFallbackAndLinePriority() {
        XCTAssertEqual(wheel(line: 0, point: -0.5), .zoom(.zoomOut))
        XCTAssertEqual(wheel(line: 1, point: -10), .zoom(.zoomIn))
    }
    func testDisabledAndModifierPassThrough() {
        XCTAssertEqual(wheel(enabled: false), .pass)
        XCTAssertEqual(wheel(modifier: false), .pass)
    }
    func testMomentumAndZeroConsumed() {
        XCTAssertEqual(wheel(momentum: true), .consume)
        XCTAssertEqual(wheel(line: 0), .consume)
    }
    func testThrottleBoundary() {
        var state = WheelState()
        func decide(_ time: Double) -> WheelDecision {
            state.decide(lineDelta: 1, pointDelta: 0, momentum: false, enabled: true,
                         modifierPressed: true, invert: false, throttleMs: 40, now: time)
        }
        XCTAssertEqual(decide(0), .zoom(.zoomIn))
        XCTAssertEqual(decide(0.039), .consume)
        XCTAssertEqual(decide(0.040), .zoom(.zoomIn))
    }
    func testClickFitsAndResets() {
        var state = MiddleButtonState()
        XCTAssertEqual(state.down(x: 0, y: 0, fitEnabled: true, panEnabled: true), .consume)
        XCTAssertEqual(state.drag(x: 3, y: 0, panEnabled: true), .consume)
        XCTAssertEqual(state.up(active: true, fitEnabled: true), .fit)
        XCTAssertEqual(state.up(active: true, fitEnabled: true), .pass)
    }
    func testFourPixelThresholdAndStickyDrag() {
        var state = MiddleButtonState()
        _ = state.down(x: 0, y: 0, fitEnabled: true, panEnabled: true)
        XCTAssertEqual(state.drag(x: 4, y: 0, panEnabled: true), .pan)
        XCTAssertEqual(state.drag(x: 0, y: 0, panEnabled: true), .pan)
        XCTAssertEqual(state.up(active: true, fitEnabled: true), .consume)
    }
    func testReleaseOutsideFCPResets() {
        var state = MiddleButtonState()
        _ = state.down(x: 0, y: 0, fitEnabled: true, panEnabled: true)
        XCTAssertEqual(state.up(active: false, fitEnabled: true), .pass)
        XCTAssertEqual(state.drag(x: 10, y: 0, panEnabled: true), .pass)
        XCTAssertEqual(state.up(active: true, fitEnabled: true), .pass)
    }
    func testDisabledPanDoesNotTurnDragIntoClick() {
        var state = MiddleButtonState()
        _ = state.down(x: 0, y: 0, fitEnabled: true, panEnabled: false)
        XCTAssertEqual(state.drag(x: 5, y: 0, panEnabled: false), .consume)
        XCTAssertEqual(state.up(active: true, fitEnabled: true), .consume)
    }
    func testDisabledMiddlePasses() {
        var state = MiddleButtonState()
        XCTAssertEqual(state.down(x: 0, y: 0, fitEnabled: false, panEnabled: false), .pass)
        XCTAssertEqual(state.up(active: true, fitEnabled: true), .pass)
    }
}
