import SwiftUI

struct BudgetSettingsView: View {
    @ObservedObject private var premiumManager: PremiumManager
    @StateObject private var viewModel: SettingsViewModel
    @State private var isPremiumSheetPresented = false
    @Environment(\.dismiss) private var dismiss

    init(settingsStore: SettingsStore, premiumManager: PremiumManager) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(settingsStore: settingsStore))
        self.premiumManager = premiumManager
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if premiumManager.isPremiumActive {
                        budgetField
                    } else {
                        lockedBudgetContent
                    }
                } footer: {
                    Text(premiumManager.isPremiumActive ? "Laissez vide pour désactiver le suivi du budget." : "Le budget max suit le montant total de la liste de produits.")
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }

                if premiumManager.isPremiumActive {
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
            .sheet(isPresented: $isPremiumSheetPresented) {
                PremiumUpgradeView(premiumManager: premiumManager)
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

    private var lockedBudgetContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Budget max Premium", systemImage: "lock.fill")
                .font(.body.weight(.semibold))

            Text("Définissez un budget et suivez la progression du total directement sous Produits ajoutés.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                isPremiumSheetPresented = true
            } label: {
                Label("Passer Premium", systemImage: "crown.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BudgetSettingsView(
        settingsStore: SettingsStore(),
        premiumManager: PremiumManager()
    )
}
