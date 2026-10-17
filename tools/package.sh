#!/bin/sh
# Arma dist/Altar-<versión>.dmg para compartir: la app, un acceso a Aplicaciones para
# instalarla arrastrando, y las instrucciones para abrirla la primera vez.
set -e
cd "$(dirname "$0")/.."
tools/check.sh
tools/build.sh
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" Info.plist)
DMG="dist/Altar-$VERSION.dmg"
STAGE="build/dmg"
rm -rf "$STAGE"
mkdir -p "$STAGE" dist
# ditto conserva la firma y los atributos del bundle tal cual.
ditto build/Altar.app "$STAGE/Altar.app"
ln -s /Applications "$STAGE/Aplicaciones"
cp "Resources/Cómo abrir la primera vez.txt" "$STAGE/"
hdiutil create -volname "Altar" -srcfolder "$STAGE" -format UDZO -ov "$DMG" >/dev/null
echo "$DMG"
