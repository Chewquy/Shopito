import Foundation

enum InputValidator {

    // MARK: - String Helpers

    static func trimmed(_ value: String) -> String {

        value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    static func isNotEmpty(_ value: String) -> Bool {

        !trimmed(value).isEmpty
    }

    // MARK: - Name Validation

    static func isValidName(_ name: String) -> Bool {

        let cleanName = trimmed(name)

        return !cleanName.isEmpty
            && cleanName.count <= 100
            && cleanName.rangeOfCharacter(
                from: .letters
            ) != nil
    }

    // MARK: - Email Validation

    static func isValidEmail(_ email: String) -> Bool {

        let cleanEmail = trimmed(email)

        let pattern =
            #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        return cleanEmail.count <= 254
            && matches(cleanEmail, pattern: pattern)
    }

    // MARK: - Postal Code Validation

    static func isValidPostalCode(
        _ postalCode: String
    ) -> Bool {

        let cleanPostalCode = trimmed(postalCode)
            .uppercased()

        let pattern =
            #"^[ABCEGHJ-NPRSTVXY][0-9][ABCEGHJ-NPRSTV-Z] ?[0-9][ABCEGHJ-NPRSTV-Z][0-9]$"#

        return matches(
            cleanPostalCode,
            pattern: pattern
        )
    }

    static func formatPostalCode(
        _ postalCode: String
    ) -> String {

        let cleaned = trimmed(postalCode)
            .uppercased()
            .replacingOccurrences(of: " ", with: "")

        guard cleaned.count == 6,
              isValidPostalCode(cleaned) else {

            return trimmed(postalCode).uppercased()
        }

        let firstPart = cleaned.prefix(3)
        let secondPart = cleaned.suffix(3)

        return "\(firstPart) \(secondPart)"
    }

    // MARK: - Address Validation

    static func isValidAddress(
        streetAddress: String,
        city: String,
        postalCode: String
    ) -> Bool {

        return isNotEmpty(streetAddress)
            && isNotEmpty(city)
            && isValidPostalCode(postalCode)
    }

    static func formatAddress(
        streetAddress: String,
        city: String,
        postalCode: String
    ) -> String {

        let street = trimmed(streetAddress)
        let city = trimmed(city)
        let postalCode = formatPostalCode(postalCode)

        return "\(street), \(city), \(postalCode)"
    }

    // MARK: - Quantity Validation

    static func isValidQuantity(
        _ quantity: Int,
        availableStock: Int
    ) -> Bool {

        quantity > 0
            && quantity <= availableStock
    }

    // MARK: - Price Validation

    static func isValidPrice(
        cents: Int
    ) -> Bool {

        cents >= 0
    }

    // MARK: - Private Helpers

    private static func matches(
        _ value: String,
        pattern: String
    ) -> Bool {

        value.range(
            of: pattern,
            options: .regularExpression
        ) != nil
    }
}
