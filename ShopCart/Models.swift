import Foundation

struct Product: Identifiable, Equatable {
    let id: Int
    let name: String
    let price: Decimal
}

struct CartItem: Equatable {
    let product: Product
    var quantity: Int
    var lineTotal: Decimal { product.price * Decimal(quantity) }
}

extension Decimal {
    /// Округлення до заданої кількості знаків після коми
    func rounded(_ scale: Int) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
}
