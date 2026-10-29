import SwiftUI

@main
struct ShopCartApp: App {
    @State private var isLoggedIn = false

    private var promoService: PromoServiceProtocol {
        CommandLine.arguments.contains("-UITests") ? StubPromoService() : PromoService()
    }

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ShopView(promoService: promoService)
            } else {
                LoginView { isLoggedIn = true }
            }
        }
    }
}
