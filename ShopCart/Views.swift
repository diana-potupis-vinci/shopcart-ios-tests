import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorText: String?
    var onSuccess: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Вхід").font(.largeTitle)
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("emailField")
            SecureField("Пароль", text: $password)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("passwordField")
            if let errorText {
                Text(errorText)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("loginError")
            }
            Button("Увійти") {
                if !Validators.isValidEmail(email) {
                    errorText = "Некоректний email"
                } else if !Validators.isValidPassword(password) {
                    errorText = "Пароль: мінімум 8 символів, літера й цифра"
                } else {
                    errorText = nil
                    onSuccess()
                }
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("loginButton")
        }
        .padding()
    }
}

struct ShopView: View {
    @StateObject private var viewModel: CartViewModel
    @State private var promoCode = ""
    @FocusState private var promoFocused: Bool

    static let catalog = [
        Product(id: 1, name: "Навушники", price: 1200),
        Product(id: 2, name: "Кабель USB-C", price: 80),
        Product(id: 3, name: "Чохол", price: 350)
    ]

    init(promoService: PromoServiceProtocol) {
        _viewModel = StateObject(wrappedValue: CartViewModel(promoService: promoService))
    }

    private func money(_ value: Decimal) -> String {
        String(format: "%.2f ₴", NSDecimalNumber(decimal: value).doubleValue)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Товари").font(.headline)
                ForEach(ShopView.catalog) { product in
                    HStack {
                        Text("\(product.name) – \(money(product.price))")
                        Spacer()
                        Button("Додати") { viewModel.add(product) }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("add_\(product.id)")
                    }
                }
                Divider()
                Text("Кошик").font(.headline)
                Text("Сума: \(money(viewModel.cart.subtotal))")
                    .accessibilityIdentifier("subtotalLabel")
                Text("Знижка: \(money(viewModel.cart.discount))")
                    .accessibilityIdentifier("discountLabel")
                Text("Доставка: \(money(viewModel.cart.shipping))")
                    .accessibilityIdentifier("shippingLabel")
                Text("Разом: \(money(viewModel.cart.total))")
                    .font(.headline)
                    .accessibilityIdentifier("totalLabel")
                Divider()
                Text("Промокод").font(.headline)
                TextField("Промокод", text: $promoCode)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .focused($promoFocused)
                    .submitLabel(.done)
                    .onSubmit { promoFocused = false }
                    .accessibilityIdentifier("promoField")
                Button("Застосувати") {
                    promoFocused = false
                    Task { await viewModel.applyPromo(promoCode) }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("applyPromoButton")
                if !viewModel.promoMessage.isEmpty {
                    Text(viewModel.promoMessage)
                        .accessibilityIdentifier("promoMessage")
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
    }
}
