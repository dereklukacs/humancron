import SwiftUI
import DesignSystem
import AppKit

struct WorkflowSelectorView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var workflowService = WorkflowService.shared
    @StateObject private var historyService = WorkflowHistoryService.shared
    @StateObject private var faviconService = FaviconService.shared
    @State private var searchText = ""
    @State private var selectedIndex = 0
    @State private var hoveredIndex: Int? = nil
    @FocusState private var isSearchFieldFocused: Bool
    
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
            ZStack {
                DSTextField("Search workflows...", text: $searchText)
                    .focused($isSearchFieldFocused)
                    .onChange(of: searchText) { oldValue, newValue in
                        // Reset selection to first item when search changes
                        selectedIndex = 0
                    }
                    .onSubmit {
                        selectWorkflow()
                    }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Token.Color.onSurface.opacity(0.5))
                        .padding(.leading, Token.Spacing.x3)
                        .allowsHitTesting(false)
                    
                    Spacer()
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Token.Color.onSurface.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, Token.Spacing.x3)
                    }
                }
            }
            
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
                            .textStyle(.body)
                            .fontWeight(.medium)
                            .foregroundColor(Token.Color.onSurface.opacity(0.7))
                        
                        Text("Create a workflow in ~/.humancron/workflows/")
                            .textStyle(.bodySmall)
                            .foregroundColor(Token.Color.onSurface.opacity(0.5))
                        
                        DSButton("Open Workflows Folder", style: .tertiary) {
                            workflowService.openWorkflowsFolder()
                            appState.hideApp()
                        }
                    } else {
                        Text("No workflows match '\(searchText)'")
                            .textStyle(.body)
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
                                isHovered: index == hoveredIndex,
                                lastRun: historyService.getLastRun(for: workflow.id),
                                shortcutNumber: nil,
                                isPaused: appState.hasPausedWorkflow(workflow)
                            )
                            .onTapGesture {
                                selectedIndex = index
                                selectWorkflow()
                            }
                            .onHover { hovering in
                                hoveredIndex = hovering ? index : nil
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            selectedIndex = 0
            // Focus the search field after a small delay to ensure the view is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSearchFieldFocused = true
            }
            // Prefetch favicons for all workflows
            faviconService.prefetchFavicons(for: workflowService.workflows)
        }
        .onReceive(NotificationCenter.default.publisher(for: .selectWorkflow)) { _ in
            selectWorkflow()
        }
        // Handle keyboard shortcuts using SwiftUI modifiers
        .onKeyPress(.upArrow) {
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
            return .handled
        }
        .onKeyPress(.downArrow) {
            if selectedIndex < filteredWorkflows.count - 1 {
                selectedIndex += 1
            }
            return .handled
        }
        .onKeyPress(.return) {
            selectWorkflow()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            selectWorkflow()
            return .handled
        }
        .onKeyPress(.escape) {
            appState.hideApp(force: true)
            return .handled
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
    let isHovered: Bool
    let lastRun: WorkflowRun?
    let shortcutNumber: Int?
    let isPaused: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Token.Spacing.x1) {
                HStack(spacing: Token.Spacing.x2) {
                    Text(workflow.name)
                        .textStyle(.body)
                        .fontWeight(.medium)
                        .foregroundColor(Token.Color.onSurface)
                    
                    if isPaused {
                        HStack(spacing: Token.Spacing.x1) {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 12))
                            Text("In Progress")
                                .textStyle(.caption)
                        }
                        .foregroundColor(Token.Color.brand)
                    }
                }
                
                Text(workflow.description)
                    .textStyle(.bodySmall)
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(workflow.steps.count) steps")
                    .textStyle(.caption)
                    .foregroundColor(Token.Color.onSurface.opacity(0.5))
                
                if let lastRun = lastRun {
                    Text(WorkflowHistoryService.shared.formatLastRunTime(lastRun.startedAt))
                        .textStyle(.caption)
                        .foregroundColor(Token.Color.onSurface.opacity(0.4))
                }
            }
        }
        .padding(Token.Spacing.x3)
        .background(
            isSelected ? Token.Color.brand.opacity(0.1) : 
            isHovered ? Token.Color.surface.opacity(0.8) : 
            Color.clear
        )
        .overlay(
            RoundedRectangle(cornerRadius: Token.Radius.md)
                .stroke(
                    isSelected ? Token.Color.brand : 
                    isHovered ? Token.Color.onSurface.opacity(0.2) : 
                    Color.clear, 
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .cornerRadius(Token.Radius.md)
    }
}