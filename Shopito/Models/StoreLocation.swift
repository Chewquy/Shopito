import Foundation
import MapKit
import CoreLocation

struct StoreLocation: Identifiable, Hashable {

    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let phoneNumber: String?
    let websiteURL: URL?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }

    var location: CLLocation {
        CLLocation(
            latitude: latitude,
            longitude: longitude
        )
    }

    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        phoneNumber: String? = nil,
        websiteURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phoneNumber = phoneNumber
        self.websiteURL = websiteURL
    }

    init(mapItem: MKMapItem) {
        self.id = UUID()
        self.name = mapItem.name ?? "Unknown Store"
        self.address = mapItem.placemark.title
            ?? "Address unavailable"
        self.latitude = mapItem.placemark.coordinate.latitude
        self.longitude = mapItem.placemark.coordinate.longitude
        self.phoneNumber = mapItem.phoneNumber
        self.websiteURL = mapItem.url
    }

    func distance(from userLocation: CLLocation) -> Double {
        location.distance(from: userLocation)
    }

    func distanceInKilometers(
        from userLocation: CLLocation
    ) -> Double {
        distance(from: userLocation) / 1000
    }

    func openInMaps() {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)

        mapItem.name = name

        mapItem.openInMaps(
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey:
                    MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
}
