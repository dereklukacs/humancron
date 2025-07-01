//
//  humancronApp.swift
//  humancron
//
//  Created by obsess on 6/30/25.
//

import SwiftUI

@main
struct humancronApp: App {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var hotkeyService = ModernHotkeyService.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Start the hotkey service
        DispatchQueue.main.async {
            ModernHotkeyService.shared.registerHotkey()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(hotkeyService)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 400)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Preferences...") {
                    AppStateManager.shared.showPreferences()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

// App delegate for lifecycle events
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("App launched!")
        
        // Keep in dock for debugging
        NSApp.setActivationPolicy(.regular)
        
        // Setup window properly
        DispatchQueue.main.async {
            if let window = NSApp.windows.first {
                // Setup app state manager with window
                AppStateManager.shared.setup(window: window)
                
                // Check accessibility permissions
                let hasPermissions = ModernHotkeyService.shared.requestAccessibilityPermissions()
                print("Accessibility permissions: \(hasPermissions)")
            }
        }
        
        // Setup system tray
        SystemTrayService.shared.setup()
        print("System tray setup complete")
        
        // Show onboarding if needed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AppStateManager.shared.showOnboardingIfNeeded()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("App terminating")
        ModernHotkeyService.shared.unregisterHotkey()
    }
}

// Helper to access window
struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            callback(view?.window)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
