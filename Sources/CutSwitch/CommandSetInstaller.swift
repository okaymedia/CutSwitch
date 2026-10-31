import AppKit

/// Uygulamayla paketlenen kısayol setlerini Final Cut Pro'ya kurar.
enum CommandSetInstaller {
    enum CommandSet: String {
        case premierePro = "Premiere Pro"
        case davinciResolve = "DaVinci Resolve"
    }

    static func bundledSet(for set: CommandSet) -> URL? {
        Bundle.main.url(forResource: set.rawValue, withExtension: "commandset")
    }

    /// Final Cut'ın kullanıcı kısayol setlerini aradığı olası klasörler.
    /// (Final Cut 11 ile sandbox'a geçti; hem eski hem yeni konumu deniyoruz.)
    private static var candidateDirectories: [URL] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return [
            home.appending(path: "Library/Containers/com.apple.FinalCut/Data/Library/Application Support/Final Cut Pro/Command Sets"),
            home.appending(path: "Library/Containers/com.apple.FinalCutApp/Data/Library/Application Support/Final Cut Pro/Command Sets"),
            home.appending(path: "Library/Application Support/Final Cut Pro/Command Sets"),
        ]
    }

    enum Outcome {
        case installed([URL])
        case missingBundledSet
        case failed(String)
    }

    static func install(_ set: CommandSet) -> Outcome {
        let setName = set.rawValue
        guard let source = bundledSet(for: set) else { return .missingBundledSet }

        let fm = FileManager.default
        var installed: [URL] = []
        var lastError: String?

        for dir in candidateDirectories {
            // Sadece Final Cut'ın gerçekten kullandığı (üst klasörü var olan) konumlara yaz.
            let finalCutSupport = dir.deletingLastPathComponent()
            guard fm.fileExists(atPath: finalCutSupport.path) else { continue }

            do {
                try fm.createDirectory(at: dir, withIntermediateDirectories: true)
                let target = dir.appending(path: "\(setName).commandset")
                if fm.fileExists(atPath: target.path) { try fm.removeItem(at: target) }
                try fm.copyItem(at: source, to: target)
                installed.append(target)
            } catch {
                lastError = error.localizedDescription
            }
        }

        if !installed.isEmpty { return .installed(installed) }
        return .failed(lastError ?? UIStrings.finalCutSettingsMissing)
    }

    /// Kurulumu yapar ve sonucu kullanıcıya gösterir.
    static func installWithFeedback(_ set: CommandSet) {
        let setName = set.rawValue
        let alert = NSAlert()

        switch install(set) {
        case .installed:
            alert.messageText = UIStrings.shortcutsInstalled(setName: setName)
            alert.informativeText = UIStrings.shortcutsInstalledDetail(setName: setName)
            alert.addButton(withTitle: UIStrings.okay)

        case .missingBundledSet:
            alert.messageText = UIStrings.commandSetMissing
            alert.informativeText = UIStrings.commandSetMissingDetail(setName: setName)
            alert.addButton(withTitle: UIStrings.okay)

        case .failed(let reason):
            alert.messageText = UIStrings.installationFailed
            alert.informativeText = UIStrings.installationFailedDetail(reason: reason, setName: setName)
            alert.addButton(withTitle: UIStrings.showFile)
            alert.addButton(withTitle: UIStrings.cancel)
            NSApp.activate(ignoringOtherApps: true)
            if alert.runModal() == .alertFirstButtonReturn, let src = bundledSet(for: set) {
                NSWorkspace.shared.activateFileViewerSelecting([src])
            }
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
