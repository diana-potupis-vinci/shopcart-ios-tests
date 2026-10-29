import XCTest
@testable import ShopCart

final class CartTests: XCTestCase {
    private var cart: Cart!
    private let headphones = Product(id: 1, name: "Навушники", price: 1200)
    private let cable = Product(id: 2, name: "Кабель USB-C", price: 80)

    override func setUp() {
        super.setUp()
        cart = Cart()
    }

    override func tearDown() {
        cart = nil
        super.tearDown()
    }

    func testEmptyCartHasZeroTotals() {
        XCTAssertEqual(cart.subtotal, 0)
        XCTAssertEqual(cart.shipping, 0)
        XCTAssertEqual(cart.total, 0)
    }

    func testAddProductIncreasesSubtotal() throws {
        try cart.add(cable, quantity: 2)
        XCTAssertEqual(cart.subtotal, 160)
    }

    func testAddingSameProductMergesQuantity() throws {
        try cart.add(cable)
        try cart.add(cable, quantity: 3)
        XCTAssertEqual(cart.items.count, 1)
        XCTAssertEqual(cart.items[0].quantity, 4)
    }

    func testQuantityAboveLimitThrows() {
        XCTAssertThrowsError(try cart.add(cable, quantity: 100)) { error in
            XCTAssertEqual(error as? CartError, .invalidQuantity)
        }
    }

    func testZeroQuantityThrows() {
        XCTAssertThrowsError(try cart.add(cable, quantity: 0)) { error in
            XCTAssertEqual(error as? CartError, .invalidQuantity)
        }
    }

    func testShippingFeeAppliedBelowThreshold() throws {
        try cart.add(cable)
        XCTAssertEqual(cart.shipping, 50)
        XCTAssertEqual(cart.total, 130)
    }

    func testShippingIsFreeAtThreshold() throws {
        try cart.add(Product(id: 8, name: "Товар за 1000", price: 1000))
        XCTAssertEqual(cart.shipping, 0)
    }

    func testShippingAppliedJustBelowThreshold() throws {
        try cart.add(Product(id: 9, name: "Товар за 999", price: 999))
        XCTAssertEqual(cart.shipping, 50)
    }

    func testMaximumQuantityIsAccepted() throws {
        try cart.add(cable, quantity: 99)
        XCTAssertEqual(cart.items[0].quantity, 99)
    }

    func testPercentDiscountIsApplied() throws {
        try cart.add(headphones)
        cart.apply(.percent(Decimal(10) / 100))
        XCTAssertEqual(cart.discount, 120)
        XCTAssertEqual(cart.total, 1080)
    }

    func testFreeShippingPromoRemovesFee() throws {
        try cart.add(cable)
        cart.apply(.freeShipping)
        XCTAssertEqual(cart.total, 80)
    }

    func testRemoveUnknownItemThrows() {
        XCTAssertThrowsError(try cart.remove(productID: 42)) { error in
            XCTAssertEqual(error as? CartError, .itemNotFound)
        }
    }
}
