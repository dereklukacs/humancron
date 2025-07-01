import SwiftUI

public struct ListItem: View {
    let leadingIcon: String?
    let title: String
    let subtitle: String?
    let trailingText: String?
    let trailingIcon: String?
    let action: (() -> Void)?
    
    public init(
        leadingIcon: String? = nil,
        title: String,
        subtitle: String? = nil,
        trailingText: String? = nil,
        trailingIcon: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.leadingIcon = leadingIcon
        self.title = title
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.trailingIcon = trailingIcon
        self.action = action
    }
    
    public var body: some View {
        let content = HStack(spacing: Token.Spacing.x3) {
            if let leadingIcon = leadingIcon {
                Image(systemName: leadingIcon)
                    .font(.system(size: Typography.TextStyle.headline.size))
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
                    .frame(width: 24)
            }
            
            VStack(alignment: .leading, spacing: Token.Spacing.x1) {
                Text(title)
                    .textStyle(.body)
                    .foregroundColor(Token.Color.onSurface)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .textStyle(.caption)
                        .foregroundColor(Token.Color.onSurface.opacity(0.7))
                }
            }
            
            Spacer()
            
            if let trailingText = trailingText {
                Text(trailingText)
                    .textStyle(.bodySmall)
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
            }
            
            if let trailingIcon = trailingIcon {
                Image(systemName: trailingIcon)
                    .font(.system(size: Typography.TextStyle.bodySmall.size))
                    .foregroundColor(Token.Color.onSurface.opacity(0.5))
            }
        }
        .padding(.horizontal, Token.Spacing.x4)
        .padding(.vertical, Token.Spacing.x3)
        
        if let action = action {
            Button(action: action) {
                content
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            content
        }
    }
}

// MARK: - Previews
struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ListItem(
                leadingIcon: "folder",
                title: "Inbox Cleanse",
                subtitle: "Clear out emails and messages",
                trailingText: "5 steps",
                trailingIcon: "chevron.right"
            ) { }
            
            DSDivider()
            
            ListItem(
                leadingIcon: "calendar",
                title: "Daily Planning",
                subtitle: "Review calendar and tasks",
                trailingText: "3 steps"
            )
            
            DSDivider()
            
            ListItem(
                title: "Weekly Review",
                trailingIcon: "chevron.right"
            ) { }
        }
        .background(Token.Color.surface)
        .previewLayout(.sizeThatFits)
    }
}