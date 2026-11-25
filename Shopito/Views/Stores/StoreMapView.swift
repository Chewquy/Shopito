import SwiftUI
import MapKit
import CoreLocation

struct StoreMapView: View {

    @Bindable var viewModel: StoreLocatorViewModel

    var onSelectPickupStore: ((StoreLocation) -> Void)? = nil

    // MARK: - State

    @State private var displayMode: DisplayMode = .map
    @State private var detailStore: StoreLocation?

    private enum DisplayMode: String, CaseIterable, Identifiable {

        case map = "Map"
        case list = "List"

        var id: String {
            rawValue
        }
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: AppTheme.Spacing.sm) {

            headerSection

            displayModePicker

            if let warning = viewModel.locationWarning {

                locationWarning(warning)
            }

            storeContent

            disclaimer
        }
        .background(AppTheme.Colors.groupedBackground)
        .navigationTitle("Find a Store")
        .searchable(
            text: $viewModel.searchText,
            prompt: "Search stores or areas"
        )
        .onSubmit(of: .search) {

            Task {
                await viewModel.searchStores()
            }
        }
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {

                Button {

                    Task {
                        await viewModel.loadNearbyStores()
                    }

                } label: {

                    Image(systemName: "location.fill")
                }
                .disabled(viewModel.isLoading)
                .accessibilityLabel("Find stores near me")
            }
        }
        .sheet(item: $detailStore) { store in

            StoreDetailSheet(
                store: store,
                viewModel: viewModel,
                onSelectPickupStore: onSelectPickupStore
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .task {

            if viewModel.stores.isEmpty {

                await viewModel.loadNearbyStores()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {

        SectionHeaderView(
            title: "Discover Nearby Stores",
            subtitle: "Find your next pickup location",
            icon: "mappin.and.ellipse"
        )
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.sm)
    }

    // MARK: - Display Mode

    private var displayModePicker: some View {

        Picker(
            "Display Mode",
            selection: $displayMode
        ) {

            ForEach(DisplayMode.allCases) { mode in

                Label(
                    mode.rawValue,
                    systemImage: mode == .map
                    ? "map"
                    : "list.bullet"
                )
                .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppTheme.Spacing.md)
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

        } else {

            switch displayMode {

            case .map:
                mapContent

            case .list:

                StoreListView(
                    viewModel: viewModel,
                    onSelectStore: openStoreDetails
                )
            }
        }
    }

    // MARK: - Map Content

    private var mapContent: some View {

        VStack(spacing: AppTheme.Spacing.sm) {

            interactiveMap

            nearbyStoresSection
        }
    }

    // MARK: - Interactive Map

    private var interactiveMap: some View {

        Map(position: $viewModel.cameraPosition) {

            if viewModel.hasLocation {
                UserAnnotation()
            }

            ForEach(viewModel.stores) { store in

                Annotation(
                    store.name,
                    coordinate: store.coordinate,
                    anchor: .bottom
                ) {

                    Button {

                        openStoreDetails(store)

                    } label: {

                        mapMarker(store)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(store.name)
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {

            MapCompass()
            MapScaleView()
        }
        .onMapCameraChange(
            frequency: .onEnd
        ) { context in

            viewModel.setVisibleRegion(
                context.region
            )
        }
        .overlay(alignment: .top) {

            searchAreaButton
                .padding(.top, AppTheme.Spacing.sm)
        }
        .overlay(alignment: .bottomTrailing) {

            if viewModel.hasLocation {

                centerLocationButton
                    .padding(AppTheme.Spacing.md)
            }
        }
        .frame(minHeight: 250)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.large
            )
        )
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Map Marker

    private func mapMarker(
        _ store: StoreLocation
    ) -> some View {

        let isSelected =
            viewModel.selectedStore?.id == store.id

        return VStack(spacing: 0) {

            Image(systemName: "storefront.fill")
                .font(.system(size: 18))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(
                    isSelected
                    ? AppTheme.Colors.secondary
                    : AppTheme.Colors.primary
                )
                .clipShape(Circle())
                .overlay {

                    Circle()
                        .strokeBorder(
                            .white,
                            lineWidth: 2
                        )
                }

            Image(systemName: "triangle.fill")
                .font(.system(size: 12))
                .rotationEffect(.degrees(180))
                .foregroundStyle(
                    isSelected
                    ? AppTheme.Colors.secondary
                    : AppTheme.Colors.primary
                )
                .offset(y: -3)
        }
        .shadow(
            color: .black.opacity(0.2),
            radius: 3,
            y: 2
        )
    }

    // MARK: - Search This Area

    private var searchAreaButton: some View {

        Button {

            Task {
                await viewModel.searchStores()
            }

        } label: {

            Label(
                "Search This Area",
                systemImage: "magnifyingglass"
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.Colors.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .shadow(radius: 3)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
    }

    // MARK: - Center Location

    private var centerLocationButton: some View {

        Button {

            withAnimation(AppTheme.Motion.standard) {

                viewModel.centerOnUser()
            }

        } label: {

            Image(systemName: "location.fill")
                .font(.title3)
                .foregroundStyle(
                    AppTheme.Colors.primary
                )
                .frame(width: 48, height: 48)
                .background(.regularMaterial)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Center map on my location")
    }

    // MARK: - Nearby Stores

    private var nearbyStoresSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {

            SectionHeaderView(
                title: "Nearby Stores",
                subtitle: "\(viewModel.storeCount) locations found",
                actionTitle: viewModel.stores.isEmpty
                    ? nil
                    : "See All",
                action: {
                    displayMode = .list
                }
            )

            if viewModel.stores.isEmpty {

                Text("No stores found. Try searching another area.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical)

            } else {

                ScrollView {

                    LazyVStack(
                        spacing: AppTheme.Spacing.sm
                    ) {

                        ForEach(
                            Array(
                                viewModel.sortedStores.prefix(3)
                            )
                        ) { store in

                            StoreRowView(
                                store: store,
                                distance: viewModel.formattedDistance(
                                    to: store
                                ),
                                isNearest:
                                    viewModel.nearestStore?.id
                                    == store.id,
                                onSelect: {
                                    openStoreDetails(store)
                                }
                            )
                        }
                    }
                }
                .frame(maxHeight: 240)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
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
        .padding(.horizontal, AppTheme.Spacing.md)
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {

        Label(
            AppConstants.Disclaimer.stores,
            systemImage: "info.circle"
        )
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.sm)
    }

    // MARK: - Actions

    private func openStoreDetails(
        _ store: StoreLocation
    ) {

        viewModel.selectStore(store)
        detailStore = store
    }
}
