//
//  DesignSystemGallery.swift
//  humancron
//
//  A gallery view showing all design system components
//

import SwiftUI
import DesignSystem

struct DesignSystemGallery: View {
    @State private var textInput = ""
    @State private var passwordInput = ""
    @State private var toggleState = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Token.Spacing.x8) {
                // Typography Section
                typographySection
                
                DSDivider()
                
                // Colors Section
                colorsSection
                
                DSDivider()
                
                // Buttons Section
                buttonsSection
                
                DSDivider()
                
                // Form Elements Section
                formElementsSection
                
                DSDivider()
                
                // Molecules Section
                moleculesSection
                
                DSDivider()
                
                // Elevation Section
                elevationSection
            }
            .padding(Token.Spacing.x6)
        }
        .background(Token.Color.background)
        .frame(minWidth: 800, minHeight: 600)
    }
    
    var typographySection: some View {
        VStack(alignment: .leading, spacing: Token.Spacing.x4) {
            Text("Typography")
                .textStyle(.title)
                .foregroundColor(Token.Color.onBackground)
            
            VStack(alignment: .leading, spacing: Token.Spacing.x2) {
                Text("Display Large (32pt Bold)")
                    .textStyle(.displayLarge)
                Text("Display Small (24pt Bold)")
                    .textStyle(.displaySmall)
                Text("Title (20pt Semibold)")
                    .textStyle(.title)
                Text("Headline (17pt Semibold)")
                    .textStyle(.headline)
                Text("Body (15pt Regular)")
                    .textStyle(.body)
                Text("Body Small (13pt Regular)")
                    .textStyle(.bodySmall)
                Text("Caption (11pt Regular)")
                    .textStyle(.caption)
            }
            .foregroundColor(Token.Color.onBackground)
        }
    }
    
    var colorsSection: some View {
        VStack(alignment: .leading, spacing: Token.Spacing.x4) {
            Text("Colors")
                .textStyle(.title)
                .foregroundColor(Token.Color.onBackground)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: Token.Spacing.x3) {
                ColorSwatch("Brand", Token.Color.brand)
                ColorSwatch("Accent", Token.Color.accent)
                ColorSwatch("Success", Token.Color.success)
                ColorSwatch("Warning", Token.Color.warning)
                ColorSwatch("Error", Token.Color.error)
                ColorSwatch("Info", Token.Color.info)
                ColorSwatch("Background", Token.Color.background)
                ColorSwatch("Surface", Token.Color.surface)
                ColorSwatch("Elevated Surface", Token.Color.elevatedSurface)
            }
        }
    }
    
    var buttonsSection: some View {
        VStack(alignment: .leading, spacing: Token.Spacing.x4) {
            Text("Buttons")
                .textStyle(.title)
                .foregroundColor(Token.Color.onBackground)
            
            HStack(spacing: Token.Spacing.x4) {
                DSButton("Primary", style: .primary) { }
                DSButton("Secondary", style: .secondary) { }
                DSButton("Tertiary", style: .tertiary) { }
            }
        }
    }
    
    var formElementsSection: some View {
        VStack(alignment: .leading, spacing: Token.Spacing.x4) {
            Text("Form Elements")
                .textStyle(.title)
                .foregroundColor(Token.Color.onBackground)
            
            VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                DSTextField("Enter your name", text: $textInput)
                    .frame(maxWidth: 300)
                
                DSTextField("Password", text: $passwordInput, isSecure: true)
                    .frame(maxWidth: 300)
                
                DSToggle("Enable notifications", isOn: $toggleState)
                
                HStack(spacing: Token.Spacing.x4) {
                    Text("Horizontal divider:")
                        .textStyle(.body)
                    DSDivider()
                        .frame(width: 100)
                }
                
                HStack(spacing: Token.Spacing.x2) {
                    Text("Vertical")
                        .textStyle(.body)
                    DSDivider(.vertical)
                        .frame(height: 20)
                    Text("divider")
                        .textStyle(.body)
                }
                .foregroundColor(Token.Color.onBackground)
            }
        }
    }
    
    var moleculesSection: some View {
        VStack(alignment: .leading, spacing: Token.Spacing.x4) {
            Text("Molecules")
                .textStyle(.title)
                .foregroundColor(Token.Color.onBackground)
            
            // Menu Items
            VStack(alignment: .leading, spacing: Token.Spacing.x2) {
                Text("Menu Items")
                    .textStyle(.headline)
                
                VStack(spacing: 0) {
                    MenuItem(icon: "calendar", label: "Check Calendar", shortcut: ["⌘", "1"]) { }
                    DSDivider()
                    MenuItem(icon: "message", label: "Review Messages", shortcut: ["⌘", "2"]) { }
                    DSDivider()
                    MenuItem(icon: "envelope", label: "Clean Email") { }
                }
                .background(Token.Color.surface)
                .cornerRadius(Token.Radius.md)
            }
            
            // List Items
            VStack(alignment: .leading, spacing: Token.Spacing.x2) {
                Text("List Items")
                    .textStyle(.headline)
                
                VStack(spacing: 0) {
                    ListItem(
                        leadingIcon: "folder",
                        title: "Inbox Cleanse",
                        subtitle: "Clear out emails and messages",
                        trailingText: "5 steps",
                        trailingIcon: "chevron.right"
                    )
                    DSDivider()
                    ListItem(
                        leadingIcon: "calendar",
                        title: "Daily Planning",
                        subtitle: "Review calendar and tasks",
                        trailingText: "3 steps"
                    )
                }
                .background(Token.Color.surface)
                .cornerRadius(Token.Radius.md)
            }
            
            // Cards
            VStack(alignment: .leading, spacing: Token.Spacing.x2) {
                Text("Cards")
                    .textStyle(.headline)
                
                Card {
                    VStack(alignment: .leading, spacing: Token.Spacing.x2) {
                        Text("Card Example")
                            .textStyle(.headline)
                        Text("This is a card with elevation and padding.")
                            .textStyle(.body)
                    }
                }
                .frame(maxWidth: 400)
            }
        }
    }
    
    var elevationSection: some View {
        VStack(alignment: .leading, spacing: Token.Spacing.x4) {
            Text("Elevation")
                .textStyle(.title)
                .foregroundColor(Token.Color.onBackground)
            
            HStack(spacing: Token.Spacing.x4) {
                ForEach([Elevation.Level.zero, .one, .two, .three], id: \.self) { level in
                    VStack {
                        Text("Level \(level.rawValue)")
                            .textStyle(.caption)
                            .foregroundColor(Token.Color.onSurface)
                        
                        Rectangle()
                            .fill(Token.Color.surface)
                            .frame(width: 100, height: 60)
                            .cornerRadius(Token.Radius.md)
                            .elevation(level)
                    }
                }
            }
        }
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color
    
    init(_ name: String, _ color: Color) {
        self.name = name
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: Token.Spacing.x2) {
            Rectangle()
                .fill(color)
                .frame(height: 60)
                .cornerRadius(Token.Radius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: Token.Radius.md)
                        .stroke(Token.Color.stroke, lineWidth: 1)
                )
            
            Text(name)
                .textStyle(.caption)
                .foregroundColor(Token.Color.onBackground)
        }
    }
}

#Preview {
    DesignSystemGallery()
}