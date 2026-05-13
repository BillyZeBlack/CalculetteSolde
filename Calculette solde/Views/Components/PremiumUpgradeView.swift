import SwiftUI

struct PremiumUpgradeView: View {
    @ObservedObject var premiumManager: PremiumManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: premiumManager.isPremiumActive ? "checkmark.seal.fill" : "sparkles")
                        .font(.title2)
                        .foregroundStyle(premiumManager.isPremiumActive ? .green : .blue)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(premiumManager.isPremiumActive ? "Premium activé" : premiumManager.displayName)
                            .font(.title3.weight(.semibold))

                        Text(premiumManager.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(premiumManager.isPremiumActive ? "Achat déjà actif" : "Achat unique \(premiumManager.displayPrice)")
                            .font(.subheadline.weight(.semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    benefitRow("Supprime les bannières publicitaires")
                    benefitRow("Supprime les publicités après ajout de produits")
                    benefitRow("Activation restaurable sur vos appareils")
                }

                if premiumManager.isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(premiumManager.statusMessage ?? "Chargement de l’offre...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if let statusMessage = premiumManager.statusMessage {
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(premiumManager.isPremiumActive ? .green : .secondary)
                }

                if let errorMessage = premiumManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    premiumManager.purchaseRemoveAds()
                } label: {
                    Text(premiumManager.isPremiumActive ? "Déjà acheté" : "Acheter")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(premiumManager.isLoading || premiumManager.removeAdsProduct == nil || premiumManager.isPremiumActive)

                Button {
                    premiumManager.restorePurchases()
                } label: {
                    Text("Restaurer les achats")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .disabled(premiumManager.isLoading)

                if premiumManager.removeAdsProduct == nil && !premiumManager.isLoading {
                    Button("Recharger l’offre") {
                        premiumManager.reloadProducts()
                    }
                    .font(.subheadline.weight(.semibold))
                }

                Spacer()
            }
            .padding(20)
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }

    private func benefitRow(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(.subheadline)
            .foregroundStyle(.primary)
    }
}

#Preview {
    PremiumUpgradeView(premiumManager: PremiumManager())
}
