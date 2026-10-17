import Foundation

// Comprueba el aviso de cuánto falta en fechas clave, incluido el cambio de año.
@main
struct CalendarioCheck {
    static func main() {
        var calendario = Calendar(identifier: .gregorian)
        calendario.timeZone = TimeZone(identifier: "America/Mexico_City")!
        var fallos = 0
        let casos: [(Int, Int, Int, String)] = [
            (2026, 10, 17, "Faltan 15 días para Día de Muertos"),
            (2026, 10, 31, "Mañana es Día de Muertos"),
            (2026, 11, 1, "Hoy llegan los angelitos"),
            (2026, 11, 2, "Hoy llegan los fieles difuntos"),
            (2026, 11, 3, "Faltan 363 días para Día de Muertos"),
            (2026, 12, 31, "Faltan 305 días para Día de Muertos"),
            (2027, 1, 1, "Faltan 304 días para Día de Muertos"),
        ]
        for (año, mes, dia, esperado) in casos {
            // A media tarde, para que la hora no cambie el resultado.
            let fecha = calendario.date(from: DateComponents(year: año, month: mes, day: dia, hour: 17))!
            let aviso = Calendario.aviso(hoy: fecha, calendario: calendario)
            let ok = aviso == esperado
            print((ok ? "ok    " : "FALLA ") + "\(dia)/\(mes)/\(año): \(aviso)")
            if !ok { fallos += 1 }
        }
        print(fallos == 0 ? "ok" : "\(fallos) fallos")
        exit(fallos == 0 ? 0 : 1)
    }
}
