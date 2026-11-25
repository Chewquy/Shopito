import Foundation

enum OrderStatus: String, CaseIterable, Identifiable, Codable {

    case confirmed
    case processing
    case shipped
    case readyForPickup
    case completed
    case cancelled

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .confirmed:
            return "Confirmed"

        case .processing:
            return "Processing"

        case .shipped:
            return "Shipped"

        case .readyForPickup:
            return "Ready for Pickup"

        case .completed:
            return "Completed"

        case .cancelled:
            return "Cancelled"
        }
    }

    var icon: String {
        switch self {
        case .confirmed:
            return "checkmark.circle"

        case .processing:
            return "clock"

        case .shipped:
            return "truck.box"

        case .readyForPickup:
            return "storefront"

        case .completed:
            return "checkmark.seal.fill"

        case .cancelled:
            return "xmark.circle"
        }
    }

    var isFinal: Bool {
        switch self {
        case .completed, .cancelled:
            return true

        default:
            return false
        }
    }
}
