import AppKit

// Custom window class that allows borderless windows to accept keyboard input
class BorderlessWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
}