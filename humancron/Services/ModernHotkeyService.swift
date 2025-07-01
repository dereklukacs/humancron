import SwiftUI
import Combine

@MainActor
class ModernHotkeyService: ObservableObject {
    static let shared = ModernHotkeyService()
    
    @Published var isRegistered = false
    private var hotkeyMonitor: Any?
    
    private init() {}
    
    func registerHotkey() {
        guard !isRegistered else { return }
        
        print("Registering global hotkey: Option+Space")
        
        // Monitor for Option+Space globally
        hotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return }
            
            // Check for Option+Space (keyCode 49 is Space)
            if event.modifierFlags.contains(.option) && event.keyCode == 49 {
                print("Global hotkey detected: Option+Space")
                DispatchQueue.main.async {
                    self.handleHotKeyPress()
                }
            }
        }
        
        // Also monitor local events (when app has focus)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            
            // Check for Option+Space
            if event.modifierFlags.contains(.option) && event.keyCode == 49 {
                print("Local hotkey detected: Option+Space")
                DispatchQueue.main.async {
                    self.handleHotKeyPress()
                }
                return nil // Consume the event
            }
            
            return event
        }
        
        isRegistered = true
        print("Hotkey registration complete")
    }
    
    func unregisterHotkey() {
        guard isRegistered else { return }
        
        if let monitor = hotkeyMonitor {
            NSEvent.removeMonitor(monitor)
            hotkeyMonitor = nil
        }
        
        isRegistered = false
    }
    
    private func handleHotKeyPress() {
        NotificationCenter.default.post(name: .hotkeyPressed, object: nil)
    }
    
    // Helper to request accessibility permissions
    func requestAccessibilityPermissions() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options)
    }
}