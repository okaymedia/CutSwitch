import AppKit

/// Uygulamanın içinde gelen "Premiere Pro" kısayol setini Final Cut Pro'ya kurar.
///
/// Set dosyası (`Premiere Pro.commandset`) Final Cut'ın kendi Command Editor'ünden
/// dışa aktarılmış bir dosyadır ve derleme sırasında uygulamanın Resources klasörüne kopyalanır.
enum CommandSetInstaller {

    static let setName = "Premiere Pro"

    static var bundledSet: URL? {
        Bundle.main.url(forResource: setName, withExtension: "commandset")
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

    static func install() -> Outcome {
        guard let source = bundledSet else { return .missingBundledSet }

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
        return .failed(lastError ?? "Final Cut Pro'nun ayar klasörü bulunamadı. Final Cut'ı en az bir kez açtın mı?")
    }

    /// Kurulumu yapar ve sonucu kullanıcıya gösterir.
    static func installWithFeedback() {
        let alert = NSAlert()

        switch install() {
        case .installed:
            alert.messageText = "Premiere Pro kısayolları kuruldu ✓"
            alert.informativeText = """
            Final Cut Pro'yu yeniden başlat, sonra:
            Final Cut Pro menüsü → Commands → "\(setName)" seç.

            Artık C ile kesme, V ile seçme gibi Premiere kısayolları çalışır.
            """
            alert.addButton(withTitle: "Tamam")

        case .missingBundledSet:
            alert.messageText = "Kısayol seti bu sürümde yok"
            alert.informativeText = "Uygulamanın bu sürümünde Premiere kısayol dosyası bulunmuyor. Mouse kontrolleri yine de çalışır."
            alert.addButton(withTitle: "Tamam")

        case .failed(let reason):
            alert.messageText = "Otomatik kurulum yapılamadı"
            alert.informativeText = """
            \(reason)

            Elle kurmak kolay: Final Cut Pro'da Commands → Customize (⌥⌘K) aç, sol üstteki menüden Import'u seç ve az sonra açılacak klasördeki "\(setName).commandset" dosyasını göster.
            """
            alert.addButton(withTitle: "Dosyayı Göster")
            alert.addButton(withTitle: "Vazgeç")
            NSApp.activate(ignoringOtherApps: true)
            if alert.runModal() == .alertFirstButtonReturn, let src = bundledSet {
                NSWorkspace.shared.activateFileViewerSelecting([src])
            }
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
