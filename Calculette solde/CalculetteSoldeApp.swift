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
        }
    }
}
