import Foundation
import Combine
import AppKit

@MainActor
class WorkflowService: ObservableObject {
    static let shared = WorkflowService()
    
    @Published var workflows: [Workflow] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var fileWatcher: DispatchSourceFileSystemObject?
    private var workflowsDirectory: URL
    
    private init() {
        // Set up workflows directory based on settings
        let settings = SettingsService.shared
        let directoryPath = settings.effectiveWorkflowsDirectory
        self.workflowsDirectory = URL(fileURLWithPath: directoryPath)
        
        // Set up notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workflowsDirectoryChanged),
            name: .workflowsDirectoryChanged,
            object: nil
        )
        
        // Defer initialization to avoid blocking
        Task { @MainActor in
            // Create directory if it doesn't exist
            createWorkflowsDirectory()
            
            // Load initial workflows
            loadWorkflows()
            
            // Set up file watcher after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.setupFileWatcher()
            }
        }
    }
    
    private func createWorkflowsDirectory() {
        do {
            try FileManager.default.createDirectory(at: workflowsDirectory, 
                                                  withIntermediateDirectories: true)
            
            // Create sample workflow if directory is empty
            let files = try FileManager.default.contentsOfDirectory(at: workflowsDirectory, 
                                                                   includingPropertiesForKeys: nil)
            if files.isEmpty {
                createSampleWorkflows()
            }
        } catch {
            print("Failed to create workflows directory: \(error)")
        }
    }
    
    private func createSampleWorkflows() {
        // Create daily planning workflow
        let dailyPlanning = YAMLParser.shared.generateSampleYAML()
        let dailyPlanningURL = workflowsDirectory.appendingPathComponent("daily-planning.yaml")
        
        // Create inbox cleanse workflow
        let inboxCleanse = """
        name: "Inbox Cleanse"
        description: "Process all inboxes and messages"
        hotkey: "cmd+2"
        steps:
          - name: "Email Triage"
            description: "Clean email inbox, archive or respond"
            link: "mailto:"
            duration: 300
            
          - name: "Slack Messages"
            description: "Review and respond to Slack messages"
            link: "slack://"
            duration: 300
            
          - name: "GitHub PRs"
            description: "Review pull requests"
            link: "https://github.com/pulls"
            duration: 600
        """
        let inboxCleanseURL = workflowsDirectory.appendingPathComponent("inbox-cleanse.yaml")
        
        // Create weekly review workflow
        let weeklyReview = """
        name: "Weekly Review"
        description: "Reflect on the week and plan ahead"
        hotkey: "cmd+3"
        steps:
          - name: "Journal"
            description: "Write weekly reflection"
            duration: 600
            
          - name: "Goals Review"
            description: "Check progress on goals"
            link: "notion://goals"
            duration: 300
            
          - name: "Next Week Planning"
            description: "Plan upcoming week"
            link: "https://calendar.google.com"
            duration: 300
        """
        let weeklyReviewURL = workflowsDirectory.appendingPathComponent("weekly-review.yaml")
        
        // Write files
        do {
            try dailyPlanning.write(to: dailyPlanningURL, atomically: true, encoding: .utf8)
            try inboxCleanse.write(to: inboxCleanseURL, atomically: true, encoding: .utf8)
            try weeklyReview.write(to: weeklyReviewURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to create sample workflows: \(error)")
        }
    }
    
    func loadWorkflows() {
        isLoading = true
        error = nil
        
        Task {
            do {
                var loadedWorkflows: [Workflow] = []
                
                let files = try FileManager.default.contentsOfDirectory(
                    at: workflowsDirectory,
                    includingPropertiesForKeys: [.isRegularFileKey]
                )
                
                for fileURL in files {
                    guard fileURL.pathExtension == "yaml" || fileURL.pathExtension == "yml" else {
                        continue
                    }
                    
                    do {
                        let workflow = try YAMLParser.shared.loadWorkflow(from: fileURL)
                        loadedWorkflows.append(workflow)
                    } catch {
                        print("Failed to load workflow from \(fileURL.lastPathComponent): \(error)")
                    }
                }
                
                // Update on main thread
                await MainActor.run {
                    self.workflows = loadedWorkflows.sorted { $0.name < $1.name }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    private func setupFileWatcher() {
        let fileDescriptor = open(workflowsDirectory.path, O_EVTONLY)
        
        guard fileDescriptor >= 0 else {
            print("Failed to open workflows directory for watching")
            return
        }
        
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global(qos: .background)
        )
        
        source.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.loadWorkflows()
            }
        }
        
        source.setCancelHandler {
            close(fileDescriptor)
        }
        
        source.resume()
        fileWatcher = source
    }
    
    func openWorkflowsFolder() {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: workflowsDirectory.path)
    }
    
    func createNewWorkflow(name: String) {
        let template = YAMLParser.shared.generateWorkflowTemplate()
        let filename = name.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "[^a-z0-9-]", with: "", options: .regularExpression)
        
        let fileURL = workflowsDirectory.appendingPathComponent("\(filename).yaml")
        
        do {
            try template.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Open in default editor
            NSWorkspace.shared.open(fileURL)
        } catch {
            self.error = error
        }
    }
    
    @objc private func workflowsDirectoryChanged() {
        // Stop existing file watcher
        fileWatcher?.cancel()
        fileWatcher = nil
        
        // Update directory path
        let settings = SettingsService.shared
        let directoryPath = settings.effectiveWorkflowsDirectory
        self.workflowsDirectory = URL(fileURLWithPath: directoryPath)
        
        // Create directory if needed
        createWorkflowsDirectory()
        
        // Reload workflows
        loadWorkflows()
        
        // Set up new file watcher
        setupFileWatcher()
    }
    
    deinit {
        fileWatcher?.cancel()
    }
}