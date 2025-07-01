import SwiftUI

public struct Elevation {
    public enum Level: Int {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
        
        var y: CGFloat {
            switch self {
            case .zero: return 0
            case .one: return 1
            case .two: return 2
            case .three: return 4
            }
        }
        
        var blur: CGFloat {
            switch self {
            case .zero: return 0
            case .one: return 3
            case .two: return 6
            case .three: return 12
            }
        }
        
        var opacity: Double {
            switch self {
            case .zero: return 0
            case .one: return 0.20
            case .two: return 0.15
            case .three: return 0.10
            }
        }
    }
}

public extension View {
    func elevation(_ level: Elevation.Level) -> some View {
        self.shadow(
            color: Color.black.opacity(level.opacity),
            radius: level.blur,
            x: 0,
            y: level.y
        )
    }
}