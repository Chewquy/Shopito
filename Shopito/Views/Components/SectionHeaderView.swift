import SwiftUI

struct SectionHeaderView: View {

    let title: String

    var subtitle: String? = nil
    var icon: String? = nil

    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {

        HStack(
            alignment: .center,
            spacing: AppTheme.Spacing.sm
        ) {

            VStack(
                alignment: .leading,
                spacing: AppTheme.Spacing.xs
            ) {

                HStack(
                    spacing: AppTheme.Spacing.sm
                ) {

                    if let icon {

                        Image(systemName: icon)
                            .foregroundStyle(
                                AppTheme.Colors.primary
                            )
                            .accessibilityHidden(true)
                    }

                    Text(title)
                        .accessibilityAddTraits(.isHeader)
                }
                .font(AppTheme.Typography.sectionTitle)

                if let subtitle {

                    Text(subtitle)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(
                            AppTheme.Colors.secondaryText
                        )
                }
            }

            Spacer()

            if let actionTitle,
               let action {

                Button(action: action) {

                    Text(actionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(
                            AppTheme.Colors.primary
                        )
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
}

// MARK: - Preview

#Preview {

    VStack(spacing: 24) {

        SectionHeaderView(
            title: "Featured Products",
            subtitle: "Discover our latest products",
            icon: "sparkles",
            actionTitle: "See All"
        ) {}

        Divider()

        SectionHeaderView(
            title: "Order Summary",
            icon: "receipt"
        )

        Divider()

        SectionHeaderView(
            title: "Spending Statistics",
            subtitle: "Your activity over the last 6 months",
            icon: "chart.bar"
        )
    }
    .padding()
}
