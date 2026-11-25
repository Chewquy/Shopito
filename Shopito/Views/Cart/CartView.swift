import SwiftUI

struct CartView: View {

    @Bindable var viewModel: CartViewModel

    let onContinueShopping: () -> Void
    let onCheckout: () -> Void

    @State private var showClearConfirmation = false
    @State private var itemToRemove: CartItem?

    // MARK: - Body

    var body: some View {

        Group {

            if viewModel.isLoading {

                LoadingView(
                    message: "Loading your cart..."
                )

            } else if viewModel.cart == nil,
                      let error = viewModel.errorMessage {

                ErrorStateView(
                    title: "Unable to load cart",
                    message: error,
                    onRetry: {
                        viewModel.loadCart()
                    }
                )

            } else if viewModel.isEmpty {

                emptyCartView

            } else {

                cartContent
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(AppTheme.Colors.groupedBackground)
        .navigationTitle("My Cart")
        .toolbar {

            if !viewModel.isEmpty {

                ToolbarItem(placement: .topBarTrailing) {

                    Button(role: .destructive) {

                        showClearConfirmation = true

                    } label: {

                        Label(
                            "Clear Cart",
                            systemImage: "trash"
                        )
                        .foregroundStyle(
                            AppTheme.Colors.danger
                        )
                    }
                }
            }
        }
        .onAppear {

            viewModel.clearMessages()
            viewModel.loadCart()
        }
        .confirmationDialog(
            "Clear your shopping cart?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {

            Button("Clear Cart", role: .destructive) {

                withAnimation(AppTheme.Motion.standard) {
                    viewModel.clearCart()
                }
            }

            Button("Cancel", role: .cancel) {}

        } message: {

            Text("All products will be removed from your cart.")
        }
        .confirmationDialog(
            "Remove product?",
            isPresented: Binding(
                get: {
                    itemToRemove != nil
                },
                set: { presented in

                    if !presented {
                        itemToRemove = nil
                    }
                }
            ),
            titleVisibility: .visible,
            presenting: itemToRemove
        ) { item in

            Button("Remove", role: .destructive) {

                withAnimation(AppTheme.Motion.standard) {
                    viewModel.removeItem(item)
                }

                itemToRemove = nil
            }

            Button("Cancel", role: .cancel) {
                itemToRemove = nil
            }

        } message: { item in

            Text(
                "Remove \(item.product.name) from your cart?"
            )
        }
        .alert(
            "Cart Error",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: { presented in

                    if !presented {
                        viewModel.clearMessages()
                    }
                }
            )
        ) {

            Button("OK", role: .cancel) {
                viewModel.clearMessages()
            }

        } message: {

            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Empty Cart

    private var emptyCartView: some View {

        EmptyStateView(
            icon: "cart",
            title: "Your cart is empty",
            message: "Discover our products and add something you like.",
            actionTitle: "Continue Shopping",
            action: onContinueShopping
        )
    }

    // MARK: - Cart Content

    private var cartContent: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.lg
            ) {

                cartHeader

                cartItemsSection

                CartSummaryView(
                    subtotalInCents: viewModel.subtotalInCents,
                    totalQuantity: viewModel.totalQuantity,
                    canCheckout: viewModel.canCheckout,
                    onCheckout: proceedToCheckout
                )

                continueShoppingButton
            }
            .padding(AppTheme.Spacing.md)
        }
        .refreshable {
            viewModel.loadCart()
        }
    }

    // MARK: - Cart Header

    private var cartHeader: some View {

        SectionHeaderView(
            title: "Shopping Cart",
            subtitle: "\(viewModel.totalQuantity) item(s) in your cart",
            icon: "cart.fill"
        )
    }

    // MARK: - Cart Items

    private var cartItemsSection: some View {

        LazyVStack(spacing: AppTheme.Spacing.md) {

            ForEach(viewModel.items, id: \.id) { item in

                CartItemRow(
                    item: item,
                    onDecrease: {

                        viewModel.decreaseQuantity(
                            for: item
                        )
                    },
                    onIncrease: {

                        viewModel.increaseQuantity(
                            for: item
                        )
                    },
                    onRemove: {

                        itemToRemove = item
                    }
                )
            }
        }
    }

    // MARK: - Continue Shopping

    private var continueShoppingButton: some View {

        Button(action: onContinueShopping) {

            Label(
                "Continue Shopping",
                systemImage: "arrow.left"
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.Colors.primary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Checkout

    private func proceedToCheckout() {

        guard viewModel.validateCart() else {
            return
        }

        onCheckout()
    }
}
