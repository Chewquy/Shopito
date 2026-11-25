import Foundation
import SwiftData

@MainActor
final class OrderRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Read

    func fetchAllOrders() throws -> [Order] {

        let descriptor = FetchDescriptor<Order>(
            sortBy: [
                SortDescriptor(
                    \Order.createdAt,
                    order: .reverse
                )
            ]
        )

        return try context.fetch(descriptor)
    }

    func fetchOrder(by id: UUID) throws -> Order? {

        var descriptor = FetchDescriptor<Order>(
            predicate: #Predicate<Order> { order in
                order.id == id
            }
        )

        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first
    }

    func fetchOrders(
        byStatus status: OrderStatus
    ) throws -> [Order] {

        let orders = try fetchAllOrders()

        return orders.filter {
            $0.status == status
        }
    }

    func fetchOrders(
        from startDate: Date,
        to endDate: Date
    ) throws -> [Order] {

        let descriptor = FetchDescriptor<Order>(
            predicate: #Predicate<Order> { order in
                order.createdAt >= startDate &&
                order.createdAt < endDate
            },
            sortBy: [
                SortDescriptor(
                    \Order.createdAt,
                    order: .reverse
                )
            ]
        )

        return try context.fetch(descriptor)
    }

    // MARK: - Create

    func addOrder(_ order: Order) throws {

        guard !order.items.isEmpty else {
            throw OrderRepositoryError.emptyOrder
        }

        context.insert(order)

        try save()
    }

    // MARK: - Update

    func updateStatus(
        for order: Order,
        status: OrderStatus
    ) throws {

        if order.status == status {
            return
        }

        guard isValidTransition(
            for: order,
            to: status
        ) else {
            throw OrderRepositoryError.invalidStatusTransition
        }

        order.status = status

        try save()
    }

    // MARK: - Delete

    func deleteOrder(_ order: Order) throws {

        guard order.status.isFinal else {
            throw OrderRepositoryError.orderNotFinal
        }

        context.delete(order)

        try save()
    }

    // MARK: - Status Validation

    private func isValidTransition(
        for order: Order,
        to newStatus: OrderStatus
    ) -> Bool {

        if order.status.isFinal {
            return false
        }

        switch (order.status, newStatus) {

        case (.confirmed, .processing):
            return true

        case (.processing, .shipped):
            return order.fulfillmentMethod == .delivery

        case (.processing, .readyForPickup):
            return order.fulfillmentMethod == .pickup

        case (.shipped, .completed):
            return true

        case (.readyForPickup, .completed):
            return true

        default:
            return false
        }
    }

    // MARK: - Save

    private func save() throws {

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}

// MARK: - Repository Errors

enum OrderRepositoryError: LocalizedError {

    case emptyOrder
    case invalidStatusTransition
    case orderNotFinal

    var errorDescription: String? {

        switch self {

        case .emptyOrder:
            return "An order must contain at least one item."

        case .invalidStatusTransition:
            return "This order status change is not allowed."

        case .orderNotFinal:
            return "An active order cannot be deleted."
        }
    }
}
