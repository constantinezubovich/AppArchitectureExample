import SwiftUI
import ComposableArchitecture

public protocol RoutableView: View {
    associatedtype State: Equatable
    associatedtype Action: RoutableAction
    
    var store: Store<State, Action> { get }
}
