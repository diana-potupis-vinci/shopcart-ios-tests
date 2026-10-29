import Foundation

enum CartError: Error, Equatable {
    case invalidQuantity
    case itemNotFound
}

enum PromoCode: Equatable {
    case percent(Decimal)   // наприклад, 0.10 для знижки 10 %
    case freeShipping
}

struct Cart {
    static let maxQuantity = 99
    static let freeShippingThreshold: Decimal = 1000
    static let shippingFee: Decimal = 50

    private(set) var items: [CartItem] = []
    private(set) var discountRate: Decimal = 0
    private(set) var hasFreeShippingPromo = false

    var subtotal: Decimal { items.reduce(0) { $0 + $1.lineTotal } }
    var discount: Decimal { (subtotal * discountRate).rounded(2) }

    var shipping: Decimal {
        if items.isEmpty || hasFreeShippingPromo { return 0 }
        return subtotal >= Cart.freeShippingThreshold ? 0 : Cart.shippingFee
    }

    var total: Decimal { subtotal - discount + shipping }

    mutating func add(_ product: Product, quantity: Int = 1) throws {
        guard quantity > 0 else { throw CartError.invalidQuantity }
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            let newQuantity = items[index].quantity + quantity
            guard newQuantity <= Cart.maxQuantity else { throw CartError.invalidQuantity }
            items[index].quantity = newQuantity
        } else {
            guard quantity <= Cart.maxQuantity else { throw CartError.invalidQuantity }
            items.append(CartItem(product: product, quantity: quantity))
        }
    }

    mutating func remove(productID: Int) throws {
        guard let index = items.firstIndex(where: { $0.product.id == productID }) else {
            throw CartError.itemNotFound
        }
        items.remove(at: index)
    }

    mutating func apply(_ promo: PromoCode) {
        switch promo {
        case .percent(let rate): discountRate = rate
        case .freeShipping: hasFreeShippingPromo = true
        }
    }
}
