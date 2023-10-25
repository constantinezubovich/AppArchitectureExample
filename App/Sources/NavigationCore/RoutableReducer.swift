import Foundation
import ComposableArchitecture

public protocol RoutableReducer: Reducer where Action: RoutableAction {
    var routeClient: RouteClient<Action.RouteDestination> { get }
}
