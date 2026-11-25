import SwiftUI
import UIKit

struct CartItemRow: View {

    let item: CartItem

    let onDecrease: () -> Void
    let onIncrease: () -> Void
    let onRemove: () -> Void

    // MARK: - Computed Properties

    private var product: Product {
        item.product
    }

    private var hasInsufficientStock: Bool {
        item.quantity > product.stock
    }

    private var isOutOfStock: Bool {
        product.stock == 0
    }

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            HStack(
                alignment: .top,
                spacing: AppTheme.Spacing.md
            ) {

                productImage

                productInformation

                Spacer(minLength: 0)

                removeButton
            }

            if hasInsufficientStock {

                stockWarning
            }

            Divider()

            quantityAndPrice
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
                hasInsufficientStock
                ? AppTheme.Colors.danger.opacity(0.5)
                : AppTheme.Colors.border.opacity(0.15),
                lineWidth: 1
            )
        }
    }

    // MARK: - Product Image

    private var productImage: some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: AppTheme.Radius.medium
            )
            .fill(AppTheme.Colors.surface)

            if let image = UIImage(
                named: product.imageName
            ) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(6)

            } else {

                Image(
                    systemName: product.category?.icon
                        ?? AppConstants.Resources.placeholderProductImage
                )
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(
                    AppTheme.Colors.primary.opacity(0.7)
                )
            }
        }
        .frame(
            width: AppTheme.Layout.cartImageSize,
            height: AppTheme.Layout.cartImageSize
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.medium
            )
        )
        .accessibilityHidden(true)
    }

    // MARK: - Product Information

    private var productInformation: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.xs
        ) {

            Text(product.category?.name ?? "Other")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(product.name)
                .font(.headline)
                .lineLimit(2)

            HStack(spacing: 4) {

                PriceLabel(
                    priceInCents: product.priceInCents,
                    font: .subheadline,
                    color: .secondary
                )

                Text("each")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            availabilityLabel
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Availability

    private var availabilityLabel: some View {

        Label(
            isOutOfStock
            ? "Out of Stock"
            : "\(product.stock) available",
            systemImage: isOutOfStock
            ? "xmark.circle"
            : "checkmark.circle"
        )
        .font(.caption2)
        .foregroundStyle(
            isOutOfStock
            ? AppTheme.Colors.danger
            : AppTheme.Colors.success
        )
    }

    // MARK: - Stock Warning

    private var stockWarning: some View {

        Label(
            isOutOfStock
            ? "This product is no longer available."
            : "Only \(product.stock) units are available. Please adjust your quantity.",
            systemImage: "exclamationmark.triangle.fill"
        )
        .font(.caption)
        .foregroundStyle(AppTheme.Colors.danger)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(AppTheme.Spacing.sm)
        .background(
            AppTheme.Colors.danger.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.small
            )
        )
    }

    // MARK: - Quantity and Price

    private var quantityAndPrice: some View {

        HStack {

            QuantityStepper(
                quantity: item.quantity,
                minimum: 1,
                maximum: product.stock,
                onDecrease: onDecrease,
                onIncrease: onIncrease
            )

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: 4
            ) {

                Text("Total")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                PriceLabel(
                    priceInCents: item.totalPriceInCents,
                    font: .title3.bold()
                )
            }
        }
    }

    // MARK: - Remove Button

    private var removeButton: some View {

        Button(
            role: .destructive,
            action: onRemove
        ) {

            Image(systemName: "trash")
                .font(.system(size: 16))
                .foregroundStyle(
                    AppTheme.Colors.danger
                )
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "Remove \(product.name) from cart"
        )
    }
}
