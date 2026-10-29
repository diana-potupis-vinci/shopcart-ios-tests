import Testing
@testable import ShopCart

@Suite("Валідація введення")
struct ValidatorTests {

    @Test("Коректні email приймаються", arguments: ["user@example.com", "a.b+c@mail.co.ua"])
    func validEmails(_ email: String) {
        #expect(Validators.isValidEmail(email))
    }

    @Test("Некоректні email відхиляються",
          arguments: ["", "user", "user@", "@example.com", "user@example"])
    func invalidEmails(_ email: String) {
        #expect(!Validators.isValidEmail(email))
    }

    @Test("Правила пароля", arguments: [
        ("Passw0rdX", true), ("short1", false), ("onlyletters", false), ("12345678", false)
    ])
    func passwordRules(_ password: String, _ expected: Bool) {
        #expect(Validators.isValidPassword(password) == expected)
    }
}
