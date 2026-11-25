import SwiftUI

struct QuantityStepper: View {

    let quantity: Int

    var minimum: Int = 1
    var maximum: Int = Int.max

    let onDecrease: () -> Void
    let onIncrease: () -> Void

    private var canDecrease: Bool {
        quantity > minimum
    }

    private var canIncrease: Bool {
        quantity < maximum
    }

    var body: some View {

        HStack(spacing: AppTheme.Spacing.xs) {

            stepButton(
                icon: "minus",
                accessibilityTitle: "Decrease quantity",
                isDisabled: !canDecrease,
                action: onDecrease
            )

            Text("\(quantity)")
                .font(.headline)
                .monospacedDigit()
                .frame(minWidth: 30)
                .accessibilityLabel("Quantity \(quantity)")

            stepButton(
                icon: "plus",
                accessibilityTitle: "Increase quantity",
                isDisabled: !canIncrease,
                action: onIncrease
            )
        }
        .padding(AppTheme.Spacing.xs)
        .background(AppTheme.Colors.surface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.medium
            )
        )
    }

    // MARK: - Step Button

    private func stepButton(
        icon: String,
        accessibilityTitle: String,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(
                    isDisabled
                    ? AppTheme.Colors.secondaryText
                    : AppTheme.Colors.primary
                )
                .frame(
                    width: AppTheme.Layout.minimumTouchTarget,
                    height: AppTheme.Layout.minimumTouchTarget
                )
                .background(
                    AppTheme.Colors.background
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppTheme.Radius.small
                    )
                )
                .opacity(isDisabled ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityTitle)
    }
}

// MARK: - Preview

#Preview {

    QuantityStepperPreview()
}

private struct QuantityStepperPreview: View {

    @State private var quantity = 1

    var body: some View {

        QuantityStepper(
            quantity: quantity,
            minimum: 1,
            maximum: 10,
            onDecrease: {
                quantity -= 1
            },
            onIncrease: {
                quantity += 1
            }
        )
        .padding()
    }
}
