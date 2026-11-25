import Foundation
import SwiftData

@Model
final class Cart {

    @Attribute(.unique) var id: UUID
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CartItem.cart)
    var items: [CartItem] = []

    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotalInCents: Int {
        items.reduce(0) { $0 + $1.totalPriceInCents }
    }

    var subtotal: Decimal {
        Decimal(subtotalInCents) / 100
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    init(
        id: UUID = UUID(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.createdAt = createdAt
    }
}
