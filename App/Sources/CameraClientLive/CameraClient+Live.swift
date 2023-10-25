import Foundation
import CameraClient
import Models
import IdentifiedCollections
import Dependencies

// There should be a production implementation
struct CameraClientLive: CameraClientProtocol {
    let connectedCameras: AsyncStream<IdentifiedArrayOf<CameraModel>> = AsyncStream { _ in }
    
    func observeConnectedCamera(_ camera: CameraModel) -> AsyncStream<Models.CameraModel> {
        AsyncStream { _ in }
    }
    
    func connect(discoveredCamera: DiscoveredCameraModel) async {
        
    }
    
    func disconnect(camera: CameraModel) async {
        
    }
    
    func makeAShot(on camera: CameraModel) async throws {
        
    }
}

extension CameraClientKey: DependencyKey {
//    public static let liveValue: CameraClientProtocol = CameraClientLive()
    
    // because production implementation is empty for this example we use mock as a liveValue
    public static let liveValue: CameraClientProtocol = CameraClientMock()
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
