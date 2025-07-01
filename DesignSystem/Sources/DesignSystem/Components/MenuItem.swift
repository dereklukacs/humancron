import SwiftUI

public struct MenuItem: View {
    let icon: String
    let label: String
    let shortcut: [String]?
    let action: () -> Void
    
    public init(icon: String, label: String, shortcut: [String]? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.shortcut = shortcut
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: Token.Spacing.x3) {
                Image(systemName: icon)
                    .font(.system(size: Typography.TextStyle.body.size))
                    .foregroundColor(Token.Color.onSurface)
                    .frame(width: 20)
                
                Text(label)
                    .textStyle(.body)
                    .foregroundColor(Token.Color.onSurface)
                
                Spacer()
                
                if let shortcut = shortcut {
                    ShortcutHint(keys: shortcut)
                }
            }
            .padding(.horizontal, Token.Spacing.x3)
            .padding(.vertical, Token.Spacing.x2)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(MenuItemButtonStyle())
    }
}

struct MenuItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed ? Token.Color.surface : Color.clear
            )
    }
}

// MARK: - Previews
struct MenuItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            MenuItem(icon: "calendar", label: "Check Calendar", shortcut: ["⌘", "1"]) { }
            MenuItem(icon: "message", label: "Review Slack Messages", shortcut: ["⌘", "2"]) { }
            MenuItem(icon: "envelope", label: "Clean Email") { }
            MenuItem(icon: "arrow.triangle.pull", label: "Review GitHub PRs", shortcut: ["⌘", "4"]) { }
        }
        .background(Token.Color.background)
        .previewLayout(.sizeThatFits)
    }
}