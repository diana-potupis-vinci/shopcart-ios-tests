import Foundation

@MainActor
final class CartViewModel: ObservableObject {
    @Published private(set) var cart = Cart()
    @Published private(set) var promoMessage = ""

    private let promoService: PromoServiceProtocol

    init(promoService: PromoServiceProtocol = PromoService()) {
        self.promoService = promoService
    }

    func add(_ product: Product) {
        _ = try? cart.add(product)
    }

    func applyPromo(_ code: String) async {
        do {
            let promo = try await promoService.validate(code: code)
            cart.apply(promo)
            promoMessage = "Промокод застосовано"
        } catch PromoError.unknownCode {
            promoMessage = "Невірний промокод"
        } catch {
            promoMessage = "Помилка мережі"
        }
    }
}
