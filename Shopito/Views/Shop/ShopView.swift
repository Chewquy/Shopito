import SwiftUI

struct ShopView: View {

    @Bindable var viewModel: ShopViewModel
    let cartViewModel: CartViewModel

    @State private var showFilters = false

    private let columns = [
        GridItem(
            .adaptive(
                minimum: AppTheme.Layout.minimumGridItemWidth
            ),
            spacing: AppTheme.Spacing.md
        )
    ]

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.lg
            ) {

                welcomeSection

                CategoryFilterView(
                    categories: viewModel.categories,
                    selectedCategory: viewModel.selectedCategory,
                    onSelect: { category in
                        viewModel.selectCategory(category)
                    }
                )

                productHeader

                productContent
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.groupedBackground)
        .navigationTitle(AppConstants.appName)
        .searchable(
            text: $viewModel.searchText,
            prompt: "Search products"
        )
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {

                Button {
                    showFilters = true
                } label: {

                    Image(
                        systemName: viewModel.hasActiveFilters
                        ? "slider.horizontal.3"
                        : "line.3.horizontal.decrease.circle"
                    )
                    .foregroundStyle(AppTheme.Colors.primary)
                }
                .accessibilityLabel("Product filters")
            }
        }
        .sheet(isPresented: $showFilters) {

            ProductFilterSheet(
                viewModel: viewModel
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .navigationDestination(for: Product.self) { product in

            ProductDetailView(
                product: product,
                cartViewModel: cartViewModel
            )
        }
        .refreshable {
            viewModel.refresh()
        }
        .onAppear {
            viewModel.loadData()
            cartViewModel.loadCart()
        }
        .alert(
            "Unable to add product",
            isPresented: Binding(
                get: {
                    cartViewModel.errorMessage != nil
                },
                set: { presented in
                    if !presented {
                        cartViewModel.clearMessages()
                    }
                }
            )
        ) {

            Button("OK", role: .cancel) {
                cartViewModel.clearMessages()
            }

        } message: {

            Text(cartViewModel.errorMessage ?? "")
        }
        .safeAreaInset(edge: .bottom) {

            if let message = cartViewModel.successMessage {
                successBanner(message: message)
            }
        }
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {

        VStack(alignment: .leading, spacing: 8) {

            Image(systemName: "bag.fill")
                .font(.system(size: 30))

            Text("Discover your favorites")
                .font(AppTheme.Typography.title)

            Text("Everything you need, in one place.")
                .font(AppTheme.Typography.body)
                .foregroundStyle(.white.opacity(0.9))
        }
        .foregroundStyle(.white)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(AppTheme.Spacing.lg)
        .background {

            LinearGradient(
                colors: [
                    AppTheme.Colors.primary,
                    AppTheme.Colors.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.extraLarge
            )
        )
    }

    // MARK: - Product Header

    private var productHeader: some View {

        SectionHeaderView(
            title: viewModel.selectedCategory?.name
                ?? "Explore Products",
            subtitle: "\(viewModel.productCount) products found",
            actionTitle: viewModel.hasActiveFilters
                ? "Reset"
                : nil,
            action: {
                viewModel.resetFilters()
            }
        )
    }

    // MARK: - Product Content

    @ViewBuilder
    private var productContent: some View {

        if viewModel.isLoading {

            LoadingView(
                message: "Loading products..."
            )

        } else if let error = viewModel.errorMessage {

            ErrorStateView(
                title: "Unable to load products",
                message: error,
                onRetry: {
                    viewModel.loadData()
                }
            )

        } else if viewModel.filteredProducts.isEmpty {

            EmptyStateView(
                icon: "magnifyingglass",
                title: "No products found",
                message: "Try changing your search or clearing your filters.",
                actionTitle: "Clear Filters",
                action: {
                    viewModel.resetFilters()
                }
            )

        } else {

            LazyVGrid(
                columns: columns,
                spacing: AppTheme.Spacing.md
            ) {

                ForEach(
                    viewModel.filteredProducts,
                    id: \.id
                ) { product in

                    ProductCardView(
                        product: product,
                        canAddToCart:
                            cartViewModel.canAddProduct(product),
                        onAddToCart: {

                            cartViewModel.addProduct(product)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Success Banner

    private func successBanner(
        message: String
    ) -> some View {

        HStack(spacing: AppTheme.Spacing.sm) {

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.Colors.success)

            Text(message)
                .font(.subheadline.weight(.medium))

            Spacer()

            Button {
                cartViewModel.clearMessages()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Dismiss message")
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.medium
            )
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
        .task(id: message) {

            do {

                try await Task.sleep(for: .seconds(3))

                cartViewModel.clearMessages()

            } catch {
                // Banner was dismissed or replaced.
            }
        }
    }
}
