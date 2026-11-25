import Foundation

enum AppError: LocalizedError {

    case databaseInitializationFailed
    case dataLoadingFailed
    case dataSavingFailed
    case productNotFound
    case orderNotFound
    case cartNotFound
    case invalidInput(message: String)
    case networkUnavailable
    case operationFailed(message: String)
    case unknown

    // MARK: - Error Description

    var errorDescription: String? {

        switch self {

        case .databaseInitializationFailed:
            return "Unable to initialize the application database."

        case .dataLoadingFailed:
            return "Unable to load the requested data."

        case .dataSavingFailed:
            return "Your changes could not be saved."

        case .productNotFound:
            return "The requested product could not be found."

        case .orderNotFound:
            return "The requested order could not be found."

        case .cartNotFound:
            return "Your shopping cart could not be found."

        case .invalidInput(let message):
            return message

        case .networkUnavailable:
            return "An internet connection is required for this feature."

        case .operationFailed(let message):
            return message

        case .unknown:
            return "An unexpected error occurred."
        }
    }

    // MARK: - Recovery Suggestion

    var recoverySuggestion: String? {

        switch self {

        case .databaseInitializationFailed:
            return "Try restarting the application."

        case .dataLoadingFailed, .dataSavingFailed:
            return "Please try again."

        case .productNotFound, .orderNotFound:
            return "Refresh the page and try again."

        case .cartNotFound:
            return "Return to the shopping catalog."

        case .invalidInput:
            return "Check the information you entered."

        case .networkUnavailable:
            return "Check your internet connection."

        case .operationFailed, .unknown:
            return "Please try again later."
        }
    }
}

// MARK: - Alert Information

struct AppAlert: Identifiable {

    let id = UUID()
    let title: String
    let message: String

    init(
        title: String = "Something went wrong",
        message: String
    ) {

        self.title = title
        self.message = message
    }

    init(error: Error) {

        self.title = "Something went wrong"
        self.message = error.localizedDescription
    }
}
