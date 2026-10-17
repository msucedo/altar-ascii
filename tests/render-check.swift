import Foundation

// Imprime el altar con cada número de niveles y comprueba que todas las líneas
// midan exactamente el ancho fijo y que el alto sea el esperado.
@main
struct RenderCheck {
    static func main() {
        var fallos = 0
        for niveles in Niveles.allCases {
            let lineas = AltarRenderer.render(AltarConfig(niveles: niveles))
            print("\(niveles.nombre): \(niveles.significado)")
            lineas.forEach { print("  " + $0) }
            print()

            let mal = lineas.filter { $0.count != AltarRenderer.ancho }
            if !mal.isEmpty {
                print("FALLA: \(mal.count) líneas no miden \(AltarRenderer.ancho)")
                fallos += 1
            }
            let alto = 1 + niveles.rawValue * (AltarRenderer.filasPorNivel + 1)
            if lineas.count != alto {
                print("FALLA: alto \(lineas.count), se esperaba \(alto)")
                fallos += 1
            }
        }
        print(fallos == 0 ? "ok" : "\(fallos) fallos")
        exit(fallos == 0 ? 0 : 1)
    }
}
