import SwiftUI

struct BudgetSettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(settingsStore: SettingsStore) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(settingsStore: settingsStore))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    budgetField
                } footer: {
                    Text("Laissez vide pour désactiver le suivi du budget.")
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }

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

}

#Preview {
    BudgetSettingsView(settingsStore: SettingsStore())
}
