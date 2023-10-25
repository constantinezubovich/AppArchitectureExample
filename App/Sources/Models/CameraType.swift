import Foundation

public enum CameraType: Equatable, Sendable {
    case nowPlus
    case i2
}

public extension CameraType {
    var name: String {
        switch self {
        case .nowPlus:
            return "Now+"
        case .i2:
            return "I-2"
        }
    }
}
