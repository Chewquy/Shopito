import Foundation
import SwiftData

@Model
final class Product {

    @Attribute(.unique) var id: UUID
    var name: String
    var productDescription: String
    var priceInCents: Int
    var stock: Int
    var imageName: String
    var category: ProductCategory?

    @Relationship(deleteRule: .cascade, inverse: \CartItem.product)
    var cartItems: [CartItem] = []

    var price: Decimal {
        Decimal(priceInCents) / 100
    }

    var isInStock: Bool {
        stock > 0
    }

    init(
        id: UUID = UUID(),
        name: String,
        productDescription: String,
        priceInCents: Int,
        stock: Int,
        imageName: String,
        category: ProductCategory? = nil
    ) {
        self.id = id
        self.name = name
        self.productDescription = productDescription
        self.priceInCents = priceInCents
        self.stock = stock
        self.imageName = imageName
        self.category = category
    }
}
