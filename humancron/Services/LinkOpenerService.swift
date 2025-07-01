import Foundation
import AppKit

@MainActor
class LinkOpenerService {
    static let shared = LinkOpenerService()
    
    private init() {}
    
    /// Opens a link, supporting various URL schemes and app protocols
    func openLink(_ link: String) {
        print("Opening link: \(link)")
        
        // Handle different link formats
        if let url = processLink(link) {
            NSWorkspace.shared.open(url)
        } else {
            print("Failed to process link: \(link)")
        }
    }
    
    private func processLink(_ link: String) -> URL? {
        // Direct URL
        if let url = URL(string: link) {
            return url
        }
        
        // Handle common app shortcuts
        let appMappings: [String: String] = [
            "calendar": "x-fantastical3://",
            "notion-calendar": "notion-calendar://",
            "slack": "slack://",
            "notion": "notion://",
            "things": "things3://",
            "obsidian": "obsidian://",
            "discord": "discord://",
            "zoom": "zoommtg://",
            "mail": "mailto:",
            "messages": "imessage://",
            "facetime": "facetime://",
            "music": "music://",
            "spotify": "spotify://",
            "vscode": "vscode://",
            "xcode": "xcode://",
            "terminal": "x-terminal://",
            "finder": "x-finder://",
            "safari": "x-safari://",
            "chrome": "googlechrome://",
            "firefox": "firefox://",
            "arc": "arc://",
            "linear": "linear://",
            "github": "x-github-client://",
            "figma": "figma://",
            "twitter": "twitter://",
            "x": "twitter://",
            "whatsapp": "whatsapp://"
        ]
        
        // Check if it's a known app shortcut
        let lowercasedLink = link.lowercased()
        for (app, scheme) in appMappings {
            if lowercasedLink == app || lowercasedLink == "\(app)://" {
                return URL(string: scheme)
            }
        }
        
        // Try adding https:// if it looks like a domain
        if link.contains(".") && !link.contains("://") {
            return URL(string: "https://\(link)")
        }
        
        return nil
    }
    
    /// Check if a URL scheme is registered on the system
    func canOpenURL(_ url: URL) -> Bool {
        return NSWorkspace.shared.urlForApplication(toOpen: url) != nil
    }
    
    /// Get a list of supported app shortcuts
    func supportedAppShortcuts() -> [String] {
        return [
            "calendar", "notion-calendar", "slack", "notion", "things",
            "obsidian", "discord", "zoom", "mail", "messages", "facetime",
            "music", "spotify", "vscode", "xcode", "terminal", "finder",
            "safari", "chrome", "firefox", "arc", "linear", "github",
            "figma", "twitter", "x", "whatsapp"
        ]
    }
}