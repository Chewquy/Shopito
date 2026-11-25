import SwiftUI
import MapKit

struct PickupStoreSheet: View {

    @Environment(\.dismiss) private var dismiss

    @Bindable var viewModel: StoreLocatorViewModel

    let selectedStore: StoreLocation?
    let onSelectStore: (StoreLocation) -> Void

    @State private var pendingSelection: StoreLocation?

    // MARK: - Body

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                disclaimer

                if let warning = viewModel.locationWarning {

                    locationWarning(warning)
                }

                storeContent
            }
            .background(
                AppTheme.Colors.groupedBackground
            )
            .navigationTitle("Pickup Store")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search stores"
            )
            .onSubmit(of: .search) {

                Task {
                    await viewModel.searchStores()
                }
            }
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button {

                        Task {
                            await viewModel.loadNearbyStores()
                        }

                    } label: {

                        Image(systemName: "location")
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel(
                        "Find stores near me"
                    )
                }
            }
            .safeAreaInset(edge: .bottom) {

                confirmationButton
            }
            .task {

                pendingSelection = selectedStore

                if viewModel.stores.isEmpty {

                    await viewModel.loadNearbyStores()
                }
            }
        }
        .tint(AppTheme.Colors.primary)
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {

        Label(
            AppConstants.Disclaimer.stores,
            systemImage: "info.circle"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(AppTheme.Spacing.md)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Location Warning

    private func locationWarning(
        _ message: String
    ) -> some View {

        Label(
            message,
            systemImage: "location.slash"
        )
        .font(.caption)
        .foregroundStyle(AppTheme.Colors.warning)
        .padding(AppTheme.Spacing.sm)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            AppTheme.Colors.warning.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.small
            )
        )
        .padding(.horizontal)
    }

    // MARK: - Store Content

    @ViewBuilder
    private var storeContent: some View {

        if viewModel.isLoading {

            Spacer()

            LoadingView(
                message: "Finding nearby stores..."
            )

            Spacer()

        } else if let error = viewModel.errorMessage {

            Spacer()

            ErrorStateView(
                title: "Unable to Find Stores",
                message: error,
                onRetry: {

                    Task {
                        await viewModel.searchStores()
                    }
                }
            )

            Spacer()

        } else if viewModel.stores.isEmpty {

            Spacer()

            EmptyStateView(
                icon: "mappin.slash",
                title: "No Stores Found",
                message: "Try searching another area or refreshing your location.",
                actionTitle: "Search Again",
                action: {

                    Task {
                        await viewModel.loadNearbyStores()
                    }
                }
            )

            Spacer()

        } else {

            storeList
        }
    }

    // MARK: - Store List

    private var storeList: some View {

        ScrollView {

            LazyVStack(
                spacing: AppTheme.Spacing.sm
            ) {

                SectionHeaderView(
                    title: "Available Stores",
                    subtitle: "\(viewModel.storeCount) locations found"
                )
                .padding(.bottom, AppTheme.Spacing.sm)

                ForEach(viewModel.sortedStores) { store in

                    storeRow(store)
                }
            }
            .padding(AppTheme.Spacing.md)
        }
        .refreshable {

            await viewModel.searchStores()
        }
    }

    // MARK: - Store Row

    private func storeRow(
        _ store: StoreLocation
    ) -> some View {

        let isSelected = isSameStore(
            pendingSelection,
            store
        )

        return Button {

            pendingSelection = store

        } label: {

            HStack(
                alignment: .top,
                spacing: AppTheme.Spacing.md
            ) {

                Image(systemName: "storefront.fill")
                    .font(.title2)
                    .foregroundStyle(
                        AppTheme.Colors.primary
                    )
                    .frame(width: 36)

                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.xs
                ) {

                    Text(store.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(store.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)

                    Label(
                        viewModel.formattedDistance(
                            to: store
                        ),
                        systemImage: "location"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        AppTheme.Colors.primary
                    )

                    if isSameStore(
                        viewModel.nearestStore,
                        store
                    ) {

                        Text("Nearest Search Result")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(
                                AppTheme.Colors.success
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
            .background(AppTheme.Colors.background)
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
                    : AppTheme.Colors.border.opacity(0.15),
                    lineWidth: isSelected ? 2 : 1
                )
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(
            isSelected ? .isSelected : []
        )
    }

    // MARK: - Confirmation Button

    private var confirmationButton: some View {

        PrimaryButton(
            title: "Confirm Pickup Store",
            icon: "checkmark",
            isDisabled:
                pendingSelection == nil
                || viewModel.isLoading,
            action: {

                guard let pendingSelection else {
                    return
                }

                onSelectStore(pendingSelection)
                dismiss()
            }
        )
        .padding(AppTheme.Spacing.md)
        .background(.regularMaterial)
    }

    // MARK: - Store Comparison

    private func isSameStore(
        _ first: StoreLocation?,
        _ second: StoreLocation
    ) -> Bool {

        guard let first else {
            return false
        }

        return first.name == second.name
            && first.address == second.address
            && abs(first.latitude - second.latitude) < 0.0001
            && abs(first.longitude - second.longitude) < 0.0001
    }
}
