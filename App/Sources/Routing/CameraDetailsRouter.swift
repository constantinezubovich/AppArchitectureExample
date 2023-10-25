import SwiftUI
import NavigationCore
import CameraFeature
import ComposableArchitecture


public struct CameraDetailsRouter: RouterProtocol {
    public init() { }
    
    public func route(
        from context: UIViewController,
        to destination: CameraDetailsFeature.Action.RouteDestination,
        parentStore: StoreOf<CameraDetailsFeature>
    ) {
        switch destination {
        case .dismiss:
            context.navigationController?.popToRootViewController(animated: true)
        }
    }
}
