import Combine
import Foundation

@MainActor
final class ScanAccessManager: ObservableObject {
    private let freeScanLimit = 3
    private let usedScanCountKey = "com.slideofdigital.Calculette-solde.usedScanCount"

    @Published private(set) var usedScanCount: Int
    @Published private(set) var rewardedScanCredits = 0

    init() {
        usedScanCount = UserDefaults.standard.integer(forKey: usedScanCountKey)
    }

    var remainingFreeScans: Int {
        max(0, freeScanLimit - usedScanCount)
    }

    func canStartScan(isPremiumActive: Bool) -> Bool {
        isPremiumActive || remainingFreeScans > 0 || rewardedScanCredits > 0
    }

    func recordScanStart(isPremiumActive: Bool) {
        guard !isPremiumActive else { return }

        if rewardedScanCredits > 0 {
            rewardedScanCredits -= 1
            return
        }

        usedScanCount += 1
        UserDefaults.standard.set(usedScanCount, forKey: usedScanCountKey)
    }

    func grantRewardedScan() {
        rewardedScanCredits += 1
    }
}
