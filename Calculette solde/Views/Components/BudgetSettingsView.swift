import SwiftUI

struct BudgetSettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    let isPremiumActive: Bool
    let onRequestPremium: () -> Void

    init(
        settingsStore: SettingsStore,
        isPremiumActive: Bool,
        onRequestPremium: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(settingsStore: settingsStore))
        self.isPremiumActive = isPremiumActive
        self.onRequestPremium = onRequestPremium
    }

    var body: some View {
        NavigationStack {
            Form {
                if isPremiumActive {
                    Section {
                        budgetField
                    } footer: {
                        Text("Laissez vide pour désactiver le suivi du budget.")
                    }
                } else {
                    lockedBudgetSection
                }
            }
            .navigationTitle("Budget max")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }

                if isPremiumActive {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Enregistrer") {
                            viewModel.save()
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }

    private var budgetField: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Budget maximum", text: $viewModel.maximumBudgetText)
                .keyboardType(.decimalPad)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
            }

            Button("Supprimer le budget", role: .destructive) {
                viewModel.clearMaximumBudget()
            }
            .disabled(viewModel.maximumBudgetText.isEmpty)
        }
    }

    private var lockedBudgetSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.orange)
                        .frame(width: 34, height: 34)
                        .background(Color.orange.opacity(0.12), in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Budget maximum")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Suivez le total de vos produits par rapport à un plafond.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                lockedBudgetPreview

                Button {
                    onRequestPremium()
                } label: {
                    Label("Débloquer avec Premium", systemImage: "crown.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 6)
        } footer: {
            Text("Le budget max est une fonctionnalité Premium. Vous pouvez voir son fonctionnement avant de la débloquer.")
        }
    }

    private var lockedBudgetPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Exemple")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("72,00 € / 100,00 €")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.primary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemFill))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.yellow, Color.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * 0.72)
                }
            }
            .frame(height: 8)

            Text("Reste 28,00 €")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    BudgetSettingsView(
        settingsStore: SettingsStore(),
        isPremiumActive: false,
        onRequestPremium: {}
    )
}
