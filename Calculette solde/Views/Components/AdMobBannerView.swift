import GoogleMobileAds
import SwiftUI

struct AdMobBannerView: View {
    private var adUnitID: String {
        #if DEBUG
        "ca-app-pub-3940256099942544/2435281174"
        #else
        "ca-app-pub-8777271534976494/4295688911"
        #endif
    }

    var body: some View {
        BannerViewContainer(adUnitID: adUnitID)
            .frame(width: 320, height: 50)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        .accessibilityHidden(true)
    }
}

private struct BannerViewContainer: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIViewController.visibleRootViewController
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ bannerView: BannerView, context: Context) {
        bannerView.rootViewController = UIViewController.visibleRootViewController
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
