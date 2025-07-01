import SwiftUI
import DesignSystem

struct SettingsView: View {
    @StateObject private var settings = SettingsService.shared
    @State private var selectedTab = "general"
    
    var body: some View {
        VStack(spacing: 0) {
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
            .padding(Token.Spacing.x3)
            .background(Token.Color.surface)
            
            Divider()
            
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
            .background(Token.Color.background)
        }
        .frame(width: 600, height: 400)
        .background(Token.Color.background)
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
                    .font(.system(size: 13, weight: .medium))
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