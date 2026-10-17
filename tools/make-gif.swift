import AppKit
import ImageIO
import UniformTypeIdentifiers

// Genera docs/altar.gif con el mismo renderer que usa la app, para mostrar la animación en el README:
//   swiftc -parse-as-library tools/make-gif.swift Sources/AltarRenderer.swift Sources/Pieces.swift -o build/make-gif
//   build/make-gif docs/altar.gif

@main
struct MakeGif {
    // 24 es el mínimo común múltiplo de los ciclos de las velas (8), el humo (4) y el viento (12),
    // así el GIF da la vuelta sin que se note el salto.
    static let fotogramas = 24
    /// El mismo ritmo que AltarView.fotogramasPorSegundo en la app.
    static let fotogramasPorSegundo = 4.0
    static let escala: CGFloat = 2
    static let tamLetra: CGFloat = 13
    static let altoLinea: CGFloat = 16
    static let margen: CGFloat = 22

    static func main() throws {
        let destino = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "docs/altar.gif"
        // Nombres de ejemplo, para no publicar los de nadie.
        let config = AltarConfig(niveles: .tres, nombres: ["Abuela Lupe", "Tío Beto"])

        let gif = CGImageDestinationCreateWithURL(URL(fileURLWithPath: destino) as CFURL,
                                                  UTType.gif.identifier as CFString, fotogramas, nil)!
        CGImageDestinationSetProperties(gif, [
            kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0],
        ] as CFDictionary)
        let pausa = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1 / fotogramasPorSegundo]] as CFDictionary
        for frame in 0..<fotogramas {
            CGImageDestinationAddImage(gif, dibujar(AltarRenderer.render(config, frame: frame)), pausa)
        }
        guard CGImageDestinationFinalize(gif) else { fatalError("no se pudo escribir \(destino)") }
        print(destino)
    }

    /// Un fotograma: el texto del altar en claro sobre fondo oscuro, como el widget del escritorio.
    static func dibujar(_ lineas: [String]) -> CGImage {
        let fuente = NSFont.monospacedSystemFont(ofSize: tamLetra * escala, weight: .medium)
        let atributos: [NSAttributedString.Key: Any] = [
            .font: fuente,
            .foregroundColor: NSColor(srgbRed: 0.96, green: 0.90, blue: 0.82, alpha: 1),
        ]
        let anchoTexto = NSAttributedString(string: lineas[0], attributes: atributos).size().width
        let ancho = Int(anchoTexto + 2 * margen * escala)
        let alto = Int((CGFloat(lineas.count) * altoLinea + 2 * margen) * escala)

        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: ancho, pixelsHigh: alto,
                                   bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                   colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        // Fondo completo y no con esquinas redondeadas: el GIF no tiene transparencia parcial y las
        // esquinas saldrían dentadas sobre el fondo de GitHub.
        NSColor(srgbRed: 0.11, green: 0.09, blue: 0.12, alpha: 1).setFill()
        NSRect(x: 0, y: 0, width: ancho, height: alto).fill()
        for (i, linea) in lineas.enumerated() {
            // AppKit cuenta y desde abajo; las líneas van de arriba hacia abajo.
            let y = CGFloat(alto) - (margen + CGFloat(i + 1) * altoLinea) * escala
            NSAttributedString(string: linea, attributes: atributos).draw(at: NSPoint(x: margen * escala, y: y))
        }
        NSGraphicsContext.restoreGraphicsState()
        return rep.cgImage!
    }
}
