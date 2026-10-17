import Foundation

// Guarda la configuración del altar en UserDefaults, como texto JSON, cada vez que cambia.
// Se puede ver desde la terminal con: defaults read local.altar-ascii altar
final class AltarStore: ObservableObject {
    static let clave = "altar"

    @Published var config: AltarConfig {
        didSet { guardar() }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // Si no hay nada guardado, o lo guardado no se puede leer, se empieza con el altar por omisión.
        if let texto = defaults.string(forKey: Self.clave),
           let config = try? JSONDecoder().decode(AltarConfig.self, from: Data(texto.utf8)) {
            self.config = config
        } else {
            self.config = AltarConfig()
        }
    }

    private func guardar() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        guard let datos = try? encoder.encode(config) else { return }
        defaults.set(String(decoding: datos, as: UTF8.self), forKey: Self.clave)
    }
}
