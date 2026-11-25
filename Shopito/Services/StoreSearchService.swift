import Foundation
import MapKit
import CoreLocation

@MainActor
final class StoreSearchService: StoreSearchServiceProtocol {

    // MARK: - Search Configuration

    private let maximumResults =
        AppConstants.Stores.maximumResults

    // MARK: - Store Search

    func searchNearbyStores(
        query: String,
        region: MKCoordinateRegion
    ) async throws -> [StoreLocation] {

        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedQuery.isEmpty else {
            throw StoreSearchServiceError.invalidQuery
        }

        try Task.checkCancellation()

        // Configure the MapKit search request.

        let request = MKLocalSearch.Request()

        request.naturalLanguageQuery = trimmedQuery
        request.region = region
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)

        // Execute the search asynchronously.

        let response: MKLocalSearch.Response

        do {
            response = try await search.start()

        } catch {

            try Task.checkCancellation()

            if let mapError = error as? MKError,
               mapError.code == .placemarkNotFound {

                return []
            }

            throw StoreSearchServiceError.searchFailed(
                message: error.localizedDescription
            )
        }

        try Task.checkCancellation()

        // Convert MapKit results into our own models.

        let stores = response.mapItems.map {
            StoreLocation(mapItem: $0)
        }

        // Remove duplicate search results.

        let uniqueStores = removeDuplicates(from: stores)

        // Sort by distance from the search area's center.

        let centerLocation = CLLocation(
            latitude: region.center.latitude,
            longitude: region.center.longitude
        )

        let sortedStores = uniqueStores.sorted {

            $0.distance(from: centerLocation)
            < $1.distance(from: centerLocation)
        }

        return Array(
            sortedStores.prefix(maximumResults)
        )
    }

    // MARK: - Duplicate Prevention

    private func removeDuplicates(
        from stores: [StoreLocation]
    ) -> [StoreLocation] {

        var seen: Set<String> = []
        var uniqueStores: [StoreLocation] = []

        for store in stores {

            let latitude = String(
                format: "%.5f",
                store.latitude
            )

            let longitude = String(
                format: "%.5f",
                store.longitude
            )

            let key = "\(store.name.lowercased())"
                + "_\(latitude)_\(longitude)"

            if seen.insert(key).inserted {
                uniqueStores.append(store)
            }
        }

        return uniqueStores
    }
}

// MARK: - Store Search Errors

enum StoreSearchServiceError: LocalizedError {

    case invalidQuery
    case searchFailed(message: String)

    var errorDescription: String? {

        switch self {

        case .invalidQuery:
            return "Please enter a valid store search."

        case .searchFailed(let message):
            return "Unable to search for nearby stores: \(message)"
        }
    }
}
