import Foundation

@MainActor
final class PricingService: PricingServiceProtocol {

    // MARK: - Tax Rates

    private let gstRate = AppConstants.Pricing.gstRate
    private let qstRate = AppConstants.Pricing.qstRate

    // MARK: - Pricing

    func calculate(
        subtotalInCents: Int,
        fulfillmentMethod: FulfillmentMethod
    ) -> CheckoutPriceSummary {

        let subtotal = max(0, subtotalInCents)

        let deliveryFee = subtotal > 0
            ? fulfillmentMethod.deliveryFeeInCents
            : 0

        let taxableAmount = subtotal + deliveryFee

        let gst = calculateTax(
            amountInCents: taxableAmount,
            rate: gstRate
        )

        let qst = calculateTax(
            amountInCents: taxableAmount,
            rate: qstRate
        )

        return CheckoutPriceSummary(
            subtotalInCents: subtotal,
            gstInCents: gst,
            qstInCents: qst,
            deliveryFeeInCents: deliveryFee
        )
    }

    // MARK: - Private Helpers

    private func calculateTax(
        amountInCents: Int,
        rate: Decimal
    ) -> Int {

        var amount = Decimal(amountInCents) * rate
        var roundedAmount = Decimal()

        NSDecimalRound(
            &roundedAmount,
            &amount,
            0,
            .plain
        )

        return NSDecimalNumber(
            decimal: roundedAmount
        ).intValue
    }
}
