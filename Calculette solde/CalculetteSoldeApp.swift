import GoogleMobileAds
import SwiftUI

@main
struct CalculetteSoldeApp: App {
    init() {
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
