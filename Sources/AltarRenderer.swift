// Convierte la configuración del altar en líneas de texto. Es una función pura: no sabe nada
// de la interfaz, así que la misma salida sirve para el panel, la ventana flotante y la prueba.

struct AltarConfig: Equatable {
    var niveles: Niveles = .tres
}

enum AltarRenderer {
    /// Ancho fijo en caracteres; todas las líneas miden exactamente esto.
    static let ancho = 44
    /// El escalón de arriba nunca es más angosto que esto, para que quepan los retratos.
    static let anchoMinimoArriba = 20
    /// Filas de espacio en cada escalón, donde irán las ofrendas.
    static let filasPorNivel = 2

    static func render(_ config: AltarConfig, frame: Int = 0) -> [String] {
        let n = config.niveles.rawValue
        // Cuánto se mete cada escalón respecto al de abajo, por lado. Con 7 niveles hay
        // que apretar más para que el de arriba no quede demasiado angosto.
        let paso = min(6, (ancho - anchoMinimoArriba) / (2 * (n - 1)))
        // Anchos de arriba hacia abajo; el último ocupa todo el ancho.
        let anchos = (0..<n).map { ancho - 2 * paso * (n - 1 - $0) }

        var lineas = [centrar(" " + repetir("_", anchos[0] - 2) + " ")]
        for (k, w) in anchos.enumerated() {
            for _ in 0..<filasPorNivel {
                lineas.append(centrar("|" + repetir(" ", w - 2) + "|"))
            }
            if k + 1 < n {
                // El piso de este escalón es a la vez el techo del de abajo, que es más ancho:
                //     ____|________|____
                //    |                  |
                let ala = repetir("_", paso - 1)
                lineas.append(centrar(" " + ala + "|" + repetir("_", w - 2) + "|" + ala + " "))
            } else {
                lineas.append(centrar("|" + repetir("_", w - 2) + "|"))
            }
        }
        return lineas
    }

    private static func repetir(_ c: Character, _ n: Int) -> String {
        String(repeating: c, count: max(0, n))
    }

    /// Todos los anchos tienen la misma paridad que `ancho`, así que el relleno siempre es exacto.
    private static func centrar(_ s: String) -> String {
        let relleno = (ancho - s.count) / 2
        return repetir(" ", relleno) + s + repetir(" ", ancho - s.count - relleno)
    }
}
