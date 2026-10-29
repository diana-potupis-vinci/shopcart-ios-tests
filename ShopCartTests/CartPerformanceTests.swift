import XCTest
@testable import ShopCart

final class CartPerformanceTests: XCTestCase {
    func testLargeCartTotalPerformance() {
        measure {
            var cart = Cart()
            for id in 1...99 {
                try? cart.add(Product(id: id, name: "Товар \(id)", price: 10), quantity: 5)
            }
            _ = cart.total
        }
    }
}
