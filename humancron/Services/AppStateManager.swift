import SwiftUI
import Combine
import DesignSystem

@MainActor
class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var isActive = false
    @Published var currentWorkflow: Workflow?
    @Published var currentStep: Int = 0
    @Published var openedLinksForSteps: Set<Int> = []
    @Published var completedSteps: Set<Int> = []
    @Published var isPinned = false
    @Published var shouldExecuteCommand: Bool = false
    
    // Store paused workflow state
    private var pausedWorkflow: Workflow?
    private var pausedStep: Int = 0
    private var pausedCompletedSteps: Set<Int> = []
    private var pausedOpenedLinks: Set<Int> = []
    
    private var window: NSWindow?
    private var preferencesWindow: NSWindow?
    private var onboardingWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private var previousApp: NSRunningApplication?
    private var lastWindowPosition: CGPoint?
    private var windowDelegate: WindowDelegate?
    
    private init() {
        setupNotifications()
        loadWindowPosition()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .hotkeyPressed)
            .sink { [weak self] _ in
                self?.toggleApp()
            }
            .store(in: &cancellables)
    }
    
    func setup(window: NSWindow?) {
        // If we get a regular window, we need to replace it with our BorderlessWindow
        if let originalWindow = window {
            // Get the content view
            let contentView = originalWindow.contentView
            
            // Create our custom borderless window
            let borderlessWindow = BorderlessWindow(
                contentRect: originalWindow.frame,
                styleMask: [.borderless, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            
            // Transfer the content view
            if let contentView = contentView {
                borderlessWindow.contentView = contentView
            }
            
            // Store our custom window
            self.window = borderlessWindow
            
            // Close the original window
            originalWindow.close()
        }
        
        configureWindow()
        
        // Set up window delegate to track movement
        windowDelegate = WindowDelegate(appState: self)
        self.window?.delegate = windowDelegate
        
        // Initially hide the window after a short delay to ensure it's fully initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.window?.orderOut(nil)
            self?.isActive = false
        }
    }
    
    private func configureWindow() {
        guard let window = window else { return }
        
        // Configure window for overlay behavior
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.isMovableByWindowBackground = false
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        // window.hasShadow = false // We'll add our own shadow
        
        // Initial center
        centerWindow()
    }
    
    private func centerWindow() {
        guard let window = window else { return }
        
        // First check if we have a saved position
        if let savedPosition = lastWindowPosition {
            let windowSize = CGSize(width: 600, height: 400)
            window.setFrame(NSRect(origin: savedPosition, size: windowSize), display: true)
            return
        }
        
        // Otherwise center on main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let windowSize = CGSize(width: 600, height: 400)
            let x = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
            let y = screenFrame.origin.y + (screenFrame.height - windowSize.height) / 2
            window.setFrame(NSRect(origin: CGPoint(x: x, y: y), size: windowSize), display: true)
        }
    }
    
    func saveWindowPosition() {
        guard let window = window else { return }
        
        // Save the top-left position instead of bottom-left to handle height changes
        let frame = window.frame
        let topLeftY = frame.origin.y + frame.height
        
        // Save position that will maintain top-left corner
        lastWindowPosition = CGPoint(x: frame.origin.x, y: topLeftY)
        UserDefaults.standard.set(frame.origin.x, forKey: "HumanCronWindowX")
        UserDefaults.standard.set(topLeftY, forKey: "HumanCronWindowTopY")
    }
    
    private func loadWindowPosition() {
        let x = UserDefaults.standard.double(forKey: "HumanCronWindowX")
        let topY = UserDefaults.standard.double(forKey: "HumanCronWindowTopY")
        
        // Only use saved position if we have valid coordinates
        if x != 0 || topY != 0 {
            // We'll store top-left, but need to convert when showing window
            lastWindowPosition = CGPoint(x: x, y: topY)
        }
    }
    
    private func positionWindowOnActiveScreen() {
        guard let window = window else { return }
        
        // Get the screen with the mouse cursor
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { screen in
            NSMouseInRect(mouseLocation, screen.frame, false)
        } ?? NSScreen.main ?? NSScreen.screens.first
        
        guard let activeScreen = screen else { return }
        
        let screenFrame = activeScreen.frame
        let settings = SettingsService.shared
        let windowSize = CGSize(width: settings.windowWidth, height: settings.windowHeight)
        
        // Center on the active screen
        let x = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
        let y = screenFrame.origin.y + (screenFrame.height - windowSize.height) / 2
        
        window.setFrame(NSRect(origin: CGPoint(x: x, y: y), size: windowSize), display: true)
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
        
        // Save the currently active application before we activate
        previousApp = NSWorkspace.shared.frontmostApplication
        print("Saved previous app: \(previousApp?.localizedName ?? "None")")
        
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
        
        // If we have a saved position, use it; otherwise position on active screen
        if let savedPosition = lastWindowPosition {
            // Get window size from settings
            let settings = SettingsService.shared
            let windowSize = CGSize(width: settings.windowWidth, height: settings.windowHeight)
            
            // Convert from saved top-left to bottom-left for window frame
            let bottomLeftY = savedPosition.y - windowSize.height
            let windowOrigin = CGPoint(x: savedPosition.x, y: bottomLeftY)
            let windowFrame = NSRect(origin: windowOrigin, size: windowSize)
            
            let isVisible = NSScreen.screens.contains { screen in
                screen.frame.intersects(windowFrame)
            }
            
            if isVisible {
                // Use saved position
                window.setFrame(windowFrame, display: true)
            } else {
                // Saved position is off-screen, position on active screen
                positionWindowOnActiveScreen()
            }
        } else {
            // No saved position, position on active screen
            positionWindowOnActiveScreen()
        }
        
        withAnimation(.easeOut(duration: Token.Motion.fast)) {
            isActive = true
        }
        
        // Show window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hideApp(force: Bool = false, restoreFocus: Bool = true) {
        // Save window position before hiding
        saveWindowPosition()
        
        // Don't hide if pinned, unless forced
        if isPinned && !force {
            // Just restore focus to previous app without hiding the window
            if restoreFocus, let previousApp = previousApp {
                print("Restoring focus to: \(previousApp.localizedName ?? "Unknown")")
                previousApp.activate()
            }
            return
        }
        
        withAnimation(.easeIn(duration: Token.Motion.fast)) {
            isActive = false
        }
        
        // Hide window
        window?.orderOut(nil)
        
        // Restore focus to the previous application only if requested
        if restoreFocus, let previousApp = previousApp {
            print("Restoring focus to: \(previousApp.localizedName ?? "Unknown")")
            previousApp.activate()
        }
        
        // Reset state if no workflow is active
        if currentWorkflow == nil {
            currentStep = 0
        }
    }
    
    // Workflow management
    func startWorkflow(_ workflow: Workflow) {
        // Check if we have a paused version of this workflow
        if hasPausedWorkflow(workflow) {
            resumePausedWorkflow()
        } else {
            currentWorkflow = workflow
            currentStep = 0
            openedLinksForSteps.removeAll()
            completedSteps.removeAll()
            WorkflowHistoryService.shared.startWorkflow(workflow)
            notifyWorkflowChange()
        }
    }
    
    func toggleCurrentStepCompletion() {
        if completedSteps.contains(currentStep) {
            completedSteps.remove(currentStep)
        } else {
            completedSteps.insert(currentStep)
            
            // Check if all tasks are now completed
            if let workflow = currentWorkflow,
               completedSteps.count == workflow.steps.count {
                // All tasks completed, close the workflow
                completeWorkflow()
                return
            }
            
            // After marking as complete, move to next uncompleted task
            moveToNextUncompletedStep()
        }
        notifyWorkflowChange()
    }
    
    func moveToNextUncompletedStep() {
        guard let workflow = currentWorkflow else { return }
        
        // Look for the next uncompleted step
        for i in (currentStep + 1)..<workflow.steps.count {
            if !completedSteps.contains(i) {
                currentStep = i
                return
            }
        }
        
        // If no uncompleted steps found after current, check from beginning
        for i in 0..<currentStep {
            if !completedSteps.contains(i) {
                currentStep = i
                return
            }
        }
        
        // If all steps are completed, stay on current step
    }
    
    func nextStep() {
        guard let workflow = currentWorkflow else { return }
        
        // Mark current step as completed
        completedSteps.insert(currentStep)
        
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
            
            // Clear paused state if it's the same workflow
            if pausedWorkflow?.id == workflow.id {
                pausedWorkflow = nil
                pausedStep = 0
                pausedCompletedSteps.removeAll()
                pausedOpenedLinks.removeAll()
            }
        }
        currentWorkflow = nil
        currentStep = 0
        completedSteps.removeAll()
        openedLinksForSteps.removeAll()
        hideApp()
        notifyWorkflowChange()
    }
    
    func backToWorkflowList() {
        // Save current workflow state
        if let workflow = currentWorkflow {
            pausedWorkflow = workflow
            pausedStep = currentStep
            pausedCompletedSteps = completedSteps
            pausedOpenedLinks = openedLinksForSteps
        }
        
        // Clear current workflow to show list
        currentWorkflow = nil
        notifyWorkflowChange()
    }
    
    func hasPausedWorkflow(_ workflow: Workflow) -> Bool {
        return pausedWorkflow?.id == workflow.id
    }
    
    func resumePausedWorkflow() {
        if let paused = pausedWorkflow {
            currentWorkflow = paused
            currentStep = pausedStep
            completedSteps = pausedCompletedSteps
            openedLinksForSteps = pausedOpenedLinks
            
            // Clear paused state
            pausedWorkflow = nil
            pausedStep = 0
            pausedCompletedSteps.removeAll()
            pausedOpenedLinks.removeAll()
            
            notifyWorkflowChange()
        }
    }
    
    func resetWorkflow() {
        currentStep = 0
        openedLinksForSteps.removeAll()
        completedSteps.removeAll()
        notifyWorkflowChange()
    }
    
    func markLinkAsOpened(forStep step: Int) {
        openedLinksForSteps.insert(step)
    }
    
    func isLinkOpened(forStep step: Int) -> Bool {
        return openedLinksForSteps.contains(step)
    }
    
    func isStepCompleted(_ step: Int) -> Bool {
        return completedSteps.contains(step)
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
    
    // MARK: - Preferences Window
    
    func showPreferences() {
        if preferencesWindow == nil {
            let settingsView = SettingsView()
            
            let hostingController = NSHostingController(rootView: settingsView)
            
            // Use borderless window to match main app style
            let window = BorderlessWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
                styleMask: [.borderless, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.contentViewController = hostingController
            window.center()
            window.isReleasedWhenClosed = false
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .floating
            // window.hasShadow = false // We add our own shadow in the view
            
            preferencesWindow = window
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func closePreferences() {
        preferencesWindow?.close()
    }
    
    // MARK: - Onboarding Window
    
    func showOnboardingIfNeeded() {
        let settings = SettingsService.shared
        if !settings.hasCompletedOnboarding {
            showOnboarding()
        }
    }
    
    func showOnboarding() {
        if onboardingWindow == nil {
            let onboardingView = OnboardingView()
            let hostingController = NSHostingController(rootView: onboardingView)
            
            // Use borderless window to match main app style
            let window = BorderlessWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.borderless, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.contentViewController = hostingController
            window.center()
            window.isReleasedWhenClosed = false
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .floating
            // window.hasShadow = false // We add our own shadow in the view
            
            onboardingWindow = window
        }
        
        onboardingWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func closeOnboarding() {
        onboardingWindow?.close()
        onboardingWindow = nil
    }
}

// Workflow models (moved to separate file)
// See Models/Workflow.swift

// Window delegate to track window movement
class WindowDelegate: NSObject, NSWindowDelegate {
    weak var appState: AppStateManager?
    
    init(appState: AppStateManager) {
        self.appState = appState
        super.init()
    }
    
    func windowDidMove(_ notification: Notification) {
        // Save position whenever window moves
        appState?.saveWindowPosition()
    }
}