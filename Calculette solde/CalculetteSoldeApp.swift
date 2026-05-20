import AppTrackingTransparency
import AdSupport
import GoogleMobileAds
import SwiftUI

@main
struct CalculetteSoldeApp: App {
    @StateObject private var premiumManager = PremiumManager()

    init() {
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(premiumManager)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        requestTrackingAuthorization()
                    }
                }
        }
    }

    private func requestTrackingAuthorization() {
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}
