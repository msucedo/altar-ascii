#!/bin/sh
# Arma dist/Altar-<versión>-AppStore.pkg para la Mac App Store: la app con sandbox, el perfil
# de aprovisionamiento adentro, firmada con Apple Distribution, en un instalador firmado con
# Mac Installer Distribution. Se sube con la app Transporter (ver appstore/PUBLICAR.md).
# Cada subida necesita un CFBundleVersion nuevo en Info.plist, aunque la versión no cambie.
set -e
cd "$(dirname "$0")/.."
PERFIL="signing/Altar_AppStore.provisionprofile"
if [ ! -f "$PERFIL" ]; then
    echo "Falta $PERFIL: descárgalo de developer.apple.com (ver appstore/PUBLICAR.md)." >&2
    exit 1
fi
tools/check.sh
SIGN_IDENTITY="${SIGN_IDENTITY:-Apple Distribution: Mario Saucedo (M6JLQVH4Y7)}" \
ENTITLEMENTS=signing/AppStore.entitlements PROVISIONING_PROFILE="$PERFIL" tools/build.sh
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" Info.plist)
PKG="dist/Altar-$VERSION-AppStore.pkg"
mkdir -p dist
productbuild --component build/Altar.app /Applications \
    --sign "${INSTALLER_IDENTITY:-3rd Party Mac Developer Installer: Mario Saucedo (M6JLQVH4Y7)}" "$PKG"
pkgutil --check-signature "$PKG"
echo "$PKG"
