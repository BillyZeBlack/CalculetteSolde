import GoogleMobileAds
import SwiftUI
import UIKit

@MainActor
final class InterstitialAdManager: NSObject, ObservableObject {
    private let presentationInterval = 3
    private var addedProductCount = 0
    private var interstitialAd: InterstitialAd?
    private var isLoading = false

    private var adUnitID: String {
        #if DEBUG
        "ca-app-pub-3940256099942544/4411468910"
        #else
        "ca-app-pub-8777271534976494/2693726498"
        #endif
    }

    func loadAdIfNeeded() {
        guard interstitialAd == nil, !isLoading else { return }

        isLoading = true
        Task {
            do {
                let ad = try await InterstitialAd.load(with: adUnitID, request: Request())
                ad.fullScreenContentDelegate = self
                interstitialAd = ad
            } catch {
                interstitialAd = nil
            }

            isLoading = false
        }
    }

    func recordAddedProduct() {
        addedProductCount += 1

        guard addedProductCount.isMultiple(of: presentationInterval) else {
            loadAdIfNeeded()
            return
        }

        presentAdIfReady()
    }

    private func presentAdIfReady() {
        guard let interstitialAd else {
            loadAdIfNeeded()
            return
        }

        guard let rootViewController = UIViewController.visibleRootViewController else {
            loadAdIfNeeded()
            return
        }

        self.interstitialAd = nil
        interstitialAd.present(from: rootViewController)
    }
}

extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        loadAdIfNeeded()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
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
