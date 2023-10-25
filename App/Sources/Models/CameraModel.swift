import Foundation

public struct CameraModel: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let cameraType: CameraType
    public var numberOfFilms: Int = 0
    public var isEjecting: Bool = false
    
    public init(
        id: UUID,
        cameraType: CameraType,
        numberOfFilms: Int = 0,
        isEjecting: Bool = false
    ) {
        self.id = id
        self.cameraType = cameraType
        self.numberOfFilms = numberOfFilms
        self.isEjecting = isEjecting
    }
    
}

public extension CameraModel {
    var name: String {
        cameraType.name
    }
}
