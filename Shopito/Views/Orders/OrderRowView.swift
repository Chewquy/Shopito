import SwiftUI

struct OrderRowView: View {

    let order: Order

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            orderHeader

            Divider()

            orderInformation

            if !order.items.isEmpty {

                productSummary
            }

            Divider()

            orderFooter
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
                AppTheme.Colors.border.opacity(0.15),
                lineWidth: 1
            )
        }
    }

    // MARK: - Header

    private var orderHeader: some View {

        HStack(alignment: .top) {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {

                Text("Order #\(order.orderNumber)")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(
                    order.createdAt.formatted(
                        date: .abbreviated,
                        time: .omitted
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            OrderStatusBadge(
                status: order.status
            )
        }
    }

    // MARK: - Order Information

    private var orderInformation: some View {

        HStack {

            Label(
                order.fulfillmentMethod.title,
                systemImage: order.fulfillmentMethod.icon
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer()

            Text("\(order.totalQuantity) item(s)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Product Summary

    private var productSummary: some View {

        let sortedItems = order.items.sorted {
            $0.productName < $1.productName
        }

        return VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.xs
        ) {

            ForEach(
                Array(sortedItems.prefix(2)),
                id: \.id
            ) { item in

                Text(
                    "\(item.quantity) × \(item.productName)"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            if sortedItems.count > 2 {

                Text(
                    "+ \(sortedItems.count - 2) more product(s)"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Footer

    private var orderFooter: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {

                Text("Order Total")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                PriceLabel(
                    priceInCents: order.totalInCents,
                    font: .title3.bold()
                )
            }

            Spacer()

            Label(
                "View Details",
                systemImage: "chevron.right"
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.Colors.primary)
        }
    }
}

// MARK: - Reusable Order Status Badge

struct OrderStatusBadge: View {

    let status: OrderStatus

    private var statusColor: Color {

        switch status {

        case .confirmed:
            return AppTheme.Colors.primary

        case .processing:
            return AppTheme.Colors.warning

        case .shipped:
            return .blue

        case .readyForPickup:
            return .teal

        case .completed:
            return AppTheme.Colors.success

        case .cancelled:
            return AppTheme.Colors.danger
        }
    }

    var body: some View {

        Label(
            status.title,
            systemImage: status.icon
        )
        .font(.caption2.weight(.semibold))
        .foregroundStyle(statusColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            statusColor.opacity(0.12)
        )
        .clipShape(Capsule())
        .accessibilityLabel(
            "Order status: \(status.title)"
        )
    }
}
