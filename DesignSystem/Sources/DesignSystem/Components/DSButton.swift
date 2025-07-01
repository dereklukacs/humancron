import SwiftUI

public struct DSButton: View {
    public enum Style {
        case primary
        case secondary
        case tertiary
        
        var backgroundColor: Color {
            switch self {
            case .primary: return Token.Color.brand
            case .secondary: return Token.Color.surface
            case .tertiary: return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return Token.Color.onBrand
            case .secondary: return Token.Color.onSurface
            case .tertiary: return Token.Color.brand
            }
        }
        
        var borderColor: Color? {
            switch self {
            case .primary: return nil
            case .secondary: return Token.Color.stroke
            case .tertiary: return nil
            }
        }
    }
    
    let title: String
    let style: Style
    let action: () -> Void
    
    public init(_ title: String, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(.body)
                .foregroundColor(style.foregroundColor)
                .padding(.horizontal, Token.Spacing.x4)
                .padding(.vertical, Token.Spacing.x2)
                .background(style.backgroundColor)
                .cornerRadius(Token.Radius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: Token.Radius.md)
                        .stroke(style.borderColor ?? Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews
struct DSButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Token.Spacing.x4) {
            DSButton("Primary Button", style: .primary) { }
            DSButton("Secondary Button", style: .secondary) { }
            DSButton("Tertiary Button", style: .tertiary) { }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}