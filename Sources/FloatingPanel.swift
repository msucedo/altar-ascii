import AppKit
import Combine
import SwiftUI

// El altar flotando sobre el escritorio. Es un NSPanel de AppKit porque SwiftUI, con el SDK
// de macOS 13, no deja hacer ventanas sin borde, transparentes y siempre encima.
final class FloatingAltar {
    /// Con este nombre AppKit guarda solo la posición de la ventana en UserDefaults.
    static let nombreDePosicion = "AltarFlotante"

    private let store: AltarStore
    private var panel: NSPanel?
    private var observacion: AnyCancellable?

    init(store: AltarStore) {
        self.store = store
        observacion = store.$config
            .map(\.flotante)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] visible in self?.mostrar(visible) }
    }

    private func mostrar(_ visible: Bool) {
        guard visible else {
            panel?.orderOut(nil)
            return
        }
        let panel = self.panel ?? crearPanel()
        self.panel = panel
        panel.orderFrontRegardless()
    }

    private func crearPanel() -> NSPanel {
        let panel = NSPanel(contentRect: .zero,
                            // nonactivatingPanel: hacer clic en el altar no le quita el foco a la app en la que estás.
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        // Que se vea en todos los escritorios (Spaces), también junto a apps en pantalla completa.
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let vista = VistaArrastrable(rootView: FloatingAltarView(store: store))
        vista.ocultar = { [weak store] in store?.config.flotante = false }
        panel.contentView = vista
        panel.setContentSize(vista.fittingSize)

        // Si ya se había movido antes, AppKit lo pone donde quedó; si no, arriba a la derecha.
        if !panel.setFrameUsingName(Self.nombreDePosicion), let pantalla = NSScreen.main?.visibleFrame {
            panel.setFrameTopLeftPoint(NSPoint(x: pantalla.maxX - panel.frame.width - 24, y: pantalla.maxY - 24))
        }
        panel.setFrameAutosaveName(Self.nombreDePosicion)
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

    var body: some View {
        AltarView(config: store.config)
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
