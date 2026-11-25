import SwiftUI

struct FulfillmentSelectionView: View {

    @Bindable var viewModel: CheckoutViewModel

    let onSelectStore: () -> Void

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Fulfillment Method",
                subtitle: "How would you like to receive your order?",
                icon: "shippingbox"
            )

            ForEach(FulfillmentMethod.allCases) { method in

                fulfillmentRow(method)
            }

            if viewModel.fulfillmentMethod == .pickup {

                Divider()

                pickupStoreSection
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.large
            )
        )
        .animation(
            AppTheme.Motion.standard,
            value: viewModel.fulfillmentMethod
        )
    }

    // MARK: - Fulfillment Row

    private func fulfillmentRow(
        _ method: FulfillmentMethod
    ) -> some View {

        let isSelected =
            viewModel.fulfillmentMethod == method

        return Button {

            viewModel.selectFulfillmentMethod(method)

        } label: {

            HStack(spacing: AppTheme.Spacing.md) {

                Image(systemName: method.icon)
                    .font(.title2)
                    .foregroundStyle(
                        AppTheme.Colors.primary
                    )
                    .frame(width: 40)

                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.xs
                ) {

                    Text(method.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(method.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)

                    if method.deliveryFeeInCents == 0 {

                        Text("Free")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(
                                AppTheme.Colors.success
                            )

                    } else {

                        PriceLabel(
                            priceInCents: method.deliveryFeeInCents,
                            font: .subheadline.weight(.semibold)
                        )
                    }
                }

                Spacer()

                Image(
                    systemName: isSelected
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .font(.title2)
                .foregroundStyle(
                    isSelected
                    ? AppTheme.Colors.primary
                    : AppTheme.Colors.secondaryText
                )
            }
            .padding(AppTheme.Spacing.md)
            .background(
                isSelected
                ? AppTheme.Colors.primary.opacity(0.06)
                : AppTheme.Colors.surface
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.medium
                )
            )
            .overlay {

                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.medium
                )
                .strokeBorder(
                    isSelected
                    ? AppTheme.Colors.primary
                    : AppTheme.Colors.border.opacity(0.2),
                    lineWidth: isSelected ? 2 : 1
                )
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(
            isSelected ? .isSelected : []
        )
    }

    // MARK: - Pickup Store Section

    private var pickupStoreSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            Text("Pickup Location")
                .font(.headline)

            if let store = viewModel.selectedStore {

                selectedStoreCard(store)

                Button(action: onSelectStore) {

                    Label(
                        "Change Pickup Store",
                        systemImage: "arrow.triangle.2.circlepath"
                    )
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(
                        AppTheme.Colors.primary
                    )
                }
                .buttonStyle(.plain)

            } else {

                PrimaryButton(
                    title: "Select Pickup Store",
                    icon: "map",
                    action: onSelectStore
                )

                Text(
                    "A pickup location is required to complete your order."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Label(
                AppConstants.Disclaimer.stores,
                systemImage: "info.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Selected Store

    private func selectedStoreCard(
        _ store: StoreLocation
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: AppTheme.Spacing.md
        ) {

            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundStyle(AppTheme.Colors.primary)

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {

                Text(store.name)
                    .font(.headline)

                Text(store.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label(
                    "Selected for pickup",
                    systemImage: "checkmark.circle"
                )
                .font(.caption)
                .foregroundStyle(
                    AppTheme.Colors.success
                )
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.medium
            )
        )
    }
}
