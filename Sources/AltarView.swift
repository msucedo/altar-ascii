import SwiftUI

// Muestra las líneas del renderer. Va en una vista aparte porque la misma se usará
// en el panel de la barra de menú y en la ventana flotante.
struct AltarView: View {
    let config: AltarConfig

    var body: some View {
        Text(AltarRenderer.render(config).joined(separator: "\n"))
            .font(.system(size: 11, design: .monospaced))
            .fixedSize()
            .textSelection(.enabled)
    }
}
