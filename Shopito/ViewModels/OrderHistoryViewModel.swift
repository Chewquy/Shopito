import Foundation
import Observation

// MARK: - Chart Data

struct MonthlySpending: Identifiable {

    let month: Date
    let totalInCents: Int
    let orderCount: Int

    var id: Date {
        month
    }

    var total: Double {
        Double(totalInCents) / 100
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class OrderHistoryViewModel {

    private let orderRepository: OrderRepository

    // MARK: - State

    private(set) var orders: [Order] = []
    private(set) var isLoading = false

    var searchText: String = ""
    var selectedStatus: OrderStatus?
    var selectedOrder: Order?
    var errorMessage: String?

    // MARK: - Initialization

    init(orderRepository: OrderRepository) {
        self.orderRepository = orderRepository
    }

    // MARK: - Filtered Orders

    var filteredOrders: [Order] {

        var result = orders

        if let selectedStatus {

            result = result.filter {
                $0.status == selectedStatus
            }
        }

        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !query.isEmpty {

            result = result.filter { order in

                order.orderNumber
                    .localizedCaseInsensitiveContains(query)

                || order.customerName
                    .localizedCaseInsensitiveContains(query)

                || order.items.contains { item in
                    item.productName
                        .localizedCaseInsensitiveContains(query)
                }
            }
        }

        return result.sorted {
            $0.createdAt > $1.createdAt
        }
    }

    // MARK: - Statistics

    var activeOrders: [Order] {

        orders.filter {
            !$0.status.isFinal
        }
    }

    var completedOrders: [Order] {

        orders.filter {
            $0.status == .completed
        }
    }

    var cancelledOrders: [Order] {

        orders.filter {
            $0.status == .cancelled
        }
    }

    var totalOrderCount: Int {
        orders.count
    }

    var activeOrderCount: Int {
        activeOrders.count
    }

    var completedOrderCount: Int {
        completedOrders.count
    }

    var totalSpendingInCents: Int {

        orders.filter {
            $0.status != .cancelled
        }
        .reduce(0) {
            $0 + $1.totalInCents
        }
    }

    var totalSpending: Decimal {
        Decimal(totalSpendingInCents) / 100
    }

    var totalProductsPurchased: Int {

        orders.filter {
            $0.status != .cancelled
        }
        .reduce(0) {
            $0 + $1.totalQuantity
        }
    }

    var averageOrderValueInCents: Int {

        let validOrders = orders.filter {
            $0.status != .cancelled
        }

        guard !validOrders.isEmpty else {
            return 0
        }

        return totalSpendingInCents / validOrders.count
    }

    var averageOrderValue: Decimal {
        Decimal(averageOrderValueInCents) / 100
    }

    // MARK: - Monthly Spending

    var monthlySpending: [MonthlySpending] {

        let calendar = Calendar.current

        guard let currentMonth = calendar.dateInterval(
            of: .month,
            for: Date()
        )?.start else {
            return []
        }

        let validOrders = orders.filter {
            $0.status != .cancelled
        }

        // Display the current month and
        // the previous five months.

        return (0..<AppConstants.Orders.spendingHistoryMonths)
            .reversed()
            .compactMap { offset in

            guard let monthStart = calendar.date(
                byAdding: .month,
                value: -offset,
                to: currentMonth
            ),
            let monthEnd = calendar.date(
                byAdding: .month,
                value: 1,
                to: monthStart
            ) else {
                return nil
            }

            let monthOrders = validOrders.filter {

                $0.createdAt >= monthStart
                && $0.createdAt < monthEnd
            }

            let total = monthOrders.reduce(0) {
                $0 + $1.totalInCents
            }

            return MonthlySpending(
                month: monthStart,
                totalInCents: total,
                orderCount: monthOrders.count
            )
        }
    }

    // MARK: - Data Loading

    func loadOrders() {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            orders = try orderRepository.fetchAllOrders()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() {
        loadOrders()
    }

    // MARK: - Selection

    func selectOrder(_ order: Order) {
        selectedOrder = order
    }

    func selectStatus(_ status: OrderStatus?) {
        selectedStatus = status
    }

    func resetFilters() {
        selectedStatus = nil
        searchText = ""
    }

    // MARK: - Order Management

    func updateOrderStatus(
        _ order: Order,
        to status: OrderStatus
    ) {

        errorMessage = nil

        do {

            try orderRepository.updateStatus(
                for: order,
                status: status
            )

            loadOrders()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func advanceOrderStatus(_ order: Order) {

        switch order.status {

        case .confirmed:
            updateOrderStatus(order, to: .processing)

        case .processing:

            let nextStatus: OrderStatus =
                order.fulfillmentMethod == .delivery
                ? .shipped
                : .readyForPickup

            updateOrderStatus(order, to: nextStatus)

        case .shipped, .readyForPickup:
            updateOrderStatus(order, to: .completed)

        case .completed, .cancelled:
            break
        }
    }

    func deleteOrder(_ order: Order) {

        errorMessage = nil

        do {

            try orderRepository.deleteOrder(order)

            if selectedOrder?.id == order.id {
                selectedOrder = nil
            }

            loadOrders()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
