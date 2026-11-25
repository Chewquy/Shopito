import SwiftUI
import SwiftData

@main
@MainActor
struct ShopitoApp: App {

    private let persistenceController =
        PersistenceController.shared

    @State private var startupError: String?

    // MARK: - Initialization

    init() {

        do {

            try DataSeeder.seed(
                context: persistenceController.context
            )

            _startupError = State(
                initialValue: nil
            )

        } catch {

            _startupError = State(
                initialValue: error.localizedDescription
            )
        }
    }

    // MARK: - Body

    var body: some Scene {

        WindowGroup {

            Group {

                if let startupError {

                    ErrorStateView(
                        title: "Unable to Start Shopito",
                        message: startupError,
                        onRetry: initializeDatabase
                    )

                } else {

                    RootTabView(
                        context: persistenceController.context
                    )
                }
            }
            .tint(AppTheme.Colors.primary)
        }
        .modelContainer(
            persistenceController.container
        )
    }

    // MARK: - Database Initialization

    private func initializeDatabase() {

        do {

            try DataSeeder.seed(
                context: persistenceController.context
            )

            startupError = nil

        } catch {

            startupError = error.localizedDescription
        }
    }
}
