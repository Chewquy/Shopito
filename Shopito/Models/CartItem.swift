import Foundation
import SwiftData

@Model
final class CartItem {

    @Attribute(.unique) var id: UUID
    var quantity: Int
    var addedAt: Date

    var product: Product
    var cart: Cart?

    var totalPriceInCents: Int {
        product.priceInCents * quantity
    }

    var totalPrice: Decimal {
        Decimal(totalPriceInCents) / 100
    }

    init(
        id: UUID = UUID(),
        product: Product,
        quantity: Int = 1,
        cart: Cart? = nil,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.product = product
        self.quantity = quantity
        self.cart = cart
        self.addedAt = addedAt
    }
}
