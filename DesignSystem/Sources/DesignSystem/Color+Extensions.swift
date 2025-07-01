import SwiftUI

extension Color {
    public init(light: Color, dark: Color) {
        self = Color(NSColor(name: nil, dynamicProvider: { appearance in
            switch appearance.name {
            case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
                return NSColor(dark)
            default:
                return NSColor(light)
            }
        }))
    }
}