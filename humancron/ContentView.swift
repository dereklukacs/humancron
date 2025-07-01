//
//  ContentView.swift
//  humancron
//
//  Created by obsess on 6/30/25.
//

import SwiftUI
import DesignSystem

struct ContentView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        Group {
            if appState.isActive {
                // Main overlay UI
                MainOverlayView()
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity.combined(with: .scale(scale: 1.05))
                    ))
            } else {
                // Empty view when hidden
                Color.clear
                    .frame(width: 1, height: 1)
            }
        }
        .frame(width: appState.isActive ? 600 : 1, height: appState.isActive ? 400 : 1)
        .background(Color.clear)
        .onAppear {
            // Debug: Show notification when hotkey is pressed
            NotificationCenter.default.addObserver(
                forName: .hotkeyPressed,
                object: nil,
                queue: .main
            ) { _ in
                print("Hotkey pressed!")
            }
        }
    }
}

struct MainOverlayView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var hotkeyItems: [HotkeyItem] {
        if appState.currentWorkflow == nil {
            // Workflow selector hotkeys
            return [
                HotkeyItem("↵", "Select"),
                HotkeyItem("↑↓", "Navigate"),
                HotkeyItem("ESC", "Cancel")
            ]
        } else {
            // Workflow execution hotkeys - dynamically built based on current step
            var items: [HotkeyItem] = []
            
            if let workflow = appState.currentWorkflow,
               let currentStep = workflow.steps[safe: appState.currentStep] {
                
                // Primary action - changes based on link state
                if let _ = currentStep.link, !appState.isLinkOpened(forStep: appState.currentStep) {
                    items.append(HotkeyItem("↵", "Open Link"))
                } else {
                    items.append(HotkeyItem("↵", "Next"))
                }
            }
            
            // Navigation
            if appState.currentStep > 0 {
                items.append(HotkeyItem("←", "Back"))
            }
            
            // Always available actions
            items.append(HotkeyItem("→", "Skip"))
            items.append(HotkeyItem("⌘R", "Restart"))
            items.append(HotkeyItem("ESC", "Exit"))
            
            return items
        }
    }
    
    var body: some View {
        ZStack {
            // Background with blur effect
            VisualEffectBackground()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 0) {
                // Main content
                VStack(spacing: 0) {
                    if appState.currentWorkflow == nil {
                        // Show workflow selector
                        WorkflowSelectorView()
                    } else {
                        // Show workflow execution view
                        WorkflowExecutionView()
                    }
                }
                .padding(Token.Spacing.x4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Hotkey bar at bottom
                HotkeyBar(items: hotkeyItems)
            }
        }
        .clipped()
        .cornerRadius(Token.Radius.lg)
        .shadow(radius: 20)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            // Hide when app loses focus
            if appState.isActive && appState.currentWorkflow == nil {
                appState.hideApp()
            }
        }
    }
}

// Visual effect background
struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        view.wantsLayer = true
        view.layer?.masksToBounds = true
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.layer?.masksToBounds = true
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStateManager.shared)
}
