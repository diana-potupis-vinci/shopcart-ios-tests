import XCTest

@MainActor
final class ShopUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        logIn()
    }

    func testAddProductUpdatesTotal() {
        let shop = ShopScreen(app)
        XCTAssertTrue(shop.addButton(2).waitForExistence(timeout: 8))
        tapSafely(shop.addButton(2))                       // кабель 80 + доставка 50
        XCTAssertEqual(shop.totalLabel.label, "Разом: 130.00 ₴")
    }

    func testPromoSave10AppliesDiscount() {
        let shop = ShopScreen(app)
        XCTAssertTrue(shop.addButton(1).waitForExistence(timeout: 8))
        tapSafely(shop.addButton(1))                       // навушники 1200
        shop.applyPromo("SAVE10")
        XCTAssertTrue(shop.promoMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(shop.totalLabel.label, "Разом: 1080.00 ₴")
    }

    func testUnknownPromoShowsError() {
        let shop = ShopScreen(app)
        XCTAssertTrue(shop.promoField.waitForExistence(timeout: 8))
        shop.applyPromo("WRONG")
        XCTAssertTrue(shop.promoMessage.waitForExistence(timeout: 3))
        XCTAssertEqual(shop.promoMessage.label, "Невірний промокод")
    }
}
