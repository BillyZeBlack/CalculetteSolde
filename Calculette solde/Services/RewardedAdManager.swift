import GoogleMobileAds
import SwiftUI
import UIKit

@MainActor
final class RewardedAdManager: NSObject, ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var isAdReady = false
    @Published var errorMessage: String?

    private var rewardedAd: RewardedAd?
    private var onReward: (() -> Void)?
    private var didEarnReward = false

    private var adUnitID: String {
        #if DEBUG
        "ca-app-pub-3940256099942544/1712485313"
        #else
        "ca-app-pub-8777271534976494/8893346914"
        #endif
    }

    func loadAdIfNeeded() {
        guard rewardedAd == nil, !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let ad = try await RewardedAd.load(with: adUnitID, request: Request())
                ad.fullScreenContentDelegate = self
                rewardedAd = ad
                isAdReady = true
            } catch {
                rewardedAd = nil
                isAdReady = false
                errorMessage = "Pub indisponible pour le moment."
            }

            isLoading = false
        }
    }

    func presentAd(onReward: @escaping () -> Void) {
        guard let rewardedAd else {
            loadAdIfNeeded()
            errorMessage = "La pub est encore en chargement."
            return
        }

        guard let rootViewController = UIViewController.visibleRootViewController else {
            errorMessage = "Impossible d’afficher la pub pour le moment."
            return
        }

        self.rewardedAd = nil
        isAdReady = false
        self.onReward = onReward
        didEarnReward = false

        rewardedAd.present(from: rootViewController) { [weak self] in
            Task { @MainActor in
                self?.didEarnReward = true
            }
        }
    }
}

extension RewardedAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        if didEarnReward {
            onReward?()
        }

        didEarnReward = false
        onReward = nil
        loadAdIfNeeded()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        didEarnReward = false
        onReward = nil
        errorMessage = "Impossible d’afficher la pub."
        loadAdIfNeeded()
    }
}


private extension UIViewController {
    static var visibleRootViewController: UIViewController? {
        let rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController

        return rootViewController?.visibleViewController
    }

    var visibleViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.visibleViewController
        }

        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.visibleViewController ?? navigationController
        }

        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController ?? tabBarController
        }

        return self
    }
}
