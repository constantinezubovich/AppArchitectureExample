import Foundation

@MainActor
public final class RouteClient<Destination> {
    var route: ((Destination) -> Void) = { _ in }
    
    public init() { }
    
    public func rote(destination: Destination) {
        route(destination)
    }
}
