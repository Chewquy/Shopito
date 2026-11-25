import SwiftUI

struct EmptyStateView: View {

    let icon: String
    let title: String
    let message: String

    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {

        VStack(spacing: AppTheme.Spacing.md) {

            ZStack {

                Circle()
                    .fill(
                        AppTheme.Colors.primary.opacity(0.1)
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 42,
                            weight: .light
                        )
                    )
                    .foregroundStyle(
                        AppTheme.Colors.primary
                    )
            }
            .accessibilityHidden(true)

            Text(title)
                .font(AppTheme.Typography.sectionTitle)
                .multilineTextAlignment(.center)

            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundStyle(
                    AppTheme.Colors.secondaryText
                )
                .multilineTextAlignment(.center)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            if let actionTitle,
               let action {

                PrimaryButton(
                    title: actionTitle,
                    action: action
                )
                .frame(maxWidth: 260)
                .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {

    EmptyStateView(
        icon: "cart",
        title: "Your cart is empty",
        message: "Explore our products and add something you like.",
        actionTitle: "Continue Shopping"
    ) {}
}
