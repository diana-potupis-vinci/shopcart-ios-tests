import XCTest

/// Page Object: екран входу
final class LoginScreen {
    private let app: XCUIApplication
    init(_ app: XCUIApplication) { self.app = app }

    var emailField: XCUIElement { app.textFields["emailField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var errorLabel: XCUIElement { app.staticTexts["loginError"] }

    func login(email: String, password: String) {
        emailField.tap()
        emailField.typeText(email)
        passwordField.tap()
        passwordField.typeText(password)
        loginButton.tap()
    }
}

/// Page Object: екран магазину та кошика
final class ShopScreen {
    private let app: XCUIApplication
    init(_ app: XCUIApplication) { self.app = app }

    func addButton(_ productID: Int) -> XCUIElement { app.buttons["add_\(productID)"] }
    var totalLabel: XCUIElement { app.staticTexts["totalLabel"] }
    var promoField: XCUIElement { app.textFields["promoField"] }
    var applyPromoButton: XCUIElement { app.buttons["applyPromoButton"] }
    var promoMessage: XCUIElement { app.staticTexts["promoMessage"] }

    func applyPromo(_ code: String) {
        promoField.tap()
        promoField.typeText(code)
        applyPromoButton.tap()
    }
}
