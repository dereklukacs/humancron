import Foundation
import DesignSystem

/// Result of a command execution
public struct CommandResult: CommandResultProtocol {
    public let command: String
    public let exitCode: Int
    public let stdout: String
    public let stderr: String
    public let duration: TimeInterval
    public let environment: [String: String]
    
    public init(
        command: String,
        exitCode: Int,
        stdout: String,
        stderr: String,
        duration: TimeInterval,
        environment: [String: String] = [:]
    ) {
        self.command = command
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
        self.duration = duration
        self.environment = environment
    }
}