import SwiftUI

struct ProductFilterSheet: View {

    @Environment(\.dismiss) private var dismiss

    let viewModel: ShopViewModel

    @State private var selectedSortOption: ProductSortOption
    @State private var selectedCategory: ProductCategory?
    @State private var showInStockOnly: Bool

    // MARK: - Initialization

    init(viewModel: ShopViewModel) {

        self.viewModel = viewModel

        _selectedSortOption = State(
            initialValue: viewModel.sortOption
        )

        _selectedCategory = State(
            initialValue: viewModel.selectedCategory
        )

        _showInStockOnly = State(
            initialValue: viewModel.showInStockOnly
        )
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            Form {

                sortingSection

                categorySection

                availabilitySection
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button("Reset") {
                        resetFilters()
                    }
                    .foregroundStyle(AppTheme.Colors.primary)
                }
            }
            .safeAreaInset(edge: .bottom) {

                PrimaryButton(
                    title: "Apply Filters",
                    icon: "checkmark",
                    action: applyFilters
                )
                .padding()
                .background(.regularMaterial)
            }
        }
        .tint(AppTheme.Colors.primary)
    }

    // MARK: - Sorting

    private var sortingSection: some View {

        Section("Sort By") {

            ForEach(ProductSortOption.allCases) { option in

                Button {
                    selectedSortOption = option
                } label: {

                    HStack {

                        Label(
                            option.title,
                            systemImage: option.icon
                        )
                        .foregroundStyle(.primary)

                        Spacer()

                        if selectedSortOption == option {

                            Image(systemName: "checkmark")
                                .foregroundStyle(
                                    AppTheme.Colors.primary
                                )
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(
                    selectedSortOption == option
                    ? .isSelected
                    : []
                )
            }
        }
    }

    // MARK: - Categories

    private var categorySection: some View {

        Section("Category") {

            categoryRow(
                title: "All Categories",
                icon: "square.grid.2x2",
                isSelected: selectedCategory == nil,
                action: {
                    selectedCategory = nil
                }
            )

            ForEach(
                viewModel.categories,
                id: \.id
            ) { category in

                categoryRow(
                    title: category.name,
                    icon: category.icon,
                    isSelected:
                        selectedCategory?.id == category.id,
                    action: {
                        selectedCategory = category
                    }
                )
            }
        }
    }

    private func categoryRow(
        title: String,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            HStack {

                Label(title, systemImage: icon)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {

                    Image(systemName: "checkmark")
                        .foregroundStyle(
                            AppTheme.Colors.primary
                        )
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(
            isSelected ? .isSelected : []
        )
    }

    // MARK: - Availability

    private var availabilitySection: some View {

        Section("Availability") {

            Toggle(
                isOn: $showInStockOnly
            ) {

                Label(
                    "In Stock Only",
                    systemImage: "checkmark.circle"
                )
            }
        }
    }

    // MARK: - Actions

    private func applyFilters() {

        viewModel.selectSortOption(
            selectedSortOption
        )

        viewModel.selectCategory(
            selectedCategory
        )

        viewModel.showInStockOnly = showInStockOnly

        dismiss()
    }

    private func resetFilters() {

        selectedSortOption = .nameAscending
        selectedCategory = nil
        showInStockOnly = false
    }
}
