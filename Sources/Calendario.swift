import Foundation

// El aviso de cuánto falta. El 1 de noviembre llegan los angelitos (los niños) y el 2 los
// fieles difuntos (los adultos); después de eso se cuenta hacia el año siguiente.
enum Calendario {
    static func aviso(hoy: Date = Date(), calendario: Calendar = .current) -> String {
        let c = calendario.dateComponents([.year, .month, .day], from: hoy)
        let (mes, dia) = (c.month!, c.day!)
        if mes == 11 && dia == 1 { return "Hoy llegan los angelitos" }
        if mes == 11 && dia == 2 { return "Hoy llegan los fieles difuntos" }

        let año = (mes == 12 || (mes == 11 && dia > 2)) ? c.year! + 1 : c.year!
        let llegada = calendario.date(from: DateComponents(year: año, month: 11, day: 1))!
        let faltan = calendario.dateComponents([.day], from: calendario.startOfDay(for: hoy), to: llegada).day!
        return faltan == 1 ? "Mañana es Día de Muertos" : "Faltan \(faltan) días para Día de Muertos"
    }
}
