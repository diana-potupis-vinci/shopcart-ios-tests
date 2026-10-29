import XCTest

/// Натискає елемент; якщо XCUITest вважає його недоступним (isHittable == false),
/// виводить дерево елементів у журнал і натискає за координатами центру елемента.
@MainActor
func tapSafely(_ element: XCUIElement) {
    if element.isHittable {
        element.tap()
    } else {
        print("Елемент не hittable, ієрархія:\n\(XCUIApplication().debugDescription)")
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
}

/// Page Object: екран входу
@MainActor
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
@MainActor
final class ShopScreen {
    private let app: XCUIApplication
    init(_ app: XCUIApplication) { self.app = app }

    func addButton(_ productID: Int) -> XCUIElement { app.buttons["add_\(productID)"] }
    var totalLabel: XCUIElement { app.staticTexts["totalLabel"] }
    var promoField: XCUIElement { app.textFields["promoField"] }
    var applyPromoButton: XCUIElement { app.buttons["applyPromoButton"] }
    var promoMessage: XCUIElement { app.staticTexts["promoMessage"] }

    func applyPromo(_ code: String) {
        tapSafely(promoField)
        promoField.typeText(code + "\n")      // Return ховає клавіатуру
        _ = applyPromoButton.waitForExistence(timeout: 5)
        tapSafely(applyPromoButton)
    }
}
