#!/bin/sh
# Compila y corre las pruebas que no necesitan interfaz: el renderer y el guardado.
set -e
cd "$(dirname "$0")/.."
mkdir -p build
swiftc -parse-as-library tests/render-check.swift Sources/AltarRenderer.swift Sources/Pieces.swift -o build/render-check
build/render-check | tail -1
swiftc -parse-as-library tests/store-check.swift Sources/AltarStore.swift Sources/AltarRenderer.swift Sources/Pieces.swift -o build/store-check
build/store-check
