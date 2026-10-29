import XCTest
@testable import ShopCart

final class MockPromoService: PromoServiceProtocol {
    var result: Result<PromoCode, Error> = .success(.freeShipping)
    private(set) var receivedCodes: [String] = []

    func validate(code: String) async throws -> PromoCode {
        receivedCodes.append(code)
        return try result.get()
    }
}

@MainActor
final class CartViewModelTests: XCTestCase {
    private let headphones = Product(id: 1, name: "Навушники", price: 1200)

    func testValidPromoUpdatesCartAndMessage() async {
        let mock = MockPromoService()
        mock.result = .success(.percent(Decimal(10) / 100))
        let viewModel = CartViewModel(promoService: mock)
        viewModel.add(headphones)

        await viewModel.applyPromo("SAVE10")

        XCTAssertEqual(viewModel.cart.total, 1080)
        XCTAssertEqual(viewModel.promoMessage, "Промокод застосовано")
        XCTAssertEqual(mock.receivedCodes, ["SAVE10"])
    }

    func testUnknownPromoShowsError() async {
        let mock = MockPromoService()
        mock.result = .failure(PromoError.unknownCode)
        let viewModel = CartViewModel(promoService: mock)

        await viewModel.applyPromo("BAD")

        XCTAssertEqual(viewModel.promoMessage, "Невірний промокод")
    }

    func testNetworkFailureShowsGenericError() async {
        let mock = MockPromoService()
        mock.result = .failure(PromoError.network)
        let viewModel = CartViewModel(promoService: mock)

        await viewModel.applyPromo("SAVE10")

        XCTAssertEqual(viewModel.promoMessage, "Помилка мережі")
    }
}
