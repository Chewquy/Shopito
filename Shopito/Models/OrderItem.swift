import Foundation
import SwiftData

@Model
final class OrderItem {

    @Attribute(.unique) var id: UUID

    // Product snapshot
    var productId: UUID
    var productName: String
    var productImageName: String
    var unitPriceInCents: Int

    var quantity: Int
    var order: Order?

    var unitPrice: Decimal {
        Decimal(unitPriceInCents) / 100
    }

    var totalPriceInCents: Int {
        unitPriceInCents * quantity
    }

    var totalPrice: Decimal {
        Decimal(totalPriceInCents) / 100
    }

    init(
        id: UUID = UUID(),
        productId: UUID,
        productName: String,
        productImageName: String,
        unitPriceInCents: Int,
        quantity: Int,
        order: Order? = nil
    ) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.productImageName = productImageName
        self.unitPriceInCents = unitPriceInCents
        self.quantity = quantity
        self.order = order
    }

    convenience init(
        cartItem: CartItem,
        order: Order? = nil
    ) {
        self.init(
            productId: cartItem.product.id,
            productName: cartItem.product.name,
            productImageName: cartItem.product.imageName,
            unitPriceInCents: cartItem.product.priceInCents,
            quantity: cartItem.quantity,
            order: order
        )
    }
}
