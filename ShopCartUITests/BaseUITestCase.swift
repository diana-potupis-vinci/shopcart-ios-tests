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
        // iOS може показати системне вікно "Save Password?", яке перекриває екран
        let notNow = app.buttons["Not Now"]
        if notNow.waitForExistence(timeout: 4) { notNow.tap() }
        // Дочекатися зникнення клавіатури, щоб вона не перекривала елементи екрана магазину
        let noKeyboard = XCTNSPredicateExpectation(predicate: NSPredicate(format: "count == 0"),
                                                   object: app.keyboards)
        _ = XCTWaiter().wait(for: [noKeyboard], timeout: 5)
    }
}
