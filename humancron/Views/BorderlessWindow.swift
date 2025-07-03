import AppKit

// Custom window class that allows borderless windows to accept keyboard input
class BorderlessWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        // Enable window movement
        self.isMovableByWindowBackground = true
        self.isMovable = true
    }
    
    override func resignKey() {
        super.resignKey()
        // Post notification when window loses key status
        NotificationCenter.default.post(name: .windowLostFocus, object: self)
    }
    
    override func resignMain() {
        super.resignMain()
        // Post notification when window loses main status
        NotificationCenter.default.post(name: .windowLostFocus, object: self)
    }
}

// Custom notification for window focus loss
extension Notification.Name {
    static let windowLostFocus = Notification.Name("windowLostFocus")
}