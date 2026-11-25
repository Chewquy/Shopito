import Foundation

enum CurrencyFormatter {

    // MARK: - Format Cents

    static func format(cents: Int) -> String {

        let amount = Decimal(cents) / 100

        return format(amount: amount)
    }

    // MARK: - Format Decimal

    static func format(amount: Decimal) -> String {

        amount.formatted(
            .currency(code: AppConstants.currencyCode)
            .locale(
                Locale(
                    identifier: AppConstants.localeIdentifier
                )
            )
        )
    }

    // MARK: - Format Double

    static func format(amount: Double) -> String {

        amount.formatted(
            .currency(code: AppConstants.currencyCode)
            .locale(
                Locale(
                    identifier: AppConstants.localeIdentifier
                )
            )
        )
    }

    // MARK: - Format Percentage

    static func formatPercentage(
        _ rate: Decimal
    ) -> String {

        rate.formatted(
            .percent
            .precision(
                .fractionLength(0...3)
            )
            .locale(
                Locale(
                    identifier: AppConstants.localeIdentifier
                )
            )
        )
    }
}
