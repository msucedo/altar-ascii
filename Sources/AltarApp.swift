import SwiftUI

// Punto de entrada. MenuBarExtra pone el icono en la barra de menú; con el estilo .window
// el contenido se abre como un panel translúcido, igual que el Centro de Control.
@main
struct AltarApp: App {
    // El store guarda la configuración cada vez que cambia, y la recupera al abrir la app.
    @StateObject private var store = AltarStore()
    @State private var configurando = false

    var body: some Scene {
        MenuBarExtra("Altar", systemImage: "flame") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Altar de muertos")
                    .font(.headline)
                AltarView(config: store.config)
                    .frame(maxWidth: .infinity)
                DisclosureGroup("Configurar", isExpanded: $configurando) {
                    SettingsView(config: $store.config)
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
