import SwiftUI

// Muestra las líneas del renderer. Va en una vista aparte porque la misma se usará
// en el panel de la barra de menú y en la ventana flotante.
struct AltarView: View {
    let config: AltarConfig
    /// Si en Accesibilidad está activado "Reducir movimiento", el altar se queda quieto.
    @Environment(\.accessibilityReduceMotion) private var reducirMovimiento

    static let fotogramasPorSegundo = 4.0

    var body: some View {
        // TimelineView vuelve a dibujar la vista en cada tic; solo corre mientras se ve en pantalla.
        TimelineView(.periodic(from: .now, by: 1 / Self.fotogramasPorSegundo)) { contexto in
            let frame = reducirMovimiento ? 0
                : Int(contexto.date.timeIntervalSinceReferenceDate * Self.fotogramasPorSegundo)
            Text(AltarRenderer.render(config, frame: frame).joined(separator: "\n"))
                .font(.system(size: 11, design: .monospaced))
                .fixedSize()
        }
    }
}
