import SwiftUI
import DesignSystem

struct GeneralSettingsView: View {
    @StateObject private var settings = SettingsService.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Token.Spacing.x4) {
                // Startup Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("Startup")
                        .textStyle(.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(Token.Color.onSurface)
                    
                    DSToggle("Launch at login", isOn: $settings.launchAtLogin)
                        .onChange(of: settings.launchAtLogin) { newValue in
                            // TODO: Implement launch at login functionality
                            print("Launch at login: \(newValue)")
                        }
                }
                
                DSDivider()
                    .padding(.vertical, Token.Spacing.x2)
                
                // Appearance Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("Appearance")
                        .textStyle(.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(Token.Color.onSurface)
                    
                    DSToggle("Show in Dock", isOn: $settings.showInDock)
                        .onChange(of: settings.showInDock) { newValue in
                            updateDockVisibility(newValue)
                        }
                    
                    Text("When disabled, Humancron will only appear in the menu bar")
                        .textStyle(.caption)
                        .foregroundColor(Token.Color.onSurface.opacity(0.7))
                }
                
                DSDivider()
                    .padding(.vertical, Token.Spacing.x2)
                
                // Window Size Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("Window Size")
                        .textStyle(.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(Token.Color.onSurface)
                    
                    HStack {
                        Text("Width")
                            .textStyle(.bodySmall)
                            .foregroundColor(Token.Color.onSurface)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $settings.windowWidth, in: 400...1200, step: 50)
                            .controlSize(.small)
                        
                        Text("\(Int(settings.windowWidth))")
                            .textStyle(.caption)
                            .fontDesign(.monospaced)
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    HStack {
                        Text("Height")
                            .textStyle(.bodySmall)
                            .foregroundColor(Token.Color.onSurface)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $settings.windowHeight, in: 300...900, step: 50)
                            .controlSize(.small)
                        
                        Text("\(Int(settings.windowHeight))")
                            .textStyle(.caption)
                            .fontDesign(.monospaced)
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    HStack {
                        DSButton("Reset to Default", style: .secondary) {
                            settings.windowWidth = 600
                            settings.windowHeight = 400
                        }
                        
                        Spacer()
                        
                        Text("Changes apply next time window opens")
                            .textStyle(.caption)
                            .foregroundColor(Token.Color.onSurface.opacity(0.5))
                    }
                }
                
                DSDivider()
                    .padding(.vertical, Token.Spacing.x2)
                
                // About Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("About")
                        .textStyle(.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(Token.Color.onSurface)
                    
                    HStack {
                        Text("Version")
                            .textStyle(.bodySmall)
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                        Spacer()
                        Text("1.0.0")
                            .textStyle(.bodySmall)
                            .foregroundColor(Token.Color.onSurface)
                    }
                    
                    HStack {
                        Text("Build")
                            .textStyle(.bodySmall)
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                        Spacer()
                        Text("100")
                            .textStyle(.bodySmall)
                            .foregroundColor(Token.Color.onSurface)
                    }
                }
                
                Spacer()
            }
            .padding(Token.Spacing.x4)
        }
    }
    
    private func updateDockVisibility(_ show: Bool) {
        if show {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}