import SwiftUI
import Models
import CameraClient
@preconcurrency import ComposableArchitecture
import Dependencies
import NavigationCore

public struct CameraDetailsFeature: RoutableReducer, Sendable {
    public struct State: Equatable, Sendable {
        var camera: CameraModel
        
        public init(camera: CameraModel) {
            self.camera = camera
        }
        
        var shutterButtonDisabled: Bool {
            camera.isEjecting || camera.numberOfFilms == 0
        }
    }
    
    public enum Action: Equatable, RoutableAction, Sendable {
        public enum ViewAction: Equatable, Sendable {
            case task
            case makeShotTapped
            case disconnectTapped
        }
        
        public enum InternalAction: Equatable, Sendable {
            case observeCameraChanges
            case cameraUpdated(CameraModel)
            case makeAShot
            case disconnect
        }
        
        public enum RouteDestination: Equatable, Sendable {
            case dismiss
        }
        
        case viewAction(ViewAction)
        case internalAction(InternalAction)
    }
    
    @Dependency(\.cameraClient) var cameraClient
    
    public let routeClient: RouteClient<Action.RouteDestination>
    public init(routeClient: RouteClient<Action.RouteDestination>) {
        self.routeClient = routeClient
    }
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .viewAction(let viewAction):
            return reduceViewAction(into: &state, action: viewAction)
            
        case .internalAction(let internalAction):
            return reduceInternalAction(into: &state, action: internalAction)
        }
    }
    
    private func reduceViewAction(into state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .task:
            return .send(.internalAction(.observeCameraChanges))
            
        case .makeShotTapped:
            return .send(.internalAction(.makeAShot))
            
        case .disconnectTapped:
            return .send(.internalAction(.disconnect))
        }
    }
    
    private func reduceInternalAction(into state: inout State, action: Action.InternalAction) -> Effect<Action> {
        switch action {
        case .observeCameraChanges:
            return .run { [pairedCamera = state.camera] send in
                for await camera in cameraClient.observeConnectedCamera(pairedCamera) {
                    await send(.internalAction(.cameraUpdated(camera)))
                }
            }
            
        case .cameraUpdated(let camera):
            state.camera = camera
            return .none
            
        case .makeAShot:
            return .run { [camera = state.camera] send in
                try await cameraClient.makeAShot(on: camera)
            }
            
        case .disconnect:
            return .run { [camera = state.camera] send in
                await cameraClient.disconnect(camera: camera)
                await routeClient.rote(destination: .dismiss)
            }
        }
    }
}

public struct CameraDetailsView: RoutableView {
    public let store: Store<CameraDetailsFeature.State, CameraDetailsFeature.Action>
    @ObservedObject var viewStore: ViewStore<CameraDetailsFeature.State, CameraDetailsFeature.Action.ViewAction>
    
    public init(store: StoreOf<CameraDetailsFeature>) {
        self.store = store
        self.viewStore = ViewStore(
            store.scope(state: { $0 }, action: CameraDetailsFeature.Action.viewAction),
            observe: { $0 }
        )
    }
    
    public var body: some View {
        VStack {
            Text("Films count: \(viewStore.camera.numberOfFilms)")
            
            Spacer()
            
            if viewStore.camera.isEjecting {
                Text("Camera is making a shot")
            }
            
            Spacer()
            
            Button {
                viewStore.send(.makeShotTapped)
            } label: {
                Circle()
                    .fill(viewStore.shutterButtonDisabled ? Color.gray : Color.red)
                    .frame(width: 88)
            }
            .disabled(viewStore.shutterButtonDisabled)

        }
        .navigationTitle(viewStore.camera.name)
        .toolbar {
            Button("Disconnect") {
                viewStore.send(.disconnectTapped)
            }
        }
        .task {
            await viewStore.send(.task).finish()
        }
    }
}

