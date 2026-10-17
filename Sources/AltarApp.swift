import SwiftUI

// Punto de entrada. MenuBarExtra pone el icono en la barra de menú; con el estilo .window
// el contenido se abre como un panel translúcido, igual que el Centro de Control.
@main
struct AltarApp: App {
    // Por ahora la configuración vive solo mientras la app está abierta; se guardará más adelante.
    @State private var config = AltarConfig()

    var body: some Scene {
        MenuBarExtra("Altar", systemImage: "flame") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Altar de muertos")
                    .font(.headline)
                AltarView(config: config)
                    .frame(maxWidth: .infinity)
                Picker("Niveles", selection: $config.niveles) {
                    ForEach(Niveles.allCases) { Text("\($0.rawValue)").tag($0) }
                }
                .pickerStyle(.segmented)
                Text(config.niveles.significado.prefix(1).uppercased() + config.niveles.significado.dropFirst())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Divider()
                Button("Salir") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut("q")
            }
            .padding(16)
            .frame(width: 360)
        }
        .menuBarExtraStyle(.window)
    }
}
