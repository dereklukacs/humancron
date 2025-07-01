import Foundation

struct WorkflowRun: Codable {
    let workflowId: String
    let workflowName: String
    let startedAt: Date
    let completedAt: Date?
    let stepsCompleted: Int
    let totalSteps: Int
}

@MainActor
class WorkflowHistoryService: ObservableObject {
    static let shared = WorkflowHistoryService()
    
    @Published var history: [String: WorkflowRun] = [:] // workflowId -> last run
    
    private let historyFileURL: URL
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                    in: .userDomainMask).first!
        let humancronDir = documentsPath.appendingPathComponent(".humancron")
        self.historyFileURL = humancronDir.appendingPathComponent("history.json")
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: humancronDir, 
                                               withIntermediateDirectories: true)
        
        // Load history
        loadHistory()
    }
    
    private func loadHistory() {
        guard FileManager.default.fileExists(atPath: historyFileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: historyFileURL)
            let runs = try JSONDecoder().decode([WorkflowRun].self, from: data)
            
            // Convert to dictionary with most recent run per workflow
            for run in runs {
                if let existing = history[run.workflowId] {
                    if run.startedAt > existing.startedAt {
                        history[run.workflowId] = run
                    }
                } else {
                    history[run.workflowId] = run
                }
            }
        } catch {
            print("Failed to load history: \(error)")
        }
    }
    
    private func saveHistory() {
        do {
            let runs = Array(history.values).sorted { $0.startedAt > $1.startedAt }
            let data = try JSONEncoder().encode(runs)
            try data.write(to: historyFileURL)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
    
    func startWorkflow(_ workflow: Workflow) {
        let run = WorkflowRun(
            workflowId: workflow.id.uuidString,
            workflowName: workflow.name,
            startedAt: Date(),
            completedAt: nil,
            stepsCompleted: 0,
            totalSteps: workflow.steps.count
        )
        history[workflow.id.uuidString] = run
        saveHistory()
    }
    
    func completeWorkflow(_ workflow: Workflow, stepsCompleted: Int) {
        guard var run = history[workflow.id.uuidString] else { return }
        
        let updatedRun = WorkflowRun(
            workflowId: run.workflowId,
            workflowName: run.workflowName,
            startedAt: run.startedAt,
            completedAt: Date(),
            stepsCompleted: stepsCompleted,
            totalSteps: run.totalSteps
        )
        
        history[workflow.id.uuidString] = updatedRun
        saveHistory()
    }
    
    func getLastRun(for workflowId: UUID) -> WorkflowRun? {
        return history[workflowId.uuidString]
    }
    
    func formatLastRunTime(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}