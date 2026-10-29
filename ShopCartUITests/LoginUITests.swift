import XCTest

@MainActor
final class LoginUITests: BaseUITestCase {

    func testInvalidEmailShowsError() {
        let login = LoginScreen(app)
        login.login(email: "not-an-email", password: "Passw0rd1")
        XCTAssertTrue(login.errorLabel.waitForExistence(timeout: 3))
        XCTAssertEqual(login.errorLabel.label, "Некоректний email")
    }

    func testWeakPasswordShowsError() {
        let login = LoginScreen(app)
        login.login(email: "user@example.com", password: "short")
        XCTAssertTrue(login.errorLabel.waitForExistence(timeout: 3))
    }

    func testSuccessfulLoginOpensShop() {
        logIn()
        XCTAssertTrue(ShopScreen(app).addButton(1).waitForExistence(timeout: 5))
    }
}
