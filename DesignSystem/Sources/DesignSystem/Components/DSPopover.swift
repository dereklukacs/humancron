import SwiftUI

/// A reusable popover component that shows content on hover
public struct DSPopover<Content: View, PopoverContent: View>: View {
    let content: Content
    let popoverContent: PopoverContent
    let delay: TimeInterval
    let preferredEdge: Edge
    
    @State private var isShowingPopover = false
    @State private var hoverTimer: Timer?
    
    public init(
        delay: TimeInterval = 0.5,
        preferredEdge: Edge = .top,
        @ViewBuilder content: () -> Content,
        @ViewBuilder popoverContent: () -> PopoverContent
    ) {
        self.content = content()
        self.popoverContent = popoverContent()
        self.delay = delay
        self.preferredEdge = preferredEdge
    }
    
    public var body: some View {
        content
            .onHover { hovering in
                if hovering {
                    hoverTimer?.invalidate()
                    hoverTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                        Task { @MainActor in
                            isShowingPopover = true
                        }
                    }
                } else {
                    hoverTimer?.invalidate()
                    hoverTimer = nil
                    isShowingPopover = false
                }
            }
            .popover(isPresented: $isShowingPopover, arrowEdge: preferredEdge) {
                popoverContent
                    .padding(Token.Spacing.x3)
                    .frame(maxWidth: 500, maxHeight: 400)
                    .background(Token.Color.background)
            }
    }
}

// MARK: - Preview

struct DSPopover_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            DSPopover {
                Text("Hover over me")
                    .padding()
                    .background(Token.Color.surface.opacity(0.5))
                    .cornerRadius(Token.Radius.sm)
            } popoverContent: {
                VStack(alignment: .leading) {
                    Text("Popover Content")
                        .font(.system(size: 18, weight: .semibold))
                    Text("This appears after hovering for 0.5 seconds")
                        .font(.system(size: 16))
                }
            }
            
            DSPopover(delay: 0.2, preferredEdge: .bottom) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Quick hover (0.2s)")
                }
                .padding()
                .background(Token.Color.brand.opacity(0.1))
                .cornerRadius(8)
            } popoverContent: {
                Text("This appears more quickly!")
                    .font(.system(size: 14))
            }
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}