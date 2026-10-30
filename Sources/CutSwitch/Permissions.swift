import AppKit
import ApplicationServices

enum Permissions {
    /// Erişilebilirlik izni var mı? `prompt: true` ise macOS izin penceresini açar.
    static func isTrusted(prompt: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        return AXIsProcessTrustedWithOptions([key: prompt] as CFDictionary)
    }

    /// Sistem Ayarları > Gizlilik ve Güvenlik > Erişilebilirlik sayfasını açar.
    static func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
