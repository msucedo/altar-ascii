// Las piezas del altar. Por ahora, los niveles y lo que significa cada opción;
// en el siguiente paso aquí vivirá el arte de cada ofrenda.

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
