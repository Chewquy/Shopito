import SwiftUI

struct CustomerInformationView: View {

    @Bindable var viewModel: CheckoutViewModel

    // MARK: - Focus Management

    private enum Field: Hashable {

        case name
        case email
        case street
        case city
        case postalCode
    }

    @FocusState private var focusedField: Field?

    // MARK: - Body

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Customer Information",
                icon: "person.crop.circle"
            )

            nameField

            emailField

            if viewModel.fulfillmentMethod == .delivery {

                Divider()

                addressSection
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Radius.large
            )
        )
        .animation(
            AppTheme.Motion.standard,
            value: viewModel.fulfillmentMethod
        )
        .toolbar {

            ToolbarItemGroup(placement: .keyboard) {

                Spacer()

                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }

    // MARK: - Name

    private var nameField: some View {

        VStack(alignment: .leading, spacing: 6) {

            fieldLabel("Full Name")

            TextField(
                "Enter your full name",
                text: $viewModel.customerName
            )
            .textContentType(.name)
            .textInputAutocapitalization(.words)
            .submitLabel(.next)
            .focused($focusedField, equals: .name)
            .onSubmit {
                focusedField = .email
            }
            .modifier(CheckoutInputStyle())

            if !viewModel.customerName.isEmpty,
               !viewModel.isNameValid {

                validationMessage(
                    "Please enter a valid name."
                )
            }
        }
    }

    // MARK: - Email

    private var emailField: some View {

        VStack(alignment: .leading, spacing: 6) {

            fieldLabel("Email Address")

            TextField(
                "example@email.com",
                text: $viewModel.customerEmail
            )
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .focused($focusedField, equals: .email)
            .onSubmit {

                focusedField =
                    viewModel.fulfillmentMethod == .delivery
                    ? .street
                    : nil
            }
            .modifier(CheckoutInputStyle())

            if !viewModel.customerEmail.isEmpty,
               !viewModel.isEmailValid {

                validationMessage(
                    "Please enter a valid email address."
                )
            }
        }
    }

    // MARK: - Address Section

    private var addressSection: some View {

        VStack(
            alignment: .leading,
            spacing: AppTheme.Spacing.md
        ) {

            SectionHeaderView(
                title: "Delivery Address",
                icon: "location"
            )

            VStack(alignment: .leading, spacing: 6) {

                fieldLabel("Street Address")

                TextField(
                    "Street and apartment number",
                    text: $viewModel.streetAddress
                )
                .textContentType(.fullStreetAddress)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .focused($focusedField, equals: .street)
                .onSubmit {
                    focusedField = .city
                }
                .modifier(CheckoutInputStyle())
            }

            VStack(alignment: .leading, spacing: 6) {

                fieldLabel("City")

                TextField(
                    "Enter your city",
                    text: $viewModel.city
                )
                .textContentType(.addressCity)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .focused($focusedField, equals: .city)
                .onSubmit {
                    focusedField = .postalCode
                }
                .modifier(CheckoutInputStyle())
            }

            postalCodeField

            Label(
                "Canada",
                systemImage: "globe.americas"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(
                "This demonstration uses Quebec tax rates."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Postal Code

    private var postalCodeField: some View {

        VStack(alignment: .leading, spacing: 6) {

            fieldLabel("Postal Code")

            TextField(
                "A1A 1A1",
                text: $viewModel.postalCode
            )
            .textContentType(.postalCode)
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .focused($focusedField, equals: .postalCode)
            .onSubmit {

                viewModel.postalCode =
                    InputValidator.formatPostalCode(
                        viewModel.postalCode
                    )

                focusedField = nil
            }
            .modifier(CheckoutInputStyle())

            if !viewModel.postalCode.isEmpty,
               !viewModel.isPostalCodeValid {

                validationMessage(
                    "Enter a valid Canadian postal code."
                )
            }
        }
    }

    // MARK: - Helpers

    private func fieldLabel(
        _ title: String
    ) -> some View {

        HStack(spacing: 4) {

            Text(title)
                .font(.subheadline.weight(.medium))

            Text("*")
                .foregroundStyle(AppTheme.Colors.danger)
        }
    }

    private func validationMessage(
        _ message: String
    ) -> some View {

        Label(
            message,
            systemImage: "exclamationmark.circle"
        )
        .font(.caption)
        .foregroundStyle(AppTheme.Colors.danger)
    }
}

// MARK: - Reusable Input Style

private struct CheckoutInputStyle: ViewModifier {

    func body(content: Content) -> some View {

        content
            .font(.body)
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.surface)
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
                    AppTheme.Colors.border.opacity(0.2),
                    lineWidth: 1
                )
            }
    }
}
