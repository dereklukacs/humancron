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
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set icon
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock.badge.checkmark", accessibilityDescription: "HumanCron")
            button.imagePosition = .imageLeading
            updateTitle(nil)
        }
        
        // Create menu
        createMenu()
        
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
        menu.addItem(NSMenuItem(
            title: "Open HumanCron",
            action: #selector(openApp),
            keyEquivalent: "o"
        ))
        
        menu.addItem(NSMenuItem.separator())
        
        // Preferences
        menu.addItem(NSMenuItem(
            title: "Preferences...",
            action: #selector(openPreferences),
            keyEquivalent: ","
        ))
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        menu.addItem(NSMenuItem(
            title: "Quit HumanCron",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))
        
        self.statusItem?.menu = menu
        statusBarMenu = menu
    }
    
    func updateTitle(_ title: String?) {
        if let button = statusItem?.button {
            if let title = title {
                button.title = " \(title)"
            } else {
                button.title = ""
            }
        }
    }
    
    func updateWorkflowStatus(_ workflow: Workflow?, step: Int) {
        guard let menu = statusBarMenu else { return }
        
        if let workflow = workflow {
            let stepText = "Step \(step + 1)/\(workflow.steps.count)"
            menu.items[0].title = "\(workflow.name) - \(stepText)"
            updateTitle(stepText)
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
        // TODO: Implement preferences window
        print("Opening preferences...")
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

extension Notification.Name {
    static let workflowChanged = Notification.Name("workflowChanged")
}