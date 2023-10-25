import SwiftUI
import Routing
import NavigationCore
import HomeFeature
import Models
import ComposableArchitecture

@MainActor
public final class AppCoordinator {
    let window: UIWindow
    
    public init(window: UIWindow) {
        self.window = window
    }
    
    public func run() {
        let routeClient = RouteClient<HomeFeature.Action.RouteDestination>()
        let vc = RoutableHostingController(
            rootView: HomeView(
                store: Store(initialState: HomeFeature.State()) {
                    HomeFeature(routeClient: routeClient)
                }
            ),
            router: HomeRouter(), 
            routeClient: routeClient
        )
        
        window.rootViewController = UINavigationController(rootViewController: vc)
        window.makeKeyAndVisible()
    }
}
