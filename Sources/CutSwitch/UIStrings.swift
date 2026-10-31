import Foundation

/// İlk tercih edilen Mac diline göre Türkçe veya İngilizce arayüz metinleri.
enum UIStrings {
    private static let isTurkish = Locale.preferredLanguages.first?.hasPrefix("tr") == true

    private static func localized(_ turkish: String, _ english: String) -> String {
        isTurkish ? turkish : english
    }

    static let appName = "CutSwitch"
    static let welcomeTitle = localized("Final Cut Pro'ya hoş geldin 👋", "Welcome to Final Cut Pro 👋")
    static let welcomeDetail = localized("Premiere Pro veya DaVinci Resolve alışkanlıklarını Final Cut'a taşıyalım.", "Bring your Premiere Pro or DaVinci Resolve habits to Final Cut.")
    static let accessibilityTitle = localized("Erişilebilirlik izni", "Accessibility permission")
    static let accessibilityDetail = localized("Mouse'u Final Cut içinde kullanabilmek için gerekli. Başka hiçbir uygulamaya dokunmaz.", "Required for mouse controls in Final Cut. Other apps are unaffected.")
    static let permissionGranted = localized("İzin verildi", "Permission granted")
    static let grantPermission = localized("İzin Ver", "Grant Permission")
    static let premiereTitle = localized("Premiere Pro'dan mı geliyorsun?", "Coming from Premiere Pro?")
    static let premiereDetail = localized("C ile kesme, V ile seçme gibi Premiere kısayollarını Final Cut'a kurar.", "Install Premiere shortcuts in Final Cut: C for Blade, V for Select, and more.")
    static let installPremiere = localized("Evet, Premiere kısayollarını kur", "Yes, install Premiere shortcuts")
    static let davinciTitle = localized("DaVinci Resolve'dan mı geliyorsun?", "Coming from DaVinci Resolve?")
    static let davinciDetail = localized(
        "Final Cut zaten DaVinci'ye çok benzer; bu set ⌘\\ ile kesme ve ⇧[ / ⇧] ile trim ekler.",
        "Final Cut is already very similar to DaVinci; this set adds ⌘\\ for Blade and ⇧[ / ⇧] for Trim."
    )
    static let installDavinci = localized("DaVinci kısayollarını kur", "Install DaVinci shortcuts")
    static let mouseTitle = localized("Mouse kontrolleri (Final Cut öndeyken)", "Mouse controls (while Final Cut is active)")
    static let mouseZoom = localized("• ⌥ Option + tekerlek → timeline zoom", "• ⌥ Option + scroll wheel → timeline zoom")
    static let mouseFit = localized("• Orta tuş tıklama → Zoom to Fit", "• Middle click → Zoom to Fit")
    static let mousePan = localized("• Orta tuşla sürükleme → timeline'ı kaydır", "• Middle drag → pan the timeline")
    static let menuHint = localized("Ayarları menü çubuğundaki ✂️ simgesinden değiştirebilirsin.", "Change settings using the ✂️ icon in the menu bar.")
    static let done = localized("Bitti", "Done")
    static let active = localized("Aktif", "Active")
    static let permissionRequired = localized("İzin gerekli", "Permission required")
    static let wheelZoom = localized("Tekerlekle zoom", "Scroll wheel zoom")
    static let modifier = localized("Basılı tuş", "Modifier key")
    static let invertZoom = localized("Zoom yönünü ters çevir", "Reverse zoom direction")
    static let sensitivity = localized("Hassasiyet", "Sensitivity")
    static let sensitivityHelp = localized("Sola çektikçe zoom hızlanır, sağa çektikçe yavaşlar.", "Move left for faster zoom, right for slower zoom.")
    static let middleFit = localized("Orta tuş → Zoom to Fit", "Middle click → Zoom to Fit")
    static let middlePan = localized("Orta tuşla sürükle → kaydır", "Middle drag → pan")
    static let invertPan = localized("Kaydırma yönünü ters çevir", "Reverse pan direction")
    static let installShortcuts = localized("Premiere kısayollarını kur…", "Install Premiere shortcuts…")
    static let openSetup = localized("Kurulum ekranını aç", "Open setup")
    static let quit = localized("Çıkış", "Quit")
    static let loginTitle = localized("Mac açılınca başlat", "Launch at login")
    static let loginDetail = localized("CutSwitch, Mac'e giriş yaptığında otomatik açılsın.", "Open CutSwitch automatically when you log in to your Mac.")
    static let loginApproval = localized("Sistem Ayarları’nda onayla…", "Approve in System Settings…")
    static let loginError = localized("Başlangıç ayarı değiştirilemedi: ", "Could not change login setting: ")
    static let option = "⌥ Option"
    static let command = "⌘ Command"
    static let control = "⌃ Control"
    static let projectURL = URL(string: "https://github.com/okaymedia/CutSwitch")!
    static var about: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        return localized("Hakkında · CutSwitch \(version) · GitHub", "About · CutSwitch \(version) · GitHub")
    }
    static let finalCutSettingsMissing = localized(
        "Final Cut Pro'nun ayar klasörü bulunamadı. Final Cut'ı en az bir kez açtın mı?",
        "Final Cut Pro’s settings folder was not found. Have you opened Final Cut at least once?"
    )
    static func shortcutsInstalled(setName: String) -> String {
        localized("\(setName) kısayolları kuruldu ✓", "\(setName) shortcuts installed ✓")
    }
    static let commandSetMissing = localized("Kısayol seti bu sürümde yok", "Command Set not included")
    static func commandSetMissingDetail(setName: String) -> String {
        localized(
            "Uygulamanın bu sürümünde \(setName) kısayol dosyası bulunmuyor. Mouse kontrolleri yine de çalışır.",
            "This version of the app does not include the \(setName) Command Set. Mouse controls still work."
        )
    }
    static let installationFailed = localized("Otomatik kurulum yapılamadı", "Automatic installation failed")
    static let okay = localized("Tamam", "OK")
    static let showFile = localized("Dosyayı Göster", "Show File")
    static let cancel = localized("Vazgeç", "Cancel")

    static func shortcutsInstalledDetail(setName: String) -> String {
        localized(
            """
            Final Cut Pro'yu yeniden başlat, sonra:
            Final Cut Pro menüsü → Commands → "\(setName)" seç.

            \(setName) kısayolları artık kullanıma hazır.
            """,
            """
            Restart Final Cut Pro, then choose:
            Final Cut Pro menu → Commands → "\(setName)".

            \(setName) shortcuts are now ready.
            """
        )
    }

    static func installationFailedDetail(reason: String, setName: String) -> String {
        localized(
            """
            \(reason)

            Elle kurmak kolay: Final Cut Pro'da Commands → Customize (⌥⌘K) aç, sol üstteki menüden Import'u seç ve az sonra açılacak klasördeki "\(setName).commandset" dosyasını göster.
            """,
            """
            \(reason)

            To install manually, open Commands → Customize (⌥⌘K) in Final Cut Pro, choose Import from the top-left menu, and select "\(setName).commandset" from the folder that opens next.
            """
        )
    }

    static func milliseconds(_ value: Double) -> String { "\(Int(value.rounded())) ms" }
}
