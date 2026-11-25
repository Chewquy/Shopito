import SwiftUI
import MapKit

struct StoreDetailSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    let store: StoreLocation
    let viewModel: StoreLocatorViewModel

    var onSelectPickupStore: ((StoreLocation) -> Void)? = nil

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: AppTheme.Spacing.lg
                ) {

                    storeHeader

                    storeMap

                    contactInformation

                    actionSection

                    disclaimer
                }
                .padding(AppTheme.Spacing.md)
            }
            .background(
                AppTheme.Colors.groupedBackground
            )
            .navigationTitle("Store Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .tint(AppTheme.Colors.primary)
    }

    // MARK: - Store Header

    private var storeHeader: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.sm
        ) {

            Image(systemName: "storefront.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    AppTheme.Colors.primary
                )
                .padding(.bottom, AppTheme.Spacing.xs)

            Text(store.name)
                .font(AppTheme.Typography.largeTitle)

            Label(
                store.address,
                systemImage: "mappin.and.ellipse"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Label(
                viewModel.formattedDistance(to: store),
                systemImage: "location"
            )
            .font(.subheadline.weight(.medium))
            .foregroundStyle(
                AppTheme.Colors.primary
            )

            if viewModel.nearestStore?.id == store.id {

                Label(
                    "Closest Search Result",
                    systemImage: "star.fill"
                )
                .font(.caption.weight(.semibold))
                .foregroundStyle(
                    AppTheme.Colors.success
                )
            }

            Text("Distances are measured in a straight line.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .modifier(StoreDetailCardStyle())
    }

    // MARK: - Store Map

    private var storeMap: some View {

        Map(
            initialPosition: .region(
                MKCoordinateRegion(
                    center: store.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.012,
                        longitudeDelta: 0.012
                    )
                )
            ),
            interactionModes: []
        ) {

            Marker(
                store.name,
                systemImage: "storefront.fill",
                coordinate: store.coordinate
            )
            .tint(AppTheme.Colors.primary)
        }
        .frame(height: 200)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.large
            )
        )
        .accessibilityLabel("Map showing \(store.name)")
    }

    // MARK: - Contact Information

    private var contactInformation: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Store Information",
                icon: "info.circle"
            )

            informationRow(
                title: "Address",
                value: store.address,
                icon: "mappin"
            )

            Divider()

            informationRow(
                title: "Phone",
                value: store.phoneNumber
                    ?? "Not available",
                icon: "phone"
            )

            Divider()

            if let websiteURL = store.websiteURL,
               let scheme = websiteURL.scheme?.lowercased(),
               ["https", "http"].contains(scheme) {

                Button {

                    openURL(websiteURL)

                } label: {

                    HStack {

                        Image(systemName: "globe")
                            .foregroundStyle(
                                AppTheme.Colors.primary
                            )
                            .frame(width: 28)

                        Text("Visit Store Website")
                            .foregroundStyle(
                                AppTheme.Colors.primary
                            )

                        Spacer()

                        Image(
                            systemName: "arrow.up.right"
                        )
                        .font(.caption)
                    }
                    .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.plain)

            } else {

                informationRow(
                    title: "Website",
                    value: "Not available",
                    icon: "globe"
                )
            }
        }
        .modifier(StoreDetailCardStyle())
    }

    // MARK: - Information Row

    private func informationRow(
        title: String,
        value: String,
        icon: String
    ) -> some View {

        HStack(
            alignment: .top,
            spacing: AppTheme.Spacing.sm
        ) {

            Image(systemName: icon)
                .foregroundStyle(
                    AppTheme.Colors.primary
                )
                .frame(width: 28)

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline.weight(.medium))
                    .textSelection(.enabled)
            }

            Spacer()
        }
    }

    // MARK: - Actions

    private var actionSection: some View {

        VStack(spacing: AppTheme.Spacing.md) {

            PrimaryButton(
                title: "Get Directions",
                icon: "arrow.triangle.turn.up.right.diamond",
                action: {

                    viewModel.openDirections(to: store)
                }
            )

            if let onSelectPickupStore {

                Button {

                    onSelectPickupStore(store)
                    dismiss()

                } label: {

                    Label(
                        "Select for Pickup",
                        systemImage: "bag.badge.plus"
                    )
                    .font(AppTheme.Typography.button)
                    .foregroundStyle(
                        AppTheme.Colors.primary
                    )
                    .frame(maxWidth: .infinity)
                    .frame(
                        minHeight: AppTheme.Layout.buttonHeight
                    )
                    .background(
                        AppTheme.Colors.background
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: AppTheme.Radius.medium
                        )
                    )
                    .overlay {

                        RoundedRectangle(
                            cornerRadius: AppTheme.Radius.medium
                        )
                        .strokeBorder(
                            AppTheme.Colors.primary,
                            lineWidth: 1.5
                        )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {

        Label(
            AppConstants.Disclaimer.stores,
            systemImage: "info.circle"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .modifier(StoreDetailCardStyle())
    }
}

// MARK: - Card Style

private struct StoreDetailCardStyle: ViewModifier {

    func body(content: Content) -> some View {

        content
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.background)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.large
                )
            )
    }
}
