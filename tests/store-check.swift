import Foundation

// Comprueba que la configuración sobreviva a "reiniciar" (crear otro AltarStore sobre los mismos
// UserDefaults), que lo ilegible caiga en el altar por omisión y que falten campos sin romper nada.
@main
struct StoreCheck {
    static func main() {
        var fallos = 0
        func esperar(_ ok: Bool, _ caso: String) {
            print((ok ? "ok    " : "FALLA ") + caso)
            if !ok { fallos += 1 }
        }

        let suite = "com.msucedo.altar.prueba"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)

        esperar(AltarStore(defaults: defaults).config == AltarConfig(), "sin nada guardado, altar por omisión")

        let primero = AltarStore(defaults: defaults)
        primero.config.niveles = .siete
        primero.config.ofrendas.remove(.copal)
        primero.config.nombres = ["Abuela Lupe", "Tío Beto"]
        esperar(AltarStore(defaults: defaults).config == primero.config, "lo guardado se recupera")

        defaults.set("esto no es json", forKey: AltarStore.clave)
        esperar(AltarStore(defaults: defaults).config == AltarConfig(), "lo ilegible cae en el altar por omisión")

        defaults.set(#"{"niveles":2}"#, forKey: AltarStore.clave)
        let parcial = AltarStore(defaults: defaults).config
        esperar(parcial.niveles == .dos && parcial.ofrendas == AltarConfig().ofrendas, "un campo faltante toma su valor por omisión")

        // Así quedaba guardado antes de que existiera el modo flotante.
        defaults.set(#"{"niveles":7,"nombres":["Ana"],"ofrendas":["velas"]}"#, forKey: AltarStore.clave)
        let anterior = AltarStore(defaults: defaults).config
        esperar(anterior.nombres == ["Ana"] && !anterior.flotante, "lo guardado antes del modo flotante se sigue leyendo")

        defaults.removePersistentDomain(forName: suite)
        print(fallos == 0 ? "ok" : "\(fallos) fallos")
        exit(fallos == 0 ? 0 : 1)
    }
}
