import Foundation

public struct DiscoveredCameraModel: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let cameraType: CameraType
    
    public init(id: UUID, cameraType: CameraType) {
        self.id = id
        self.cameraType = cameraType
    }
    
}
