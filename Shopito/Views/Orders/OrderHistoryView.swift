import SwiftUI

struct OrderHistoryView: View {

    @Bindable var viewModel: OrderHistoryViewModel

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.lg
            ) {

                statisticsSection

                spendingChartLink

                statusFilters

                orderHeader

                orderContent
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.groupedBackground)
        .navigationTitle("My Orders")
        .searchable(
            text: $viewModel.searchText,
            prompt: "Search orders or products"
        )
        .navigationDestination(for: Order.self) { order in

            OrderDetailView(
                order: order,
                viewModel: viewModel
            )
        }
        .refreshable {
            viewModel.refresh()
        }
        .onAppear {
            viewModel.loadOrders()
        }
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {

                Button {
                    viewModel.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .accessibilityLabel("Refresh orders")
            }
        }
    }

    // MARK: - Statistics

    private var statisticsSection: some View {

        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: AppTheme.Spacing.md
        ) {

            statisticCard(
                title: "Total Spending",
                value: CurrencyFormatter.format(
                    cents: viewModel.totalSpendingInCents
                ),
                icon: "wallet.bifold"
            )

            statisticCard(
                title: "Total Orders",
                value: "\(viewModel.totalOrderCount)",
                icon: "bag.fill"
            )

            statisticCard(
                title: "Active Orders",
                value: "\(viewModel.activeOrderCount)",
                icon: "clock"
            )

            statisticCard(
                title: "Completed",
                value: "\(viewModel.completedOrderCount)",
                icon: "checkmark.seal"
            )
        }
    }

    private func statisticCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppTheme.Colors.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.Colors.primary)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
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

    // MARK: - Spending Chart Navigation

    private var spendingChartLink: some View {

        NavigationLink {

            SpendingChartView(
                viewModel: viewModel
            )

        } label: {

            HStack(spacing: AppTheme.Spacing.md) {

                Image(systemName: "chart.bar.xaxis")
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.primary)

                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.xs
                ) {

                    Text("Spending Statistics")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("Explore your shopping activity")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.background)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.large
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Status Filters

    private var statusFilters: some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(spacing: AppTheme.Spacing.sm) {

                filterButton(
                    title: "All",
                    status: nil
                )

                ForEach(OrderStatus.allCases) { status in

                    filterButton(
                        title: status.title,
                        status: status
                    )
                }
            }
        }
    }

    private func filterButton(
        title: String,
        status: OrderStatus?
    ) -> some View {

        let isSelected =
            viewModel.selectedStatus == status

        return Button {

            withAnimation(AppTheme.Motion.standard) {
                viewModel.selectStatus(status)
            }

        } label: {

            Text(title)
                .font(.subheadline.weight(.medium))
                .fixedSize()
                .foregroundStyle(
                    isSelected
                    ? Color.white
                    : Color.primary
                )
                .padding(.horizontal, 16)
                .frame(minHeight: 44)
                .background(
                    isSelected
                    ? AppTheme.Colors.primary
                    : AppTheme.Colors.background
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(
            isSelected ? .isSelected : []
        )
    }

    // MARK: - Order Header

    private var orderHeader: some View {

        SectionHeaderView(
            title: "Purchase History",
            subtitle: "\(viewModel.filteredOrders.count) order(s) found",
            actionTitle: viewModel.selectedStatus != nil
                || !viewModel.searchText.isEmpty
                ? "Reset"
                : nil,
            action: {
                viewModel.resetFilters()
            }
        )
    }

    // MARK: - Order Content

    @ViewBuilder
    private var orderContent: some View {

        if viewModel.isLoading {

            LoadingView(
                message: "Loading orders..."
            )

        } else if let error = viewModel.errorMessage {

            ErrorStateView(
                title: "Unable to Load Orders",
                message: error,
                onRetry: {
                    viewModel.loadOrders()
                }
            )

        } else if viewModel.orders.isEmpty {

            EmptyStateView(
                icon: "receipt",
                title: "No Orders Yet",
                message: "Your purchases will appear here after completing checkout."
            )

        } else if viewModel.filteredOrders.isEmpty {

            EmptyStateView(
                icon: "magnifyingglass",
                title: "No Matching Orders",
                message: "Try changing your search or clearing your filters.",
                actionTitle: "Clear Filters",
                action: {
                    viewModel.resetFilters()
                }
            )

        } else {

            LazyVStack(
                spacing: AppTheme.Spacing.md
            ) {

                ForEach(
                    viewModel.filteredOrders,
                    id: \.id
                ) { order in

                    NavigationLink(value: order) {

                        OrderRowView(order: order)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
