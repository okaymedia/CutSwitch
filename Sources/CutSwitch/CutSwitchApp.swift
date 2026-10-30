import SwiftUI

@main
struct CutSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settings = Settings.shared

    var body: some Scene {
        MenuBarExtra(UIStrings.appName, systemImage: "scissors") {
            MenuView()
                .environmentObject(settings)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) weak var shared: AppDelegate?

    private var welcomeWindow: NSWindow?
    private var permissionTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        NSApp.setActivationPolicy(.accessory) // Dock'ta görünmesin, sadece menü çubuğunda dursun.

        if !Settings.shared.onboarded {
            showWelcome()
        }
        startWhenTrusted(prompt: false)
    }

    /// İzin verildiği anda mouse kontrollerini başlatır; izin yoksa 2 sn'de bir kontrol eder.
    func startWhenTrusted(prompt: Bool) {
        permissionTimer?.invalidate()

        permissionTimer = nil
        if attemptStart(prompt: prompt) { return }
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
            guard let self, self.attemptStart(prompt: false) else { return }
            timer.invalidate()
            self.permissionTimer = nil
        }
    }

    private func attemptStart(prompt: Bool) -> Bool {
        let ready = Permissions.isTrusted(prompt: prompt) && MouseController.shared.start()
        Settings.shared.isTrusted = ready
        return ready
    }

    func applicationWillTerminate(_ notification: Notification) {
        permissionTimer?.invalidate()
        MouseController.shared.stop()
    }

    func showWelcome() {
        if welcomeWindow == nil {
            let host = NSHostingController(rootView: WelcomeView().environmentObject(Settings.shared))
            let window = NSWindow(contentViewController: host)
            window.title = UIStrings.appName
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            welcomeWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        welcomeWindow?.center()
        welcomeWindow?.makeKeyAndOrderFront(nil)
    }

    func closeWelcome() {
        welcomeWindow?.close()
    }
}
