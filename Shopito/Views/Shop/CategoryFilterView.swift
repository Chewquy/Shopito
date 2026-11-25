import SwiftUI

struct CategoryFilterView: View {

    let categories: [ProductCategory]
    let selectedCategory: ProductCategory?
    let onSelect: (ProductCategory?) -> Void

    var body: some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(spacing: AppTheme.Spacing.sm) {

                categoryButton(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    action: {
                        onSelect(nil)
                    }
                )

                ForEach(categories, id: \.id) { category in

                    categoryButton(
                        title: category.name,
                        icon: category.icon,
                        isSelected:
                            selectedCategory?.id == category.id,
                        action: {
                            onSelect(category)
                        }
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Category Button

    private func categoryButton(
        title: String,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button {

            withAnimation(AppTheme.Motion.standard) {
                action()
            }

        } label: {

            HStack(spacing: 6) {

                Image(systemName: icon)
                    .font(.system(size: 14))

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .fixedSize()
            }
            .foregroundStyle(
                isSelected
                ? AppTheme.Colors.onPrimary
                : AppTheme.Colors.primaryText
            )
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background(
                isSelected
                ? AppTheme.Colors.primary
                : AppTheme.Colors.background
            )
            .clipShape(Capsule())
            .overlay {

                Capsule()
                    .strokeBorder(
                        isSelected
                        ? Color.clear
                        : AppTheme.Colors.border.opacity(0.25),
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(
            isSelected ? .isSelected : []
        )
    }
}
