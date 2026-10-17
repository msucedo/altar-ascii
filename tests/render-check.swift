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
            // La animación no debe mover el ancho de ninguna línea en ningún fotograma, y tiene que
            // repetirse exacta tras un ciclo (así el GIF da la vuelta sin salto).
            let completo = AltarConfig(niveles: niveles, nombres: familia)
            for frame in 0..<AltarRenderer.ciclo {
                revisar(completo, "\(niveles.nombre) fotograma \(frame)", frame: frame)
                if AltarRenderer.render(completo, frame: frame) != AltarRenderer.render(completo, frame: frame + AltarRenderer.ciclo) {
                    print("FALLA (\(niveles.nombre)): el fotograma \(frame) no se repite tras el ciclo")
                    fallos += 1
                }
            }
            revisar(AltarConfig(niveles: niveles, nombres: ["Abuela 👵 Lupe", "李小龙", "Ana\u{00A0}\u{00AD}Sofía"]),
                    "\(niveles.nombre) con emoji y caracteres anchos guardados")
            for ofrenda in Ofrenda.allCases {
                revisar(AltarConfig(niveles: niveles, ofrendas: [ofrenda], nombres: familia),
                        "\(niveles.nombre) solo \(ofrenda.nombre)")
            }
        }
        // Lo que se acepta y lo que se quita de un nombre.
        let nombres: [(String, String)] = [
            ("Abuela 👵 Lupe", "Abuela Lupe"),
            ("José Ñúñez", "José Ñúñez"),
            ("Zoë", "Zoë"),
            ("李小龙", ""),
            ("  👻  ", ""),
            ("Ana\u{00A0}Sofía", "AnaSofía"),
            ("Maximiliano Hernández", "Maximiliano"),
        ]
        for (escrito, esperado) in nombres where AltarRenderer.limpiarNombre(escrito) != esperado {
            print("FALLA: limpiarNombre(\"\(escrito)\") = \"\(AltarRenderer.limpiarNombre(escrito))\", se esperaba \"\(esperado)\"")
            fallos += 1
        }
        if AltarRenderer.nombresLimpios(["李小龙"]) != ["    "] {
            print("FALLA: un nombre sin letras latinas no debe aparecer en el altar")
            fallos += 1
        }

        print(fallos == 0 ? "ok" : "\(fallos) fallos")
        exit(fallos == 0 ? 0 : 1)
    }
}
