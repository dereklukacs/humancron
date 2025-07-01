import SwiftUI
import Carbon

class HotkeyService: ObservableObject {
    static let shared = HotkeyService()
    
    @Published var isRegistered = false
    
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: FourCharCode("HCRN".fourCharCodeValue), id: 1)
    
    private init() {}
    
    func registerHotkey() {
        guard !isRegistered else { return }
        
        // Register event handler
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        let handler: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            HotkeyService.shared.handleHotKeyPress()
            return noErr
        }
        
        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, nil, &eventHandler)
        
        // Register Option+Space (⌥+Space)
        let modifierFlags: UInt32 = UInt32(optionKey)
        let keyCode: UInt32 = 49 // Space key
        
        RegisterEventHotKey(keyCode, modifierFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        isRegistered = true
    }
    
    func unregisterHotkey() {
        guard isRegistered else { return }
        
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
        
        isRegistered = false
    }
    
    private func handleHotKeyPress() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .hotkeyPressed, object: nil)
        }
    }
}

extension Notification.Name {
    static let hotkeyPressed = Notification.Name("hotkeyPressed")
}

extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0
        if let data = self.data(using: .macOSRoman) {
            data.withUnsafeBytes { bytes in
                for i in 0..<min(4, bytes.count) {
                    result = result << 8 | FourCharCode(bytes[i])
                }
            }
        }
        return result
    }
}