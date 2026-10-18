import ServiceManagement
import SwiftUI

// Punto de entrada. MenuBarExtra pone el icono en la barra de menú; con el estilo .window
// el contenido se abre como un panel translúcido, igual que el Centro de Control.
@main
struct AltarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegado

    var body: some Scene {
        MenuBarExtra {
            PanelView(store: delegado.store, animacion: delegado.animacion)
        } label: {
            Text("🌼")
        }
        .menuBarExtraStyle(.window)
    }
}

/// El store vive en el delegado y no en la App, porque la ventana flotante tiene que aparecer
/// al abrir la app, aunque nunca se haya abierto el panel de la barra de menú.
final class AppDelegate: NSObject, NSApplicationDelegate {
    // El store guarda la configuración cada vez que cambia, y la recupera al abrir la app.
    let store = AltarStore()
    let animacion = Animacion()
    private var flotante: FloatingAltar?

    func applicationDidFinishLaunching(_ notification: Notification) {
        flotante = FloatingAltar(store: store, animacion: animacion)
    }
}

struct PanelView: View {
    @ObservedObject var store: AltarStore
    @ObservedObject var animacion: Animacion
    /// Si están a la vista las opciones de abajo del altar. Empieza cerrado y se recuerda.
    @AppStorage("panelAbierto") private var abierto = false
    @State private var altoAltar: CGFloat = 0
    @State private var altoOpciones: CGFloat = 0
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
            AltarView(config: store.config, animar: animacion.pantallaActiva)
                .frame(maxWidth: .infinity)
                .background(medirAlto { altoAltar = $0 })
            Button {
                // Abrir se anima; cerrar no. Al cerrar, la ventana se encoge de golpe y, si las
                // opciones siguieran saliendo con animación, el contenido no cabría por un instante
                // y el altar parpadearía.
                if abierto {
                    abierto = false
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) { abierto = true }
                }
            } label: {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(abierto ? 180 : 0))
                    // La flecha gira en los dos sentidos; su giro no cambia el tamaño de la ventana.
                    .animation(.easeInOut(duration: 0.2), value: abierto)
                    .frame(maxWidth: .infinity, minHeight: 18)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .help(abierto ? "Ocultar opciones" : "Mostrar opciones")

            if abierto {
                // Las opciones van en un scroll que mide lo mismo que su contenido, salvo que no
                // quepan en la pantalla junto con el altar: entonces se recorta y se desplaza.
                ScrollView {
                    opciones
                        .background(medirAlto { altoOpciones = $0 })
                }
                .frame(height: min(altoOpciones, altoMaximoOpciones))
                .transition(.opacity)
            }
        }
        // Anclado arriba: si la ventana tarda un instante en ajustarse, el altar se queda pegado
        // a la barra de menú en lugar de moverse.
        .frame(maxHeight: .infinity, alignment: .top)
        // Salir sigue funcionando con ⌘Q aunque el botón esté oculto.
        .background(Button("") { NSApplication.shared.terminate(nil) }.keyboardShortcut("q").hidden())
        .padding(16)
        .frame(width: 380)
    }

    private var opciones: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Mostrar en el escritorio", isOn: $store.config.flotante)
                .toggleStyle(.switch)
            Divider()
            SettingsView(config: $store.config)
            Divider()
            HStack {
                Toggle("Abrir al iniciar sesión", isOn: Binding(get: { alIniciarSesion }, set: cambiarInicio))
                    .toggleStyle(.checkbox)
                Spacer()
                Button("Salir") { NSApplication.shared.terminate(nil) }
            }
            if let errorDeInicio {
                Text(errorDeInicio)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        // Un poco de aire a la derecha para que la barra del scroll no tape los controles.
        .padding(.trailing, 4)
    }

    /// Lo que cabe debajo del altar: el alto visible de la pantalla menos el altar, el título, la
    /// flecha y los márgenes del panel.
    private var altoMaximoOpciones: CGFloat {
        let pantalla = NSScreen.main?.visibleFrame.height ?? 800
        return max(140, pantalla - altoAltar - 140)
    }

    /// Informa el alto que ocupa una vista, sin cambiar cómo se dibuja.
    private func medirAlto(_ alCambiar: @escaping (CGFloat) -> Void) -> some View {
        GeometryReader { geometria in
            Color.clear
                .onAppear { alCambiar(geometria.size.height) }
                .onChange(of: geometria.size.height) { alCambiar($0) }
        }
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
