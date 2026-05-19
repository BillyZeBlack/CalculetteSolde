import SwiftUI

struct ScanLimitSheetView: View {
    @ObservedObject var premiumManager: PremiumManager
    @ObservedObject var rewardedAdManager: RewardedAdManager
    let onWatchAd: () -> Void

    @State private var isPremiumSheetPresented = false
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

                        Text("Vous pouvez passer Premium ou regarder une pub pour débloquer un scan.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if rewardedAdManager.isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text("Chargement de la publicité...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if let errorMessage = rewardedAdManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    isPremiumSheetPresented = true
                } label: {
                    Text("Passer Premium")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)

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
            .sheet(isPresented: $isPremiumSheetPresented) {
                PremiumUpgradeView(
                    premiumManager: premiumManager,
                    context: .scan
                )
            }
        }
    }
}

#Preview {
    ScanLimitSheetView(
        premiumManager: PremiumManager(),
        rewardedAdManager: RewardedAdManager(),
        onWatchAd: {}
    )
}
