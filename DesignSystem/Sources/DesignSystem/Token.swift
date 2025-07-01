import SwiftUI

public enum Token {
    public enum Color {
        // Brand colors
        public static let brand = SwiftUI.Color(light: .init(red: 0.25, green: 0.47, blue: 0.85),
                                               dark: .init(red: 0.40, green: 0.60, blue: 0.90))
        public static let accent = SwiftUI.Color(light: .init(red: 0.95, green: 0.36, blue: 0.36),
                                                dark: .init(red: 0.98, green: 0.50, blue: 0.50))
        
        // Semantic colors
        public static let success = SwiftUI.Color(light: .init(red: 0.27, green: 0.73, blue: 0.36),
                                                 dark: .init(red: 0.40, green: 0.80, blue: 0.47))
        public static let warning = SwiftUI.Color(light: .init(red: 0.98, green: 0.75, blue: 0.18),
                                                 dark: .init(red: 0.98, green: 0.82, blue: 0.35))
        public static let error = SwiftUI.Color(light: .init(red: 0.90, green: 0.26, blue: 0.26),
                                               dark: .init(red: 0.95, green: 0.42, blue: 0.42))
        public static let info = SwiftUI.Color(light: .init(red: 0.25, green: 0.60, blue: 0.95),
                                              dark: .init(red: 0.40, green: 0.70, blue: 0.98))
        
        // Surface colors
        public static let background = SwiftUI.Color(light: .init(red: 0.98, green: 0.98, blue: 0.98),
                                                    dark: .init(red: 0.11, green: 0.11, blue: 0.12))
        public static let surface = SwiftUI.Color(light: .white,
                                                 dark: .init(red: 0.15, green: 0.15, blue: 0.16))
        public static let elevatedSurface = SwiftUI.Color(light: .white,
                                                         dark: .init(red: 0.20, green: 0.20, blue: 0.22))
        
        // Text colors
        public static let onBackground = SwiftUI.Color(light: .init(red: 0.11, green: 0.11, blue: 0.12),
                                                      dark: .init(red: 0.98, green: 0.98, blue: 0.98))
        public static let onSurface = SwiftUI.Color(light: .init(red: 0.11, green: 0.11, blue: 0.12),
                                                   dark: .init(red: 0.98, green: 0.98, blue: 0.98))
        public static let onBrand = SwiftUI.Color(light: .white, dark: .white)
        
        // Utility colors
        public static let divider = SwiftUI.Color(light: .init(white: 0, opacity: 0.12),
                                                 dark: .init(white: 1, opacity: 0.12))
        public static let stroke = SwiftUI.Color(light: .init(white: 0, opacity: 0.20),
                                                dark: .init(white: 1, opacity: 0.20))
        public static let overlay = SwiftUI.Color(light: .init(white: 0, opacity: 0.50),
                                                 dark: .init(white: 0, opacity: 0.70))
    }
    
    public enum Spacing {
        public static let zero: CGFloat = 0
        public static let x1: CGFloat = 4
        public static let x2: CGFloat = 8
        public static let x3: CGFloat = 12
        public static let x4: CGFloat = 16
        public static let x6: CGFloat = 24
        public static let x8: CGFloat = 32
        public static let x10: CGFloat = 40
        public static let x12: CGFloat = 48
        public static let x16: CGFloat = 64
    }
    
    public enum Radius {
        public static let none: CGFloat = 0
        public static let sm: CGFloat = 4
        public static let md: CGFloat = 8
        public static let lg: CGFloat = 16
    }
    
    public enum Motion {
        public static let fast: Double = 0.05
        public static let normal: Double = 0.15
        public static let slow: Double = 0.30
    }
}