import Combine
import SwiftUI

// Muestra las líneas del renderer. Va en una vista aparte porque la misma se usa en el panel
// de la barra de menú y en el widget del escritorio.
struct AltarView: View {
    let config: AltarConfig
    /// false cuando nadie lo puede ver (pantalla bloqueada o widget tapado): el dibujo se queda quieto.
    var animar = true
    /// Si en Accesibilidad está activado "Reducir movimiento", el altar se queda quieto.
    @Environment(\.accessibilityReduceMotion) private var reducirMovimiento
    @State private var frame = AltarView.frameActual()

    static let fotogramasPorSegundo = 4.0

    /// Un temporizador común y no TimelineView: medido con el widget en el escritorio, TimelineView
    /// gastaba el doble de CPU (7% contra 3.5%) para dibujar los mismos 4 fotogramas por segundo.
    private static let reloj = Timer.publish(every: 1 / fotogramasPorSegundo, on: .main, in: .common)
        .autoconnect()

    /// El fotograma sale de la hora, así el panel y el widget van sincronizados.
    private static func frameActual(_ fecha: Date = Date()) -> Int {
        Int(fecha.timeIntervalSinceReferenceDate * fotogramasPorSegundo)
    }

    var body: some View {
        Text(AltarRenderer.render(config, frame: reducirMovimiento ? 0 : frame).joined(separator: "\n"))
            .font(.system(size: 11, design: .monospaced))
            .fixedSize()
            // En pausa la vista deja de escuchar el reloj y no se vuelve a dibujar.
            .onReceive(animar && !reducirMovimiento ? Self.reloj.eraseToAnyPublisher()
                                                    : Empty().eraseToAnyPublisher()) { fecha in
                frame = Self.frameActual(fecha)
            }
    }
}
