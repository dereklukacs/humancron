import SwiftUI
import DesignSystem
import AppKit

struct WorkflowsSettingsView: View {
    @StateObject private var settings = SettingsService.shared
    @State private var showingDirectoryPicker = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Token.Spacing.x4) {
                // Workflows Directory Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("Workflows Directory")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Token.Color.onSurface)
                    
                    Text("Location where your workflow YAML files are stored")
                        .font(.system(size: 12))
                        .foregroundColor(Token.Color.onSurface.opacity(0.7))
                    
                    HStack {
                        Text(settings.effectiveWorkflowsDirectory)
                            .font(.system(size: 12))
                            .foregroundColor(Token.Color.onSurface)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Token.Spacing.x3)
                            .padding(.vertical, Token.Spacing.x2)
                            .background(
                                RoundedRectangle(cornerRadius: Token.Radius.sm)
                                    .fill(Token.Color.surface)
                            )
                        
                        Button("Choose...") {
                            showDirectoryPicker()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Open") {
                            openWorkflowsDirectory()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    
                    if settings.workflowsDirectory.isEmpty {
                        Label("Using default directory", systemImage: "info.circle")
                            .font(.system(size: 11))
                            .foregroundColor(Token.Color.onSurface.opacity(0.5))
                    }
                }
                
                Divider()
                    .padding(.vertical, Token.Spacing.x2)
                
                // Workflow Management Section
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Text("Workflow Management")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Token.Color.onSurface)
                    
                    Button(action: createExampleWorkflows) {
                        Label("Create Example Workflows", systemImage: "doc.badge.plus")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Text("Creates sample workflow files to help you get started")
                        .font(.system(size: 12))
                        .foregroundColor(Token.Color.onSurface.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(Token.Spacing.x4)
        }
    }
    
    private func showDirectoryPicker() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "Select Workflows Directory"
        
        if panel.runModal() == .OK, let url = panel.url {
            // Use the new method that creates security-scoped bookmarks
            settings.saveWorkflowsDirectory(url)
            
            // Notify workflow service to reload
            NotificationCenter.default.post(name: .workflowsDirectoryChanged, object: nil)
        }
    }
    
    private func openWorkflowsDirectory() {
        let url = URL(fileURLWithPath: settings.effectiveWorkflowsDirectory)
        NSWorkspace.shared.open(url)
    }
    
    private func createExampleWorkflows() {
        let workflowsDir = settings.effectiveWorkflowsDirectory
        let fileManager = FileManager.default
        
        // Ensure directory exists
        try? fileManager.createDirectory(atPath: workflowsDir, withIntermediateDirectories: true)
        
        // Create example workflows
        let examples = [
            (
                name: "daily-standup.yaml",
                content: """
                name: "Daily Standup"
                description: "Prepare for daily standup meeting"
                steps:
                  - name: "Review Calendar"
                    description: "Check today's meetings and schedule"
                    link: "notion-calendar://"
                    
                  - name: "Review Yesterday's Work"
                    description: "Look at completed tasks from yesterday"
                    link: "https://linear.app/team/completed"
                    
                  - name: "Check Today's Tasks"
                    description: "Review planned work for today"
                    link: "https://linear.app/team/active"
                    
                  - name: "Review PRs"
                    description: "Check pending pull requests"
                    link: "https://github.com/pulls"
                    
                  - name: "Update Status"
                    description: "Post standup update in Slack"
                    link: "slack://channel?team=YOUR_TEAM_ID&id=YOUR_CHANNEL_ID"
                """
            ),
            (
                name: "inbox-cleanse.yaml",
                content: """
                name: "Inbox Cleanse"
                description: "Process all inboxes and messages"
                steps:
                  - name: "Check Email"
                    description: "Process and archive emails"
                    link: "https://mail.google.com"
                    
                  - name: "Review Slack"
                    description: "Catch up on important messages"
                    link: "slack://"
                    
                  - name: "Check Notifications"
                    description: "Review GitHub notifications"
                    link: "https://github.com/notifications"
                    
                  - name: "Process Tasks"
                    description: "Triage new tasks in Linear"
                    link: "https://linear.app/team/triage"
                """
            ),
            (
                name: "end-of-day.yaml",
                content: """
                name: "End of Day"
                description: "Wrap up the work day"
                steps:
                  - name: "Update Task Status"
                    description: "Mark completed tasks and update progress"
                    link: "https://linear.app/team/active"
                    
                  - name: "Review Tomorrow"
                    description: "Check tomorrow's calendar and priorities"
                    link: "notion-calendar://"
                    
                  - name: "Clear Desktop"
                    description: "Close unnecessary apps and windows"
                    
                  - name: "Update Team"
                    description: "Post EOD update if needed"
                    link: "slack://channel?team=YOUR_TEAM_ID&id=YOUR_CHANNEL_ID"
                """
            )
        ]
        
        for (filename, content) in examples {
            let path = "\(workflowsDir)/\(filename)"
            if !fileManager.fileExists(atPath: path) {
                try? content.write(toFile: path, atomically: true, encoding: .utf8)
            }
        }
        
        // Show success message
        let alert = NSAlert()
        alert.messageText = "Example Workflows Created"
        alert.informativeText = "Example workflow files have been created in your workflows directory."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
        // Notify workflow service to reload
        NotificationCenter.default.post(name: .workflowsDirectoryChanged, object: nil)
    }
}

extension Notification.Name {
    static let workflowsDirectoryChanged = Notification.Name("workflowsDirectoryChanged")
}