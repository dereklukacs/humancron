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
                HotkeyItem("↵", "Select", action: {
                    // Trigger select action for workflow selector
                    NotificationCenter.default.post(name: .selectWorkflow, object: nil)
                }),
                HotkeyItem("↑↓", "Navigate"),  // No action - keyboard only
                HotkeyItem("ESC", "Cancel", action: {
                    appState.hideApp()
                })
            ]
        } else {
            // Workflow execution hotkeys - dynamically built based on current step
            var items: [HotkeyItem] = []
            
            if let workflow = appState.currentWorkflow,
               let currentStep = workflow.steps[safe: appState.currentStep] {
                
                // Primary action - changes based on link state
                if let link = currentStep.link, !appState.isLinkOpened(forStep: appState.currentStep) {
                    items.append(HotkeyItem("↵", "Open Link", action: {
                        LinkOpenerService.shared.openLink(link)
                        appState.markLinkAsOpened(forStep: appState.currentStep)
                        appState.hideApp()
                    }))
                } else {
                    items.append(HotkeyItem("↵", "Next", action: {
                        appState.nextStep()
                    }))
                }
            }
            
            // Navigation - always show back button to prevent layout shift
            items.append(HotkeyItem("←", "Back", action: appState.currentStep > 0 ? {
                appState.previousStep()
            } : nil))
            
            // Always available actions
            items.append(HotkeyItem("→", "Skip", action: {
                appState.nextStep()
            }))
            items.append(HotkeyItem("⌘R", "Restart", action: {
                appState.resetWorkflow()
            }))
            items.append(HotkeyItem("ESC", "Exit", action: {
                appState.hideApp()
                appState.completeWorkflow()
            }))
            
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
