import SwiftUI

struct ErrorStateView: View {

    var title: String = "Something went wrong"
    let message: String

    var retryTitle: String = "Try Again"
    var onRetry: (() -> Void)? = nil

    var body: some View {

        VStack(spacing: AppTheme.Spacing.md) {

            ZStack {

                Circle()
                    .fill(
                        AppTheme.Colors.danger.opacity(0.1)
                    )
                    .frame(width: 90, height: 90)

                Image(
                    systemName: "exclamationmark.triangle"
                )
                .font(
                    .system(
                        size: 38,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    AppTheme.Colors.danger
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

            if let onRetry {

                PrimaryButton(
                    title: retryTitle,
                    icon: "arrow.clockwise",
                    action: onRetry
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

    ErrorStateView(
        title: "Unable to load stores",
        message: "Check your internet connection and try again.",
        onRetry: {
            print("Retry requested")
        }
    )
}
