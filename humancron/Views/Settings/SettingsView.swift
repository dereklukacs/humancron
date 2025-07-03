import SwiftUI
import DesignSystem

struct SettingsView: View {
    @StateObject private var settings = SettingsService.shared
    @State private var selectedTab = "general"
    
    var body: some View {
        ZStack {
            // Background with blur effect to match main app
            VisualEffectBackground()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 0) {
                // Drag handle area at the top to match main app
                HStack {
                    Text("Preferences")
                        .textStyle(.headline)
                        .foregroundColor(Token.Color.onSurface)
                        .padding(.leading, Token.Spacing.x4)
                    
                    Spacer()
                    
                    // Close button
                    Button(action: {
                        AppStateManager.shared.closePreferences()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Token.Color.onSurface.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, Token.Spacing.x3)
                }
                .frame(height: 40)
                .background(WindowDragView())
                
                // Tab Bar
                HStack(spacing: Token.Spacing.x3) {
                    SettingsTab(
                        title: "General",
                        icon: "gearshape",
                        isSelected: selectedTab == "general"
                    ) {
                        selectedTab = "general"
                    }
                    
                    SettingsTab(
                        title: "Hotkeys",
                        icon: "keyboard",
                        isSelected: selectedTab == "hotkeys"
                    ) {
                        selectedTab = "hotkeys"
                    }
                    
                    SettingsTab(
                        title: "Workflows",
                        icon: "folder",
                        isSelected: selectedTab == "workflows"
                    ) {
                        selectedTab = "workflows"
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Token.Spacing.x3)
                .padding(.vertical, Token.Spacing.x2)
                
                DSDivider()
                
                // Tab Content
                Group {
                    switch selectedTab {
                        case "general":
                            GeneralSettingsView()
                        case "hotkeys":
                            HotkeysSettingsView()
                        case "workflows":
                            WorkflowsSettingsView()
                        default:
                            EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 600, height: 400)
        .clipShape(RoundedRectangle(cornerRadius: Token.Radius.lg))
        .shadow(radius: 20)
    }
}

struct SettingsTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Token.Spacing.x2) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .textStyle(.bodySmall)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? Token.Color.onSurface : Token.Color.onSurface.opacity(0.7))
            .padding(.horizontal, Token.Spacing.x3)
            .padding(.vertical, Token.Spacing.x2)
            .background(
                RoundedRectangle(cornerRadius: Token.Radius.sm)
                    .fill(isSelected ? Token.Color.elevatedSurface : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}