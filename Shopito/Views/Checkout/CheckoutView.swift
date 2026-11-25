import SwiftUI

struct CheckoutView: View {

    @Environment(\.dismiss) private var dismiss

    @Bindable var viewModel: CheckoutViewModel

    let storeLocatorViewModel: StoreLocatorViewModel

    var onOrderCompleted: () -> Void = {}

    // MARK: - State

    @State private var showPickupStores = false
    @State private var showCancelConfirmation = false

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.lg
            ) {

                checkoutHeader

                CustomerInformationView(
                    viewModel: viewModel
                )

                FulfillmentSelectionView(
                    viewModel: viewModel,
                    onSelectStore: {
                        showPickupStores = true
                    }
                )

                orderSummary

                paymentDisclaimer
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.groupedBackground)
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            ToolbarItem(placement: .cancellationAction) {

                Button("Cancel") {
                    showCancelConfirmation = true
                }
                .disabled(viewModel.isProcessing)
            }
        }
        .safeAreaInset(edge: .bottom) {

            checkoutButton
        }
        .sheet(isPresented: $showPickupStores) {

            PickupStoreSheet(
                viewModel: storeLocatorViewModel,
                selectedStore: viewModel.selectedStore,
                onSelectStore: { store in

                    viewModel.selectStore(store)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(
            isPresented: $viewModel.showOrderConfirmation
        ) {

            if let order = viewModel.completedOrder {

                OrderConfirmationView(
                    order: order,
                    onDone: {

                        viewModel.showOrderConfirmation = false
                        onOrderCompleted()
                        dismiss()
                    }
                )
            }
        }
        .confirmationDialog(
            "Cancel checkout?",
            isPresented: $showCancelConfirmation,
            titleVisibility: .visible
        ) {

            Button(
                "Cancel Checkout",
                role: .destructive
            ) {

                viewModel.resetCheckout()
                dismiss()
            }

            Button(
                "Continue Checkout",
                role: .cancel
            ) {}

        } message: {

            Text(
                "Your cart will be preserved, but your checkout information will be cleared."
            )
        }
        .alert(
            "Checkout Error",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: { presented in

                    if !presented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {

            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }

        } message: {

            Text(viewModel.errorMessage ?? "")
        }
        .interactiveDismissDisabled(
            viewModel.isProcessing
            || viewModel.completedOrder != nil
        )
    }

    // MARK: - Checkout Header

    private var checkoutHeader: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {

            Label(
                "Complete Your Purchase",
                systemImage: "bag.badge.plus"
            )
            .font(AppTheme.Typography.title)
            .foregroundStyle(AppTheme.Colors.primary)

            Text(
                "Enter your information and choose how you would like to receive your order."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                "\(viewModel.totalQuantity) item(s) in your order"
            )
            .font(.caption.weight(.medium))
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.large
            )
        )
    }

    // MARK: - Order Summary

    private var orderSummary: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Order Summary",
                icon: "receipt"
            )

            Divider()

            priceRow(
                title: "Subtotal",
                amountInCents: viewModel.subtotalInCents
            )

            priceRow(
                title: "Delivery Fee",
                amountInCents: viewModel.deliveryFeeInCents
            )

            priceRow(
                title: "GST (\(gstPercentage))",
                amountInCents: viewModel.gstInCents
            )

            priceRow(
                title: "QST (\(qstPercentage))",
                amountInCents: viewModel.qstInCents
            )

            Divider()

            HStack {

                Text("Total")
                    .font(.headline)

                Spacer()

                PriceLabel(
                    priceInCents: viewModel.totalInCents,
                    font: .title2.bold()
                )
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.large
            )
        )
    }

    // MARK: - Price Helpers

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

    private func priceRow(
        title: String,
        amountInCents: Int
    ) -> some View {

        HStack {

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            if title == "Delivery Fee",
               amountInCents == 0 {

                Text("Free")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.Colors.success)

            } else {

                PriceLabel(
                    priceInCents: amountInCents,
                    font: .subheadline.weight(.medium),
                    color: .primary
                )
            }
        }
    }

    // MARK: - Payment Disclaimer

    private var paymentDisclaimer: some View {

        Label(
            AppConstants.Disclaimer.payment,
            systemImage: "info.circle"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(AppTheme.Spacing.md)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(AppTheme.Colors.background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.medium
            )
        )
    }

    // MARK: - Checkout Button

    // MARK: - Checkout Button

    private var checkoutButton: some View {

        VStack(spacing: AppTheme.Spacing.sm) {

            if !viewModel.isFormValid {

                Text(
                    "Complete all required information to continue."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            PrimaryButton(
                title: "Place Order • \(CurrencyFormatter.format(cents: viewModel.totalInCents))",
                icon: "checkmark.circle",
                isDisabled: !viewModel.canPlaceOrder,
                isLoading: viewModel.isProcessing,
                action: {
                    viewModel.placeOrder()
                }
            )
        }
        .padding(AppTheme.Spacing.md)
        .background(.regularMaterial)
    }
}
