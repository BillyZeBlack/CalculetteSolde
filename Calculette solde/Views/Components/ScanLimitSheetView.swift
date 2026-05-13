import SwiftUI

struct ScanLimitSheetView: View {
    @ObservedObject var premiumManager: PremiumManager
    @ObservedObject var rewardedAdManager: RewardedAdManager
    let onWatchAd: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title2)
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Scanner illimité avec Premium")
                            .font(.title3.weight(.semibold))

                        Text("Débloquez le scan sans limite et retirez les publicités de Solde facile.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Achat unique \(premiumManager.displayPrice)")
                            .font(.subheadline.weight(.semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    benefitRow("Scan illimité")
                    benefitRow("Publicités supprimées")
                    benefitRow("Activation restaurable sur vos appareils")
                }

                if premiumManager.isLoading || rewardedAdManager.isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(premiumManager.statusMessage ?? "Chargement...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if let statusMessage = premiumManager.statusMessage {
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(premiumManager.isPremiumActive ? .green : .secondary)
                }

                if let errorMessage = premiumManager.errorMessage ?? rewardedAdManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    premiumManager.purchaseRemoveAds()
                } label: {
                    Text("Passer Premium")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(premiumManager.isLoading || premiumManager.removeAdsProduct == nil || premiumManager.isPremiumActive)

                Button {
                    onWatchAd()
                } label: {
                    Text("Regarder une pub pour 1 scan")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .disabled(rewardedAdManager.isLoading)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Scan Premium")
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
    ScanLimitSheetView(
        premiumManager: PremiumManager(),
        rewardedAdManager: RewardedAdManager(),
        onWatchAd: {}
    )
}
