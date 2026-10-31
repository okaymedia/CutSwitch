🇬🇧 [English](README.md)

# ✂️ CutSwitch

**Premiere Pro'dan Final Cut Pro'ya geçenler için ücretsiz, açık kaynak Mac aracı.**

Premiere'de yıllarca kullandığın kas hafızasını Final Cut'a taşır:

| Ne yapar | Nasıl |
|---|---|
| Timeline zoom | **⌥ Option + mouse tekerleği** (Premiere'deki Alt + tekerlek gibi) |
| Zoom to Fit | **Orta tuşa tıkla** |
| Timeline'ı kaydır | **Orta tuşla sürükle** (el aracı gibi) |
| Premiere kısayolları | Tek tıkla kurulur: **C** kesme, **V** seçme ve diğerleri |

- Skimming açıkken (**S**) zoom mouse imlecinin olduğu yere yapılır; kapalıyken playhead'e göre yapılır.
- Sadece Final Cut Pro öndeyken çalışır, diğer uygulamalara dokunmaz.
- İstersen Mac açılınca otomatik başlar (Ayarlar → "Mac açılınca başlat").
- Türkçe ve İngilizce arayüz (Mac’in diline göre otomatik seçilir).
- Türkçe Q / F ve diğer klavye düzenlerinde çalışır.
- Final Cut'ın tek seferlik, Creator Studio ve deneme sürümleriyle uyumlu.
- İnternet bağlantısı yok, veri toplamaz.

---

## Kurulum (kullanıcılar için)

1. [Releases](https://github.com/okaymedia/CutSwitch/releases) sayfasından `CutSwitch-<sürüm>.dmg` dosyasını indir, uygulamayı **Applications** klasörüne sürükle.
2. Aç. Kurulum ekranında **İzin Ver**'e bas ve Sistem Ayarları'nda CutSwitch'e Erişilebilirlik izni ver.
3. Premiere'den geliyorsan **"Evet, Premiere kısayollarını kur"** butonuna bas. Sonra Final Cut'ı yeniden başlat ve **Final Cut Pro → Commands → Premiere Pro**'yu seç.

DaVinci Resolve'dan geliyorsan **"DaVinci kısayollarını kur"** butonuna bas; Final Cut'ı yeniden başlatıp **Commands → DaVinci Resolve**'u seç: bu set mevcut kısayolları koruyarak **⌘\** ile kesme ve **⇧[ / ⇧]** ile trim ekler.

Ayarlar menü çubuğundaki ✂️ simgesinde.

> Uygulamayı yalnızca bu reponun Releases sayfasından indir. Oradaki DMG Apple tarafından imzalanmış ve onaylanmıştır (notarized). Başka yerden gelen kopyalara güvenme.

### Premiere kısayol seti

| Premiere | Final Cut komutu |
|---|---|
| C | Blade |
| V | Select |
| ⌘K | Blade at Playhead |
| Q / W | Trim Start / Trim End |
| = / - | Zoom In / Zoom Out |
| \\ | Zoom to Fit |

> Final Cut'ın kendi kısayolları silinmez. İstediğin zaman **Commands → Default** ile geri dönebilirsin.

---

## Geliştiriciler için

**Gereksinimler:** macOS 13+, Xcode (ya da Command Line Tools ve Swift 5.9+).

```bash
git clone https://github.com/okaymedia/CutSwitch.git
cd CutSwitch
chmod +x make-app.sh
./make-app.sh
open build/CutSwitch.app
```

> Ad-hoc imzalı sürümde her yeniden derlemeden sonra macOS Erişilebilirlik iznini sıfırlayabilir. Sistem Ayarları'nda CutSwitch'i listeden kaldırıp yeniden ekle.

### Premiere kısayol setini üretmek

Kısayol seti, Final Cut'ın kendi **Command Editor**'ünden dışa aktarılmış bir dosya (`.commandset`):

1. Final Cut Pro'da **Commands → Customize** (⌥⌘K).
2. Sol üstteki menüden **Duplicate** seç, adını tam olarak **`Premiere Pro`** koy.
3. Yukarıdaki tablodaki eşleştirmeleri yap. Komutu arama kutusunda bul, klavyedeki tuşa sürükle. Çakışma uyarısında **Reassign** de.
4. **Save** ile kaydet. Sonra aynı menüden **Export** seçip dosyayı `Resources/Premiere Pro.commandset` olarak kaydet.
5. `./make-app.sh` set dosyasını uygulamanın içine otomatik koyar.

### Proje yapısı

```
Sources/CutSwitch/
  CutSwitchApp.swift        Uygulama + menü çubuğu + açılış
  MouseController.swift     Mouse olaylarını yakalama (CGEventTap)
  FCPMenuActions.swift      Final Cut menü komutlarını tetikleme (Accessibility API)
  CommandSetInstaller.swift Premiere kısayol setini kurma
  Settings.swift            Ayarlar
  Views.swift               Arayüz
```

**Neden menü komutu, neden kısayol değil?** Zoom için ⌘+ tuşunu taklit etmek Türkçe klavyede yanlış tuşa denk geliyor. CutSwitch bunun yerine Final Cut'ın menüsünde kısayolu `⌘+`, `⌘-` ve `⇧Z` olan öğeleri bulup doğrudan onlara basıyor. Bu yüzden klavye düzeninden ve arayüz dilinden bağımsız çalışıyor.

**Neden Mac App Store'da değil?** App Store uygulamaları sandbox'ta çalışmak zorunda. Sandbox içindeki uygulamalar başka uygulamaların mouse olaylarını değiştiremiyor. Bu yüzden CutSwitch (BetterTouchTool, Mac Mouse Fix ve CommandPost gibi) Developer ID ile imzalanıp notarize edilerek doğrudan dağıtılıyor.

### Dağıtım (imza + notarization)

```bash
./make-app.sh "Developer ID Application: Ad Soyad (TEAMID)"
ditto -c -k --keepParent build/CutSwitch.app build/CutSwitch.zip
xcrun notarytool submit build/CutSwitch.zip --keychain-profile "notary" --wait
xcrun stapler staple build/CutSwitch.app
```

---

## Yol haritası

- [ ] Sparkle ile otomatik güncelleme

Katkılar memnuniyetle karşılanır: issue aç ya da PR gönder.

## Lisans

MIT © 2026 Hakan Okay / [OkayMedia](https://okaymedia.agency)

*Final Cut Pro, Apple Inc.'in; Premiere Pro, Adobe Inc.'in ticari markasıdır. CutSwitch bağımsız bir projedir, Apple ya da Adobe ile bir bağlantısı yoktur.*
