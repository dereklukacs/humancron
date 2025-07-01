import SwiftUI

public struct DSDivider: View {
    public enum Orientation {
        case horizontal
        case vertical
    }
    
    let orientation: Orientation
    
    public init(_ orientation: Orientation = .horizontal) {
        self.orientation = orientation
    }
    
    public var body: some View {
        Rectangle()
            .fill(Token.Color.divider)
            .frame(
                width: orientation == .horizontal ? nil : 1,
                height: orientation == .horizontal ? 1 : nil
            )
    }
}

// MARK: - Previews
struct DSDivider_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Token.Spacing.x6) {
            VStack(spacing: Token.Spacing.x4) {
                Text("Above divider")
                    .textStyle(.body)
                DSDivider()
                Text("Below divider")
                    .textStyle(.body)
            }
            
            HStack(spacing: Token.Spacing.x4) {
                Text("Left")
                    .textStyle(.body)
                DSDivider(.vertical)
                    .frame(height: 30)
                Text("Right")
                    .textStyle(.body)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}