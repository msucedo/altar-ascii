#!/bin/sh
# Arma dist/Altar-<versión>.dmg para GitHub Releases: la app firmada con Developer ID y un
# acceso a Aplicaciones para instalarla arrastrando. Luego lo manda a notarizar con Apple y le
# engrapa el ticket, para que se abra con doble clic, sin avisos de Gatekeeper.
# La primera vez guarda las credenciales en el Llavero (ver appstore/PUBLICAR.md):
#   xcrun notarytool store-credentials altar-notary --apple-id <correo> --team-id M6JLQVH4Y7
set -e
cd "$(dirname "$0")/.."
IDENTIDAD="${SIGN_IDENTITY:-Developer ID Application: Mario Saucedo (M6JLQVH4Y7)}"
PERFIL_NOTARIO="${NOTARY_PROFILE:-altar-notary}"
tools/check.sh
SIGN_IDENTITY="$IDENTIDAD" tools/build.sh
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" Info.plist)
DMG="dist/Altar-$VERSION.dmg"
STAGE="build/dmg"
rm -rf "$STAGE"
mkdir -p "$STAGE" dist
# ditto conserva la firma y los atributos del bundle tal cual.
ditto build/Altar.app "$STAGE/Altar.app"
ln -s /Applications "$STAGE/Aplicaciones"
hdiutil create -volname "Altar" -srcfolder "$STAGE" -format UDZO -ov "$DMG" >/dev/null
codesign --force --timestamp --sign "$IDENTIDAD" "$DMG"
# Apple revisa el DMG y la app de adentro; --wait espera el veredicto (unos minutos).
xcrun notarytool submit "$DMG" --keychain-profile "$PERFIL_NOTARIO" --wait
xcrun stapler staple "$DMG"
# Lo mismo que hará Gatekeeper en la Mac de quien lo descargue.
spctl -a -t open --context context:primary-signature -vv "$DMG"
echo "$DMG"
