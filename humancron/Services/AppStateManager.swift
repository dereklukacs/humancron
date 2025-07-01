import SwiftUI
import Combine
import DesignSystem

@MainActor
class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var isActive = false
    @Published var currentWorkflow: Workflow?
    @Published var currentStep: Int = 0
    
    private var window: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .hotkeyPressed)
            .sink { [weak self] _ in
                self?.toggleApp()
            }
            .store(in: &cancellables)
    }
    
    func setup(window: NSWindow?) {
        self.window = window
        configureWindow()
        
        // Initially hide the window after a short delay to ensure it's fully initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            window?.orderOut(nil)
            self?.isActive = false
        }
    }
    
    private func configureWindow() {
        guard let window = window else { return }
        
        // Configure window for overlay behavior
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.styleMask = [.borderless, .fullSizeContentView]
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Initial center
        centerWindow()
    }
    
    private func centerWindow() {
        guard let window = window else { return }
        
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let windowSize = CGSize(width: 600, height: 400)
            let x = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
            let y = screenFrame.origin.y + (screenFrame.height - windowSize.height) / 2
            window.setFrame(NSRect(origin: CGPoint(x: x, y: y), size: windowSize), display: true)
        }
    }
    
    func toggleApp() {
        if isActive {
            hideApp()
        } else {
            showApp()
        }
    }
    
    func showApp() {
        guard let window = window else { 
            print("No window available")
            return 
        }
        
        // Ensure we have accessibility permissions
        let hasPermissions = ModernHotkeyService.shared.requestAccessibilityPermissions()
        print("Accessibility permissions: \(hasPermissions)")
        
        if !hasPermissions {
            // Show alert to user
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "HumanCron needs accessibility permissions to use global hotkeys. Please grant access in System Settings > Privacy & Security > Accessibility."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Cancel")
            
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
            return
        }
        
        print("Showing app window")
        
        // Center window before showing
        centerWindow()
        
        withAnimation(.easeOut(duration: Token.Motion.fast)) {
            isActive = true
        }
        
        // Show window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hideApp() {
        withAnimation(.easeIn(duration: Token.Motion.fast)) {
            isActive = false
        }
        
        // Hide window
        window?.orderOut(nil)
        
        // Reset state if no workflow is active
        if currentWorkflow == nil {
            currentStep = 0
        }
    }
    
    // Workflow management
    func startWorkflow(_ workflow: Workflow) {
        currentWorkflow = workflow
        currentStep = 0
        WorkflowHistoryService.shared.startWorkflow(workflow)
        notifyWorkflowChange()
    }
    
    func nextStep() {
        guard let workflow = currentWorkflow else { return }
        
        if currentStep < workflow.steps.count - 1 {
            currentStep += 1
            notifyWorkflowChange()
        } else {
            // Workflow completed
            completeWorkflow()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
            notifyWorkflowChange()
        }
    }
    
    func completeWorkflow() {
        if let workflow = currentWorkflow {
            WorkflowHistoryService.shared.completeWorkflow(workflow, stepsCompleted: currentStep + 1)
        }
        currentWorkflow = nil
        currentStep = 0
        hideApp()
        notifyWorkflowChange()
    }
    
    func resetWorkflow() {
        currentStep = 0
        notifyWorkflowChange()
    }
    
    private func notifyWorkflowChange() {
        var userInfo: [String: Any] = [:]
        if let workflow = currentWorkflow {
            userInfo["workflow"] = workflow
            userInfo["step"] = currentStep
        }
        NotificationCenter.default.post(
            name: .workflowChanged,
            object: self,
            userInfo: userInfo
        )
    }
}

// Workflow models (moved to separate file)
// See Models/Workflow.swift