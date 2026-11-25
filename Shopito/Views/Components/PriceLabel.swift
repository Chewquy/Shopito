import SwiftUI

struct PriceLabel: View {

    let priceInCents: Int

    var originalPriceInCents: Int? = nil
    var font: Font = AppTheme.Typography.price
    var color: Color = AppTheme.Colors.primary

    private var hasDiscount: Bool {

        guard let originalPriceInCents else {
            return false
        }

        return originalPriceInCents > priceInCents
    }

    var body: some View {

        HStack(
            alignment: .firstTextBaseline,
            spacing: AppTheme.Spacing.sm
        ) {

            Text(
                CurrencyFormatter.format(
                    cents: priceInCents
                )
            )
            .font(font)
            .foregroundStyle(color)
            .monospacedDigit()

            if hasDiscount,
               let originalPriceInCents {

                Text(
                    CurrencyFormatter.format(
                        cents: originalPriceInCents
                    )
                )
                .font(.caption)
                .foregroundStyle(
                    AppTheme.Colors.secondaryText
                )
                .strikethrough()
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview {

    VStack(alignment: .leading, spacing: 20) {

        PriceLabel(priceInCents: 7999)

        PriceLabel(
            priceInCents: 2499,
            originalPriceInCents: 3499
        )

        PriceLabel(
            priceInCents: 19083,
            font: .largeTitle.bold()
        )

        PriceLabel(
            priceInCents: 1299,
            font: .body,
            color: .primary
        )
    }
    .padding()
}
