import Foundation
import Models
import Dependencies
import IdentifiedCollections
@preconcurrency import Combine

public protocol CameraClientProtocol: Sendable {
    var connectedCameras: AsyncStream<IdentifiedArrayOf<CameraModel>> { get }
    
    func observeConnectedCamera(_ camera: CameraModel) -> AsyncStream<CameraModel>
    
    func connect(discoveredCamera: DiscoveredCameraModel) async
    func disconnect(camera: CameraModel) async
    func makeAShot(on camera: CameraModel) async throws
}

public struct CameraClientMock: CameraClientProtocol {
    
    private let subject: CurrentValueSubject<IdentifiedArrayOf<CameraModel>, Never> = CurrentValueSubject([])
    
    public var connectedCameras: AsyncStream<IdentifiedArrayOf<CameraModel>> {
        subject.values.eraseToStream()
    }
    
    public init() { }
    
    public func observeConnectedCamera(_ camera: CameraModel) -> AsyncStream<CameraModel> {
        subject
            .compactMap { cameras in
                cameras.first { $0.id == camera.id }
            }
            .eraseToAnyPublisher()
            .values
            .eraseToStream()
    }
    
    public func connect(discoveredCamera: DiscoveredCameraModel) async {
        subject.value.append(
            CameraModel(
                id: discoveredCamera.id,
                cameraType: discoveredCamera.cameraType,
                numberOfFilms: 8,
                isEjecting: false
            )
        )
    }
    
    public func disconnect(camera: CameraModel) async {
        subject.value.remove(camera)
    }
    
    public func makeAShot(on camera: CameraModel) async throws {
        // Simulate making a shot
        
        subject.value[id: camera.id]?.isEjecting = true
        
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
        
        subject.value[id: camera.id]?.isEjecting = false
        subject.value[id: camera.id]?.numberOfFilms -= 1
    }
}



public enum CameraClientKey: TestDependencyKey {
    public static let testValue: CameraClientProtocol = CameraClientMock()
}

public extension DependencyValues {
    var cameraClient: CameraClientProtocol {
        get { self[CameraClientKey.self] }
        set { self[CameraClientKey.self] = newValue }
    }
}
