#!/bin/bash
# CutSwitch.app paketini oluşturur.
#
#   ./make-app.sh                 → yerel test için (ad-hoc imza)
#   ./make-app.sh "Developer ID Application: Ad Soyad (TEAMID)"
#                                 → dağıtım için Developer ID ile imzalar
set -euo pipefail

APP_NAME="CutSwitch"
BUNDLE_ID="agency.okaymedia.cutswitch"
VERSION="0.1.0"
SIGN_ID="${1:--}"   # varsayılan "-" = ad-hoc

cd "$(dirname "$0")"

echo "▸ Derleniyor (Apple Silicon + Intel)…"
swift build --scratch-path .build -c release --arch arm64 --arch x86_64

BIN_PATH="$(swift build --scratch-path .build -c release --arch arm64 --arch x86_64 --show-bin-path)/$APP_NAME"
APP_DIR="build/$APP_NAME.app"

echo "▸ Uygulama paketi hazırlanıyor…"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BIN_PATH" "$APP_DIR/Contents/MacOS/$APP_NAME"

if [ -f "Resources/Premiere Pro.commandset" ]; then
  cp "Resources/Premiere Pro.commandset" "$APP_DIR/Contents/Resources/"
  echo "  ✓ Premiere Pro kısayol seti eklendi"
else
  echo "  ⚠ Resources/Premiere Pro.commandset yok, kısayol kurulumu devre dışı kalacak (README'ye bak)"
fi

if [ ! -f "Resources/AppIcon.icns" ]; then
  swift scripts/make-icon.swift
fi
cp "Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>             <string>$APP_NAME</string>
  <key>CFBundleDisplayName</key>      <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>       <string>$BUNDLE_ID</string>
  <key>CFBundleExecutable</key>       <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>      <string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key>          <string>1</string>
  <key>CFBundleIconFile</key>         <string>AppIcon</string>
  <key>LSMinimumSystemVersion</key>   <string>13.0</string>
  <key>LSUIElement</key>              <true/>
  <key>NSHumanReadableCopyright</key> <string>© 2026 OkayMedia · MIT License</string>
</dict>
</plist>
PLIST

echo "▸ İmzalanıyor ($SIGN_ID)…"
if [ "$SIGN_ID" = "-" ]; then
  codesign --force --sign - "$APP_DIR"
else
  codesign --force --options runtime --timestamp --sign "$SIGN_ID" "$APP_DIR"
fi

echo ""
echo "✅ Hazır: $APP_DIR"
echo "   Açmak için: open \"$APP_DIR\""
