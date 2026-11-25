import SwiftUI

struct CartSummaryView: View {

    let subtotalInCents: Int
    let totalQuantity: Int
    let canCheckout: Bool
    let onCheckout: () -> Void

    private let pricingService = PricingService()

    // MARK: - Estimated Pricing

    private var priceSummary: CheckoutPriceSummary {

        pricingService.calculate(
            subtotalInCents: subtotalInCents,
            fulfillmentMethod: .pickup
        )
    }

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Order Summary",
                subtitle: "\(totalQuantity) item(s)",
                icon: "receipt"
            )

            Divider()

            pricingDetails

            Divider()

            totalSection

            deliveryInformation

            if !canCheckout {
                checkoutWarning
            }

            PrimaryButton(
                title: "Proceed to Checkout",
                icon: "arrow.right",
                isDisabled: !canCheckout,
                action: onCheckout
            )

            securityInformation
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.large
            )
        )
        .overlay {

            RoundedRectangle(
                cornerRadius: AppTheme.Radius.large
            )
            .strokeBorder(
                AppTheme.Colors.border.opacity(0.15),
                lineWidth: 1
            )
        }
    }

    // MARK: - Pricing Details

    private var pricingDetails: some View {

        VStack(spacing: AppTheme.Spacing.md) {

            priceRow(
                title: "Subtotal",
                amountInCents: priceSummary.subtotalInCents
            )

            priceRow(
                title: "GST (\(gstPercentage))",
                amountInCents: priceSummary.gstInCents
            )

            priceRow(
                title: "QST (\(qstPercentage))",
                amountInCents: priceSummary.qstInCents
            )
        }
    }

    // MARK: - Tax Formatting

    private var gstPercentage: String {

        CurrencyFormatter.formatPercentage(
            AppConstants.Pricing.gstRate
        )
    }

    private var qstPercentage: String {

        CurrencyFormatter.formatPercentage(
            AppConstants.Pricing.qstRate
        )
    }

    // MARK: - Price Row

    private func priceRow(
        title: String,
        amountInCents: Int
    ) -> some View {

        HStack {

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            PriceLabel(
                priceInCents: amountInCents,
                font: .subheadline.weight(.medium),
                color: .primary
            )
        }
    }

    // MARK: - Estimated Total

    private var totalSection: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("Estimated Total")
                    .font(.headline)

                Text("Including taxes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            PriceLabel(
                priceInCents: priceSummary.totalInCents,
                font: .title2.bold()
            )
        }
    }

    // MARK: - Delivery Information

    private var deliveryInformation: some View {

        Label(
            "Delivery fees will be calculated at checkout. In-store pickup is free.",
            systemImage: "truck.box"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .fixedSize(
            horizontal: false,
            vertical: true
        )
    }

    // MARK: - Checkout Warning

    private var checkoutWarning: some View {

        Label(
            "Please resolve unavailable products or invalid quantities before checkout.",
            systemImage: "exclamationmark.triangle"
        )
        .font(.caption)
        .foregroundStyle(AppTheme.Colors.danger)
        .padding(AppTheme.Spacing.sm)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            AppTheme.Colors.danger.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.small
            )
        )
    }

    // MARK: - Security Information

    private var securityInformation: some View {

        HStack {

            Image(systemName: "info.circle")

            Text(AppConstants.Disclaimer.payment)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Preview

#Preview {

    ScrollView {

        CartSummaryView(
            subtotalInCents: 15998,
            totalQuantity: 2,
            canCheckout: true,
            onCheckout: {}
        )
        .padding()
    }
    .background(AppTheme.Colors.groupedBackground)
}
