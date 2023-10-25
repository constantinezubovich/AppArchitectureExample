import UIKit
import ComposableArchitecture

@MainActor
public protocol RouterProtocol {
    associatedtype State: Equatable
    associatedtype Action: RoutableAction
    
    func route(
        from context: UIViewController,
        to destination: Action.RouteDestination,
        parentStore: Store<State, Action>
    )
}

