import SwiftUI

// Los controles para armar el altar. Viven dentro del mismo panel de la barra de menú,
// como los del Centro de Control, en vez de en una ventana de preferencias aparte.
struct SettingsView: View {
    @Binding var config: AltarConfig
    @State private var nuevoNombre = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Picker("Niveles", selection: $config.niveles) {
                    ForEach(Niveles.allCases) { Text("\($0.rawValue)").tag($0) }
                }
                .pickerStyle(.segmented)
                Text(config.niveles.significado.prefix(1).uppercased() + config.niveles.significado.dropFirst())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Ofrendas").font(.subheadline.bold())
            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading),
                                GridItem(.flexible(), alignment: .leading)], spacing: 6) {
                ForEach(Ofrenda.allCases) { ofrenda in
                    Toggle(ofrenda.nombre, isOn: incluye(ofrenda))
                        .toggleStyle(.checkbox)
                }
            }

            Text("Nombres").font(.subheadline.bold())
            ForEach(Array(config.nombres.enumerated()), id: \.offset) { i, nombre in
                HStack {
                    Text(nombre)
                    Spacer()
                    Button {
                        config.nombres.remove(at: i)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .buttonStyle(.borderless)
                    .help("Quitar")
                }
            }
            if config.nombres.count < Arte.maxNombres {
                HStack {
                    TextField("Agregar un nombre", text: $nuevoNombre)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(agregar)
                    Button("Agregar", action: agregar)
                        .disabled(nuevoNombre.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            if !config.ofrendas.contains(.retratos) && !config.nombres.isEmpty {
                Text("Activa los retratos para ver los nombres en el altar.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func incluye(_ ofrenda: Ofrenda) -> Binding<Bool> {
        Binding(
            get: { config.ofrendas.contains(ofrenda) },
            set: { if $0 { config.ofrendas.insert(ofrenda) } else { config.ofrendas.remove(ofrenda) } }
        )
    }

    private func agregar() {
        let nombre = nuevoNombre.trimmingCharacters(in: .whitespaces)
        guard !nombre.isEmpty, config.nombres.count < Arte.maxNombres else { return }
        // Se guarda recortado al largo que cabe en el retrato, para que la lista muestre lo mismo que el altar.
        config.nombres.append(String(nombre.prefix(Arte.largoNombre)))
        nuevoNombre = ""
    }
}
