import Foundation
import SwiftData

@MainActor
final class DataSeeder {

    static func seed(context: ModelContext) throws {

        let descriptor = FetchDescriptor<ProductCategory>()
        let categoryCount = try context.fetchCount(descriptor)

        do {
            if categoryCount == 0 {
                seedProducts(context: context)
            }

            try seedCart(context: context)
            try context.save()

        } catch {
            context.rollback()
            throw error
        }
    }

    private static func seedProducts(context: ModelContext) {

        // MARK: - Categories

        let electronics = ProductCategory(
            name: "Electronics",
            icon: "headphones"
        )

        let clothing = ProductCategory(
            name: "Clothing",
            icon: "tshirt"
        )

        let home = ProductCategory(
            name: "Home",
            icon: "house"
        )

        let accessories = ProductCategory(
            name: "Accessories",
            icon: "backpack"
        )

        let sports = ProductCategory(
            name: "Sports",
            icon: "sportscourt"
        )

        let categories = [
            electronics,
            clothing,
            home,
            accessories,
            sports
        ]

        for category in categories {
            context.insert(category)
        }

        // MARK: - Electronics

        let products: [Product] = [

            Product(
                name: "Wireless Headphones",
                productDescription: "Comfortable wireless headphones with high-quality sound and long battery life.",
                priceInCents: 7999,
                stock: 25,
                imageName: "wireless_headphones",
                category: electronics
            ),

            Product(
                name: "Bluetooth Speaker",
                productDescription: "Portable Bluetooth speaker with powerful sound.",
                priceInCents: 4999,
                stock: 18,
                imageName: "bluetooth_speaker",
                category: electronics
            ),

            Product(
                name: "USB-C Charger",
                productDescription: "Compact fast charger compatible with USB-C devices.",
                priceInCents: 1999,
                stock: 50,
                imageName: "usb_c_charger",
                category: electronics
            ),

            Product(
                name: "Mechanical Keyboard",
                productDescription: "Mechanical keyboard designed for work and gaming.",
                priceInCents: 8999,
                stock: 12,
                imageName: "mechanical_keyboard",
                category: electronics
            ),

            // MARK: - Clothing

            Product(
                name: "Classic T-Shirt",
                productDescription: "Soft cotton T-shirt for everyday wear.",
                priceInCents: 1999,
                stock: 40,
                imageName: "classic_tshirt",
                category: clothing
            ),

            Product(
                name: "Comfort Hoodie",
                productDescription: "Warm and comfortable hoodie with a relaxed fit.",
                priceInCents: 4499,
                stock: 30,
                imageName: "comfort_hoodie",
                category: clothing
            ),

            Product(
                name: "Classic Sneakers",
                productDescription: "Versatile sneakers designed for everyday comfort.",
                priceInCents: 5999,
                stock: 20,
                imageName: "classic_sneakers",
                category: clothing
            ),

            Product(
                name: "Baseball Cap",
                productDescription: "Adjustable baseball cap with a minimalist design.",
                priceInCents: 1499,
                stock: 35,
                imageName: "baseball_cap",
                category: clothing
            ),

            // MARK: - Home

            Product(
                name: "Desk Lamp",
                productDescription: "Modern desk lamp with adjustable lighting.",
                priceInCents: 3499,
                stock: 15,
                imageName: "desk_lamp",
                category: home
            ),

            Product(
                name: "Soft Blanket",
                productDescription: "Comfortable blanket for relaxing at home.",
                priceInCents: 2999,
                stock: 22,
                imageName: "soft_blanket",
                category: home
            ),

            Product(
                name: "Ceramic Mug",
                productDescription: "Minimalist ceramic mug for hot beverages.",
                priceInCents: 1299,
                stock: 45,
                imageName: "ceramic_mug",
                category: home
            ),

            Product(
                name: "Decorative Cushion",
                productDescription: "Soft decorative cushion for your living space.",
                priceInCents: 2499,
                stock: 28,
                imageName: "decorative_cushion",
                category: home
            ),

            // MARK: - Accessories

            Product(
                name: "Everyday Backpack",
                productDescription: "Spacious backpack for school, work and travel.",
                priceInCents: 4499,
                stock: 20,
                imageName: "everyday_backpack",
                category: accessories
            ),

            Product(
                name: "Classic Watch",
                productDescription: "Elegant minimalist wristwatch.",
                priceInCents: 6999,
                stock: 10,
                imageName: "classic_watch",
                category: accessories
            ),

            Product(
                name: "Sunglasses",
                productDescription: "Stylish sunglasses with UV protection.",
                priceInCents: 2499,
                stock: 30,
                imageName: "sunglasses",
                category: accessories
            ),

            Product(
                name: "Leather Wallet",
                productDescription: "Compact wallet with multiple card compartments.",
                priceInCents: 2999,
                stock: 25,
                imageName: "leather_wallet",
                category: accessories
            ),

            // MARK: - Sports

            Product(
                name: "Water Bottle",
                productDescription: "Reusable insulated stainless steel water bottle.",
                priceInCents: 2499,
                stock: 40,
                imageName: "water_bottle",
                category: sports
            ),

            Product(
                name: "Yoga Mat",
                productDescription: "Non-slip exercise mat for yoga and stretching.",
                priceInCents: 3499,
                stock: 16,
                imageName: "yoga_mat",
                category: sports
            ),

            Product(
                name: "Dumbbell Set",
                productDescription: "Compact dumbbell set for home workouts.",
                priceInCents: 5499,
                stock: 8,
                imageName: "dumbbell_set",
                category: sports
            ),

            Product(
                name: "Resistance Bands",
                productDescription: "Set of resistance bands for strength training.",
                priceInCents: 1999,
                stock: 0,
                imageName: "resistance_bands",
                category: sports
            )
        ]

        for product in products {
            context.insert(product)
        }
    }

    private static func seedCart(
        context: ModelContext
    ) throws {

        let descriptor = FetchDescriptor<Cart>()
        let cartCount = try context.fetchCount(descriptor)

        if cartCount == 0 {
            let cart = Cart()
            context.insert(cart)
        }
    }
}
