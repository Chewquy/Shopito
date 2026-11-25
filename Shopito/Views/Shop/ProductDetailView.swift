import SwiftUI
import UIKit

struct ProductDetailView: View {

    let product: Product
    let cartViewModel: CartViewModel

    @State private var quantity = 1
    @State private var showSuccess = false
    @State private var showError = false

    // MARK: - Computed Properties

    private var remainingStock: Int {

        cartViewModel.remainingStock(
            for: product
        )
    }

    private var canAddToCart: Bool {

        quantity > 0
        && quantity <= remainingStock
    }

    private var totalPriceInCents: Int {

        product.priceInCents * quantity
    }

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.lg
            ) {

                productImage

                productInformation

                Divider()

                descriptionSection

                Divider()

                quantitySection
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            purchaseSection
        }
        .alert(
            "Added to Cart",
            isPresented: $showSuccess
        ) {

            Button("Continue Shopping", role: .cancel) {
                cartViewModel.clearMessages()
            }

        } message: {

            Text(
                "\(quantity) × \(product.name) added successfully."
            )
        }
        .alert(
            "Unable to add product",
            isPresented: $showError
        ) {

            Button("OK", role: .cancel) {
                cartViewModel.clearMessages()
            }

        } message: {

            Text(
                cartViewModel.errorMessage
                ?? "An unexpected error occurred."
            )
        }
        .onChange(of: remainingStock) { _, newValue in

            if quantity > newValue {
                quantity = max(1, newValue)
            }
        }
    }

    // MARK: - Product Image

    private var productImage: some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: AppTheme.Radius.extraLarge
            )
            .fill(AppTheme.Colors.surface)

            if let image = UIImage(
                named: product.imageName
            ) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(AppTheme.Spacing.md)

            } else {

                Image(
                    systemName: product.category?.icon
                        ?? AppConstants.Resources.placeholderProductImage
                )
                .font(.system(size: 100, weight: .light))
                .foregroundStyle(
                    AppTheme.Colors.primary.opacity(0.7)
                )
            }
        }
        .frame(
            height: AppTheme.Layout.productDetailImageHeight
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.extraLarge
            )
        )
        .accessibilityHidden(true)
    }

    // MARK: - Product Information

    private var productInformation: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {

            if let category = product.category {

                Label(
                    category.name,
                    systemImage: category.icon
                )
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.primary)
            }

            Text(product.name)
                .font(AppTheme.Typography.largeTitle)

            PriceLabel(
                priceInCents: product.priceInCents,
                font: .title.bold()
            )

            Label(
                product.isInStock
                ? "\(product.stock) items available"
                : "Currently out of stock",
                systemImage: product.isInStock
                ? "checkmark.circle.fill"
                : "xmark.circle.fill"
            )
            .font(.subheadline)
            .foregroundStyle(
                product.isInStock
                ? AppTheme.Colors.success
                : AppTheme.Colors.danger
            )
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {

            SectionHeaderView(
                title: "Description"
            )

            Text(product.productDescription)
                .font(AppTheme.Typography.body)
                .foregroundStyle(.secondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
    }

    // MARK: - Quantity Selection

    private var quantitySection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Quantity"
            )

            HStack {

                QuantityStepper(
                    quantity: quantity,
                    minimum: 1,
                    maximum: remainingStock,
                    onDecrease: {
                        quantity -= 1
                    },
                    onIncrease: {
                        quantity += 1
                    }
                )
                .disabled(remainingStock == 0)

                Spacer()

                Text(
                    "\(remainingStock) more available"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            let quantityInCart =
                cartViewModel.quantityInCart(for: product)

            if quantityInCart > 0 {

                Label(
                    "\(quantityInCart) already in your cart",
                    systemImage: "cart.fill"
                )
                .font(.subheadline)
                .foregroundStyle(AppTheme.Colors.primary)
            }
        }
    }

    // MARK: - Purchase Section

    private var purchaseSection: some View {

        VStack(spacing: AppTheme.Spacing.md) {

            HStack {

                VStack(alignment: .leading, spacing: 4) {

                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    PriceLabel(
                        priceInCents: totalPriceInCents,
                        font: .title2.bold()
                    )
                }

                Spacer()

                Text("\(quantity) item(s)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            PrimaryButton(
                title: buttonTitle,
                icon: "cart.badge.plus",
                isDisabled: !canAddToCart,
                action: addToCart
            )
        }
        .padding(AppTheme.Spacing.md)
        .background(.regularMaterial)
    }

    private var buttonTitle: String {

        if !product.isInStock {
            return "Out of Stock"
        }

        if remainingStock == 0 {
            return "Maximum Stock in Cart"
        }

        return "Add to Cart"
    }

    // MARK: - Cart Action

    private func addToCart() {

        guard canAddToCart else {
            return
        }

        cartViewModel.addProduct(
            product,
            quantity: quantity
        )

        if cartViewModel.errorMessage != nil {

            showError = true

        } else {

            showSuccess = true
        }
    }
}
