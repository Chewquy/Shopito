import SwiftUI

struct LoadingView: View {

    var message: String = "Loading..."

    var body: some View {

        VStack(spacing: AppTheme.Spacing.md) {

            ProgressView()
                .controlSize(.large)
                .tint(AppTheme.Colors.primary)

            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundStyle(
                    AppTheme.Colors.secondaryText
                )
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview {

    VStack(spacing: 32) {

        LoadingView()

        LoadingView(
            message: "Finding nearby stores..."
        )

        LoadingView(
            message: "Processing your order..."
        )
    }
    .padding()
}
