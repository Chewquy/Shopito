import SwiftUI

struct StoreListView: View {

    let viewModel: StoreLocatorViewModel
    let onSelectStore: (StoreLocation) -> Void

    // MARK: - Body

    var body: some View {

        Group {

            if viewModel.isLoading {

                LoadingView(
                    message: "Loading nearby stores..."
                )

            } else if let error = viewModel.errorMessage {

                ErrorStateView(
                    title: "Unable to Load Stores",
                    message: error,
                    onRetry: {

                        Task {
                            await viewModel.searchStores()
                        }
                    }
                )

            } else if viewModel.stores.isEmpty {

                emptyStoresView

            } else {

                storeList
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // MARK: - Empty State

    private var emptyStoresView: some View {

        EmptyStateView(
            icon: "mappin.slash",
            title: "No Stores Found",
            message: "Try searching another area or refreshing your current location.",
            actionTitle: "Find Nearby Stores",
            action: {

                Task {
                    await viewModel.loadNearbyStores()
                }
            }
        )
    }

    // MARK: - Store List

    private var storeList: some View {

        ScrollView {

            LazyVStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.md
            ) {

                listHeader

                if let nearestStore = viewModel.nearestStore {

                    nearestStoreCard(nearestStore)
                }

                SectionHeaderView(
                    title: "All Locations"
                )

                ForEach(viewModel.sortedStores) { store in

                    StoreRowView(
                        store: store,
                        distance: viewModel.formattedDistance(
                            to: store
                        ),
                        isNearest:
                            viewModel.nearestStore?.id
                            == store.id,
                        onSelect: {

                            onSelectStore(store)
                        }
                    )
                }
            }
            .padding(AppTheme.Spacing.md)
        }
        .refreshable {

            await viewModel.searchStores()
        }
    }

    // MARK: - Header

    private var listHeader: some View {

        SectionHeaderView(
            title: "Store Locations",
            subtitle: viewModel.hasLocation
                ? "\(viewModel.storeCount) locations • Sorted by distance"
                : "\(viewModel.storeCount) locations found",
            icon: "storefront"
        )
    }

    // MARK: - Nearest Store

    private func nearestStoreCard(
        _ store: StoreLocation
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            Label(
                "Closest Search Result",
                systemImage: "location.circle.fill"
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.9))

            Text(store.name)
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(store.address)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            HStack {

                Label(
                    viewModel.formattedDistance(to: store),
                    systemImage: "location"
                )
                .font(.headline)
                .foregroundStyle(.white)

                Spacer()

                Button {

                    onSelectStore(store)

                } label: {

                    Label(
                        "View Store",
                        systemImage: "arrow.right"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(
                        AppTheme.Colors.primary
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
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
                cornerRadius: AppTheme.Radius.large
            )
        )
    }
}
