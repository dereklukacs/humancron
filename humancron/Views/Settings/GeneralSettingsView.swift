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
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Token.Color.onSurface)
                    
                    Toggle("Launch at login", isOn: $settings.launchAtLogin)
                        .toggleStyle(SwitchToggleStyle())
                        .onChange(of: settings.launchAtLogin) { newValue in
                            // TODO: Implement launch at login functionality
                            print("Launch at login: \(newValue)")
                        }
                }
                
                Divider()
                    .padding(.vertical, Token.Spacing.x2)
                
                // Appearance Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("Appearance")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Token.Color.onSurface)
                    
                    Toggle("Show in Dock", isOn: $settings.showInDock)
                        .toggleStyle(SwitchToggleStyle())
                        .onChange(of: settings.showInDock) { newValue in
                            updateDockVisibility(newValue)
                        }
                    
                    Text("When disabled, Humancron will only appear in the menu bar")
                        .font(.system(size: 12))
                        .foregroundColor(Token.Color.onSurface.opacity(0.7))
                }
                
                Divider()
                    .padding(.vertical, Token.Spacing.x2)
                
                // Window Size Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("Window Size")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Token.Color.onSurface)
                    
                    HStack {
                        Text("Width")
                            .font(.system(size: 13))
                            .foregroundColor(Token.Color.onSurface)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $settings.windowWidth, in: 400...1200, step: 50)
                            .controlSize(.small)
                        
                        Text("\(Int(settings.windowWidth))")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    HStack {
                        Text("Height")
                            .font(.system(size: 13))
                            .foregroundColor(Token.Color.onSurface)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $settings.windowHeight, in: 300...900, step: 50)
                            .controlSize(.small)
                        
                        Text("\(Int(settings.windowHeight))")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                            .frame(width: 50, alignment: .trailing)
                    }
                    
                    HStack {
                        Button("Reset to Default") {
                            settings.windowWidth = 600
                            settings.windowHeight = 400
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Spacer()
                        
                        Text("Changes apply next time window opens")
                            .font(.system(size: 11))
                            .foregroundColor(Token.Color.onSurface.opacity(0.5))
                    }
                }
                
                Divider()
                    .padding(.vertical, Token.Spacing.x2)
                
                // About Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("About")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Token.Color.onSurface)
                    
                    HStack {
                        Text("Version")
                            .font(.system(size: 13))
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                        Spacer()
                        Text("1.0.0")
                            .font(.system(size: 13))
                            .foregroundColor(Token.Color.onSurface)
                    }
                    
                    HStack {
                        Text("Build")
                            .font(.system(size: 13))
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                        Spacer()
                        Text("100")
                            .font(.system(size: 13))
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