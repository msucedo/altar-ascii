import SwiftUI

// Punto de entrada. MenuBarExtra pone el icono en la barra de menú; con el estilo .window
// el contenido se abre como un panel translúcido, igual que el Centro de Control.
@main
struct AltarApp: App {
    var body: some Scene {
        MenuBarExtra("Altar", systemImage: "flame") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Altar de muertos")
                    .font(.headline)
                Text("Aquí irá el altar.")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.secondary)
                Divider()
                Button("Salir") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut("q")
            }
            .padding(16)
            .frame(width: 320)
        }
        .menuBarExtraStyle(.window)
    }
}
