import XCTest

@MainActor
final class ShopUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        logIn()
    }

    func testAddProductUpdatesTotal() {
        let shop = ShopScreen(app)
        XCTAssertTrue(waitUntilHittable(shop.addButton(2)))
        shop.addButton(2).tap()                       // кабель 80 + доставка 50
        XCTAssertEqual(shop.totalLabel.label, "Разом: 130.00 ₴")
    }

    func testPromoSave10AppliesDiscount() {
        let shop = ShopScreen(app)
        XCTAssertTrue(waitUntilHittable(shop.addButton(1)))
        shop.addButton(1).tap()                       // навушники 1200
        shop.applyPromo("SAVE10")
        XCTAssertTrue(shop.promoMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(shop.totalLabel.label, "Разом: 1080.00 ₴")
    }

    func testUnknownPromoShowsError() {
        let shop = ShopScreen(app)
        XCTAssertTrue(waitUntilHittable(shop.promoField))
        shop.applyPromo("WRONG")
        XCTAssertTrue(shop.promoMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(shop.promoMessage.label, "Невірний промокод")
    }
}
