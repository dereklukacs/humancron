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
    @StateObject private var settings = SettingsService.shared
    
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
        .frame(width: appState.isActive ? settings.windowWidth : 1, height: appState.isActive ? settings.windowHeight : 1)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: Token.Radius.lg))
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
    @State private var windowDragLocation = CGPoint.zero
    
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
                    appState.hideApp(force: true)
                })
            ]
        } else {
            // Workflow execution hotkeys - dynamically built based on current step
            var items: [HotkeyItem] = []
            
            if let workflow = appState.currentWorkflow,
               let currentStep = workflow.steps[safe: appState.currentStep] {
                
                // Enter key - toggle completion
                items.append(HotkeyItem("↵", "Toggle Done", action: {
                    appState.toggleCurrentStepCompletion()
                }))
                
                // Spacebar - open link if available, otherwise disabled
                if let link = currentStep.link {
                    items.append(HotkeyItem("␣", "Open Link", action: {
                        LinkOpenerService.shared.openLink(link)
                        appState.markLinkAsOpened(forStep: appState.currentStep)
                        appState.hideApp(restoreFocus: false)
                    }))
                } else {
                    // Show disabled spacebar when no link
                    items.append(HotkeyItem("␣", "Open Link", action: nil))
                }
            }
            
            // Navigation arrows
            items.append(HotkeyItem("↑↓", "Navigate"))  // No action - keyboard only
            
            // Back to workflow list
            items.append(HotkeyItem("←", "Back", action: {
                appState.backToWorkflowList()
            }))
            
            items.append(HotkeyItem("ESC", "Exit", action: {
                appState.hideApp(force: true)
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
                // Drag handle area at the top
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 30)
                    .overlay(
                        ZStack {
                            // Visual drag indicator in center
                            Capsule()
                                .fill(Token.Color.onSurface.opacity(0.1))
                                .frame(width: 50, height: 4)
                            
                            // Pin button on the right
                            HStack {
                                Spacer()
                                Button(action: {
                                    appState.isPinned.toggle()
                                }) {
                                    Image(systemName: appState.isPinned ? "pin.fill" : "pin")
                                        .font(.system(size: 14))
                                        .foregroundColor(appState.isPinned ? Token.Color.brand : Token.Color.onSurface.opacity(0.6))
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, Token.Spacing.x2)
                            }
                        }
                    )
                    .background(WindowDragView())
                
                // Main content
                VStack(spacing: 0) {
                    if appState.currentWorkflow == nil {
                        // Show workflow selector
                        WorkflowSelectorView()
                            .padding(Token.Spacing.x4)
                            .padding(.top, -Token.Spacing.x4) // Compensate for drag area
                    } else {
                        // Show workflow execution view
                        WorkflowExecutionView()
                            .padding(.top, Token.Spacing.x4)
                            .padding(.top, -Token.Spacing.x4) // Compensate for drag area
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Hotkey bar at bottom
                HotkeyBar(items: hotkeyItems)
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: Token.Radius.lg))
        .shadow(radius: 20)
        .overlay(
            // Resize handle in bottom right corner - outside the clipped area
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ResizeHandle()
                        .frame(width: 20, height: 20)
                        .offset(x: -8, y: -8)
                }
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: .windowLostFocus)) { _ in
            // Hide when window loses focus only if not pinned
            if appState.isActive && !appState.isPinned {
                appState.hideApp()
            }
        }
    }
}

// Visual effect background
struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .sidebar
        view.blendingMode = .withinWindow
        view.state = .active
        view.wantsLayer = true
        view.layer?.masksToBounds = true
        view.layer?.cornerRadius = 16 // Match Token.Radius.lg
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.layer?.masksToBounds = true
        nsView.layer?.cornerRadius = 16 // Match Token.Radius.lg
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStateManager.shared)
}

// Window drag view that allows dragging the window
struct WindowDragView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        return DraggableView()
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // No updates needed
    }
}

// Custom NSView that handles window dragging
class DraggableView: NSView {
    override func mouseDown(with event: NSEvent) {
        if let window = self.window {
            window.performDrag(with: event)
        }
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}

// Resize handle view
struct ResizeHandle: View {
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            // Background for better visibility
            RoundedRectangle(cornerRadius: 4)
                .fill(Token.Color.surface.opacity(isHovered ? 0.8 : 0.5))
            
            // Visual indicator - diagonal lines
            Path { path in
                // First line
                path.move(to: CGPoint(x: 6, y: 14))
                path.addLine(to: CGPoint(x: 14, y: 6))
                
                // Second line
                path.move(to: CGPoint(x: 10, y: 14))
                path.addLine(to: CGPoint(x: 14, y: 10))
                
                // Third line
                path.move(to: CGPoint(x: 14, y: 14))
                path.addLine(to: CGPoint(x: 14, y: 14))
            }
            .stroke(Token.Color.onSurface.opacity(isHovered ? 0.6 : 0.4), lineWidth: 1.5)
        }
        .overlay(ResizableView())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// Window resize view
struct ResizableView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        return ResizeView()
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // No updates needed
    }
}

// Custom NSView that handles window resizing
class ResizeView: NSView {
    private var initialMouseLocation: NSPoint?
    private var initialFrame: NSRect?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
    }
    
    override func mouseDown(with event: NSEvent) {
        if let window = self.window {
            // Convert to screen coordinates
            let mouseLocation = window.convertPoint(toScreen: event.locationInWindow)
            initialMouseLocation = mouseLocation
            initialFrame = window.frame
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let window = self.window,
              let initialMouseLocation = initialMouseLocation,
              let initialFrame = initialFrame else { return }
        
        // Convert current mouse location to screen coordinates
        let currentMouseLocation = window.convertPoint(toScreen: event.locationInWindow)
        
        // Calculate deltas
        let deltaX = currentMouseLocation.x - initialMouseLocation.x
        let deltaY = -(currentMouseLocation.y - initialMouseLocation.y) // Invert Y for natural dragging
        
        // Calculate new size
        var newFrame = initialFrame
        newFrame.size.width = max(400, initialFrame.width + deltaX)
        newFrame.size.height = max(300, initialFrame.height + deltaY)
        
        // Keep the top-left corner in place
        newFrame.origin.y = initialFrame.origin.y + initialFrame.height - newFrame.height
        
        // Update window frame
        window.setFrame(newFrame, display: true, animate: false)
        
        // Update settings
        DispatchQueue.main.async {
            let settings = SettingsService.shared
            settings.windowWidth = newFrame.width
            settings.windowHeight = newFrame.height
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        initialMouseLocation = nil
        initialFrame = nil
    }
    
    override func resetCursorRects() {
        // Use the diagonal resize cursor
        self.addCursorRect(self.bounds, cursor: .crosshair)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}
