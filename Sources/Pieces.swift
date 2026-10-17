// Las piezas del altar: las opciones de niveles, las ofrendas y el arte ASCII de cada una.

enum Niveles: Int, CaseIterable, Codable, Identifiable {
    case dos = 2, tres = 3, siete = 7

    var id: Int { rawValue }

    var nombre: String { "\(rawValue) niveles" }

    var significado: String {
        switch self {
        case .dos: return "el cielo y la tierra"
        case .tres: return "el cielo, la tierra y el inframundo"
        case .siete: return "los siete pasos hacia el descanso"
        }
    }
}

enum Ofrenda: String, CaseIterable, Codable, Identifiable {
    case papelPicado, retratos, velas, cempasuchil, pan, calaveritas, comida, agua, sal, copal

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .papelPicado: return "Papel picado"
        case .retratos: return "Retratos"
        case .velas: return "Velas"
        case .cempasuchil: return "Cempasúchil"
        case .pan: return "Pan de muerto"
        case .calaveritas: return "Calaveritas"
        case .comida: return "Comida favorita"
        case .agua: return "Agua"
        case .sal: return "Sal"
        case .copal: return "Copal"
        }
    }
}

/// Un dibujo pequeño. Todas sus líneas miden lo mismo, para poder ponerlo junto a otros.
struct Pieza {
    let lineas: [String]

    init(_ lineas: [String]) {
        let ancho = lineas.map(\.count).max() ?? 0
        self.lineas = lineas.map { $0 + String(repeating: " ", count: ancho - $0.count) }
    }

    var ancho: Int { lineas.first?.count ?? 0 }
    var alto: Int { lineas.count }
}

enum Arte {
    /// Los retratos tienen que caber en el escalón de arriba, así que los nombres se recortan.
    static let largoNombre = 12
    static let maxNombres = 6

    /// La llama cambia de forma en una secuencia irregular, para que no se vea como un reloj.
    static let llamas: [Character] = [")", ")", "(", ")", "'", "(", ")", "|"]

    static func vela(frame: Int) -> Pieza {
        Pieza([" \(llamas[frame % llamas.count]) ", "| |", "|_|"])
    }

    /// El cempasúchil: una vez por ciclo la flor "gira" (la @ pasa a *), y con viento se inclina
    /// hacia el mismo lado al que se recorre el papel picado.
    static func flor(frame: Int, viento: Bool) -> Pieza {
        let cabeza = frame % 8 == 7 ? "*" : "@"
        return viento ? Pieza(["  " + cabeza, " |/"]) : Pieza([" " + cabeza + " ", "\\|/"])
    }

    static let pan = Pieza([" .x. ", "(___)"])
    /// Parpadea una vez por ciclo completo. Es en el último fotograma y no en el primero, porque con
    /// "Reducir movimiento" el altar se queda en el fotograma 0 y saldría siempre con los ojos cerrados.
    static func calaverita(frame: Int) -> Pieza {
        Pieza([" .-. ", frame % AltarRenderer.ciclo == AltarRenderer.ciclo - 1 ? "(-.-)" : "(o.o)", " |=| "])
    }

    static let comida = Pieza(["(~~~)", "\\___/"])
    /// La superficie del agua ondula.
    static let olas: [Character] = ["~", "-", "~", "="]

    static func agua(frame: Int) -> Pieza {
        Pieza(["|\(olas[frame % olas.count])|", "|_|"])
    }

    static let sal = Pieza([".:.", "\\_/"])
    /// El humo del copal: cada fila toma la forma que tenía la de abajo un momento antes, así parece que sube.
    static let humo = ["  ~ ", " (  ", "  ) ", " ~  "]

    static func copal(frame: Int) -> Pieza {
        Pieza([humo[(frame + 1) % humo.count], humo[frame % humo.count], "\\##/"])
    }

    static func retrato(_ nombre: String) -> Pieza {
        let borde = String(repeating: "-", count: nombre.count)
        return Pieza([".-" + borde + "-.", "| " + nombre + " |", "'-" + borde + "-'"])
    }

    /// Una tira de banderitas colgando de un hilo, del ancho que se pida. Con `viento` las
    /// banderitas se recorren un carácter, como si el aire las moviera.
    static func papelPicado(ancho: Int, viento: Bool) -> [String] {
        let motivos = ["><", "::", "<>", "**"]
        let cuantas = (ancho - 1) / 5
        let banderas = (0..<cuantas).map { "|" + motivos[$0 % motivos.count] + "|" }
        let picos = Array(repeating: "\\/\\/", count: cuantas)
        let sangria = viento ? "  " : " "
        return [
            "o" + String(repeating: "-", count: ancho - 2) + "o",
            sangria + banderas.joined(separator: " "),
            sangria + picos.joined(separator: " "),
        ]
    }

    /// El camino de pétalos que guía a las almas hasta el altar; se abre hacia quien mira. Cada fila
    /// alterna sus pétalos un paso después que la de abajo, así parece que avanzan hacia el altar.
    static func caminoDePetalos(frame: Int) -> [String] {
        [7, 11, 15].enumerated().map { fila, largo in
            let desfase = (frame / 2 + fila) % 2
            return String((0..<largo).map { ($0 + desfase) % 2 == 0 ? "*" : "." })
        }
    }
}
