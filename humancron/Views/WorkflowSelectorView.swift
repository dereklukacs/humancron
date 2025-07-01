import SwiftUI
import DesignSystem

struct WorkflowSelectorView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var workflowService = WorkflowService.shared
    @State private var searchText = ""
    @State private var selectedIndex = 0
    
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
                                isSelected: index == selectedIndex
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
                ShortcutHint("↵")
                Text("to select or")
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
                ShortcutHint("ESC")
                Text("to cancel")
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
            }
            .font(.system(size: 12))
        }
        .onAppear {
            selectedIndex = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("arrowUp"))) { _ in
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("arrowDown"))) { _ in
            if selectedIndex < filteredWorkflows.count - 1 {
                selectedIndex += 1
            }
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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Token.Spacing.x1) {
                Text(workflow.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Token.Color.onSurface)
                
                Text(workflow.description)
                    .font(.system(size: 13))
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
            }
            
            Spacer()
            
            Text("\(workflow.steps.count) steps")
                .font(.system(size: 12))
                .foregroundColor(Token.Color.onSurface.opacity(0.5))
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