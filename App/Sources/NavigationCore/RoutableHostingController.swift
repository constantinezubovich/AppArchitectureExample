import SwiftUI
import ComposableArchitecture

public final class RoutableHostingController<
    Content: RoutableView,
    Router: RouterProtocol
> : UIHostingController<Content> where Router.Action == Content.Action, Router.State == Content.State {
    
    public init(rootView: Content, router: Router, routeClient: RouteClient<Router.Action.RouteDestination>) {
        super.init(rootView: rootView)
        
        routeClient.route = { [weak self, weak store = rootView.store] destination in
            guard
                let store = store,
                let self = self
            else {
                return
            }
            
            router.route(from: self, to: destination, parentStore: store)
        }
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
