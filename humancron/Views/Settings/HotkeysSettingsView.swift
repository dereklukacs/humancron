import SwiftUI
import DesignSystem
import AppKit

struct HotkeysSettingsView: View {
    @StateObject private var settings = SettingsService.shared
    @State private var isRecordingHotkey = false
    @State private var recordedModifiers: NSEvent.ModifierFlags = []
    @State private var recordedKeyCode: UInt16 = 0
    @State private var eventMonitor: Any?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Token.Spacing.x4) {
                // Global Hotkey Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("Global Hotkey")
                        .textStyle(.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(Token.Color.onSurface)
                    
                    Text("The keyboard shortcut to activate Humancron from anywhere")
                        .textStyle(.caption)
                        .foregroundColor(Token.Color.onSurface.opacity(0.7))
                    
                    HStack {
                        HotkeyRecorderView(
                            isRecording: $isRecordingHotkey,
                            currentHotkey: settings.globalHotkey,
                            onStartRecording: startRecordingHotkey,
                            onStopRecording: stopRecordingHotkey
                        )
                        
                        DSButton("Reset", style: .secondary) {
                            settings.updateHotkey(modifiers: .option, keyCode: 49) // Reset to Option+Space
                            // Notify hotkey service to update
                            NotificationCenter.default.post(name: .hotkeyChanged, object: nil)
                        }
                    }
                }
                
                DSDivider()
                    .padding(.vertical, Token.Spacing.x2)
                
                // Workflow Shortcuts Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("Workflow Shortcuts")
                        .textStyle(.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(Token.Color.onSurface)
                    
                    Text("Quick keyboard shortcuts for frequently used workflows")
                        .textStyle(.caption)
                        .foregroundColor(Token.Color.onSurface.opacity(0.7))
                    
                    Text("Coming soon...")
                        .textStyle(.caption)
                        .foregroundColor(Token.Color.onSurface.opacity(0.5))
                        .italic()
                }
                
                Spacer()
            }
            .padding(Token.Spacing.x4)
        }
        .onDisappear {
            stopRecordingHotkey()
        }
    }
    
    private func startRecordingHotkey() {
        isRecordingHotkey = true
        
        // Create local event monitor
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Record the key combination
            self.recordedModifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
            self.recordedKeyCode = event.keyCode
            
            // Update settings
            self.settings.updateHotkey(modifiers: self.recordedModifiers, keyCode: self.recordedKeyCode)
            
            // Stop recording
            self.stopRecordingHotkey()
            
            // Notify hotkey service to update
            NotificationCenter.default.post(name: .hotkeyChanged, object: nil)
            
            return nil // Consume the event
        }
    }
    
    private func stopRecordingHotkey() {
        isRecordingHotkey = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

struct HotkeyRecorderView: View {
    @Binding var isRecording: Bool
    let currentHotkey: String
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void
    
    var body: some View {
        Button(action: {
            if isRecording {
                onStopRecording()
            } else {
                onStartRecording()
            }
        }) {
            HStack {
                if isRecording {
                    Text("Press any key combination...")
                        .foregroundColor(Token.Color.onSurface.opacity(0.7))
                } else {
                    Text(currentHotkey.uppercased())
                        .foregroundColor(Token.Color.onSurface)
                }
                Spacer()
            }
            .padding(.horizontal, Token.Spacing.x3)
            .padding(.vertical, Token.Spacing.x2)
            .background(
                RoundedRectangle(cornerRadius: Token.Radius.sm)
                    .fill(Token.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Token.Radius.sm)
                            .stroke(isRecording ? Token.Color.brand : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 200)
    }
}

extension Notification.Name {
    static let hotkeyChanged = Notification.Name("hotkeyChanged")
}