import Foundation
import Observation
import SwiftUI
import MapKit
import CoreLocation

// MARK: - Service Contracts

@MainActor
protocol LocationServiceProtocol {

    func requestCurrentLocation() async throws -> CLLocation
}

@MainActor
protocol StoreSearchServiceProtocol {

    func searchNearbyStores(
        query: String,
        region: MKCoordinateRegion
    ) async throws -> [StoreLocation]
}

// MARK: - ViewModel

@Observable
@MainActor
final class StoreLocatorViewModel {

    private let locationService: any LocationServiceProtocol
    private let storeSearchService: any StoreSearchServiceProtocol

    // MARK: - State

    private(set) var stores: [StoreLocation] = []
    private(set) var userLocation: CLLocation?
    private(set) var isLoading = false

    var selectedStore: StoreLocation?
    var searchText: String = ""
    var errorMessage: String?
    var locationWarning: String?

    // MARK: - Map State

    var cameraPosition: MapCameraPosition
    private(set) var searchRegion: MKCoordinateRegion

    // Default search area: Montreal

    private static let defaultRegion = MKCoordinateRegion(

        center: AppConstants.Stores.defaultCoordinate,

        span: MKCoordinateSpan(
            latitudeDelta: AppConstants.Stores.latitudeDelta,
            longitudeDelta: AppConstants.Stores.longitudeDelta
        )
    )

    private let defaultStoreQuery =
        AppConstants.Stores.defaultSearchQuery

    // MARK: - Initialization

    init(
        locationService: any LocationServiceProtocol,
        storeSearchService: any StoreSearchServiceProtocol
    ) {

        self.locationService = locationService
        self.storeSearchService = storeSearchService

        self.searchRegion = Self.defaultRegion

        self.cameraPosition = .region(
            Self.defaultRegion
        )
    }

    // MARK: - Computed Properties

    var sortedStores: [StoreLocation] {

        guard let userLocation else {

            return stores.sorted {
                $0.name < $1.name
            }
        }

        return stores.sorted {

            $0.distance(from: userLocation)
            < $1.distance(from: userLocation)
        }
    }

    var nearestStore: StoreLocation? {

        guard userLocation != nil else {
            return nil
        }

        return sortedStores.first
    }

    var storeCount: Int {
        stores.count
    }

    var hasLocation: Bool {
        userLocation != nil
    }

    // MARK: - Initialization Workflow

    func loadNearbyStores() async {

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        locationWarning = nil

        defer {
            isLoading = false
        }

        do {

            let location = try await locationService
                .requestCurrentLocation()

            userLocation = location

            updateSearchRegion(
                center: location.coordinate
            )

        } catch is CancellationError {
            return

        } catch {

            // If permission is denied or location
            // is unavailable, use Montreal.

            userLocation = nil

            searchRegion = Self.defaultRegion
            cameraPosition = .region(Self.defaultRegion)

            locationWarning =
                "Your location is unavailable. Showing stores in Montreal instead."
        }

        await performSearch()
    }

    // MARK: - Store Search

    func searchStores() async {

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        await performSearch()
    }

    private func performSearch() async {

        let trimmedQuery = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let query = trimmedQuery.isEmpty
            ? defaultStoreQuery
            : "\(defaultStoreQuery) \(trimmedQuery)"

        do {

            let results = try await storeSearchService
                .searchNearbyStores(
                    query: query,
                    region: searchRegion
                )

            try Task.checkCancellation()

            stores = results
            selectedStore = nil

        } catch is CancellationError {
            return

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Map Management

    func updateSearchRegion(
        center: CLLocationCoordinate2D
    ) {

        let region = MKCoordinateRegion(

            center: center,

            span: MKCoordinateSpan(
                latitudeDelta: 0.12,
                longitudeDelta: 0.12
            )
        )

        searchRegion = region
        cameraPosition = .region(region)
    }

    func setVisibleRegion(
        _ region: MKCoordinateRegion
    ) {

        searchRegion = region
    }

    func centerOnUser() {

        guard let userLocation else {

            errorMessage = "Your current location is unavailable."
            return
        }

        updateSearchRegion(
            center: userLocation.coordinate
        )
    }

    func centerOnStore(_ store: StoreLocation) {

        let region = MKCoordinateRegion(

            center: store.coordinate,

            span: MKCoordinateSpan(
                latitudeDelta: 0.015,
                longitudeDelta: 0.015
            )
        )

        cameraPosition = .region(region)
    }

    // MARK: - Store Selection

    func selectStore(_ store: StoreLocation) {

        selectedStore = store
        centerOnStore(store)
    }

    func clearSelection() {
        selectedStore = nil
    }

    // MARK: - Distance

    func distanceInKilometers(
        to store: StoreLocation
    ) -> Double? {

        guard let userLocation else {
            return nil
        }

        return store.distanceInKilometers(
            from: userLocation
        )
    }

    func formattedDistance(
        to store: StoreLocation
    ) -> String {

        guard let distance = distanceInKilometers(
            to: store
        ) else {
            return "Distance unavailable"
        }

        if distance < 1 {

            let meters = Int(
                (distance * 1000).rounded()
            )

            return "\(meters) m"
        }

        return String(
            format: "%.1f km",
            distance
        )
    }

    // MARK: - Directions

    func openDirections(to store: StoreLocation) {
        store.openInMaps()
    }

    // MARK: - Reset

    func resetSearch() {

        searchText = ""
        selectedStore = nil
        errorMessage = nil
    }
}
