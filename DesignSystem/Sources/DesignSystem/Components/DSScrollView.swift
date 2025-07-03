import SwiftUI

// MARK: - Custom ScrollView with hidden scrollbars
public struct DSScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let content: Content
    
    public init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = false, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content
        }
    }
}

// MARK: - ScrollView Style Modifier
public struct HiddenScrollContentStyle: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
    }
}

public extension View {
    func hiddenScrollStyle() -> some View {
        modifier(HiddenScrollContentStyle())
    }
}