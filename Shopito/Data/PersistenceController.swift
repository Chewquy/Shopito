import Foundation
import SwiftData

@MainActor
final class PersistenceController {

    static let shared = PersistenceController()

    let container: ModelContainer

    var context: ModelContext {
        container.mainContext
    }

    init(inMemory: Bool = false) {

        let schema = Schema([
            Product.self,
            ProductCategory.self,
            Cart.self,
            CartItem.self,
            Order.self,
            OrderItem.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        do {

            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )

            container.mainContext.autosaveEnabled = false

        } catch {

            fatalError(
                "Failed to initialize SwiftData: \(error)"
            )
        }
    }
}
