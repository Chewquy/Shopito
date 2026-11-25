import Foundation
import SwiftData

@MainActor
final class CheckoutService: CheckoutServiceProtocol {

    private let context: ModelContext
    private let cartRepository: CartRepository
    private let pricingService: any PricingServiceProtocol

    // MARK: - Initialization

    init(
        context: ModelContext,
        pricingService: any PricingServiceProtocol
    ) {
        self.context = context
        self.cartRepository = CartRepository(
            context: context
        )
        self.pricingService = pricingService
    }

    // MARK: - Checkout

    func placeOrder(
        request: CheckoutRequest
    ) throws -> Order {

        try validateRequest(request)
        try cartRepository.validateCart()

        guard let cart = try cartRepository.fetchCart(),
              !cart.items.isEmpty else {

            throw CheckoutServiceError.emptyCart
        }

        let cartItems = Array(cart.items)

        // Validate combined quantities for each product.

        var requestedQuantities: [UUID: Int] = [:]

        for item in cartItems {

            requestedQuantities[
                item.product.id,
                default: 0
            ] += item.quantity
        }

        for item in cartItems {

            let requestedQuantity =
                requestedQuantities[item.product.id] ?? 0

            guard requestedQuantity <= item.product.stock else {

                throw CheckoutServiceError.insufficientStock(
                    productName: item.product.name
                )
            }
        }

        // Calculate final pricing.

        let pricing = pricingService.calculate(
            subtotalInCents: cart.subtotalInCents,
            fulfillmentMethod: request.fulfillmentMethod
        )

        do {

            // Create the order.

            let order = Order(
                customerName: request.customerName,
                customerEmail: request.customerEmail,
                deliveryAddress: request.fulfillmentMethod == .delivery
                    ? request.deliveryAddress
                    : nil,
                pickupStoreName: request.fulfillmentMethod == .pickup
                    ? request.pickupStore?.name
                    : nil,
                pickupStoreAddress: request.fulfillmentMethod == .pickup
                    ? request.pickupStore?.address
                    : nil,
                fulfillmentMethod: request.fulfillmentMethod,
                status: .confirmed,
                subtotalInCents: pricing.subtotalInCents,
                gstInCents: pricing.gstInCents,
                qstInCents: pricing.qstInCents,
                deliveryFeeInCents: pricing.deliveryFeeInCents
            )

            context.insert(order)

            // Create order item snapshots.

            for cartItem in cartItems {

                let orderItem = OrderItem(
                    cartItem: cartItem,
                    order: order
                )

                context.insert(orderItem)

                // Reduce available inventory.

                cartItem.product.stock -= cartItem.quantity
            }

            // Remove purchased items from the cart.

            for cartItem in cartItems {
                context.delete(cartItem)
            }

            // Save the entire purchase together.

            try context.save()

            return order

        } catch {

            // Undo unsaved changes if checkout fails.

            context.rollback()

            throw error
        }
    }

    // MARK: - Request Validation

    private func validateRequest(
        _ request: CheckoutRequest
    ) throws {

        guard InputValidator.isValidName(
            request.customerName
        ) else {

            throw CheckoutServiceError.invalidCustomerName
        }

        guard InputValidator.isValidEmail(
            request.customerEmail
        ) else {

            throw CheckoutServiceError.invalidEmail
        }

        switch request.fulfillmentMethod {

        case .delivery:

            guard let address = request.deliveryAddress,
                  InputValidator.isNotEmpty(address) else {

                throw CheckoutServiceError.invalidDeliveryAddress
            }

        case .pickup:

            guard request.pickupStore != nil else {

                throw CheckoutServiceError.missingPickupStore
            }
        }
    }
}

// MARK: - Checkout Errors

enum CheckoutServiceError: LocalizedError {

    case emptyCart
    case invalidCustomerName
    case invalidEmail
    case invalidDeliveryAddress
    case missingPickupStore
    case insufficientStock(productName: String)

    var errorDescription: String? {

        switch self {

        case .emptyCart:
            return "Your shopping cart is empty."

        case .invalidCustomerName:
            return "Please enter a valid customer name."

        case .invalidEmail:
            return "Please enter a valid email address."

        case .invalidDeliveryAddress:
            return "Please enter a valid delivery address."

        case .missingPickupStore:
            return "Please select a pickup location."

        case .insufficientStock(let productName):
            return "There is not enough stock for \(productName)."
        }
    }
}
