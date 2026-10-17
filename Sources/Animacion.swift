import AppKit
import Combine

// Decide si vale la pena animar. Con la pantalla bloqueada o apagada nadie ve el altar, y el
// widget del escritorio tampoco se ve si una ventana lo tapa por completo; en esos casos la
// animación se pausa para no gastar CPU todo el día.
final class Animacion: ObservableObject {
    @Published private(set) var pantallaActiva = true
    /// Lo actualiza FloatingAltar: false cuando el widget queda completamente tapado.
    @Published var widgetVisible = true

    private var bloqueada = false
    private var dormida = false
    private var observaciones: [AnyCancellable] = []

    init() {
        // El bloqueo de pantalla solo se anuncia por notificaciones distribuidas, entre procesos.
        let distribuidas = DistributedNotificationCenter.default()
        let espacio = NSWorkspace.shared.notificationCenter
        observar(distribuidas, "com.apple.screenIsLocked") { $0.bloqueada = true }
        observar(distribuidas, "com.apple.screenIsUnlocked") { $0.bloqueada = false }
        observar(espacio, NSWorkspace.screensDidSleepNotification.rawValue) { $0.dormida = true }
        observar(espacio, NSWorkspace.screensDidWakeNotification.rawValue) { $0.dormida = false }
    }

    private func observar(_ centro: NotificationCenter, _ nombre: String, _ cambio: @escaping (Animacion) -> Void) {
        centro.publisher(for: Notification.Name(nombre))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                cambio(self)
                // Despertar con la sesión todavía bloqueada no debe reanudar la animación.
                self.pantallaActiva = !self.bloqueada && !self.dormida
            }
            .store(in: &observaciones)
    }
}
