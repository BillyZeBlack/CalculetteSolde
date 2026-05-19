import SwiftUI

enum PremiumPresentationContext {
    case general
    case scan
    case categories
    case budget

    var title: String {
        switch self {
        case .general:
            return "Premium"
        case .scan:
            return "Scanner illimité"
        case .categories:
            return "Catégories Premium"
        case .budget:
            return "Budget maximum"
        }
    }

    var message: String {
        switch self {
        case .general:
            return "Débloquez toutes les fonctions Premium de Solde Facile."
        case .scan:
            return "Scannez vos produits sans limite et ajoutez-les plus vite à votre liste."
        case .categories:
            return "Accédez aux catégories Premium et créez vos propres catégories."
        case .budget:
            return "Fixez un budget maximum et suivez le total de vos produits en temps réel."
        }
    }

    var benefits: [String] {
        let allBenefits = [
            "Scan illimité",
            "Catégories Premium et personnalisées",
            "Fixer un budget maximum",
            "Supprime les publicités"
        ]

        switch self {
        case .general:
            return allBenefits
        case .scan:
            return ["Scan illimité", "Supprime les publicités", "Catégories Premium et personnalisées", "Fixer un budget maximum"]
        case .categories:
            return ["Catégories Premium et personnalisées", "Scan illimité", "Fixer un budget maximum", "Supprime les publicités"]
        case .budget:
            return ["Fixer un budget maximum", "Scan illimité", "Catégories Premium et personnalisées", "Supprime les publicités"]
        }
    }
}

struct PremiumUpgradeView: View {
    @ObservedObject var premiumManager: PremiumManager
    let context: PremiumPresentationContext
    @Environment(\.dismiss) private var dismiss

    init(
        premiumManager: PremiumManager,
        context: PremiumPresentationContext = .general
    ) {
        self.premiumManager = premiumManager
        self.context = context
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: premiumManager.isPremiumActive ? "checkmark.seal.fill" : "sparkles")
                        .font(.title2)
                        .foregroundStyle(premiumManager.isPremiumActive ? .green : .blue)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(premiumManager.isPremiumActive ? "Premium activé" : context.title)
                            .font(.title3.weight(.semibold))

                        Text(premiumManager.isPremiumActive ? premiumManager.description : context.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(premiumManager.isPremiumActive ? "Achat déjà actif" : "Achat unique \(premiumManager.displayPrice)")
                            .font(.subheadline.weight(.semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(context.benefits, id: \.self) { benefit in
                        benefitRow(benefit)
                    }
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
