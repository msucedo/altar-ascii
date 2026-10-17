#!/bin/sh
# Compila y corre la prueba del renderer (sin interfaz).
set -e
cd "$(dirname "$0")/.."
mkdir -p build
swiftc -parse-as-library tests/render-check.swift Sources/AltarRenderer.swift Sources/Pieces.swift -o build/render-check
build/render-check
