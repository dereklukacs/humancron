import SwiftUI

public struct Card<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let elevation: Elevation.Level
    
    public init(
        padding: CGFloat = Token.Spacing.x4,
        elevation: Elevation.Level = .one,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.elevation = elevation
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(Token.Color.surface)
            .cornerRadius(Token.Radius.md)
            .elevation(elevation)
    }
}

// MARK: - Previews
struct Card_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Token.Spacing.x4) {
            Card {
                VStack(alignment: .leading, spacing: Token.Spacing.x2) {
                    Text("Simple Card")
                        .textStyle(.headline)
                    Text("This is a basic card with some content.")
                        .textStyle(.body)
                }
            }
            
            Card(elevation: .two) {
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                            .foregroundColor(Token.Color.brand)
                        Spacer()
                        Text("Today")
                            .textStyle(.caption)
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                    }
                    
                    Text("Daily Standup")
                        .textStyle(.headline)
                    
                    Text("Review yesterday's progress and plan today's tasks.")
                        .textStyle(.bodySmall)
                        .foregroundColor(Token.Color.onSurface.opacity(0.8))
                    
                    DSDivider()
                    
                    DSButton("Start Routine", style: .primary) { }
                }
            }
            
            Card(padding: Token.Spacing.x2, elevation: .zero) {
                HStack {
                    Text("Minimal padding, no shadow")
                        .textStyle(.body)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Token.Color.background)
        .previewLayout(.sizeThatFits)
    }
}