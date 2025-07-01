import SwiftUI

public struct ShortcutHint: View {
    let keys: [String]
    
    public init(_ keys: String...) {
        self.keys = keys
    }
    
    public init(keys: [String]) {
        self.keys = keys
    }
    
    public var body: some View {
        HStack(spacing: Token.Spacing.x1) {
            ForEach(keys, id: \.self) { key in
                Text(key)
                    .textStyle(.caption)
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
                    .padding(.horizontal, Token.Spacing.x1)
                    .padding(.vertical, 2)
                    .background(Token.Color.surface)
                    .cornerRadius(Token.Radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Token.Radius.sm)
                            .stroke(Token.Color.stroke, lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Previews
struct ShortcutHint_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Token.Spacing.x4) {
            ShortcutHint("⌘", "S")
            ShortcutHint("⌥", "Space")
            ShortcutHint("⌘", "⇧", "P")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}