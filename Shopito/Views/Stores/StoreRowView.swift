import SwiftUI

struct StoreRowView: View {

    let store: StoreLocation
    let distance: String

    var isNearest: Bool = false

    let onSelect: () -> Void

    // MARK: - Body

    var body: some View {

        Button(action: onSelect) {

            HStack(
                alignment: .center,
                spacing: AppTheme.Spacing.md
            ) {

                storeIcon

                storeInformation

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.background)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.large
                )
            )
            .overlay {

                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.large
                )
                .strokeBorder(
                    AppTheme.Colors.border.opacity(0.15),
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens store details")
    }

    // MARK: - Store Icon

    private var storeIcon: some View {

        ZStack {

            RoundedRectangle(
                cornerRadius: AppTheme.Radius.medium
            )
            .fill(
                AppTheme.Colors.primary.opacity(0.1)
            )

            Image(systemName: "storefront.fill")
                .font(.system(size: 24))
                .foregroundStyle(
                    AppTheme.Colors.primary
                )
        }
        .frame(width: 54, height: 54)
        .accessibilityHidden(true)
    }

    // MARK: - Store Information

    private var storeInformation: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.xs
        ) {

            Text(store.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(store.address)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)

            Label(
                distance,
                systemImage: "location"
            )
            .font(.caption.weight(.medium))
            .foregroundStyle(
                AppTheme.Colors.primary
            )

            if isNearest {

                nearestLabel
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Nearest Label

    private var nearestLabel: some View {

        Label(
            "Closest Search Result",
            systemImage: "star.fill"
        )
        .font(.caption2.weight(.semibold))
        .foregroundStyle(
            AppTheme.Colors.success
        )
    }
}

// MARK: - Preview

#Preview {

    VStack(spacing: 16) {

        StoreRowView(
            store: StoreLocation(
                name: "Example Store",
                address: "123 Example Street, Montreal",
                latitude: 45.5019,
                longitude: -73.5674
            ),
            distance: "1.2 km",
            isNearest: true,
            onSelect: {}
        )

        StoreRowView(
            store: StoreLocation(
                name: "Another Example Store",
                address: "456 Example Street, Montreal",
                latitude: 45.5100,
                longitude: -73.5800
            ),
            distance: "Distance unavailable",
            onSelect: {}
        )
    }
    .padding()
    .background(
        AppTheme.Colors.groupedBackground
    )
}
