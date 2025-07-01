import SwiftUI

public struct DSTextField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    
    public init(_ placeholder: String, text: Binding<String>, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
    }
    
    public var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(DSTextFieldStyle())
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(DSTextFieldStyle())
            }
        }
    }
}

struct DSTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: Typography.TextStyle.body.size, weight: Typography.TextStyle.body.weight))
            .padding(.horizontal, Token.Spacing.x3)
            .padding(.vertical, Token.Spacing.x2)
            .background(Token.Color.surface)
            .cornerRadius(Token.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Token.Radius.md)
                    .stroke(Token.Color.stroke, lineWidth: 1)
            )
    }
}

// MARK: - Previews
struct DSTextField_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var text = ""
        @State private var password = ""
        
        var body: some View {
            VStack(spacing: Token.Spacing.x4) {
                DSTextField("Enter your name", text: $text)
                DSTextField("Password", text: $password, isSecure: true)
            }
            .padding()
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
            .previewLayout(.sizeThatFits)
    }
}