import Foundation
import CoreLocation

enum AppConstants {

    // MARK: - Application

    static let appName = "Shopito"
    static let currencyCode = "CAD"
    static let localeIdentifier = "en_CA"

    // MARK: - Pricing

    enum Pricing {

        static let gstRate = Decimal(5) / Decimal(100)
        static let qstRate = Decimal(9975) / Decimal(100000)

        static let deliveryFeeInCents = 599
    }

    // MARK: - Store Locator

    enum Stores {

        static let defaultSearchQuery = "Walmart"
        static let maximumResults = 20

        static let defaultLatitude = 45.5019
        static let defaultLongitude = -73.5674

        static let latitudeDelta = 0.12
        static let longitudeDelta = 0.12

        static let locationTimeoutSeconds = 30

        static var defaultCoordinate: CLLocationCoordinate2D {

            CLLocationCoordinate2D(
                latitude: defaultLatitude,
                longitude: defaultLongitude
            )
        }
    }

    // MARK: - Order History

    enum Orders {

        static let spendingHistoryMonths = 6
        static let orderNumberLength = 8
    }

    // MARK: - Resources

    enum Resources {

        static let placeholderProductImage = "shippingbox"
    }

    // MARK: - Disclaimer

    enum Disclaimer {

        static let payment =
            "This is a simulated purchase. No payment will be processed."

        static let stores =
            "Shopito is fictional. Real store locations are displayed for demonstration purposes only."
    }
}
