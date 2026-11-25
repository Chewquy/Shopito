import Foundation

enum ProductSortOption: String, CaseIterable, Identifiable, Codable {

    case nameAscending
    case nameDescending
    case priceLowToHigh
    case priceHighToLow

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .nameAscending:
            return "Name: A to Z"

        case .nameDescending:
            return "Name: Z to A"

        case .priceLowToHigh:
            return "Price: Low to High"

        case .priceHighToLow:
            return "Price: High to Low"
        }
    }

    var icon: String {
        switch self {
        case .nameAscending:
            return "textformat.abc"

        case .nameDescending:
            return "textformat.abc"

        case .priceLowToHigh:
            return "arrow.up"

        case .priceHighToLow:
            return "arrow.down"
        }
    }
}
