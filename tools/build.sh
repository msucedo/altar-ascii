#!/bin/sh
# Compila la app y la envuelve en build/Altar.app, firmada ad hoc.
set -e
cd "$(dirname "$0")/.."
mkdir -p build
# swiftc directo: SwiftPM necesita Xcode, y con las command line tools basta para esto.
swiftc -O -parse-as-library Sources/*.swift -o build/Altar
APP="build/Altar.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp build/Altar "$APP/Contents/MacOS/Altar"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
echo "$APP"
