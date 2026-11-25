import Foundation
import Observation

@Observable
@MainActor
final class CartViewModel {

    private let cartRepository: CartRepository

    // MARK: - State

    private(set) var cart: Cart?
    private(set) var isLoading = false

    var errorMessage: String?
    var successMessage: String?

    // MARK: - Initialization

    init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
    }

    // MARK: - Computed Properties

    var items: [CartItem] {
        cart?.items.sorted {
            $0.addedAt < $1.addedAt
        } ?? []
    }

    var totalQuantity: Int {
        cart?.totalQuantity ?? 0
    }

    var subtotalInCents: Int {
        cart?.subtotalInCents ?? 0
    }

    var subtotal: Decimal {
        Decimal(subtotalInCents) / 100
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    var canCheckout: Bool {

        !isEmpty && items.allSatisfy {
            $0.quantity > 0
            && $0.quantity <= $0.product.stock
        }
    }

    // MARK: - Data Loading

    func loadCart() {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            cart = try cartRepository.getOrCreateCart()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create

    func addProduct(
        _ product: Product,
        quantity: Int = 1
    ) {

        performCartOperation {

            try cartRepository.addProduct(
                product,
                quantity: quantity
            )

            successMessage = "\(product.name) added to cart."
        }
    }

    // MARK: - Update

    func updateQuantity(
        for item: CartItem,
        quantity: Int
    ) {

        performCartOperation {

            try cartRepository.updateQuantity(
                for: item,
                quantity: quantity
            )
        }
    }

    func increaseQuantity(for item: CartItem) {

        performCartOperation {
            try cartRepository.increaseQuantity(for: item)
        }
    }

    func decreaseQuantity(for item: CartItem) {

        performCartOperation {
            try cartRepository.decreaseQuantity(for: item)
        }
    }

    // MARK: - Delete

    func removeItem(_ item: CartItem) {

        performCartOperation {
            try cartRepository.removeItem(item)
        }
    }

    func clearCart() {

        performCartOperation {
            try cartRepository.clearCart()
        }
    }

    // MARK: - Product Helpers

    func quantityInCart(for product: Product) -> Int {

        items.filter {
            $0.product.id == product.id
        }
        .reduce(0) {
            $0 + $1.quantity
        }
    }

    func remainingStock(for product: Product) -> Int {

        max(
            0,
            product.stock - quantityInCart(for: product)
        )
    }

    func canAddProduct(_ product: Product) -> Bool {
        remainingStock(for: product) > 0
    }

    // MARK: - Validation

    func validateCart() -> Bool {

        errorMessage = nil

        do {
            try cartRepository.validateCart()
            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Private Helpers

    private func performCartOperation(
        _ operation: () throws -> Void
    ) {

        errorMessage = nil
        successMessage = nil

        do {
            try operation()
            cart = try cartRepository.fetchCart()

        } catch {
            errorMessage = error.localizedDescription
            successMessage = nil
        }
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
