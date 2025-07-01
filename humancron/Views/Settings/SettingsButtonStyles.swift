import SwiftUI
import DesignSystem

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13))
            .foregroundColor(Token.Color.onSurface)
            .padding(.horizontal, Token.Spacing.x3)
            .padding(.vertical, Token.Spacing.x2)
            .background(
                RoundedRectangle(cornerRadius: Token.Radius.sm)
                    .fill(Token.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Token.Radius.sm)
                            .stroke(Token.Color.stroke, lineWidth: 1)
                    )
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}