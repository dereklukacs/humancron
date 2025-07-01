import Testing
import SwiftUI
@testable import DesignSystem

@Suite("Token Tests")
struct TokenTests {
    
    @Test("Color tokens are accessible")
    func testColorTokensExist() {
        // Brand colors
        _ = Token.Color.brand
        _ = Token.Color.accent
        
        // Semantic colors
        _ = Token.Color.success
        _ = Token.Color.warning
        _ = Token.Color.error
        _ = Token.Color.info
        
        // Surface colors
        _ = Token.Color.background
        _ = Token.Color.surface
        _ = Token.Color.elevatedSurface
        
        // Text colors
        _ = Token.Color.onBackground
        _ = Token.Color.onSurface
        _ = Token.Color.onBrand
        
        // Utility colors
        _ = Token.Color.divider
        _ = Token.Color.stroke
        _ = Token.Color.overlay
    }
    
    @Test("Spacing tokens have correct values")
    func testSpacingTokens() {
        #expect(Token.Spacing.zero == 0)
        #expect(Token.Spacing.x1 == 4)
        #expect(Token.Spacing.x2 == 8)
        #expect(Token.Spacing.x3 == 12)
        #expect(Token.Spacing.x4 == 16)
        #expect(Token.Spacing.x6 == 24)
        #expect(Token.Spacing.x8 == 32)
        #expect(Token.Spacing.x10 == 40)
        #expect(Token.Spacing.x12 == 48)
        #expect(Token.Spacing.x16 == 64)
    }
    
    @Test("Radius tokens have correct values")
    func testRadiusTokens() {
        #expect(Token.Radius.none == 0)
        #expect(Token.Radius.sm == 4)
        #expect(Token.Radius.md == 8)
        #expect(Token.Radius.lg == 16)
    }
    
    @Test("Motion tokens have correct values")
    func testMotionTokens() {
        #expect(Token.Motion.fast == 0.00)
        #expect(Token.Motion.normal == 0.05)
        #expect(Token.Motion.slow == 0.10)
    }
}