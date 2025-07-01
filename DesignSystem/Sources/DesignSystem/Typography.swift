import SwiftUI

public struct Typography {
    public enum TextStyle {
        case displayLarge
        case displaySmall
        case title
        case headline
        case body
        case bodySmall
        case caption
        
        var size: CGFloat {
            switch self {
            case .displayLarge: return 32
            case .displaySmall: return 24
            case .title: return 20
            case .headline: return 17
            case .body: return 15
            case .bodySmall: return 13
            case .caption: return 11
            }
        }
        
        var weight: Font.Weight {
            switch self {
            case .displayLarge, .displaySmall: return .bold
            case .title, .headline: return .semibold
            case .body, .bodySmall, .caption: return .regular
            }
        }
    }
}

public extension View {
    func textStyle(_ style: Typography.TextStyle) -> some View {
        self
            .font(.system(size: style.size, weight: style.weight, design: .default))
    }
}

public extension Text {
    func textStyle(_ style: Typography.TextStyle) -> Text {
        self
            .font(.system(size: style.size, weight: style.weight, design: .default))
    }
}