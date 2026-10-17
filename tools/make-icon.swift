import AppKit

// Dibuja el icono de la app: una calaverita en ASCII sobre fondo de cempasúchil, con la forma
// de los iconos de macOS. Se corre una sola vez y el .icns resultante se guarda en el repo:
//   swiftc tools/make-icon.swift -o build/make-icon && build/make-icon build/AppIcon.iconset
//   iconutil -c icns build/AppIcon.iconset -o Resources/AppIcon.icns

let destino = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "build/AppIcon.iconset"
try FileManager.default.createDirectory(atPath: destino, withIntermediateDirectories: true)

let arte = [" .-. ", "(o.o)", " |=| "]

func dibujar(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let s = CGFloat(px) / 1024

    // La retícula de iconos de macOS: un cuadro de 824 de 1024, con esquinas de unos 185.
    let caja = NSRect(x: 100 * s, y: 100 * s, width: 824 * s, height: 824 * s)
    let forma = NSBezierPath(roundedRect: caja, xRadius: 185 * s, yRadius: 185 * s)
    let claro = NSColor(srgbRed: 1.00, green: 0.72, blue: 0.20, alpha: 1)
    let oscuro = NSColor(srgbRed: 0.93, green: 0.40, blue: 0.08, alpha: 1)
    NSGradient(starting: claro, ending: oscuro)!.draw(in: forma, angle: -90)

    // Alineado a la izquierda y centrado como bloque: el centrado por línea ignora los espacios
    // finales pero no los iniciales, y descuadra el dibujo.
    let parrafo = NSMutableParagraphStyle()
    parrafo.maximumLineHeight = 210 * s
    parrafo.minimumLineHeight = 210 * s
    let texto = NSAttributedString(string: arte.joined(separator: "\n"), attributes: [
        .font: NSFont.monospacedSystemFont(ofSize: 190 * s, weight: .heavy),
        .foregroundColor: NSColor(srgbRed: 0.24, green: 0.05, blue: 0.22, alpha: 1),
        .paragraphStyle: parrafo,
    ])
    let tam = texto.size()
    texto.draw(at: NSPoint(x: caja.midX - tam.width / 2, y: caja.midY - tam.height / 2 - 20 * s))

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

// Los tamaños que pide iconutil: cada uno a 1x y a 2x.
for base in [16, 32, 128, 256, 512] {
    for escala in [1, 2] {
        let nombre = escala == 1 ? "icon_\(base)x\(base).png" : "icon_\(base)x\(base)@2x.png"
        try dibujar(base * escala).write(to: URL(fileURLWithPath: destino).appendingPathComponent(nombre))
    }
}
print(destino)
