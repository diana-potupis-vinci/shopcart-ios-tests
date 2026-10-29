import XCTest

@MainActor
class BaseUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-UITests"]   // вмикає StubPromoService
        app.launch()
    }

    func logIn() {
        LoginScreen(app).login(email: "user@example.com", password: "Passw0rd1")
    }
}
