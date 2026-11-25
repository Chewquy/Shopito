import SwiftUI
import SwiftData

@MainActor
struct RootTabView: View {

    // MARK: - Navigation

    private enum Tab: Hashable {

        case shop
        case cart
        case stores
        case orders
    }

    @State private var selectedTab: Tab = .shop
    @State private var showCheckout = false

    // MARK: - ViewModels

    @State private var shopViewModel: ShopViewModel
    @State private var cartViewModel: CartViewModel
    @State private var checkoutViewModel: CheckoutViewModel
    @State private var storeLocatorViewModel: StoreLocatorViewModel
    @State private var orderHistoryViewModel: OrderHistoryViewModel

    // MARK: - Initialization

    init(context: ModelContext) {

        // Repositories

        let productRepository = ProductRepository(
            context: context
        )

        let cartRepository = CartRepository(
            context: context
        )

        let orderRepository = OrderRepository(
            context: context
        )

        // Services

        let pricingService = PricingService()

        let checkoutService = CheckoutService(
            context: context,
            pricingService: pricingService
        )

        let locationService = LocationService()

        let storeSearchService = StoreSearchService()

        // ViewModels

        let shopVM = ShopViewModel(
            productRepository: productRepository
        )

        let cartVM = CartViewModel(
            cartRepository: cartRepository
        )

        let checkoutVM = CheckoutViewModel(
            cartViewModel: cartVM,
            pricingService: pricingService,
            checkoutService: checkoutService
        )

        let storeVM = StoreLocatorViewModel(
            locationService: locationService,
            storeSearchService: storeSearchService
        )

        let orderVM = OrderHistoryViewModel(
            orderRepository: orderRepository
        )

        // Initialize observable state

        _shopViewModel = State(
            initialValue: shopVM
        )

        _cartViewModel = State(
            initialValue: cartVM
        )

        _checkoutViewModel = State(
            initialValue: checkoutVM
        )

        _storeLocatorViewModel = State(
            initialValue: storeVM
        )

        _orderHistoryViewModel = State(
            initialValue: orderVM
        )
    }

    // MARK: - Body

    var body: some View {

        TabView(selection: $selectedTab) {

            shopTab

            cartTab

            storesTab

            ordersTab
        }
        .tint(AppTheme.Colors.primary)
        .sheet(
            isPresented: $showCheckout,
            onDismiss: handleCheckoutDismissal
        ) {

            checkoutSheet
        }
        .task {

            loadInitialData()
        }
    }

    // MARK: - Shop Tab

    private var shopTab: some View {

        NavigationStack {

            ShopView(
                viewModel: shopViewModel,
                cartViewModel: cartViewModel
            )
        }
        .tabItem {

            Label(
                "Shop",
                systemImage: "bag"
            )
        }
        .tag(Tab.shop)
    }

    // MARK: - Cart Tab

    private var cartTab: some View {

        NavigationStack {

            CartView(
                viewModel: cartViewModel,
                onContinueShopping: {

                    selectedTab = .shop
                },
                onCheckout: {

                    openCheckout()
                }
            )
        }
        .tabItem {

            Label(
                "Cart",
                systemImage: "cart"
            )
        }
        .badge(cartViewModel.totalQuantity)
        .tag(Tab.cart)
    }

    // MARK: - Stores Tab

    private var storesTab: some View {

        NavigationStack {

            StoreMapView(
                viewModel: storeLocatorViewModel,
                onSelectPickupStore: { store in

                    selectPickupStore(store)
                }
            )
        }
        .tabItem {

            Label(
                "Stores",
                systemImage: "map"
            )
        }
        .tag(Tab.stores)
    }

    // MARK: - Orders Tab

    private var ordersTab: some View {

        NavigationStack {

            OrderHistoryView(
                viewModel: orderHistoryViewModel
            )
        }
        .tabItem {

            Label(
                "Orders",
                systemImage: "receipt"
            )
        }
        .tag(Tab.orders)
    }

    // MARK: - Checkout Sheet

    private var checkoutSheet: some View {

        NavigationStack {

            CheckoutView(
                viewModel: checkoutViewModel,
                storeLocatorViewModel:
                    storeLocatorViewModel,
                onOrderCompleted: {

                    handleOrderCompleted()
                }
            )
        }
        .tint(AppTheme.Colors.primary)
    }

    // MARK: - Initial Data

    private func loadInitialData() {

        shopViewModel.loadData()

        cartViewModel.loadCart()

        orderHistoryViewModel.loadOrders()
    }

    // MARK: - Checkout Navigation

    private func openCheckout() {

        guard cartViewModel.validateCart() else {
            return
        }

        // Preserve a store previously selected
        // from the Stores tab.

        let previouslySelectedStore =
            checkoutViewModel.selectedStore

        checkoutViewModel.resetCheckout()

        if let previouslySelectedStore {

            checkoutViewModel.selectFulfillmentMethod(
                .pickup
            )

            checkoutViewModel.selectStore(
                previouslySelectedStore
            )
        }

        showCheckout = true
    }

    // MARK: - Pickup Selection

    private func selectPickupStore(
        _ store: StoreLocation
    ) {

        checkoutViewModel.selectFulfillmentMethod(
            .pickup
        )

        checkoutViewModel.selectStore(store)

        selectedTab = .cart
    }

    // MARK: - Order Completion

    private func handleOrderCompleted() {

        shopViewModel.refresh()

        cartViewModel.loadCart()

        orderHistoryViewModel.loadOrders()

        selectedTab = .orders
    }

    // MARK: - Checkout Dismissal

    private func handleCheckoutDismissal() {

        checkoutViewModel.resetCheckout()

        cartViewModel.loadCart()

        orderHistoryViewModel.loadOrders()

        shopViewModel.refresh()
    }
}
