import SwiftUI
import AppKit

@MainActor
class SystemTrayService: ObservableObject {
    static let shared = SystemTrayService()
    
    private var statusItem: NSStatusItem?
    private var statusBarMenu: NSMenu?
    @Published var currentWorkflow: String?
    
    private init() {}
    
    func setup() {
        print("SystemTrayService: Starting setup")
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        print("SystemTrayService: Created status item: \(statusItem != nil)")
        
        // Set icon
        if let button = statusItem?.button {
            // Use text instead of icon for better visibility
            button.title = "HC"
            button.toolTip = "HumanCron"
            
            // Make sure the status item is visible
            statusItem?.isVisible = true
            print("SystemTrayService: Status item setup complete with title: \(button.title ?? "nil")")
        }
        
        // Create menu
        createMenu()
        print("SystemTrayService: Menu created")
        
        // Set button action to show menu
        if let button = statusItem?.button {
            button.action = #selector(statusItemClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Subscribe to workflow changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workflowChanged(_:)),
            name: .workflowChanged,
            object: nil
        )
    }
    
    private func createMenu() {
        let menu = NSMenu()
        
        // Current workflow status
        let statusItem = NSMenuItem(title: "No active workflow", action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Open app
        let openItem = NSMenuItem(
            title: "Open HumanCron",
            action: #selector(openApp),
            keyEquivalent: "o"
        )
        openItem.target = self
        menu.addItem(openItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Preferences
        let preferencesItem = NSMenuItem(
            title: "Preferences...",
            action: #selector(openPreferences),
            keyEquivalent: ","
        )
        preferencesItem.target = self
        menu.addItem(preferencesItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit HumanCron",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        self.statusItem?.menu = menu
        statusBarMenu = menu
    }
    
    func updateTitle(_ title: String?) {
        if let button = statusItem?.button {
            if let title = title {
                button.title = "HC: \(title)"
            } else {
                button.title = "HC"
            }
        }
    }
    
    func updateWorkflowStatus(_ workflow: Workflow?, step: Int) {
        guard let menu = statusBarMenu else { return }
        
        if let workflow = workflow {
            let currentStepTitle = workflow.steps[step].name
            let stepProgress = "(\(step + 1)/\(workflow.steps.count))"
            menu.items[0].title = "\(workflow.name) - Step \(step + 1): \(currentStepTitle)"
            updateTitle("\(currentStepTitle) \(stepProgress)")
            currentWorkflow = workflow.name
        } else {
            menu.items[0].title = "No active workflow"
            updateTitle(nil)
            currentWorkflow = nil
        }
    }
    
    @objc private func workflowChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let workflow = userInfo["workflow"] as? Workflow,
           let step = userInfo["step"] as? Int {
            updateWorkflowStatus(workflow, step: step)
        } else {
            updateWorkflowStatus(nil, step: 0)
        }
    }
    
    @objc private func openApp() {
        AppStateManager.shared.showApp()
    }
    
    @objc private func openPreferences() {
        AppStateManager.shared.showPreferences()
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc private func statusItemClicked(_ sender: Any?) {
        print("SystemTrayService: Status item clicked")
        if let event = NSApp.currentEvent {
            statusItem?.menu = statusBarMenu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil // Remove menu after showing to allow future clicks
        }
    }
}

extension Notification.Name {
    static let workflowChanged = Notification.Name("workflowChanged")
    static let selectWorkflow = Notification.Name("selectWorkflow")
}