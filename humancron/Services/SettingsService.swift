import Foundation
import SwiftUI

@MainActor
class SettingsService: ObservableObject {
    static let shared = SettingsService()
    
    @AppStorage("globalHotkey") var globalHotkey: String = "option+space"
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("showInDock") var showInDock: Bool = false
    @AppStorage("workflowsDirectory") var workflowsDirectory: String = ""
    @AppStorage("windowPosition") var windowPosition: String = ""
    @AppStorage("windowSize") var windowSize: String = ""
    
    // Hotkey components
    @Published var hotkeyModifiers: NSEvent.ModifierFlags = .option
    @Published var hotkeyKeyCode: UInt16 = 49 // Space key
    
    private init() {
        // Parse stored hotkey on init
        parseStoredHotkey()
    }
    
    var effectiveWorkflowsDirectory: String {
        if workflowsDirectory.isEmpty {
            return NSHomeDirectory() + "/.humancron/workflows"
        }
        return workflowsDirectory
    }
    
    func parseStoredHotkey() {
        let components = globalHotkey.lowercased().split(separator: "+")
        var modifiers: NSEvent.ModifierFlags = []
        var keyCode: UInt16 = 49 // Default to space
        
        for component in components {
            switch component {
            case "cmd", "command":
                modifiers.insert(.command)
            case "option", "alt":
                modifiers.insert(.option)
            case "control", "ctrl":
                modifiers.insert(.control)
            case "shift":
                modifiers.insert(.shift)
            case "space":
                keyCode = 49
            case "return", "enter":
                keyCode = 36
            case "tab":
                keyCode = 48
            case "escape", "esc":
                keyCode = 53
            default:
                // Handle letter keys
                if component.count == 1, let char = component.first {
                    keyCode = keyCodeForCharacter(char)
                }
            }
        }
        
        hotkeyModifiers = modifiers
        hotkeyKeyCode = keyCode
    }
    
    func updateHotkey(modifiers: NSEvent.ModifierFlags, keyCode: UInt16) {
        hotkeyModifiers = modifiers
        hotkeyKeyCode = keyCode
        
        // Build string representation
        var parts: [String] = []
        if modifiers.contains(.command) { parts.append("cmd") }
        if modifiers.contains(.option) { parts.append("option") }
        if modifiers.contains(.control) { parts.append("control") }
        if modifiers.contains(.shift) { parts.append("shift") }
        
        // Add key
        if let keyString = stringForKeyCode(keyCode) {
            parts.append(keyString)
        }
        
        globalHotkey = parts.joined(separator: "+")
    }
    
    func keyCodeForCharacter(_ char: Character) -> UInt16 {
        switch char.lowercased() {
        case "a": return 0
        case "s": return 1
        case "d": return 2
        case "f": return 3
        case "h": return 4
        case "g": return 5
        case "z": return 6
        case "x": return 7
        case "c": return 8
        case "v": return 9
        case "b": return 11
        case "q": return 12
        case "w": return 13
        case "e": return 14
        case "r": return 15
        case "y": return 16
        case "t": return 17
        case "1": return 18
        case "2": return 19
        case "3": return 20
        case "4": return 21
        case "6": return 22
        case "5": return 23
        case "9": return 25
        case "7": return 26
        case "8": return 28
        case "0": return 29
        case "o": return 31
        case "u": return 32
        case "i": return 34
        case "p": return 35
        case "l": return 37
        case "j": return 38
        case "k": return 40
        case "n": return 45
        case "m": return 46
        default: return 49 // Default to space
        }
    }
    
    func stringForKeyCode(_ keyCode: UInt16) -> String? {
        switch keyCode {
        case 0: return "a"
        case 1: return "s"
        case 2: return "d"
        case 3: return "f"
        case 4: return "h"
        case 5: return "g"
        case 6: return "z"
        case 7: return "x"
        case 8: return "c"
        case 9: return "v"
        case 11: return "b"
        case 12: return "q"
        case 13: return "w"
        case 14: return "e"
        case 15: return "r"
        case 16: return "y"
        case 17: return "t"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 22: return "6"
        case 23: return "5"
        case 25: return "9"
        case 26: return "7"
        case 28: return "8"
        case 29: return "0"
        case 31: return "o"
        case 32: return "u"
        case 34: return "i"
        case 35: return "p"
        case 37: return "l"
        case 38: return "j"
        case 40: return "k"
        case 45: return "n"
        case 46: return "m"
        case 36: return "return"
        case 48: return "tab"
        case 49: return "space"
        case 53: return "escape"
        default: return nil
        }
    }
    
    func saveWindowPosition(_ window: NSWindow) {
        let frame = window.frame
        windowPosition = "\(frame.origin.x),\(frame.origin.y)"
        windowSize = "\(frame.size.width),\(frame.size.height)"
    }
    
    func restoreWindowPosition(_ window: NSWindow) {
        if !windowPosition.isEmpty && !windowSize.isEmpty {
            let posComponents = windowPosition.split(separator: ",").compactMap { Double($0) }
            let sizeComponents = windowSize.split(separator: ",").compactMap { Double($0) }
            
            if posComponents.count == 2 && sizeComponents.count == 2 {
                let frame = NSRect(
                    x: posComponents[0],
                    y: posComponents[1],
                    width: sizeComponents[0],
                    height: sizeComponents[1]
                )
                window.setFrame(frame, display: true)
            }
        }
    }
}