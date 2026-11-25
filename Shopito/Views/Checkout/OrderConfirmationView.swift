import SwiftUI

struct OrderConfirmationView: View {

    let order: Order
    let onDone: () -> Void

    @State private var showAnimation = false

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                spacing: AppTheme.Spacing.lg
            ) {

                successHeader

                orderInformation

                purchasedItems

                paymentSummary

                fulfillmentInformation
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.groupedBackground)
        .safeAreaInset(edge: .bottom) {

            doneButton
        }
        .onAppear {

            if reduceMotion {

                showAnimation = true

            } else {

                withAnimation(
                    AppTheme.Motion.spring
                ) {

                    showAnimation = true
                }
            }
        }
        .interactiveDismissDisabled()
    }

    // MARK: - Success Header

    private var successHeader: some View {

        VStack(spacing: AppTheme.Spacing.md) {

            ZStack {

                Circle()
                    .fill(
                        AppTheme.Colors.success.opacity(0.12)
                    )
                    .frame(width: 120, height: 120)

                Image(
                    systemName: "checkmark.circle.fill"
                )
                .font(.system(size: 76))
                .foregroundStyle(
                    AppTheme.Colors.success
                )
            }
            .scaleEffect(
                showAnimation ? 1 : 0.5
            )
            .opacity(
                showAnimation ? 1 : 0
            )
            .accessibilityHidden(true)

            Text("Order Confirmed!")
                .font(AppTheme.Typography.largeTitle)
                .multilineTextAlignment(.center)

            Text(
                "Thank you for shopping with Shopito, \(order.customerName)!"
            )
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Text(
                "Your order has been saved successfully."
            )
            .font(.subheadline)
            .multilineTextAlignment(.center)
        }
        .padding(.vertical, AppTheme.Spacing.lg)
    }

    // MARK: - Order Information

    private var orderInformation: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Order Information",
                icon: "receipt"
            )

            informationRow(
                title: "Order Number",
                value: "#\(order.orderNumber)"
            )

            informationRow(
                title: "Order Date",
                value: order.createdAt.formatted(
                    date: .abbreviated,
                    time: .shortened
                )
            )

            informationRow(
                title: "Customer",
                value: order.customerName
            )

            informationRow(
                title: "Email",
                value: order.customerEmail
            )

            HStack {

                Text("Status")
                    .foregroundStyle(.secondary)

                Spacer()

                Label(
                    order.status.title,
                    systemImage: order.status.icon
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(
                    AppTheme.Colors.success
                )
            }
        }
        .font(.subheadline)
        .modifier(ConfirmationCardStyle())
    }

    // MARK: - Purchased Items

    private var purchasedItems: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Purchased Items",
                subtitle: "\(order.totalQuantity) item(s)",
                icon: "bag"
            )

            ForEach(
                order.items.sorted {
                    $0.productName < $1.productName
                },
                id: \.id
            ) { item in

                HStack(alignment: .top) {

                    VStack(
                        alignment: .leading,
                        spacing: AppTheme.Spacing.xs
                    ) {

                        Text(item.productName)
                            .font(.subheadline.weight(.medium))

                        Text(
                            "\(item.quantity) × \(CurrencyFormatter.format(cents: item.unitPriceInCents))"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    PriceLabel(
                        priceInCents: item.totalPriceInCents,
                        font: .subheadline.weight(.medium),
                        color: .primary
                    )
                }
            }
        }
        .modifier(ConfirmationCardStyle())
    }

    // MARK: - Payment Summary

    private var paymentSummary: some View {

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

                Text("Order Total")
                    .font(.headline)

                Spacer()

                PriceLabel(
                    priceInCents: order.totalInCents,
                    font: .title.bold()
                )
            }

            Label(
                "Simulated payment — no money was charged.",
                systemImage: "info.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .modifier(ConfirmationCardStyle())
    }

    // MARK: - Fulfillment Information

    private var fulfillmentInformation: some View {

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
        .modifier(ConfirmationCardStyle())
    }

    // MARK: - Information Row

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

    // MARK: - Price Row

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

    // MARK: - Done Button

    private var doneButton: some View {

        PrimaryButton(
            title: "Done",
            icon: "checkmark",
            action: onDone
        )
        .padding(AppTheme.Spacing.md)
        .background(.regularMaterial)
    }
}

// MARK: - Card Style

private struct ConfirmationCardStyle: ViewModifier {

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
