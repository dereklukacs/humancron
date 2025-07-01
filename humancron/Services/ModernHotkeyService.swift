import SwiftUI
import Combine

@MainActor
class ModernHotkeyService: ObservableObject {
    static let shared = ModernHotkeyService()
    
    @Published var isRegistered = false
    private var hotkeyMonitor: Any?
    
    private init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hotkeyChanged),
            name: .hotkeyChanged,
            object: nil
        )
    }
    
    @objc private func hotkeyChanged() {
        unregisterHotkey()
        registerHotkey()
    }
    
    func registerHotkey() {
        guard !isRegistered else { return }
        
        let settings = SettingsService.shared
        let modifiers = settings.hotkeyModifiers
        let keyCode = settings.hotkeyKeyCode
        
        print("Registering global hotkey: \(settings.globalHotkey)")
        
        // Monitor for the configured hotkey globally
        hotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return }
            
            // Check if the event matches our hotkey
            if event.modifierFlags.intersection([.command, .option, .control, .shift]) == modifiers && event.keyCode == keyCode {
                print("Global hotkey detected: \(settings.globalHotkey)")
                DispatchQueue.main.async {
                    self.handleHotKeyPress()
                }
            }
        }
        
        // Also monitor local events (when app has focus)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            
            // Check if the event matches our hotkey
            if event.modifierFlags.intersection([.command, .option, .control, .shift]) == modifiers && event.keyCode == keyCode {
                print("Local hotkey detected: \(settings.globalHotkey)")
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