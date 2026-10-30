#!/bin/bash
# Kimlik verilirse Keychain'deki "notary" profili kullanılır.
set -euo pipefail
cd "$(dirname "$0")/.."
SIGN_ID="${1:--}"
./make-app.sh "$SIGN_ID"
APP="build/CutSwitch.app"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")
DMG="build/CutSwitch-$VERSION.dmg"

if [ "$SIGN_ID" != "-" ]; then
  ditto -c -k --keepParent "$APP" build/CutSwitch-notary.zip
  xcrun notarytool submit build/CutSwitch-notary.zip --keychain-profile notary --wait
  xcrun stapler staple "$APP"
fi

STAGING=$(mktemp -d "$PWD/build/dmg-staging.XXXXXX")
trap 'rm -rf "$STAGING"' EXIT
# ditto, app üzerindeki notarization ticket ve metaveriyi korur.
mkdir -p "$STAGING/contents"
ditto "$APP" "$STAGING/contents/CutSwitch.app"
ln -s /Applications "$STAGING/contents/Applications"
# makehybrid + convert, diski bağlamadan Applications kısayollu HFS+ DMG üretir.
hdiutil makehybrid -hfs -hfs-volume-name "CutSwitch $VERSION" -o "$STAGING/payload.dmg" "$STAGING/contents"
hdiutil convert "$STAGING/payload.dmg" -format UDZO -ov -o "$DMG"
if [ "$SIGN_ID" != "-" ]; then
  codesign --force --timestamp --sign "$SIGN_ID" "$DMG"
  xcrun notarytool submit "$DMG" --keychain-profile notary --wait
  xcrun stapler staple "$DMG"
fi
printf '✓ Hazır: %s\n' "$DMG"
