import ServiceManagement
import SwiftUI

// Punto de entrada. MenuBarExtra pone el icono en la barra de menú; con el estilo .window
// el contenido se abre como un panel translúcido, igual que el Centro de Control.
@main
struct AltarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegado

    var body: some Scene {
        MenuBarExtra("Altar", systemImage: "flame") {
            PanelView(store: delegado.store)
        }
        .menuBarExtraStyle(.window)
    }
}

/// El store vive en el delegado y no en la App, porque la ventana flotante tiene que aparecer
/// al abrir la app, aunque nunca se haya abierto el panel de la barra de menú.
final class AppDelegate: NSObject, NSApplicationDelegate {
    // El store guarda la configuración cada vez que cambia, y la recupera al abrir la app.
    let store = AltarStore()
    private var flotante: FloatingAltar?

    func applicationDidFinishLaunching(_ notification: Notification) {
        flotante = FloatingAltar(store: store)
    }
}

struct PanelView: View {
    @ObservedObject var store: AltarStore
    @State private var configurando = false
    // Si la app abre al iniciar sesión lo sabe el sistema, no la configuración del altar,
    // así que se le pregunta a SMAppService en vez de guardarlo aparte.
    @State private var alIniciarSesion = SMAppService.mainApp.status == .enabled
    @State private var errorDeInicio: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Altar de muertos")
                    .font(.headline)
                Text(Calendario.aviso())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            AltarView(config: store.config)
                .frame(maxWidth: .infinity)
            Toggle("Mostrar en el escritorio", isOn: $store.config.flotante)
                .toggleStyle(.switch)
            DisclosureGroup("Configurar", isExpanded: $configurando) {
                SettingsView(config: $store.config)
                    .padding(.top, 8)
            }
            Divider()
            HStack {
                Toggle("Abrir al iniciar sesión", isOn: Binding(get: { alIniciarSesion }, set: cambiarInicio))
                    .toggleStyle(.checkbox)
                Spacer()
                Button("Salir") { NSApplication.shared.terminate(nil) }
                    .keyboardShortcut("q")
            }
            if let errorDeInicio {
                Text(errorDeInicio)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(16)
        .frame(width: 380)
    }

    private func cambiarInicio(_ activar: Bool) {
        do {
            if activar {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            errorDeInicio = nil
        } catch {
            errorDeInicio = "No se pudo cambiar: \(error.localizedDescription)"
        }
        // macOS puede pedir que se apruebe en Ajustes > General > Ítems de inicio.
        if SMAppService.mainApp.status == .requiresApproval {
            errorDeInicio = "Apruébalo en Ajustes del Sistema > General > Ítems de inicio."
        }
        alIniciarSesion = SMAppService.mainApp.status == .enabled
    }
}
