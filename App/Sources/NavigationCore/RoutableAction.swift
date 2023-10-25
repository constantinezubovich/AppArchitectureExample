import Foundation
import ComposableArchitecture

public protocol RoutableAction {
    associatedtype RouteDestination: Equatable
}
