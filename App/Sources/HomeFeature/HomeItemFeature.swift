import Foundation
import Models
import ComposableArchitecture
import CameraClient
import SwiftUI
import Dependencies

public struct HomeCameraItemFeature: Reducer, Sendable {
    public struct State: Equatable, Identifiable, Sendable {
        let camera: DiscoveredCameraModel
        let cameraState: CameraState
        
        public var id: UUID {
            camera.id
        }
        
        enum CameraState: Equatable {
            case connected(CameraModel)
            case disconnected
        }
    }
    
    public enum Action: Equatable, Sendable {
        public enum ViewAction: Equatable, Sendable {
            case connectTapped
            case disconnectTapped
        }
        
        public enum InternalAction: Equatable, Sendable {
            case connect
            case disconnect
        }
        
        case viewAction(ViewAction)
        case internalAction(InternalAction)
    }
    
    @Dependency(\.cameraClient) var cameraClient
    
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .viewAction(let viewAction):
            return _reduce(into: &state, viewAction: viewAction)
        case .internalAction(let internalAction):
            return _reduce(into: &state, internalAction: internalAction)
        }
    }
    
    private func _reduce(into state: inout State, viewAction: Action.ViewAction) -> Effect<Action> {
        switch viewAction {
        case .connectTapped:
            return .send(.internalAction(.connect))
            
        case .disconnectTapped:
            return .send(.internalAction(.disconnect))
        }
    }
    
    private func _reduce(into state: inout State, internalAction: Action.InternalAction) -> Effect<Action> {
        switch internalAction {
        case .connect:
            return .run { [camera = state.camera] _ in
                await cameraClient.connect(discoveredCamera: camera)
            }
        
        case .disconnect:
            guard case .connected(let camera) = state.cameraState else {
                return .none
            }
            
            return .run { _ in
                await cameraClient.disconnect(camera: camera)
            }
        }
    }
}

struct HomeCameraItemView: View {
    
    let store: StoreOf<HomeCameraItemFeature>
    @ObservedObject var viewStore: ViewStore<HomeCameraItemFeature.State, HomeCameraItemFeature.Action.ViewAction>
    
    init(store: StoreOf<HomeCameraItemFeature>) {
        self.store = store
        self.viewStore = ViewStore(
            store.scope(state: { $0 }, action: HomeCameraItemFeature.Action.viewAction),
            observe: { $0 }
        )
    }
    
    public var body: some View {
        HStack {
            cameraInfoView
            
            if viewStore.cameraState != .disconnected {
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.mint)
        .cornerRadius(12)
    }
    
    private var cameraInfoView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(viewStore.camera.cameraType.name)
            
            switch viewStore.cameraState {
            case .connected(let camera):
                Text("Films count: \(camera.numberOfFilms)")
                
                Button("Disconnect") {
                    viewStore.send(.disconnectTapped)
                }
            case .disconnected:
                Button("Connect") {
                    viewStore.send(.connectTapped)
                }
            }
        }
    }
}


struct HomeCameraItemView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCameraItemView(
            store: Store(
                initialState: HomeCameraItemFeature.State(
                    camera: .init(id: UUID(), cameraType: .i2),
                    cameraState: .disconnected
                )
            ) {
                EmptyReducer()
            }
        )
    }
}
