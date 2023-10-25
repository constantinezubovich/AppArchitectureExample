import SwiftUI
import Models
import CameraClient
import DiscoveredCamerasClient
@preconcurrency import ComposableArchitecture
import NavigationCore
import AsyncAlgorithms

public struct HomeFeature: RoutableReducer, Sendable {
    public struct State: Equatable, Sendable {
        var items: IdentifiedArrayOf<HomeCameraItemFeature.State> = []
        
        public init(items: IdentifiedArrayOf<HomeCameraItemFeature.State> = []) {
            self.items = items
        }
    }
    
    public enum Action: Equatable, RoutableAction, Sendable {
        public enum ViewAction: Equatable, Sendable {
            case task
            case itemTapped(HomeCameraItemFeature.State)
        }
        
        public enum InternalAction: Equatable, Sendable {
            case observeCameras
            case receivedCameras(
                discoveredCameras: IdentifiedArrayOf<DiscoveredCameraModel>,
                connectedCameras: IdentifiedArrayOf<CameraModel>
            )
        }
        
        public enum RouteDestination: Equatable, Sendable {
            case cameraDetails(CameraModel)
        }
        
        case viewAction(ViewAction)
        case internalAction(InternalAction)
        
        case items(id: HomeCameraItemFeature.State.ID, action: HomeCameraItemFeature.Action)
    }
    
    @Dependency(\.discoveredCamerasClient) var discoveredCamerasClient
    @Dependency(\.cameraClient) var cameraClient
    
    public let routeClient: RouteClient<Action.RouteDestination>
    public init(routeClient: RouteClient<Action.RouteDestination>) {
        self.routeClient = routeClient
    }
    
    public var body: some Reducer<State, Action> {
        Reduce(self._reduce)
            .forEach(\.items, action: /Action.items) {
                HomeCameraItemFeature()
            }
        
    }
    
    
    private func _reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .viewAction(let viewAction):
            return reduceViewAction(into: &state, action: viewAction)
            
        case .internalAction(let internalAction):
            return reduceInternalAction(into: &state, action: internalAction)
            
        case .items:
            return .none
        }
    }
    
    private func reduceViewAction(into state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .task:
            return .send(.internalAction(.observeCameras))
            
        case .itemTapped(let item):
            guard case .connected(let camera) = item.cameraState else {
                return .none
            }
            
            return .run { send in
                await routeClient.rote(destination: .cameraDetails(camera))
            }
        }
    }
    
    private func reduceInternalAction(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
        switch action {
        case .observeCameras:
            return .run { send in
                let stream = combineLatest(discoveredCamerasClient.discoveredCameras, cameraClient.connectedCameras)
                
                for await (discoveredCameras, connectedCameras) in stream {
                    await send(.internalAction(.receivedCameras(discoveredCameras: discoveredCameras, connectedCameras: connectedCameras)))
                }
            }
            
        case .receivedCameras(let discoveredCameras, let connectedCameras):
            let items = discoveredCameras.map { discoveredCamera in
                let connectedCamera = connectedCameras.first {
                    $0.id == discoveredCamera.id
                }
                
                return HomeCameraItemFeature.State(
                    camera: discoveredCamera,
                    cameraState: connectedCamera.map { .connected($0) } ?? .disconnected
                )
            }
            
            state.items = IdentifiedArray(uniqueElements: items)
            return .none
            
        }
    }
}


public struct HomeView: RoutableView {
    
    public let store: StoreOf<HomeFeature>
    @ObservedObject var viewStore: ViewStore<HomeFeature.State, HomeFeature.Action.ViewAction>
    
    public init(store: StoreOf<HomeFeature>) {
        self.store = store
        self.viewStore = ViewStore(
            store.scope(state: { $0 }, action: HomeFeature.Action.viewAction),
            observe: { $0 }
        )
    }
    
    public var body: some View {
        
        ScrollView {
            ForEachStore(
                self.store.scope(state: \.items, action: HomeFeature.Action.items(id:action:))
            ) { itemStore in
                HomeCameraItemView(store: itemStore)
                    .onTapGesture {
                        viewStore.send(
                            .itemTapped(
                                ViewStore(itemStore, observe: { $0 }).state
                            )
                        )
                    }
                    .padding()
            }
        }
        .task {
            await viewStore.send(.task).finish()
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: Store(
                initialState: HomeFeature.State(items: [
                    .init(
                        camera: .init(id: UUID(), cameraType: .nowPlus),
                        cameraState: .disconnected
                    ),
                    .init(
                        camera: .init(id: mockI2.id, cameraType: .i2),
                        cameraState: .connected(mockI2)
                    )
                ])
            ) {
                EmptyReducer()
            }
        )
    }
}


let mockI2 = CameraModel(id: UUID(), cameraType: .i2, numberOfFilms: 8, isEjecting: false)

