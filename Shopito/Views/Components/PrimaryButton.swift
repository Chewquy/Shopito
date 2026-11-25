import SwiftUI

struct PrimaryButton: View {

    let title: String
    var icon: String? = nil
    var isDisabled: Bool = false
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack(spacing: AppTheme.Spacing.sm) {

                if isLoading {

                    ProgressView()
                        .tint(AppTheme.Colors.onPrimary)

                } else {

                    if let icon {
                        Image(systemName: icon)
                    }

                    Text(title)
                }
            }
            .font(AppTheme.Typography.button)
            .foregroundStyle(AppTheme.Colors.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppTheme.Layout.buttonHeight)
            .padding(.horizontal, AppTheme.Spacing.md)
            .background(
                isDisabled
                ? Color.gray
                : AppTheme.Colors.primary
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Radius.medium
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
    }
}

// MARK: - Preview

#Preview {

    VStack(spacing: 16) {

        PrimaryButton(
            title: "Add to Cart",
            icon: "cart.badge.plus"
        ) {}

        PrimaryButton(
            title: "Proceed to Checkout",
            icon: "arrow.right"
        ) {}

        PrimaryButton(
            title: "Out of Stock",
            isDisabled: true
        ) {}

        PrimaryButton(
            title: "Processing",
            isLoading: true
        ) {}
    }
    .padding()
}
