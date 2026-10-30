import SwiftUI

// MARK: - İlk açılış ekranı

struct WelcomeView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            VStack(alignment: .leading, spacing: 6) {
                Text(UIStrings.welcomeTitle)
                    .font(.title2.bold())
                Text(UIStrings.welcomeDetail)
                    .foregroundStyle(.secondary)
            }

            // Adım 1: İzin
            StepRow(number: 1, title: UIStrings.accessibilityTitle,
                    detail: UIStrings.accessibilityDetail) {
                if settings.isTrusted {
                    Label(UIStrings.permissionGranted, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Button(UIStrings.grantPermission) {
                        AppDelegate.shared?.startWhenTrusted(prompt: true)
                        Permissions.openAccessibilitySettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            // Adım 2: Premiere mi?
            StepRow(number: 2, title: UIStrings.premiereTitle,
                    detail: UIStrings.premiereDetail) {
                HStack {
                    Button(UIStrings.installPremiere) {
                        CommandSetInstaller.installWithFeedback()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(CommandSetInstaller.bundledSet == nil)
                }
            }

            StepRow(number: 3, title: UIStrings.loginTitle, detail: UIStrings.loginDetail) {
                LoginToggle()
            }

            // Mouse özeti
            VStack(alignment: .leading, spacing: 6) {
                Text(UIStrings.mouseTitle).font(.headline)
                Text(UIStrings.mouseZoom)
                Text(UIStrings.mouseFit)
                Text(UIStrings.mousePan)
                Text(UIStrings.menuHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

            HStack {
                Spacer()
                Button(UIStrings.done) {
                    settings.onboarded = true
                    AppDelegate.shared?.closeWelcome()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 460)
    }
}

private struct StepRow<Content: View>: View {
    let number: Int
    let title: String
    let detail: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .frame(width: 26, height: 26)
                .background(Circle().fill(Color.accentColor.opacity(0.15)))
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.headline)
                Text(detail).font(.callout).foregroundStyle(.secondary)
                content.padding(.top, 2)
            }
        }
    }
}

// MARK: - Menü çubuğu paneli

struct MenuView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(UIStrings.appName).font(.headline)
                Spacer()
                if settings.isTrusted {
                    Label(UIStrings.active, systemImage: "circle.fill")
                        .font(.caption).foregroundStyle(.green)
                } else {
                    Button(UIStrings.permissionRequired) {
                        AppDelegate.shared?.startWhenTrusted(prompt: true)
                        Permissions.openAccessibilitySettings()
                    }
                    .font(.caption)
                }
            }

            Divider()

            Toggle(UIStrings.wheelZoom, isOn: $settings.zoomEnabled)
            if settings.zoomEnabled {
                Picker(UIStrings.modifier, selection: $settings.zoomModifier) {
                    ForEach(ZoomModifier.allCases) { Text($0.label).tag($0) }
                }
                .padding(.leading, 18)
                Toggle(UIStrings.invertZoom, isOn: $settings.invertZoom)
                    .padding(.leading, 18)
                HStack {
                    Text(UIStrings.sensitivity)
                    Slider(value: $settings.zoomThrottleMs, in: 0...150)
                    Text(UIStrings.milliseconds(settings.zoomThrottleMs))
                        .monospacedDigit()
                        .frame(width: 48, alignment: .trailing)
                }
                .padding(.leading, 18)
                .help(UIStrings.sensitivityHelp)
            }

            Toggle(UIStrings.middleFit, isOn: $settings.middleClickFit)
            Toggle(UIStrings.middlePan, isOn: $settings.middleDragPan)
            if settings.middleDragPan {
                Toggle(UIStrings.invertPan, isOn: $settings.invertPan)
                    .padding(.leading, 18)
            }

            Divider()

            Button(UIStrings.installShortcuts) {
                CommandSetInstaller.installWithFeedback()
            }
            .disabled(CommandSetInstaller.bundledSet == nil)

            LoginToggle()

            Button(UIStrings.openSetup) {
                AppDelegate.shared?.showWelcome()
            }

            Divider()

            Link(UIStrings.about, destination: UIStrings.projectURL)
                .font(.caption)

            Button(UIStrings.quit) { NSApp.terminate(nil) }
                .keyboardShortcut("q")
        }
        .padding(14)
        .frame(width: 280)
    }
}

private struct LoginToggle: View {
    @StateObject private var login = LaunchAtLogin.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(UIStrings.loginTitle, isOn: Binding(get: { login.enabled }, set: { login.setEnabled($0) }))
            if login.needsApproval {
                Button(UIStrings.loginApproval) { login.openSettings() }
                    .font(.caption)
            }
            if let error = login.error { Text(error).font(.caption).foregroundStyle(.red) }
        }
        .onAppear { login.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            login.refresh()
        }
    }
}
