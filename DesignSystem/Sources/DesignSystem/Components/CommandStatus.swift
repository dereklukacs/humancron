import SwiftUI

/// Represents the execution state of a command
public enum CommandState {
    case ready
    case running
    case success
    case failure
}

/// Protocol for command execution results
public protocol CommandResultProtocol {
    var command: String { get }
    var exitCode: Int { get }
    var stdout: String { get }
    var stderr: String { get }
    var duration: TimeInterval { get }
}

/// A component that displays command execution status with a popover for details
public struct CommandStatus<Result: CommandResultProtocol>: View {
    let state: CommandState
    let executionResult: Result?
    
    public init(state: CommandState, executionResult: Result? = nil) {
        self.state = state
        self.executionResult = executionResult
    }
    
    public var body: some View {
        DSPopover {
            HStack(spacing: 4) {
                Image(systemName: "scroll")
                    .foregroundColor(iconColor)
                    .frame(width: 14, height: 14)
                
                statusIcon
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .cornerRadius(4)

        } popoverContent: {
            if let result = executionResult {
                CommandOutputView(result: result)
            } else {
                Text("No execution data available")
                    .font(.system(size: 14))
                    .foregroundColor(Token.Color.onBackground.opacity(0.7))
            }
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        
            switch state {
            case .ready:
                Color.clear.frame(width: 0, height: 14)
            case .running:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.5).frame(width: 14, height: 14)
            case .success:
                Image(systemName: "checkmark")
                    .foregroundColor(.green).frame(width: 14, height: 14)
            case .failure:
                Image(systemName: "xmark")
                    .foregroundColor(.red).frame(width: 14, height: 14)
            }
        
        
    }
    
    private var iconColor: Color {
        switch state {
        case .ready:
            return Token.Color.onBackground.opacity(0.5)
        case .running:
            return Token.Color.brand
        case .success:
            return .green
        case .failure:
            return .red
        }
    }
    
    private var backgroundColor: Color {
        switch state {
        case .ready:
            return Token.Color.surface.opacity(0.5)
        case .running:
            return Token.Color.brand.opacity(0.1)
        case .success:
            return Color.green.opacity(0.1)
        case .failure:
            return Color.red.opacity(0.1)
        }
    }
}

/// View for displaying command output in the popover
struct CommandOutputView<Result: CommandResultProtocol>: View {
    let result: Result
    
    var body: some View {
        VStack(alignment: .leading, spacing: Token.Spacing.x2) {
            // Header
            HStack {
                Text("Command Output")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(String(format: "%.1fs", result.duration))
                    .font(.system(size: 14))
                    .foregroundColor(Token.Color.onBackground.opacity(0.7))
            }
            
            DSDivider()
            
            // Command
            VStack(alignment: .leading, spacing: Token.Spacing.x1) {
                Text("Command:")
                    .font(.system(size: 14))
                    .foregroundColor(Token.Color.onBackground.opacity(0.7))
                Text(result.command)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(Token.Color.onBackground)
                    .lineLimit(3)
                    .truncationMode(.middle)
            }
            
            // Exit Code
            HStack {
                Text("Exit code:")
                    .font(.system(size: 14))
                    .foregroundColor(Token.Color.onBackground.opacity(0.7))
                Text("\(result.exitCode)")
                    .font(.system(size: 14))
                    .foregroundColor(result.exitCode == 0 ? .green : .red)
            }
            
            DSDivider()
            
            // Output
            ScrollView {
                VStack(alignment: .leading, spacing: Token.Spacing.x1) {
                    if !result.stdout.isEmpty {
                        Text("Output:")
                            .font(.system(size: 14))
                            .foregroundColor(Token.Color.onBackground.opacity(0.7))
                        Text(result.stdout)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(Token.Color.onBackground)
                            .textSelection(.enabled)
                    }
                    
                    if !result.stderr.isEmpty {
                        Text("Error:")
                            .font(.system(size: 14))
                            .foregroundColor(Token.Color.onBackground.opacity(0.7))
                        Text(result.stderr)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.red)
                            .textSelection(.enabled)
                    }
                    
                    if result.stdout.isEmpty && result.stderr.isEmpty {
                        Text("No output")
                            .font(.system(size: 14))
                            .foregroundColor(Token.Color.onBackground.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 300)
        }
        .frame(width: 450)
    }
}

// MARK: - Preview Support

private struct MockCommandResult: CommandResultProtocol {
    let command: String
    let exitCode: Int
    let stdout: String
    let stderr: String
    let duration: TimeInterval
}

struct CommandStatus_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CommandStatus<MockCommandResult>(state: .ready)
            
            CommandStatus<MockCommandResult>(state: .running)
            
            CommandStatus(
                state: .success,
                executionResult: MockCommandResult(
                    command: "ls -la ~/Documents",
                    exitCode: 0,
                    stdout: "total 64\ndrwx------ 8 user staff 256 Dec 10 14:23 .\ndrwxr-xr-x 6 user staff 192 Dec 10 14:23 ..",
                    stderr: "",
                    duration: 0.134
                )
            )
            
            CommandStatus(
                state: .failure,
                executionResult: MockCommandResult(
                    command: "cat /nonexistent/file.txt",
                    exitCode: 1,
                    stdout: "",
                    stderr: "cat: /nonexistent/file.txt: No such file or directory",
                    duration: 0.023
                )
            )
        }
        .padding()
        .frame(width: 300)
        .background(Token.Color.background)
    }
}