//
//  DesignSystemExample.swift
//  humancron
//
//  Example view demonstrating the design system components
//

import SwiftUI
import DesignSystem

struct DesignSystemExample: View {
    @State private var searchText = ""
    @State private var isEnabled = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Workflow Selector")
                    .textStyle(.headline)
                    .foregroundColor(Token.Color.onSurface)
                Spacer()
                ShortcutHint("⌥", "Space")
            }
            .padding(Token.Spacing.x4)
            .background(Token.Color.surface)
            
            DSDivider()
            
            // Search Bar
            DSTextField("Search workflows...", text: $searchText)
                .padding(.horizontal, Token.Spacing.x4)
                .padding(.vertical, Token.Spacing.x3)
            
            // Workflow List
            ScrollView {
                VStack(spacing: 0) {
                    MenuItem(
                        icon: "calendar",
                        label: "Daily Planning",
                        shortcut: ["⌘", "1"]
                    ) { }
                    
                    DSDivider()
                    
                    MenuItem(
                        icon: "message",
                        label: "Inbox Cleanse",
                        shortcut: ["⌘", "2"]
                    ) { }
                    
                    DSDivider()
                    
                    MenuItem(
                        icon: "arrow.triangle.pull",
                        label: "Review PRs"
                    ) { }
                }
            }
            
            DSDivider()
            
            // Footer
            HStack {
                DSToggle("Dark mode", isOn: $isEnabled)
                Spacer()
                DSButton("New Workflow", style: .secondary) { }
            }
            .padding(Token.Spacing.x4)
            .background(Token.Color.surface)
        }
        .background(Token.Color.background)
        .frame(width: 400, height: 500)
        .cornerRadius(Token.Radius.lg)
        .elevation(.two)
    }
}

#Preview {
    DesignSystemExample()
        .padding()
}