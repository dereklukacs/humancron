import SwiftUI

// MARK: - DSColor Helper
public struct DSColor {
    public static func foreground(_ color: Color) -> some ViewModifier {
        ForegroundColorModifier(color: color)
    }
    
    public static func background(_ color: Color) -> some ViewModifier {
        BackgroundColorModifier(color: color)
    }
}

struct ForegroundColorModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content.foregroundColor(color)
    }
}

struct BackgroundColorModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content.background(color)
    }
}

// MARK: - DSSpacer Helper
public struct DSSpacer: View {
    let spacing: CGFloat
    let axis: Axis?
    
    public init(_ spacing: CGFloat) {
        self.spacing = spacing
        self.axis = nil
    }
    
    public init(_ spacing: CGFloat, axis: Axis) {
        self.spacing = spacing
        self.axis = axis
    }
    
    public var body: some View {
        switch axis {
        case .horizontal:
            Spacer()
                .frame(width: spacing, height: nil)
        case .vertical:
            Spacer()
                .frame(width: nil, height: spacing)
        case nil:
            Spacer()
                .frame(width: spacing, height: spacing)
        }
    }
}

// MARK: - View Extensions
public extension View {
    func dsBackground(_ color: Color) -> some View {
        self.modifier(DSColor.background(color))
    }
    
    func dsForeground(_ color: Color) -> some View {
        self.modifier(DSColor.foreground(color))
    }
}