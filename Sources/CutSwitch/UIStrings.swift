import Foundation

/// Türkçe arayüz metinleri.
enum UIStrings {
    static let appName = "CutSwitch"
    static let welcomeTitle = "Final Cut Pro'ya hoş geldin 👋"
    static let welcomeDetail = "Premiere Pro alışkanlıklarını Final Cut'a taşıyalım."
    static let accessibilityTitle = "Erişilebilirlik izni"
    static let accessibilityDetail = "Mouse'u Final Cut içinde kullanabilmek için gerekli. Başka hiçbir uygulamaya dokunmaz."
    static let permissionGranted = "İzin verildi"
    static let grantPermission = "İzin Ver"
    static let premiereTitle = "Premiere Pro'dan mı geliyorsun?"
    static let premiereDetail = "C ile kesme, V ile seçme gibi Premiere kısayollarını Final Cut'a kurar."
    static let installPremiere = "Evet, Premiere kısayollarını kur"
    static let mouseTitle = "Mouse kontrolleri (Final Cut öndeyken)"
    static let mouseZoom = "• ⌥ Option + tekerlek → timeline zoom"
    static let mouseFit = "• Orta tuş tıklama → Zoom to Fit"
    static let mousePan = "• Orta tuşla sürükleme → timeline'ı kaydır"
    static let menuHint = "Ayarları menü çubuğundaki ✂️ simgesinden değiştirebilirsin."
    static let done = "Bitti"
    static let active = "Aktif"
    static let permissionRequired = "İzin gerekli"
    static let wheelZoom = "Tekerlekle zoom"
    static let modifier = "Basılı tuş"
    static let invertZoom = "Zoom yönünü ters çevir"
    static let sensitivity = "Hassasiyet"
    static let sensitivityHelp = "Sola çektikçe zoom hızlanır, sağa çektikçe yavaşlar."
    static let middleFit = "Orta tuş → Zoom to Fit"
    static let middlePan = "Orta tuşla sürükle → kaydır"
    static let invertPan = "Kaydırma yönünü ters çevir"
    static let installShortcuts = "Premiere kısayollarını kur…"
    static let openSetup = "Kurulum ekranını aç"
    static let quit = "Çıkış"
    static let loginTitle = "Mac açılınca başlat"
    static let loginDetail = "CutSwitch, Mac'e giriş yaptığında otomatik açılsın."
    static let loginApproval = "Sistem Ayarları’nda onayla…"
    static let loginError = "Başlangıç ayarı değiştirilemedi: "
    static let option = "⌥ Option"
    static let command = "⌘ Command"
    static let control = "⌃ Control"
    static let projectURL = URL(string: "https://github.com/okaymedia/CutSwitch")!
    static var about: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        return "Hakkında · CutSwitch \(version) · GitHub"
    }
    static func milliseconds(_ value: Double) -> String { "\(Int(value.rounded())) ms" }
}
