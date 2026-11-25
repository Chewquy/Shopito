import Foundation
import SwiftData

@Model
final class ProductCategory {

    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String

    @Relationship(deleteRule: .nullify, inverse: \Product.category)
    var products: [Product] = []

    init(
        id: UUID = UUID(),
        name: String,
        icon: String
    ) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}
