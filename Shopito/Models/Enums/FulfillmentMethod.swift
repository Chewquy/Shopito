import Foundation

enum FulfillmentMethod: String, CaseIterable, Identifiable, Codable {

    case delivery
    case pickup

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .delivery:
            return "Home Delivery"

        case .pickup:
            return "In-Store Pickup"
        }
    }

    var description: String {
        switch self {
        case .delivery:
            return "Receive your order at your address."

        case .pickup:
            return "Collect your order at a nearby store."
        }
    }

    var icon: String {
        switch self {
        case .delivery:
            return "truck.box"

        case .pickup:
            return "storefront"
        }
    }

    var deliveryFeeInCents: Int {

        switch self {

        case .delivery:
            return AppConstants.Pricing.deliveryFeeInCents

        case .pickup:
            return 0
        }
    }
}
