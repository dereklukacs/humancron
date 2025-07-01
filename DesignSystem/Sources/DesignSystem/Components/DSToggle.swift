import SwiftUI

public struct DSToggle: View {
    @Binding var isOn: Bool
    let label: String
    
    public init(_ label: String, isOn: Binding<Bool>) {
        self.label = label
        self._isOn = isOn
    }
    
    public var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .textStyle(.body)
                .foregroundColor(Token.Color.onSurface)
        }
        .toggleStyle(SwitchToggleStyle(tint: Token.Color.brand))
    }
}

// MARK: - Previews
struct DSToggle_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isEnabled = false
        @State private var isDarkMode = true
        
        var body: some View {
            VStack(spacing: Token.Spacing.x4) {
                DSToggle("Enable notifications", isOn: $isEnabled)
                DSToggle("Dark mode", isOn: $isDarkMode)
            }
            .padding()
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
            .previewLayout(.sizeThatFits)
    }
}