import Foundation

// Imprime el altar con cada número de niveles y comprueba que todas las líneas midan
// exactamente el ancho fijo, con y sin ofrendas, y con nombres largos o muchos nombres.
@main
struct RenderCheck {
    static func main() {
        var fallos = 0
        func revisar(_ config: AltarConfig, _ caso: String, imprimir: Bool = false, frame: Int = 0) {
            let lineas = AltarRenderer.render(config, frame: frame)
            if imprimir {
                print("\(caso)")
                lineas.forEach { print("  " + $0) }
                print()
            }
            let mal = lineas.filter { $0.count != AltarRenderer.ancho }
            if !mal.isEmpty {
                print("FALLA (\(caso)): \(mal.count) líneas no miden \(AltarRenderer.ancho)")
                mal.forEach { print("  [\($0)]") }
                fallos += 1
            }
            let texto = lineas.joined()
            for nombre in AltarRenderer.nombresLimpios(config.nombres)
            where config.ofrendas.contains(.retratos) && !texto.contains(nombre) {
                print("FALLA (\(caso)): falta el nombre \(nombre)")
                fallos += 1
            }
        }

        let familia = ["Abuela Lupe", "Tío Beto"]
        for niveles in Niveles.allCases {
            revisar(AltarConfig(niveles: niveles, nombres: familia),
                    "\(niveles.nombre): \(niveles.significado)", imprimir: true)
            revisar(AltarConfig(niveles: niveles, ofrendas: []), "\(niveles.nombre) sin ofrendas")
            revisar(AltarConfig(niveles: niveles, nombres: ["Maximiliano Hernández", "Ana", "José", "Rosa", "Pedro", "Luz", "Sobra"]),
                    "\(niveles.nombre) con muchos nombres")
            // La animación no debe mover el ancho de ninguna línea en ningún fotograma.
            for frame in 0..<48 {
                revisar(AltarConfig(niveles: niveles, nombres: familia), "\(niveles.nombre) fotograma \(frame)", frame: frame)
            }
            for ofrenda in Ofrenda.allCases {
                revisar(AltarConfig(niveles: niveles, ofrendas: [ofrenda], nombres: familia),
                        "\(niveles.nombre) solo \(ofrenda.nombre)")
            }
        }
        print(fallos == 0 ? "ok" : "\(fallos) fallos")
        exit(fallos == 0 ? 0 : 1)
    }
}
