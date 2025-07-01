import SwiftUI
import Combine
import CoreGraphics

@MainActor
class ModernHotkeyService: ObservableObject {
    static let shared = ModernHotkeyService()
    
    @Published var isRegistered = false
    private var hotkeyMonitor: Any?
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
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
        
        // Create event tap for global hotkey monitoring
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        // Create the event tap callback
        let callback: CGEventTapCallBack = { (proxy, type, event, refcon) in
            // Get the service instance from refcon
            let service = Unmanaged<ModernHotkeyService>.fromOpaque(refcon!).takeUnretainedValue()
            
            // Check if this is our hotkey
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags
            
            // Convert CGEventFlags to NSEvent.ModifierFlags
            var modifierFlags = NSEvent.ModifierFlags()
            if flags.contains(.maskCommand) { modifierFlags.insert(.command) }
            if flags.contains(.maskShift) { modifierFlags.insert(.shift) }
            if flags.contains(.maskControl) { modifierFlags.insert(.control) }
            if flags.contains(.maskAlternate) { modifierFlags.insert(.option) }
            
            // Check if this matches our hotkey
            if modifierFlags == service.getCurrentModifiers() && keyCode == Int64(service.getCurrentKeyCode()) {
                print("Global hotkey detected via CGEvent")
                DispatchQueue.main.async {
                    service.handleHotKeyPress()
                }
                return nil // Consume the event to prevent the space from being typed
            }
            
            return Unmanaged.passRetained(event)
        }
        
        // Create the event tap
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            isRegistered = true
            print("Hotkey registration complete with CGEvent tap")
        } else {
            print("Failed to create event tap - falling back to NSEvent monitoring")
            // Fallback to NSEvent monitoring (won't consume events globally)
            registerWithNSEvent()
        }
    }
    
    private func registerWithNSEvent() {
        let settings = SettingsService.shared
        let modifiers = settings.hotkeyModifiers
        let keyCode = settings.hotkeyKeyCode
        
        // Monitor local events (when app has focus)
        hotkeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
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
    }
    
    private func getCurrentModifiers() -> NSEvent.ModifierFlags {
        return SettingsService.shared.hotkeyModifiers
    }
    
    private func getCurrentKeyCode() -> UInt16 {
        return SettingsService.shared.hotkeyKeyCode
    }
    
    func unregisterHotkey() {
        guard isRegistered else { return }
        
        // Remove CGEvent tap if it exists
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            }
            self.eventTap = nil
            self.runLoopSource = nil
        }
        
        // Remove NSEvent monitor if it exists
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