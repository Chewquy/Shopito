import Foundation
import Observation

// MARK: - Service Contracts

struct CheckoutPriceSummary {

    let subtotalInCents: Int
    let gstInCents: Int
    let qstInCents: Int
    let deliveryFeeInCents: Int

    var totalInCents: Int {
        subtotalInCents
        + gstInCents
        + qstInCents
        + deliveryFeeInCents
    }

    var total: Decimal {
        Decimal(totalInCents) / 100
    }
}

struct CheckoutRequest {

    let customerName: String
    let customerEmail: String
    let deliveryAddress: String?
    let fulfillmentMethod: FulfillmentMethod
    let pickupStore: StoreLocation?
}

@MainActor
protocol PricingServiceProtocol {

    func calculate(
        subtotalInCents: Int,
        fulfillmentMethod: FulfillmentMethod
    ) -> CheckoutPriceSummary
}

@MainActor
protocol CheckoutServiceProtocol {

    func placeOrder(
        request: CheckoutRequest
    ) throws -> Order
}

// MARK: - ViewModel

@Observable
@MainActor
final class CheckoutViewModel {

    private let cartViewModel: CartViewModel
    private let pricingService: any PricingServiceProtocol
    private let checkoutService: any CheckoutServiceProtocol

    // MARK: - Customer Information

    var customerName: String = ""
    var customerEmail: String = ""
    var streetAddress: String = ""
    var city: String = ""
    var postalCode: String = ""
    
    // MARK: - Checkout Validation

    var isFulfillmentValid: Bool {

        switch fulfillmentMethod {

        case .delivery:
            return isAddressValid

        case .pickup:
            return selectedStore != nil
        }
    }

    var isFormValid: Bool {

        isNameValid
            && isEmailValid
            && isFulfillmentValid
    }

    var canPlaceOrder: Bool {

        isFormValid
            && cartViewModel.canCheckout
            && !isProcessing
            && completedOrder == nil
    }
    // MARK: - Fulfillment

    var fulfillmentMethod: FulfillmentMethod = .delivery
    var selectedStore: StoreLocation?

    // MARK: - State

    private(set) var isProcessing = false
    private(set) var completedOrder: Order?

    var errorMessage: String?
    var showOrderConfirmation = false

    // MARK: - Initialization

    init(
        cartViewModel: CartViewModel,
        pricingService: any PricingServiceProtocol,
        checkoutService: any CheckoutServiceProtocol
    ) {
        self.cartViewModel = cartViewModel
        self.pricingService = pricingService
        self.checkoutService = checkoutService
    }

    // MARK: - Pricing

    var priceSummary: CheckoutPriceSummary {

        pricingService.calculate(
            subtotalInCents: cartViewModel.subtotalInCents,
            fulfillmentMethod: fulfillmentMethod
        )
    }

    var subtotalInCents: Int {
        priceSummary.subtotalInCents
    }

    var gstInCents: Int {
        priceSummary.gstInCents
    }

    var qstInCents: Int {
        priceSummary.qstInCents
    }

    var deliveryFeeInCents: Int {
        priceSummary.deliveryFeeInCents
    }

    var totalInCents: Int {
        priceSummary.totalInCents
    }

    var total: Decimal {
        priceSummary.total
    }

    var totalQuantity: Int {
        cartViewModel.totalQuantity
    }

    // MARK: - Customer Validation

    var isNameValid: Bool {

        InputValidator.isValidName(customerName)
    }

    var isEmailValid: Bool {

        InputValidator.isValidEmail(customerEmail)
    }

    var isPostalCodeValid: Bool {

        InputValidator.isValidPostalCode(postalCode)
    }

    var isAddressValid: Bool {

        InputValidator.isValidAddress(
            streetAddress: streetAddress,
            city: city,
            postalCode: postalCode
        )
    }

    var formattedDeliveryAddress: String {

        InputValidator.formatAddress(
            streetAddress: streetAddress,
            city: city,
            postalCode: postalCode
        )
    }

    // MARK: - Fulfillment Actions

    func selectFulfillmentMethod(
        _ method: FulfillmentMethod
    ) {
        fulfillmentMethod = method
    }

    func selectStore(_ store: StoreLocation) {
        selectedStore = store
    }

    // MARK: - Checkout

    func placeOrder() {

        guard !isProcessing,
              completedOrder == nil else {
            return
        }

        errorMessage = nil

        guard validateForm() else {
            return
        }

        guard cartViewModel.validateCart() else {

            errorMessage = cartViewModel.errorMessage
                ?? "Your cart is invalid."

            return
        }

        isProcessing = true

        defer {
            isProcessing = false
        }

        let request = CheckoutRequest(
            customerName: trimmed(customerName),
            customerEmail: trimmed(customerEmail),
            deliveryAddress: fulfillmentMethod == .delivery
                ? formattedDeliveryAddress
                : nil,
            fulfillmentMethod: fulfillmentMethod,
            pickupStore: fulfillmentMethod == .pickup
                ? selectedStore
                : nil
        )

        do {

            let order = try checkoutService.placeOrder(
                request: request
            )

            completedOrder = order

            cartViewModel.loadCart()

            showOrderConfirmation = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Form Validation

    @discardableResult
    func validateForm() -> Bool {

        errorMessage = nil

        guard isNameValid else {
            errorMessage = "Please enter your name."
            return false
        }

        guard isEmailValid else {
            errorMessage = "Please enter a valid email address."
            return false
        }

        switch fulfillmentMethod {

        case .delivery:

            guard isAddressValid else {
                errorMessage = "Please enter a valid delivery address and Canadian postal code."
                return false
            }

        case .pickup:

            guard selectedStore != nil else {
                errorMessage = "Please select a pickup store."
                return false
            }
        }

        return true
    }

    // MARK: - Reset

    func resetCheckout() {

        customerName = ""
        customerEmail = ""
        streetAddress = ""
        city = ""
        postalCode = ""

        fulfillmentMethod = .delivery
        fulfillmentMethod = .delivery
        selectedStore = nil

        completedOrder = nil
        showOrderConfirmation = false
        errorMessage = nil
    }

    // MARK: - Helpers

    private func trimmed(_ value: String) -> String {

        InputValidator.trimmed(value)
    }
}
