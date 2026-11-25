import SwiftUI
import UIKit

struct OrderDetailView: View {

    @Environment(\.dismiss) private var dismiss

    let order: Order

    @Bindable var viewModel: OrderHistoryViewModel

    @State private var showDeleteConfirmation = false
    @State private var showStatusConfirmation = false

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.lg
            ) {

                orderHeader

                trackingSection

                customerSection

                fulfillmentSection

                purchasedItemsSection

                paymentSection

                managementSection
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.groupedBackground)
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {

                ShareLink(
                    item: receiptText
                ) {

                    Image(
                        systemName: "square.and.arrow.up"
                    )
                }
                .accessibilityLabel("Share order receipt")
            }
        }
        .confirmationDialog(
            "Delete this order?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {

            Button("Delete Order", role: .destructive) {

                viewModel.deleteOrder(order)

                if viewModel.errorMessage == nil {
                    dismiss()
                }
            }

            Button("Cancel", role: .cancel) {}

        } message: {

            Text(
                "This permanently removes the order from your local history and spending statistics."
            )
        }
        .confirmationDialog(
            "Advance order status?",
            isPresented: $showStatusConfirmation,
            titleVisibility: .visible
        ) {

            Button("Advance Status") {
                viewModel.advanceOrderStatus(order)
            }

            Button("Cancel", role: .cancel) {}

        } message: {

            Text(
                "This simulates order fulfillment for demonstration purposes."
            )
        }
        .alert(
            "Order Error",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: { presented in
                    if !presented {
                        viewModel.clearError()
                    }
                }
            )
        ) {

            Button("OK", role: .cancel) {
                viewModel.clearError()
            }

        } message: {

            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Order Header

    private var orderHeader: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            HStack {

                Image(systemName: "receipt")
                    .font(.largeTitle)
                    .foregroundStyle(
                        AppTheme.Colors.primary
                    )

                Spacer()

                OrderStatusBadge(status: order.status)
            }

            Text("Order #\(order.orderNumber)")
                .font(AppTheme.Typography.title)
                .textSelection(.enabled)

            Text(
                order.createdAt.formatted(
                    date: .abbreviated,
                    time: .shortened
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            PriceLabel(
                priceInCents: order.totalInCents,
                font: .largeTitle.bold()
            )
        }
        .modifier(OrderDetailCardStyle())
    }

    // MARK: - Tracking

    private var trackingSteps: [OrderStatus] {

        switch order.fulfillmentMethod {

        case .delivery:
            return [
                .confirmed,
                .processing,
                .shipped,
                .completed
            ]

        case .pickup:
            return [
                .confirmed,
                .processing,
                .readyForPickup,
                .completed
            ]
        }
    }

    private var currentStepIndex: Int {

        trackingSteps.firstIndex(
            of: order.status
        ) ?? -1
    }

    private var trackingSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Order Progress",
                subtitle: "Simulated fulfillment tracking",
                icon: "shippingbox"
            )

            if order.status == .cancelled {

                Label(
                    "This order has been cancelled.",
                    systemImage: "xmark.circle.fill"
                )
                .foregroundStyle(
                    AppTheme.Colors.danger
                )

            } else {

                ForEach(
                    trackingSteps.indices,
                    id: \.self
                ) { index in

                    trackingRow(
                        status: trackingSteps[index],
                        index: index
                    )
                }
            }
        }
        .modifier(OrderDetailCardStyle())
    }

    private func trackingRow(
        status: OrderStatus,
        index: Int
    ) -> some View {

        let isReached = index <= currentStepIndex
        let isCurrent = index == currentStepIndex

        return HStack(
            alignment: .top,
            spacing: AppTheme.Spacing.md
        ) {

            VStack(spacing: 4) {

                Image(
                    systemName: isReached
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .font(.title2)
                .foregroundStyle(
                    isReached
                    ? AppTheme.Colors.success
                    : Color.secondary.opacity(0.4)
                )

                if index < trackingSteps.count - 1 {

                    Rectangle()
                        .fill(
                            index < currentStepIndex
                            ? AppTheme.Colors.success
                            : Color.secondary.opacity(0.2)
                        )
                        .frame(width: 2, height: 26)
                }
            }
            .frame(width: 28)

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {

                Text(status.title)
                    .font(
                        isCurrent
                        ? .headline
                        : .subheadline
                    )
                    .foregroundStyle(
                        isReached
                        ? Color.primary
                        : Color.secondary
                    )

                if isCurrent {

                    Text("Current Status")
                        .font(.caption)
                        .foregroundStyle(
                            AppTheme.Colors.primary
                        )
                }
            }

            Spacer()
        }
    }

    // MARK: - Customer Information

    private var customerSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Customer Information",
                icon: "person.crop.circle"
            )

            informationRow(
                title: "Name",
                value: order.customerName
            )

            informationRow(
                title: "Email",
                value: order.customerEmail
            )
        }
        .modifier(OrderDetailCardStyle())
    }

    // MARK: - Fulfillment

    private var fulfillmentSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Fulfillment Details",
                icon: order.fulfillmentMethod.icon
            )

            informationRow(
                title: "Method",
                value: order.fulfillmentMethod.title
            )

            switch order.fulfillmentMethod {

            case .delivery:

                informationRow(
                    title: "Delivery Address",
                    value: order.deliveryAddress
                        ?? "Unavailable"
                )

            case .pickup:

                informationRow(
                    title: "Pickup Store",
                    value: order.pickupStoreName
                        ?? "Unavailable"
                )

                informationRow(
                    title: "Store Address",
                    value: order.pickupStoreAddress
                        ?? "Unavailable"
                )

                Text(AppConstants.Disclaimer.stores)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .modifier(OrderDetailCardStyle())
    }

    // MARK: - Purchased Items

    private var purchasedItemsSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Purchased Products",
                subtitle: "\(order.totalQuantity) item(s)",
                icon: "bag"
            )

            ForEach(
                order.items.sorted {
                    $0.productName < $1.productName
                },
                id: \.id
            ) { item in

                purchasedItemRow(item)

                Divider()
            }
        }
        .modifier(OrderDetailCardStyle())
    }

    private func purchasedItemRow(
        _ item: OrderItem
    ) -> some View {

        HStack(
            spacing: AppTheme.Spacing.md
        ) {

            ZStack {

                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.medium
                )
                .fill(AppTheme.Colors.surface)

                if let image = UIImage(
                    named: item.productImageName
                ) {

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(6)

                } else {

                    Image(
                        systemName:
                            AppConstants.Resources
                            .placeholderProductImage
                    )
                    .font(.title2)
                    .foregroundStyle(
                        AppTheme.Colors.primary
                    )
                }
            }
            .frame(width: 64, height: 64)
            .accessibilityHidden(true)

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {

                Text(item.productName)
                    .font(.subheadline.weight(.semibold))

                Text(
                    "\(item.quantity) × \(CurrencyFormatter.format(cents: item.unitPriceInCents))"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            PriceLabel(
                priceInCents: item.totalPriceInCents,
                font: .subheadline.weight(.semibold)
            )
        }
    }

    // MARK: - Payment Summary

    private var paymentSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Payment Summary",
                icon: "creditcard"
            )

            priceRow(
                title: "Subtotal",
                cents: order.subtotalInCents
            )

            priceRow(
                title: "Delivery Fee",
                cents: order.deliveryFeeInCents
            )

            priceRow(
                title: "GST",
                cents: order.gstInCents
            )

            priceRow(
                title: "QST",
                cents: order.qstInCents
            )

            Divider()

            HStack {

                Text("Total")
                    .font(.headline)

                Spacer()

                PriceLabel(
                    priceInCents: order.totalInCents,
                    font: .title2.bold()
                )
            }

            Label(
                AppConstants.Disclaimer.payment,
                systemImage: "info.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .modifier(OrderDetailCardStyle())
    }

    // MARK: - Order Management

    @ViewBuilder
    private var managementSection: some View {

        if order.status.isFinal {

            Button(role: .destructive) {

                showDeleteConfirmation = true

            } label: {

                Label(
                    "Delete Order from History",
                    systemImage: "trash"
                )
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.Colors.danger)

        } else {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.md
            ) {

                SectionHeaderView(
                    title: "Demonstration Controls",
                    icon: "gearshape"
                )

                Text(
                    "Shopito is fictional. Use this control to simulate the next stage of order fulfillment."
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                PrimaryButton(
                    title: "Simulate Next Order Status",
                    icon: "arrow.right.circle",
                    action: {
                        showStatusConfirmation = true
                    }
                )
            }
            .modifier(OrderDetailCardStyle())
        }
    }

    // MARK: - Helpers

    private func informationRow(
        title: String,
        value: String
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: AppTheme.Spacing.md
        ) {

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }

    private func priceRow(
        title: String,
        cents: Int
    ) -> some View {

        HStack {

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            PriceLabel(
                priceInCents: cents,
                font: .subheadline,
                color: .primary
            )
        }
    }

    // MARK: - Shareable Receipt

    private var receiptText: String {

        let items = order.items.sorted {
            $0.productName < $1.productName
        }
        .map { item in

            "\(item.quantity) × \(item.productName): \(CurrencyFormatter.format(cents: item.totalPriceInCents))"
        }
        .joined(separator: "\n")

        return """
        SHOPITO — ORDER RECEIPT

        Order: #\(order.orderNumber)
        Date: \(order.createdAt.formatted())
        Status: \(order.status.title)
        Fulfillment: \(order.fulfillmentMethod.title)

        PRODUCTS
        \(items)

        Subtotal: \(CurrencyFormatter.format(cents: order.subtotalInCents))
        Delivery: \(CurrencyFormatter.format(cents: order.deliveryFeeInCents))
        GST: \(CurrencyFormatter.format(cents: order.gstInCents))
        QST: \(CurrencyFormatter.format(cents: order.qstInCents))

        TOTAL: \(CurrencyFormatter.format(cents: order.totalInCents))

        Simulated purchase. No payment was processed.
        """
    }
}

// MARK: - Card Styling

private struct OrderDetailCardStyle: ViewModifier {

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
