import SwiftUI
import Charts

struct SpendingChartView: View {

    let viewModel: OrderHistoryViewModel

    @State private var chartMode: ChartMode = .spending

    private enum ChartMode: String, CaseIterable, Identifiable {

        case spending = "Spending"
        case orders = "Orders"

        var id: String {
            rawValue
        }
    }

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.lg
            ) {

                overviewSection

                statisticsGrid

                chartSection

                monthlyBreakdown

                disclaimer
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.groupedBackground)
        .navigationTitle("Spending Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadOrders()
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - Overview

    private var overviewSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {

            Label(
                "Your Shopping Activity",
                systemImage: "chart.bar.xaxis"
            )
            .font(.headline)
            .foregroundStyle(.white.opacity(0.9))

            Text(
                CurrencyFormatter.format(
                    cents: viewModel.totalSpendingInCents
                )
            )
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .monospacedDigit()

            Text("Total recorded spending")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
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

    // MARK: - Statistics Grid

    private var statisticsGrid: some View {

        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: AppTheme.Spacing.md
        ) {

            statisticCard(
                title: "Total Orders",
                value: "\(viewModel.totalOrderCount)",
                icon: "bag"
            )

            statisticCard(
                title: "Average Order",
                value: CurrencyFormatter.format(
                    cents: viewModel.averageOrderValueInCents
                ),
                icon: "chart.line.uptrend.xyaxis"
            )

            statisticCard(
                title: "Products Purchased",
                value: "\(viewModel.totalProductsPurchased)",
                icon: "shippingbox"
            )

            statisticCard(
                title: "Completed Orders",
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
                .foregroundStyle(
                    AppTheme.Colors.primary
                )

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2.bold())
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
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

    // MARK: - Chart Section

    private var chartSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Monthly Activity",
                subtitle: "Last \(AppConstants.Orders.spendingHistoryMonths) months",
                icon: "chart.bar"
            )

            Picker(
                "Chart Type",
                selection: $chartMode
            ) {

                ForEach(ChartMode.allCases) { mode in

                    Text(mode.rawValue)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if viewModel.isLoading {

                LoadingView(
                    message: "Loading statistics..."
                )

            } else if let error = viewModel.errorMessage {

                ErrorStateView(
                    title: "Unable to Load Statistics",
                    message: error,
                    onRetry: {
                        viewModel.refresh()
                    }
                )

            } else if !hasChartData {

                EmptyStateView(
                    icon: "chart.bar",
                    title: "No Recent Activity",
                    message: "Complete a purchase to start tracking your monthly shopping activity."
                )

            } else {

                switch chartMode {

                case .spending:
                    spendingChart

                case .orders:
                    orderCountChart
                }
            }
        }
        .modifier(SpendingCardStyle())
    }

    private var hasChartData: Bool {

        viewModel.monthlySpending.contains {
            $0.orderCount > 0
        }
    }

    // MARK: - Spending Chart

    private var spendingChart: some View {

        Chart(viewModel.monthlySpending) { entry in

            BarMark(
                x: .value(
                    "Month",
                    entry.month,
                    unit: .month
                ),
                y: .value(
                    "Spending",
                    entry.total
                )
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        AppTheme.Colors.secondary,
                        AppTheme.Colors.primary
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(5)
            .accessibilityLabel(
                entry.month.formatted(
                    .dateTime.month(.wide).year()
                )
            )
            .accessibilityValue(
                CurrencyFormatter.format(
                    cents: entry.totalInCents
                )
            )
        }
        .chartXAxis {

            AxisMarks(values: .stride(by: .month)) {

                AxisGridLine()

                AxisValueLabel(
                    format: .dateTime.month(.abbreviated)
                )
            }
        }
        .chartYAxis {

            AxisMarks(position: .leading) { value in

                AxisGridLine()

                AxisValueLabel {

                    if let amount = value.as(Double.self) {

                        Text(
                            amount.formatted(
                                .currency(
                                    code: AppConstants.currencyCode
                                )
                                .precision(.fractionLength(0))
                            )
                        )
                        .font(.caption2)
                    }
                }
            }
        }
        .chartYScale(domain: 0...spendingUpperBound)
        .frame(height: 240)
        .padding(.top, AppTheme.Spacing.sm)
    }

    private var spendingUpperBound: Double {

        let maximum = viewModel.monthlySpending
            .map(\.total)
            .max() ?? 0

        return max(10, maximum * 1.2)
    }

    // MARK: - Order Count Chart

    private var orderCountChart: some View {

        Chart(viewModel.monthlySpending) { entry in

            BarMark(
                x: .value(
                    "Month",
                    entry.month,
                    unit: .month
                ),
                y: .value(
                    "Orders",
                    entry.orderCount
                )
            )
            .foregroundStyle(AppTheme.Colors.secondary)
            .cornerRadius(5)
            .accessibilityLabel(
                entry.month.formatted(
                    .dateTime.month(.wide).year()
                )
            )
            .accessibilityValue(
                "\(entry.orderCount) orders"
            )
        }
        .chartXAxis {

            AxisMarks(values: .stride(by: .month)) {

                AxisGridLine()

                AxisValueLabel(
                    format: .dateTime.month(.abbreviated)
                )
            }
        }
        .chartYAxis {
            AxisMarks(
                position: .leading,
                values: Array(
                    stride(
                        from: 0,
                        through: orderUpperBound,
                        by: orderAxisStep
                    )
                )
            ) { value in

                AxisGridLine()

                AxisValueLabel {
                    if let count = value.as(Int.self) {
                        Text("\(count)")
                    }
                }
            }
        }
        .chartYScale(domain: 0...orderUpperBound)
        .frame(height: 240)
        .padding(.top, AppTheme.Spacing.sm)
    }

    private var orderUpperBound: Int {

        let maximum = viewModel.monthlySpending
            .map(\.orderCount)
            .max() ?? 0

        return max(4, maximum + 1)
    }

    private var orderAxisStep: Int {
        max(1, orderUpperBound / 4)
    }

    // MARK: - Monthly Breakdown

    private var monthlyBreakdown: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Monthly Breakdown",
                icon: "calendar"
            )

            ForEach(
                Array(
                    viewModel.monthlySpending.reversed()
                )
            ) { entry in

                monthlyRow(entry)

                Divider()
            }
        }
        .modifier(SpendingCardStyle())
    }

    private func monthlyRow(
        _ entry: MonthlySpending
    ) -> some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {

                Text(
                    entry.month.formatted(
                        .dateTime.month(.wide).year()
                    )
                )
                .font(.subheadline.weight(.medium))

                Text("\(entry.orderCount) order(s)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            PriceLabel(
                priceInCents: entry.totalInCents,
                font: .headline
            )
        }
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {

        Label(
            "Statistics are based on saved, non-cancelled simulated purchases. Deleted orders are not included.",
            systemImage: "info.circle"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .modifier(SpendingCardStyle())
    }
}

// MARK: - Card Styling

private struct SpendingCardStyle: ViewModifier {

    func body(content: Content) -> some View {

        content
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
}
