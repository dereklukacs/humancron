import SwiftUI
import DesignSystem

struct HotkeyBar: View {
    let items: [HotkeyItem]
    
    var body: some View {
        HStack(spacing: Token.Spacing.x4) {
            ForEach(items) { item in
                Button(action: {
                    item.action?()
                }) {
                    HotkeyItemView(item: item)
                }
                .buttonStyle(HotkeyButtonStyle(isDisabled: item.action == nil))
                .disabled(item.action == nil)
                
                if item.id != items.last?.id {
                    Divider()
                        .frame(height: 16)
                        .opacity(0.3)
                }
            }
        }
        .padding(.horizontal, Token.Spacing.x4)
        .padding(.vertical, Token.Spacing.x3)
        .frame(maxWidth: .infinity)
        .background(Token.Color.surface.opacity(0.8))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Token.Color.onSurface.opacity(0.1)),
            alignment: .top
        )
    }
}

struct HotkeyItemView: View {
    let item: HotkeyItem
    
    var body: some View {
        HStack(spacing: Token.Spacing.x2) {
            ShortcutHint(item.key)
                .opacity(item.action == nil ? 0.4 : 1.0)
            Text(item.label)
                .font(.system(size: 13))
                .foregroundColor(Token.Color.onBackground.opacity(item.action == nil ? 0.4 : 0.8))
        }
    }
}

struct HotkeyItem: Identifiable {
    let id = UUID()
    let key: String
    let label: String
    let action: (() -> Void)?
    
    init(_ key: String, _ label: String, action: (() -> Void)? = nil) {
        self.key = key
        self.label = label
        self.action = action
    }
}

struct HotkeyButtonStyle: ButtonStyle {
    let isDisabled: Bool
    @State private var isHovered = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Token.Spacing.x2)
            .padding(.vertical, Token.Spacing.x1)
            .background(
                RoundedRectangle(cornerRadius: Token.Radius.sm)
                    .fill(
                        isDisabled ? Color.clear :
                        configuration.isPressed ? Token.Color.surface.opacity(0.3) : 
                        isHovered ? Token.Color.surface.opacity(0.2) : 
                        Color.clear
                    )
            )
            .opacity(configuration.isPressed && !isDisabled ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed && !isDisabled ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.1), value: isHovered)
            .onHover { hovering in
                if !isDisabled {
                    isHovered = hovering
                }
            }
    }
}

// Preview
struct HotkeyBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            HotkeyBar(items: [
                HotkeyItem("↵", "Select"),
                HotkeyItem("↑↓", "Navigate"),
                HotkeyItem("ESC", "Cancel")
            ])
        }
        .frame(width: 600, height: 400)
        .background(Color.black)
    }
}