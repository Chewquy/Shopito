import Foundation
import SwiftData

@MainActor
final class CartRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Read

    func fetchCart() throws -> Cart? {

        var descriptor = FetchDescriptor<Cart>(
            sortBy: [
                SortDescriptor(\Cart.createdAt)
            ]
        )

        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first
    }

    func getOrCreateCart() throws -> Cart {

        if let existingCart = try fetchCart() {
            return existingCart
        }

        let cart = Cart()

        context.insert(cart)
        try save()

        return cart
    }

    func fetchCartItems() throws -> [CartItem] {

        guard let cart = try fetchCart() else {
            return []
        }

        return cart.items.sorted {
            $0.addedAt < $1.addedAt
        }
    }

    func findCartItem(
        for product: Product,
        in cart: Cart
    ) -> CartItem? {

        return cart.items.first {
            $0.product.id == product.id
        }
    }

    // MARK: - Create

    @discardableResult
    func addProduct(
        _ product: Product,
        quantity: Int = 1
    ) throws -> CartItem {

        guard quantity > 0 else {
            throw CartRepositoryError.invalidQuantity
        }

        guard product.stock > 0 else {
            throw CartRepositoryError.outOfStock
        }

        let cart = try getOrCreateCart()

        // Update quantity if the product is already
        // present in the cart.

        if let existingItem = findCartItem(
            for: product,
            in: cart
        ) {

            guard quantity <= product.stock
                    - existingItem.quantity else {
                throw CartRepositoryError.insufficientStock
            }

            let newQuantity = existingItem.quantity + quantity

            try updateQuantity(
                for: existingItem,
                quantity: newQuantity
            )

            return existingItem
        }

        guard quantity <= product.stock else {
            throw CartRepositoryError.insufficientStock
        }

        let cartItem = CartItem(
            product: product,
            quantity: quantity,
            cart: cart
        )

        context.insert(cartItem)

        try save()

        return cartItem
    }

    // MARK: - Update

    func updateQuantity(
        for item: CartItem,
        quantity: Int
    ) throws {

        guard quantity > 0 else {
            throw CartRepositoryError.invalidQuantity
        }

        guard InputValidator.isValidQuantity(
            quantity,
            availableStock: item.product.stock
        ) else {

            throw CartRepositoryError.insufficientStock
        }

        item.quantity = quantity

        try save()
    }

    func increaseQuantity(
        for item: CartItem
    ) throws {

        guard item.quantity < item.product.stock else {
            throw CartRepositoryError.insufficientStock
        }

        try updateQuantity(
            for: item,
            quantity: item.quantity + 1
        )
    }

    func decreaseQuantity(
        for item: CartItem
    ) throws {

        if item.quantity <= 1 {
            try removeItem(item)
        } else {
            try updateQuantity(
                for: item,
                quantity: item.quantity - 1
            )
        }
    }

    // MARK: - Delete

    func removeItem(_ item: CartItem) throws {

        context.delete(item)

        try save()
    }

    func clearCart() throws {

        guard let cart = try fetchCart() else {
            return
        }

        let items = Array(cart.items)

        for item in items {
            context.delete(item)
        }

        try save()
    }

    // MARK: - Validation

    func validateCart() throws {

        guard let cart = try fetchCart(),
              !cart.items.isEmpty else {

            throw CartRepositoryError.emptyCart
        }

        for item in cart.items {

            guard item.quantity > 0 else {
                throw CartRepositoryError.invalidQuantity
            }

            guard item.product.stock > 0 else {
                throw CartRepositoryError.outOfStock
            }

            guard item.quantity <= item.product.stock else {
                throw CartRepositoryError.insufficientStock
            }
        }
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

enum CartRepositoryError: LocalizedError {

    case invalidQuantity
    case outOfStock
    case insufficientStock
    case emptyCart

    var errorDescription: String? {

        switch self {

        case .invalidQuantity:
            return "The quantity must be greater than zero."

        case .outOfStock:
            return "This product is currently out of stock."

        case .insufficientStock:
            return "There is not enough stock available."

        case .emptyCart:
            return "Your shopping cart is empty."
        }
    }
}
