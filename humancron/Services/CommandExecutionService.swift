import Foundation
import AppKit

/// Service responsible for executing shell commands from workflow steps
@MainActor
class CommandExecutionService: ObservableObject {
    static let shared = CommandExecutionService()
    
    private init() {}
    
    /// Environment variables to inject into all commands
    private var baseEnvironment: [String: String] {
        var env = ProcessInfo.processInfo.environment
        
        // Add HumanCron-specific variables
        let workflowDir = URL(fileURLWithPath: SettingsService.shared.effectiveWorkflowsDirectory)
        env["HUMANCRON_WORKFLOW_DIR"] = workflowDir.path
        env["HUMANCRON_SCRIPTS_DIR"] = workflowDir
            .appendingPathComponent("scripts").path
        
        return env
    }
    
    /// Execute a command with optional environment variables
    /// - Parameters:
    ///   - command: The shell command to execute
    ///   - workflowName: Name of the current workflow
    ///   - stepName: Name of the current step
    ///   - additionalEnv: Additional environment variables to include
    /// - Returns: CommandResult with execution details
    func executeCommand(
        _ command: String,
        workflowName: String,
        stepName: String,
        additionalEnv: [String: String] = [:]
    ) async -> CommandResult {
        let startTime = Date()
        
        // Prepare environment
        var environment = baseEnvironment
        environment["HUMANCRON_WORKFLOW_NAME"] = workflowName
        environment["HUMANCRON_STEP_NAME"] = stepName
        environment.merge(additionalEnv) { _, new in new }
        
        // Create process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        process.environment = environment
        
        // Set up pipes for output
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Capture output
        var stdout = ""
        var stderr = ""
        
        do {
            // Start the process
            try process.run()
            
            // Read output asynchronously
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            stdout = String(data: outputData, encoding: .utf8) ?? ""
            stderr = String(data: errorData, encoding: .utf8) ?? ""
            
            // Wait for completion
            process.waitUntilExit()
            
            let duration = Date().timeIntervalSince(startTime)
            
            return CommandResult(
                command: command,
                exitCode: Int(process.terminationStatus),
                stdout: stdout,
                stderr: stderr,
                duration: duration,
                environment: environment
            )
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            
            return CommandResult(
                command: command,
                exitCode: -1,
                stdout: stdout,
                stderr: "Failed to execute command: \(error.localizedDescription)",
                duration: duration,
                environment: environment
            )
        }
    }
    
    /// Check if a command looks like a script path and make it executable if needed
    private func prepareScriptIfNeeded(_ command: String) -> String {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if it's a path (starts with ~, /, or ./)
        if trimmed.hasPrefix("~/") || trimmed.hasPrefix("/") || trimmed.hasPrefix("./") {
            // Expand tilde if present
            let expandedPath = NSString(string: trimmed).expandingTildeInPath
            let url = URL(fileURLWithPath: expandedPath)
            
            // Check if file exists and make it executable
            if FileManager.default.fileExists(atPath: url.path) {
                // Make executable (chmod +x)
                try? FileManager.default.setAttributes(
                    [.posixPermissions: 0o755],
                    ofItemAtPath: url.path
                )
            }
        }
        
        return command
    }
}

// MARK: - CommandResult Extension for Display

extension CommandResult {
    /// Format the result for display in UI
    var displaySummary: String {
        if exitCode == 0 {
            return "Command executed successfully"
        } else {
            return "Command failed with exit code \(exitCode)"
        }
    }
    
    /// Check if the command was successful
    var isSuccess: Bool {
        exitCode == 0
    }
    
    /// Get formatted duration string
    var durationString: String {
        String(format: "%.1fs", duration)
    }
    
    /// Combined output for display
    var combinedOutput: String {
        var output = ""
        
        if !stdout.isEmpty {
            output += stdout
        }
        
        if !stderr.isEmpty {
            if !output.isEmpty {
                output += "\n\n--- Error Output ---\n"
            }
            output += stderr
        }
        
        return output.isEmpty ? "No output" : output
    }
}