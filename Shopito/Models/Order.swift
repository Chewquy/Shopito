import Foundation
import SwiftData

@Model
final class Order {

    @Attribute(.unique) var id: UUID
    var createdAt: Date

    // Customer information
    var customerName: String
    var customerEmail: String
    var deliveryAddress: String?

    // Pickup information
    var pickupStoreName: String?
    var pickupStoreAddress: String?

    // Order information
    var fulfillmentMethod: FulfillmentMethod
    var status: OrderStatus

    // Pricing
    var subtotalInCents: Int
    var gstInCents: Int
    var qstInCents: Int
    var deliveryFeeInCents: Int

    @Relationship(deleteRule: .cascade, inverse: \OrderItem.order)
    var items: [OrderItem] = []

    var totalInCents: Int {
        subtotalInCents
        + gstInCents
        + qstInCents
        + deliveryFeeInCents
    }

    var total: Decimal {
        Decimal(totalInCents) / 100
    }

    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var orderNumber: String {

        String(
            id.uuidString.prefix(
                AppConstants.Orders.orderNumberLength
            )
        )
        .uppercased()
    }

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        customerName: String,
        customerEmail: String,
        deliveryAddress: String? = nil,
        pickupStoreName: String? = nil,
        pickupStoreAddress: String? = nil,
        fulfillmentMethod: FulfillmentMethod,
        status: OrderStatus = .confirmed,
        subtotalInCents: Int,
        gstInCents: Int,
        qstInCents: Int,
        deliveryFeeInCents: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.deliveryAddress = deliveryAddress
        self.pickupStoreName = pickupStoreName
        self.pickupStoreAddress = pickupStoreAddress
        self.fulfillmentMethod = fulfillmentMethod
        self.status = status
        self.subtotalInCents = subtotalInCents
        self.gstInCents = gstInCents
        self.qstInCents = qstInCents
        self.deliveryFeeInCents = deliveryFeeInCents
    }
}
