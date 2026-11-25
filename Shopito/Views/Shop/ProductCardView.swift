import SwiftUI
import UIKit

struct ProductCardView: View {

    let product: Product
    let canAddToCart: Bool
    let onAddToCart: () -> Void

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {

            NavigationLink(value: product) {

                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.sm
                ) {

                    productImage

                    Text(product.category?.name ?? "Other")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(product.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .frame(
                            minHeight: 44,
                            alignment: .topLeading
                        )

                    stockLabel
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            HStack {

                PriceLabel(
                    priceInCents: product.priceInCents,
                    font: .headline
                )

                Spacer(minLength: 4)

                addToCartButton
            }
        }
        .padding(AppTheme.Spacing.sm)
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
                    .padding(8)

            } else {

                Image(
                    systemName: product.category?.icon
                        ?? AppConstants.Resources.placeholderProductImage
                )
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(
                    AppTheme.Colors.primary.opacity(0.7)
                )
            }
        }
        .frame(height: AppTheme.Layout.productImageHeight)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.medium
            )
        )
        .accessibilityHidden(true)
    }

    // MARK: - Stock Label

    private var stockLabel: some View {

        HStack(spacing: 4) {

            Circle()
                .fill(
                    product.isInStock
                    ? AppTheme.Colors.success
                    : AppTheme.Colors.danger
                )
                .frame(width: 7, height: 7)

            Text(
                product.isInStock
                ? "In Stock"
                : "Out of Stock"
            )
            .font(.caption2)
            .foregroundStyle(
                product.isInStock
                ? AppTheme.Colors.success
                : AppTheme.Colors.danger
            )
        }
    }

    // MARK: - Add to Cart

    private var addToCartButton: some View {

        Button(action: onAddToCart) {

            Image(systemName: "plus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    canAddToCart
                    ? AppTheme.Colors.primary
                    : Color.gray
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppTheme.Radius.medium
                    )
                )
        }
        .buttonStyle(.plain)
        .disabled(!canAddToCart)
        .accessibilityLabel(
            "Add \(product.name) to cart"
        )
    }
}
