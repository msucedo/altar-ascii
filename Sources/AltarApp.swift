import SwiftUI

// Punto de entrada. MenuBarExtra pone el icono en la barra de menú; con el estilo .window
// el contenido se abre como un panel translúcido, igual que el Centro de Control.
@main
struct AltarApp: App {
    // Por ahora la configuración vive solo mientras la app está abierta; se guardará más adelante.
    @State private var config = AltarConfig()
    @State private var configurando = false

    var body: some Scene {
        MenuBarExtra("Altar", systemImage: "flame") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Altar de muertos")
                    .font(.headline)
                AltarView(config: config)
                    .frame(maxWidth: .infinity)
                DisclosureGroup("Configurar", isExpanded: $configurando) {
                    SettingsView(config: $config)
                        .padding(.top, 8)
                }
                Divider()
                Button("Salir") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut("q")
            }
            .padding(16)
            .frame(width: 380)
        }
        .menuBarExtraStyle(.window)
    }
}
