import Foundation
import SwiftUI
import DesignSystem

/// Manages the state of command executions across workflow steps
@MainActor
class CommandStateManager: ObservableObject {
    static let shared = CommandStateManager()
    
    // Key: "\(workflowId)_\(stepId)"
    @Published private var commandStates: [String: CommandState] = [:]
    @Published private var commandResults: [String: CommandResult] = [:]
    
    private init() {}
    
    /// Get the state for a specific workflow step
    func getState(workflowId: UUID, stepId: UUID) -> CommandState {
        let key = "\(workflowId)_\(stepId)"
        return commandStates[key] ?? .ready
    }
    
    /// Get the result for a specific workflow step
    func getResult(workflowId: UUID, stepId: UUID) -> CommandResult? {
        let key = "\(workflowId)_\(stepId)"
        return commandResults[key]
    }
    
    /// Set the state for a specific workflow step
    func setState(_ state: CommandState, workflowId: UUID, stepId: UUID) {
        let key = "\(workflowId)_\(stepId)"
        commandStates[key] = state
    }
    
    /// Set the result for a specific workflow step
    func setResult(_ result: CommandResult, workflowId: UUID, stepId: UUID) {
        let key = "\(workflowId)_\(stepId)"
        commandResults[key] = result
    }
    
    /// Clear all states and results for a workflow
    func clearWorkflow(_ workflowId: UUID) {
        let prefix = "\(workflowId)_"
        commandStates = commandStates.filter { !$0.key.hasPrefix(prefix) }
        commandResults = commandResults.filter { !$0.key.hasPrefix(prefix) }
    }
    
    /// Clear all states and results
    func clearAll() {
        commandStates.removeAll()
        commandResults.removeAll()
    }
}