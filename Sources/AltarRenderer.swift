import Foundation

// Convierte la configuración del altar en líneas de texto. Es una función pura: no sabe nada
// de la interfaz, así que la misma salida sirve para el panel, la ventana flotante y la prueba.

struct AltarConfig: Equatable {
    var niveles: Niveles = .tres
    var ofrendas: Set<Ofrenda> = Set(Ofrenda.allCases)
    var nombres: [String] = []
}

enum AltarRenderer {
    /// Ancho fijo en caracteres; todas las líneas miden exactamente esto.
    static let ancho = 48
    /// El escalón de arriba nunca es más angosto que esto, para que quepan los retratos.
    static let anchoMinimoArriba = 24
    /// Cuánto se mete cada escalón respecto al de abajo, por lado, como máximo.
    static let pasoMaximo = 4
    /// Un escalón vacío conserva al menos este alto.
    static let filasMinimas = 2

    static func render(_ config: AltarConfig, frame: Int = 0) -> [String] {
        let n = config.niveles.rawValue
        // Cuánto se mete cada escalón respecto al de abajo, por lado. Con 7 niveles hay
        // que apretar más para que el de arriba no quede demasiado angosto.
        let paso = min(pasoMaximo, (ancho - anchoMinimoArriba) / (2 * (n - 1)))
        // Anchos de arriba hacia abajo; el último ocupa todo el ancho.
        let anchos = (0..<n).map { ancho - 2 * paso * (n - 1 - $0) }
        let contenido = repartir(config)

        var lineas: [String] = []
        if config.ofrendas.contains(.papelPicado) {
            lineas += Arte.papelPicado(ancho: ancho - 2).map(centrar)
        }
        lineas.append(centrar(" " + repetir("_", anchos[0] - 2) + " "))
        for (k, w) in anchos.enumerated() {
            for fila in acomodar(contenido[k], interior: w - 2) {
                lineas.append(centrar("|" + fila + "|"))
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
        if config.ofrendas.contains(.cempasuchil) {
            lineas += Arte.caminoDePetalos.map(centrar)
        }
        return lineas
    }

    /// Decide qué piezas van en cada escalón (índice 0 = arriba) y en qué orden de izquierda a derecha.
    /// Los retratos van en el cielo; el agua, la sal y el copal, abajo, en la tierra.
    static func repartir(_ config: AltarConfig) -> [[Pieza]] {
        let n = config.niveles.rawValue
        let abajo = n - 1
        // Con 7 niveles las ofrendas se reparten por los pasos intermedios.
        let nivelPan = [2: 1, 3: 1, 7: 3][n]!
        let nivelComida = [2: 1, 3: 1, 7: 4][n]!
        let nivelCalaveritas = [2: 0, 3: 1, 7: 2][n]!

        // (nivel, posición, pieza); la posición ordena las piezas dentro del escalón.
        var lugares: [(Int, Int, Pieza)] = []
        let tiene = config.ofrendas.contains
        if tiene(.velas) {
            // Con 3 o más niveles el cielo queda para los retratos y las velas bajan un escalón.
            for nivel in Set([n == 2 ? 0 : 1, abajo]) {
                lugares += [(nivel, 1, Arte.vela), (nivel, 9, Arte.vela)]
            }
        }
        if tiene(.retratos) {
            lugares += nombresLimpios(config.nombres).map { (0, 4, Arte.retrato($0)) }
        }
        if tiene(.cempasuchil) {
            for nivel in 1..<n {
                lugares += [(nivel, 0, Arte.flor), (nivel, 10, Arte.flor)]
            }
        }
        if tiene(.agua) { lugares.append((abajo, 2, Arte.agua)) }
        if tiene(.pan) { lugares.append((nivelPan, 3, Arte.pan)) }
        if tiene(.calaveritas) { lugares.append((nivelCalaveritas, 5, Arte.calaverita)) }
        if tiene(.comida) { lugares.append((nivelComida, 6, Arte.comida)) }
        if tiene(.copal) { lugares.append((abajo, 7, Arte.copal)) }
        if tiene(.sal) { lugares.append((abajo, 8, Arte.sal)) }

        // sorted es estable: los retratos conservan el orden en que se agregaron los nombres.
        let ordenados = lugares.enumerated().sorted { ($0.element.1, $0.offset) < ($1.element.1, $1.offset) }
        var niveles = Array(repeating: [Pieza](), count: n)
        for (_, (nivel, _, pieza)) in ordenados { niveles[nivel].append(pieza) }
        return niveles
    }

    /// Sin nombres se pone un retrato vacío, para que el lugar se vea.
    static func nombresLimpios(_ nombres: [String]) -> [String] {
        let limpios = nombres
            .map { String($0.trimmingCharacters(in: .whitespaces).prefix(Arte.largoNombre)) }
            .filter { !$0.isEmpty }
            .prefix(Arte.maxNombres)
        return limpios.isEmpty ? ["    "] : Array(limpios)
    }

    /// Acomoda las piezas en filas del ancho interior del escalón, repartiendo el espacio libre
    /// entre ellas. Si no caben todas juntas, las que sobran pasan a otra fila del
    /// mismo escalón. Las piezas de cada fila se alinean abajo.
    static func acomodar(_ piezas: [Pieza], interior: Int) -> [String] {
        var grupos: [[Pieza]] = []
        var actual: [Pieza] = []
        var usado = 1
        for p in piezas {
            if !actual.isEmpty && usado + p.ancho + 1 > interior {
                grupos.append(actual)
                actual = []
                usado = 1
            }
            actual.append(p)
            usado += p.ancho + 1
        }
        if !actual.isEmpty { grupos.append(actual) }

        var filas: [String] = []
        for grupo in grupos {
            let alto = grupo.map(\.alto).max()!
            let libre = interior - grupo.reduce(0) { $0 + $1.ancho }
            let huecos = grupo.count + 1
            for r in 0..<alto {
                var fila = ""
                for (i, p) in grupo.enumerated() {
                    fila += repetir(" ", libre * (i + 1) / huecos - libre * i / huecos)
                    let desde = alto - p.alto
                    fila += r < desde ? repetir(" ", p.ancho) : p.lineas[r - desde]
                }
                fila += repetir(" ", libre - libre * grupo.count / huecos)
                filas.append(fila)
            }
        }
        while filas.count < filasMinimas { filas.insert(repetir(" ", interior), at: 0) }
        return filas
    }

    private static func repetir(_ c: Character, _ n: Int) -> String {
        String(repeating: c, count: max(0, n))
    }

    private static func centrar(_ s: String) -> String {
        let relleno = (ancho - s.count) / 2
        return repetir(" ", relleno) + s + repetir(" ", ancho - s.count - relleno)
    }
}
