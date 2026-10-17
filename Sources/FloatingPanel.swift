import AppKit
import Combine
import SwiftUI

// El altar sobre el escritorio. Es un NSPanel de AppKit porque SwiftUI, con el SDK de macOS 13,
// no deja hacer ventanas sin borde, transparentes y en un nivel de ventana elegido.
final class FloatingAltar {
    /// Con este nombre AppKit guarda solo la posición de la ventana en UserDefaults.
    static let nombreDePosicion = "AltarFlotante"

    private let store: AltarStore
    private let animacion: Animacion
    private var panel: NSPanel?
    private var observaciones: [AnyCancellable] = []

    init(store: AltarStore, animacion: Animacion) {
        self.store = store
        self.animacion = animacion
        store.$config
            .map(\.flotante)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] visible in self?.mostrar(visible) }
            .store(in: &observaciones)
        // Al conectar o desconectar un monitor, o cambiar la resolución, el widget podría quedar
        // donde ya no hay pantalla.
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.asegurarVisible() }
            .store(in: &observaciones)
    }

    private func mostrar(_ visible: Bool) {
        guard visible else {
            panel?.orderOut(nil)
            return
        }
        let panel = self.panel ?? crearPanel()
        self.panel = panel
        asegurarVisible()
        panel.orderFrontRegardless()
    }

    /// Si ninguna pantalla muestra al menos un pedazo del widget, lo regresa a la esquina.
    private func asegurarVisible() {
        guard let panel else { return }
        let seVe = NSScreen.screens.contains { pantalla in
            let comun = pantalla.visibleFrame.intersection(panel.frame)
            return comun.width >= 60 && comun.height >= 60
        }
        if !seVe { ponerEnLaEsquina(panel) }
    }

    /// Arriba a la derecha de la pantalla principal.
    private func ponerEnLaEsquina(_ panel: NSPanel) {
        guard let pantalla = NSScreen.main?.visibleFrame else { return }
        panel.setFrameTopLeftPoint(NSPoint(x: pantalla.maxX - panel.frame.width - 24, y: pantalla.maxY - 24))
    }

    private func crearPanel() -> NSPanel {
        let panel = NSPanel(contentRect: .zero,
                            // nonactivatingPanel: hacer clic en el altar no le quita el foco a la app en la que estás.
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        // Pegado al fondo, como un widget: un nivel arriba de los iconos del escritorio (para que se
        // pueda arrastrar) y debajo de todas las ventanas normales.
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        // Que se vea en todos los escritorios (Spaces) y se quede quieto en Mission Control y al
        // mostrar el escritorio, como los iconos.
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        let vista = VistaArrastrable(rootView: FloatingAltarView(store: store, animacion: animacion))
        vista.ocultar = { [weak store] in store?.config.flotante = false }
        panel.contentView = vista
        panel.setContentSize(vista.fittingSize)

        // Si ya se había movido antes, AppKit lo pone donde quedó; si no, arriba a la derecha.
        if !panel.setFrameUsingName(Self.nombreDePosicion) {
            ponerEnLaEsquina(panel)
        }
        panel.setFrameAutosaveName(Self.nombreDePosicion)

        // Tapado por completo por otras ventanas no se ve, así que no hace falta animarlo.
        NotificationCenter.default.publisher(for: NSWindow.didChangeOcclusionStateNotification, object: panel)
            .sink { [weak self, weak panel] _ in
                guard let panel else { return }
                self?.animacion.widgetVisible = panel.occlusionState.contains(.visible)
            }
            .store(in: &observaciones)
        return panel
    }
}

/// La vista que llena el panel. Como no tiene controles, cualquier clic sirve para arrastrar la
/// ventana, y el clic derecho ofrece ocultarla.
private final class VistaArrastrable<Contenido: View>: NSHostingView<Contenido> {
    var ocultar: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        let menu = NSMenu()
        menu.addItem(withTitle: "Ocultar del escritorio", action: #selector(ocultarDesdeMenu), keyEquivalent: "")
            .target = self
        return menu
    }

    @objc private func ocultarDesdeMenu() {
        ocultar?()
    }
}

private struct FloatingAltarView: View {
    @ObservedObject var store: AltarStore
    @ObservedObject var animacion: Animacion

    var body: some View {
        AltarView(config: store.config, animar: animacion.pantallaActiva && animacion.widgetVisible)
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
