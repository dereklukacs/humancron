import SwiftUI
import DesignSystem
import AppKit

struct WorkflowSelectorView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var workflowService = WorkflowService.shared
    @StateObject private var historyService = WorkflowHistoryService.shared
    @State private var searchText = ""
    @State private var selectedIndex = 0
    @State private var eventMonitor: Any?
    
    var filteredWorkflows: [Workflow] {
        if searchText.isEmpty {
            return workflowService.workflows
        }
        return workflowService.workflows.filter { 
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: Token.Spacing.x3) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Token.Color.onSurface.opacity(0.5))
                
                TextField("Search workflows...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .onSubmit {
                        selectWorkflow()
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Token.Color.onSurface.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Token.Spacing.x3)
            .background(Token.Color.surface.opacity(0.8))
            .cornerRadius(Token.Radius.md)
            
            // Workflow list
            if workflowService.isLoading {
                Spacer()
                ProgressView("Loading workflows...")
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
                Spacer()
            } else if filteredWorkflows.isEmpty {
                Spacer()
                VStack(spacing: Token.Spacing.x3) {
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(Token.Color.onSurface.opacity(0.3))
                    
                    if searchText.isEmpty {
                        Text("No workflows found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                        
                        Text("Create a workflow in ~/.humancron/workflows/")
                            .font(.system(size: 14))
                            .foregroundColor(Token.Color.onSurface.opacity(0.5))
                        
                        Button("Open Workflows Folder") {
                            workflowService.openWorkflowsFolder()
                            appState.hideApp()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(Token.Color.brand)
                    } else {
                        Text("No workflows match '\(searchText)'")
                            .font(.system(size: 16))
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                    }
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: Token.Spacing.x2) {
                        ForEach(Array(filteredWorkflows.enumerated()), id: \.element.id) { index, workflow in
                            WorkflowRow(
                                workflow: workflow,
                                isSelected: index == selectedIndex,
                                lastRun: historyService.getLastRun(for: workflow.id),
                                shortcutNumber: index < 9 ? index + 1 : nil
                            )
                            .onTapGesture {
                                selectedIndex = index
                                selectWorkflow()
                            }
                        }
                    }
                }
            }
            
            // Help text
            HStack {
                Text("Press")
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
                ShortcutHint("1-9")
                Text("or")
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
                ShortcutHint("↵")
                Text("to select •")
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
                ShortcutHint("↑↓")
                Text("to navigate •")
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
                ShortcutHint("ESC")
                Text("to cancel")
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
            }
            .font(.system(size: 12))
        }
        .onAppear {
            selectedIndex = 0
            setupKeyboardHandling()
        }
        .onDisappear {
            removeKeyboardHandling()
        }
    }
    
    private func setupKeyboardHandling() {
        // Remove any existing monitor
        removeKeyboardHandling()
        
        // Add new monitor for keyboard events
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            switch event.keyCode {
            case 126: // Arrow Up
                if selectedIndex > 0 {
                    selectedIndex -= 1
                }
                return nil // Consume the event
                
            case 125: // Arrow Down
                if selectedIndex < filteredWorkflows.count - 1 {
                    selectedIndex += 1
                }
                return nil // Consume the event
                
            case 36: // Enter
                selectWorkflow()
                return nil // Consume the event
                
            case 53: // Escape
                appState.hideApp()
                return nil // Consume the event
                
            case 18...26: // Number keys 1-9
                let number = Int(event.keyCode - 17) // Convert keyCode to number (1-9)
                if number <= filteredWorkflows.count {
                    selectedIndex = number - 1
                    selectWorkflow()
                }
                return nil // Consume the event
                
            default:
                return event // Let the event pass through
            }
        }
    }
    
    private func removeKeyboardHandling() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func selectWorkflow() {
        guard filteredWorkflows.indices.contains(selectedIndex) else { return }
        let workflow = filteredWorkflows[selectedIndex]
        appState.startWorkflow(workflow)
    }
}

struct WorkflowRow: View {
    let workflow: Workflow
    let isSelected: Bool
    let lastRun: WorkflowRun?
    let shortcutNumber: Int?
    
    var body: some View {
        HStack {
            // Shortcut number indicator
            if let number = shortcutNumber {
                Text("\(number)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(isSelected ? Token.Color.brand : Token.Color.onSurface.opacity(0.5))
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(isSelected ? Token.Color.brand.opacity(0.2) : Token.Color.surface.opacity(0.8))
                    )
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Token.Color.brand : Token.Color.onSurface.opacity(0.2), lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: Token.Spacing.x1) {
                Text(workflow.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Token.Color.onSurface)
                
                Text(workflow.description)
                    .font(.system(size: 13))
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(workflow.steps.count) steps")
                    .font(.system(size: 12))
                    .foregroundColor(Token.Color.onSurface.opacity(0.5))
                
                if let lastRun = lastRun {
                    Text(WorkflowHistoryService.shared.formatLastRunTime(lastRun.startedAt))
                        .font(.system(size: 11))
                        .foregroundColor(Token.Color.onSurface.opacity(0.4))
                }
            }
        }
        .padding(Token.Spacing.x3)
        .background(isSelected ? Token.Color.brand.opacity(0.1) : Token.Color.surface.opacity(0.5))
        .overlay(
            RoundedRectangle(cornerRadius: Token.Radius.md)
                .stroke(isSelected ? Token.Color.brand : Color.clear, lineWidth: 2)
        )
        .cornerRadius(Token.Radius.md)
    }
}