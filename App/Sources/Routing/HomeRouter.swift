import SwiftUI
import NavigationCore
import HomeFeature
import CameraFeature
import ComposableArchitecture


public struct HomeRouter: RouterProtocol {
    public init() { }
    
    public func route(
        from context: UIViewController,
        to destination: HomeFeature.Action.RouteDestination,
        parentStore: StoreOf<HomeFeature>
    ) {
        switch destination {
        case .cameraDetails(let cameraModel):
            let routeClient = RouteClient<CameraDetailsFeature.Action.RouteDestination>()
            
            let store = Store(initialState: CameraDetailsFeature.State(camera: cameraModel)) {
                CameraDetailsFeature(routeClient: routeClient)
            }
            
            let vc = RoutableHostingController(
                rootView: CameraDetailsView(store: store),
                router: CameraDetailsRouter(), 
                routeClient: routeClient
            )
            
            context.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
