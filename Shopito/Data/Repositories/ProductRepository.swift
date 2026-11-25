import Foundation
import SwiftData

@MainActor
final class ProductRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Read

    func fetchAllProducts() throws -> [Product] {

        let descriptor = FetchDescriptor<Product>(
            sortBy: [
                SortDescriptor(\Product.name)
            ]
        )

        return try context.fetch(descriptor)
    }

    func fetchAllCategories() throws -> [ProductCategory] {

        let descriptor = FetchDescriptor<ProductCategory>(
            sortBy: [
                SortDescriptor(\ProductCategory.name)
            ]
        )

        return try context.fetch(descriptor)
    }

    func fetchProduct(by id: UUID) throws -> Product? {

        var descriptor = FetchDescriptor<Product>(
            predicate: #Predicate<Product> { product in
                product.id == id
            }
        )

        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first
    }

    func fetchProducts(
        byCategory category: ProductCategory
    ) throws -> [Product] {

        let products = try fetchAllProducts()

        return products.filter {
            $0.category?.id == category.id
        }
    }

    func fetchAvailableProducts() throws -> [Product] {

        let descriptor = FetchDescriptor<Product>(
            predicate: #Predicate<Product> { product in
                product.stock > 0
            },
            sortBy: [
                SortDescriptor(\Product.name)
            ]
        )

        return try context.fetch(descriptor)
    }

    // MARK: - Create

    func addProduct(_ product: Product) throws {

        context.insert(product)
        try save()
    }

    func addCategory(
        _ category: ProductCategory
    ) throws {

        context.insert(category)
        try save()
    }

    // MARK: - Update

    func updateProduct(
        _ product: Product,
        name: String,
        description: String,
        priceInCents: Int,
        stock: Int,
        imageName: String,
        category: ProductCategory?
    ) throws {

        guard !name.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            throw ProductRepositoryError.invalidName
        }

        guard priceInCents >= 0 else {
            throw ProductRepositoryError.invalidPrice
        }

        guard stock >= 0 else {
            throw ProductRepositoryError.invalidStock
        }

        product.name = name
        product.productDescription = description
        product.priceInCents = priceInCents
        product.stock = stock
        product.imageName = imageName
        product.category = category

        try save()
    }

    func updateStock(
        for product: Product,
        quantity: Int
    ) throws {

        guard quantity >= 0 else {
            throw ProductRepositoryError.invalidStock
        }

        product.stock = quantity

        try save()
    }

    // MARK: - Delete

    func deleteProduct(_ product: Product) throws {

        context.delete(product)
        try save()
    }

    func deleteCategory(
        _ category: ProductCategory
    ) throws {

        context.delete(category)
        try save()
    }

    // MARK: - Save

    private func save() throws {

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

// MARK: - Repository Errors

enum ProductRepositoryError: LocalizedError {

    case invalidName
    case invalidPrice
    case invalidStock

    var errorDescription: String? {

        switch self {

        case .invalidName:
            return "The product name cannot be empty."

        case .invalidPrice:
            return "The product price cannot be negative."

        case .invalidStock:
            return "Product stock cannot be negative."
        }
    }
}
