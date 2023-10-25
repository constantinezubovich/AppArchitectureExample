import Foundation
import DiscoveredCamerasClient
import Models
import Dependencies
import IdentifiedCollections

// There should be a production implementation
struct DiscoveredCamerasClientLive: DiscoveredCamerasClientProtocol {
    private let cameras = [
        DiscoveredCameraModel(id: UUID(), cameraType: .i2),
        DiscoveredCameraModel(id: UUID(), cameraType: .nowPlus),
    ]
    
    var discoveredCameras: AsyncStream<IdentifiedArrayOf<DiscoveredCameraModel>> {
        AsyncStream { continuation in
            continuation.yield(
                IdentifiedArray(uniqueElements: cameras)
            )
        }
    }
}


extension DiscoveredCamerasClientKey: DependencyKey {
    public static let liveValue: DiscoveredCamerasClientProtocol = DiscoveredCamerasClientLive()
}

// Long compile time simulation
public let __tmp0 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
public let __tmp1 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
public let __tmp2 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
public let __tmp3 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
public let __tmp4 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
public let __tmp5 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
public let __tmp6 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
public let __tmp7 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
public let __tmp8 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
public let __tmp9 = 2 * 2 * 2 * 2.0 / 2 + 2 + 2 * 2 * 2 * 2.0 / 2 + 2
