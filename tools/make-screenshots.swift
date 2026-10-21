import AppKit
import ImageIO
import UniformTypeIdentifiers

// Arma las capturas para la Mac App Store a partir de las de docs/: cada una sobre un fondo de
// noche, con un título, a 2880×1800 y sin transparencia, que es lo que acepta App Store Connect.
// Se corre desde la raíz del repo:
//   swiftc tools/make-screenshots.swift -o build/make-screenshots && build/make-screenshots appstore/capturas

let destino = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "appstore/capturas"
try FileManager.default.createDirectory(atPath: destino, withIntermediateDirectories: true)

let ancho = 2880, alto = 1800
let lienzo = NSRect(x: 0, y: 0, width: ancho, height: alto)
let cempasuchil = NSColor(srgbRed: 1.00, green: 0.72, blue: 0.20, alpha: 1)

enum Acomodo {
    /// La captura a la derecha y el texto a la izquierda, para los paneles verticales.
    case aLaDerecha
    /// La captura abajo, centrada, y el texto arriba, para la del escritorio.
    case abajo
}

struct Captura {
    let origen: String
    let archivo: String
    let titulo: String
    let subtitulo: String
    let acomodo: Acomodo
}

let capturas = [
    Captura(origen: "docs/altar1.png", archivo: "1-barra-de-menu.png",
            titulo: "Tu altar en la barra de menú",
            subtitulo: "Velas, copal y papel picado que se mueven con el viento", acomodo: .aLaDerecha),
    Captura(origen: "docs/altar2.png", archivo: "2-opciones.png",
            titulo: "Hazlo tuyo",
            subtitulo: "Elige 2, 3 o 7 niveles, las ofrendas y los nombres de tus seres queridos",
            acomodo: .aLaDerecha),
    Captura(origen: "docs/altar3.png", archivo: "3-escritorio.png",
            titulo: "O déjalo en el escritorio",
            subtitulo: "Detrás de tus ventanas, donde quieras", acomodo: .abajo),
]

/// El título y el subtítulo juntos, para medirlos y dibujarlos como un solo bloque.
func texto(_ c: Captura, alineacion: NSTextAlignment) -> NSAttributedString {
    let parrafo = NSMutableParagraphStyle()
    parrafo.alignment = alineacion
    parrafo.paragraphSpacing = 36
    let resultado = NSMutableAttributedString(string: c.titulo + "\n", attributes: [
        .font: NSFont.systemFont(ofSize: 120, weight: .bold),
        .foregroundColor: cempasuchil,
        .paragraphStyle: parrafo,
    ])
    resultado.append(NSAttributedString(string: c.subtitulo, attributes: [
        .font: NSFont.systemFont(ofSize: 64, weight: .regular),
        .foregroundColor: NSColor(white: 1, alpha: 0.8),
        .paragraphStyle: parrafo,
    ]))
    return resultado
}

/// Dibuja el bloque de texto dentro de `caja`, centrado a lo alto.
func dibujar(_ t: NSAttributedString, en caja: NSRect) {
    let opciones: NSString.DrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
    let alto = t.boundingRect(with: caja.size, options: opciones).height
    t.draw(with: NSRect(x: caja.minX, y: caja.midY - alto / 2, width: caja.width, height: alto), options: opciones)
}

func dibujar(_ c: Captura) throws -> CGImage {
    // La captura se dibuja pixel por pixel, a escala 1: si se agranda, el ASCII se ve borroso.
    guard let imagen = NSImage(contentsOfFile: c.origen),
          let pixeles = imagen.representations.first as? NSBitmapImageRep else {
        throw NSError(domain: "make-screenshots", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "No se pudo leer \(c.origen)"])
    }
    let tam = NSSize(width: pixeles.pixelsWide, height: pixeles.pixelsHigh)

    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: ancho, pixelsHigh: alto,
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    // La noche: el morado del icono, que baja a casi negro.
    let morado = NSColor(srgbRed: 0.24, green: 0.05, blue: 0.22, alpha: 1)
    let negro = NSColor(srgbRed: 0.06, green: 0.02, blue: 0.07, alpha: 1)
    NSGradient(starting: morado, ending: negro)!.draw(in: lienzo, angle: -90)

    let marco: NSRect
    switch c.acomodo {
    case .aLaDerecha:
        marco = NSRect(x: 2050 - tam.width / 2, y: (CGFloat(alto) - tam.height) / 2,
                       width: tam.width, height: tam.height)
        dibujar(texto(c, alineacion: .left), en: NSRect(x: 240, y: 0, width: 1300, height: CGFloat(alto)))
    case .abajo:
        marco = NSRect(x: (CGFloat(ancho) - tam.width) / 2, y: 90, width: tam.width, height: tam.height)
        let arriba = marco.maxY
        dibujar(texto(c, alineacion: .center),
                en: NSRect(x: 200, y: arriba, width: CGFloat(ancho) - 400, height: CGFloat(alto) - arriba))
    }

    // Primero la sombra, con un rectángulo lleno; luego la captura recortada con las mismas esquinas.
    let esquinas = NSBezierPath(roundedRect: marco, xRadius: 28, yRadius: 28)
    NSGraphicsContext.saveGraphicsState()
    let sombra = NSShadow()
    sombra.shadowColor = NSColor(white: 0, alpha: 0.6)
    sombra.shadowBlurRadius = 60
    sombra.shadowOffset = NSSize(width: 0, height: -20)
    sombra.set()
    negro.setFill()
    esquinas.fill()
    NSGraphicsContext.restoreGraphicsState()
    NSGraphicsContext.saveGraphicsState()
    esquinas.addClip()
    pixeles.draw(in: marco)
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.restoreGraphicsState()

    // App Store Connect rechaza capturas con canal alfa: se pasa a un contexto RGB sin él.
    let rgb = CGContext(data: nil, width: ancho, height: alto, bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    rgb.draw(rep.cgImage!, in: CGRect(x: 0, y: 0, width: ancho, height: alto))
    return rgb.makeImage()!
}

for c in capturas {
    let ruta = URL(fileURLWithPath: destino).appendingPathComponent(c.archivo)
    let salida = CGImageDestinationCreateWithURL(ruta as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(salida, try dibujar(c), nil)
    guard CGImageDestinationFinalize(salida) else { fatalError("No se pudo guardar \(ruta.path)") }
    print(ruta.path)
}
