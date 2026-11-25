import SwiftUI

enum AppTheme {

    // MARK: - Colors

    enum Colors {

        static let primary = Color(
            red: 109.0 / 255,
            green: 40.0 / 255,
            blue: 217.0 / 255
        )

        static let secondary = Color(
            red: 139.0 / 255,
            green: 92.0 / 255,
            blue: 246.0 / 255
        )

        static let accent = Color(
            red: 245.0 / 255,
            green: 158.0 / 255,
            blue: 11.0 / 255
        )

        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red

        static let background = Color(
            uiColor: .systemBackground
        )

        static let surface = Color(
            uiColor: .secondarySystemBackground
        )

        static let groupedBackground = Color(
            uiColor: .systemGroupedBackground
        )

        static let primaryText = Color.primary
        static let secondaryText = Color.secondary

        static let border = Color(
            uiColor: .separator
        )

        static let onPrimary = Color.white
    }

    // MARK: - Spacing

    enum Spacing {

        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum Radius {

        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }

    // MARK: - Typography

    enum Typography {

        static let largeTitle =
            Font.largeTitle.weight(.bold)

        static let title =
            Font.title.weight(.bold)

        static let sectionTitle =
            Font.title2.weight(.semibold)

        static let headline =
            Font.headline

        static let body =
            Font.body

        static let caption =
            Font.caption

        static let price =
            Font.title3.weight(.bold)

        static let button =
            Font.headline.weight(.semibold)
    }

    // MARK: - Layout

    enum Layout {

        static let buttonHeight: CGFloat = 50
        static let minimumTouchTarget: CGFloat = 44

        static let productImageHeight: CGFloat = 150
        static let productDetailImageHeight: CGFloat = 300

        static let cartImageSize: CGFloat = 80

        static let minimumGridItemWidth: CGFloat = 150
    }

    // MARK: - Animation

    enum Motion {

        static let standard = Animation.easeInOut(
            duration: 0.25
        )

        static let spring = Animation.spring(
            response: 0.35,
            dampingFraction: 0.8
        )
    }
}
