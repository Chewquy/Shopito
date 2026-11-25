import Foundation
import Observation

@Observable
@MainActor
final class ShopViewModel {

    private let productRepository: ProductRepository

    // MARK: - State

    private(set) var products: [Product] = []
    private(set) var categories: [ProductCategory] = []

    var searchText: String = ""
    var selectedCategory: ProductCategory?
    var sortOption: ProductSortOption = .nameAscending
    var showInStockOnly: Bool = false

    private(set) var isLoading = false
    var errorMessage: String?

    // MARK: - Initialization

    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }

    // MARK: - Computed Properties

    var filteredProducts: [Product] {

        var result = products

        // Filter by category
        if let selectedCategory {
            result = result.filter {
                $0.category?.id == selectedCategory.id
            }
        }

        // Filter by search text
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !query.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(query)
                || $0.productDescription
                    .localizedCaseInsensitiveContains(query)
                || ($0.category?.name
                    .localizedCaseInsensitiveContains(query) ?? false)
            }
        }

        // Filter by availability
        if showInStockOnly {
            result = result.filter {
                $0.isInStock
            }
        }

        // Sort products
        switch sortOption {

        case .nameAscending:
            result.sort {
                $0.name.localizedCompare($1.name)
                    == .orderedAscending
            }

        case .nameDescending:
            result.sort {
                $0.name.localizedCompare($1.name)
                    == .orderedDescending
            }

        case .priceLowToHigh:
            result.sort {
                $0.priceInCents < $1.priceInCents
            }

        case .priceHighToLow:
            result.sort {
                $0.priceInCents > $1.priceInCents
            }
        }

        return result
    }

    var productCount: Int {
        filteredProducts.count
    }

    var hasActiveFilters: Bool {
        selectedCategory != nil
        || !searchText.isEmpty
        || showInStockOnly
        || sortOption != .nameAscending
    }

    // MARK: - Data Loading

    func loadData() {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            products = try productRepository.fetchAllProducts()
            categories = try productRepository.fetchAllCategories()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() {
        loadData()
    }

    // MARK: - Filtering

    func selectCategory(_ category: ProductCategory?) {
        selectedCategory = category
    }

    func selectSortOption(_ option: ProductSortOption) {
        sortOption = option
    }

    func resetFilters() {
        searchText = ""
        selectedCategory = nil
        sortOption = .nameAscending
        showInStockOnly = false
    }

    func clearError() {
        errorMessage = nil
    }
}
