import SwiftUI
import DesignSystem

struct HotkeyBar: View {
    let items: [HotkeyItem]
    
    var body: some View {
        HStack(spacing: Token.Spacing.x4) {
            ForEach(items) { item in
                HotkeyItemView(item: item)
                
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
            Text(item.label)
                .font(.system(size: 13))
                .foregroundColor(Token.Color.onBackground.opacity(0.8))
        }
    }
}

struct HotkeyItem: Identifiable {
    let id = UUID()
    let key: String
    let label: String
    
    init(_ key: String, _ label: String) {
        self.key = key
        self.label = label
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