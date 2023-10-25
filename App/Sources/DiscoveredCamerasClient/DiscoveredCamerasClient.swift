import Foundation
import Models
import Dependencies
import IdentifiedCollections

public protocol DiscoveredCamerasClientProtocol: Sendable {
    var discoveredCameras: AsyncStream<IdentifiedArrayOf<DiscoveredCameraModel>> { get }
}

struct DiscoveredCamerasClientMock: DiscoveredCamerasClientProtocol {
    private let cameras = [
        DiscoveredCameraModel(id: UUID(), cameraType: .nowPlus),
        DiscoveredCameraModel(id: UUID(), cameraType: .i2),
    ]
    
    var discoveredCameras: AsyncStream<IdentifiedArrayOf<DiscoveredCameraModel>> {
        AsyncStream { continuation in
            continuation.yield(
                IdentifiedArray(uniqueElements: cameras)
            )
        }
    }
}

public enum DiscoveredCamerasClientKey: TestDependencyKey {
    public static let testValue: DiscoveredCamerasClientProtocol = DiscoveredCamerasClientMock()
}

public extension DependencyValues {
    var discoveredCamerasClient: DiscoveredCamerasClientProtocol {
        get { self[DiscoveredCamerasClientKey.self] }
        set { self[DiscoveredCamerasClientKey.self] = newValue }
    }
}
