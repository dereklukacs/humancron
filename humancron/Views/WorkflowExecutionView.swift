import SwiftUI
import DesignSystem

struct WorkflowExecutionView: View {
    @EnvironmentObject var appState: AppStateManager
    @StateObject private var faviconService = FaviconService.shared
    @State private var eventMonitor: Any?
    
    var currentStep: WorkflowStep? {
        guard let workflow = appState.currentWorkflow,
              workflow.steps.indices.contains(appState.currentStep) else { return nil }
        return workflow.steps[appState.currentStep]
    }
    
    var progress: Double {
        guard let workflow = appState.currentWorkflow else { return 0 }
        return Double(appState.completedSteps.count) / Double(workflow.steps.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with workflow name and progress
            VStack(spacing: Token.Spacing.x2) {
                HStack {
                    Text(appState.currentWorkflow?.name ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Token.Color.onBackground)
                    
                    Spacer()
                    
                    Text("\(appState.completedSteps.count) of \(appState.currentWorkflow?.steps.count ?? 0) completed")
                        .font(.system(size: 14))
                        .foregroundColor(Token.Color.onBackground.opacity(0.7))
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Token.Color.surface.opacity(0.3))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Token.Color.brand)
                            .frame(width: geometry.size.width * progress, height: 4)
                            .animation(.easeInOut(duration: Token.Motion.normal), value: progress)
                    }
                }
                .frame(height: 4)
            }
            .padding(.bottom, Token.Spacing.x4)
            
            // Checklist of all steps
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: Token.Spacing.x2) {
                        if let workflow = appState.currentWorkflow {
                            ForEach(Array(workflow.steps.enumerated()), id: \.element.id) { index, step in
                                ChecklistStepRow(
                                    step: step,
                                    stepNumber: index + 1,
                                    isCompleted: appState.isStepCompleted(index),
                                    isCurrent: index == appState.currentStep,
                                    isLinkOpened: appState.isLinkOpened(forStep: index),
                                    favicon: step.link != nil ? faviconService.favicon(for: step.link!) : nil,
                                    stepIndex: index
                                )
                                .id(index)
                            }
                        }
                    }
                    .padding(.vertical, Token.Spacing.x1)
                }
                .onChange(of: appState.currentStep) { newValue in
                    // Scroll to current step when it changes
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
                .onAppear {
                    // Scroll to current step on appear
                    proxy.scrollTo(appState.currentStep, anchor: .center)
                }
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            setupKeyboardHandling()
            // Prefetch favicons for current workflow
            if let workflow = appState.currentWorkflow {
                faviconService.prefetchFavicons(for: [workflow])
            }
        }
        .onDisappear {
            removeKeyboardHandling()
        }
    }
    
    private func setupKeyboardHandling() {
        // Remove any existing monitor
        removeKeyboardHandling()
        
        // Add new monitor
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Check for Shift+P to toggle pinning
            if event.modifierFlags.contains(.shift) && event.keyCode == 35 { // P key
                appState.isPinned.toggle()
                return nil // Consume the event
            }
            
            // Check for Cmd+, to open preferences
            if event.modifierFlags.contains(.command) && event.keyCode == 43 { // Comma key
                appState.showPreferences()
                return nil // Consume the event
            }
            
            // Check for command key combinations
            if event.modifierFlags.contains(.command) {
                switch event.keyCode {
                case 36: // Cmd+Enter - advance and trigger automation
                    if let link = currentStep?.link {
                        openLink(link)
                        appState.markLinkAsOpened(forStep: appState.currentStep)
                    }
                    appState.nextStep()
                    return nil
                case 15: // Cmd+R - restart workflow
                    appState.resetWorkflow()
                    return nil
                default:
                    break
                }
            }
            
            // Regular key handling
            switch event.keyCode {
            case 36: // Enter - toggle completion status
                if !event.modifierFlags.contains(.command) {
                    appState.toggleCurrentStepCompletion()
                    return nil
                }
            case 49: // Spacebar - open link
                if let link = currentStep?.link {
                    openLink(link)
                    appState.markLinkAsOpened(forStep: appState.currentStep)
                    // Hide the app so user can interact with the opened link
                    appState.hideApp(restoreFocus: false)
                }
                return nil
            case 53: // Escape
                appState.hideApp(force: true)
                appState.completeWorkflow()
                return nil
            case 126: // Up arrow - navigate to previous step
                if appState.currentStep > 0 {
                    appState.currentStep -= 1
                }
                return nil
            case 125: // Down arrow - navigate to next step
                if let workflow = appState.currentWorkflow,
                   appState.currentStep < workflow.steps.count - 1 {
                    appState.currentStep += 1
                }
                return nil
            case 123: // Left arrow - back to workflow list
                appState.backToWorkflowList()
                return nil
            default:
                return nil // Consume all other events
            }
            
            return nil // Consume all events by default
        }
    }
    
    private func openLink(_ link: String) {
        LinkOpenerService.shared.openLink(link)
    }
    
    private func removeKeyboardHandling() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

// MARK: - Checklist Step Row

struct ChecklistStepRow: View {
    @EnvironmentObject var appState: AppStateManager
    let step: WorkflowStep
    let stepNumber: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let isLinkOpened: Bool
    let favicon: NSImage?
    let stepIndex: Int
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .center, spacing: Token.Spacing.x3) {
            // Step indicator - fixed size for both states
            Button(action: {
                // Toggle completion when clicking the circle
                appState.currentStep = stepIndex
                appState.toggleCurrentStepCompletion()
            }) {
                ZStack {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Token.Color.success)
                    } else {
                        Circle()
                            .stroke(Token.Color.onBackground.opacity(0.3), lineWidth: 2)
                    }
                }
                .frame(width: 24, height: 24) // Fixed frame for consistent sizing
            }
            .buttonStyle(.plain)
            
            // Step content
            HStack(spacing: Token.Spacing.x2) {
                Text(step.name)
                    .font(.system(size: 16, weight: isCurrent ? .semibold : .medium))
                    .foregroundColor(isCompleted ? Token.Color.onBackground.opacity(0.5) : Token.Color.onBackground)
                    .strikethrough(isCompleted, color: Token.Color.onBackground.opacity(0.5))
                
                // Always reserve space for link indicator
                Group {
                    if let link = step.link {
                        Button(action: {
                            // Open link when clicking the icon
                            LinkOpenerService.shared.openLink(link)
                            appState.markLinkAsOpened(forStep: stepIndex)
                            appState.hideApp(restoreFocus: false)
                        }) {
                            HStack(spacing: Token.Spacing.x1) {
                                // Favicon if available
                                if let favicon = favicon {
                                    Image(nsImage: favicon)
                                        .frame(width: 16, height: 16)
                                } else {
                                    Image(systemName: "globe")
                                        .font(.system(size: 14))
                                        .foregroundColor(Token.Color.onBackground.opacity(0.5))
                                }
                                
                                // Link status indicator
                                if isLinkOpened {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Token.Color.success)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Invisible spacer to maintain consistent width
                        Color.clear
                            .frame(width: 16, height: 16)
                    }
                }
                
                if let duration = step.duration {
                    Spacer()
                    HStack(spacing: Token.Spacing.x1) {
                        Image(systemName: "timer")
                            .font(.system(size: 12))
                        Text("~\(Int(duration / 60)) min")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Token.Color.onBackground.opacity(0.5))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, Token.Spacing.x3)
        .padding(.vertical, Token.Spacing.x2)
        .contentShape(Rectangle())
        .onTapGesture {
            // Select this step when clicking anywhere on the row
            appState.currentStep = stepIndex
        }
        .background(
            RoundedRectangle(cornerRadius: Token.Radius.md)
                .fill(
                    isCurrent ? Token.Color.brand.opacity(0.1) : 
                    isHovered ? Token.Color.surface.opacity(0.8) : 
                    Color.clear
                )
                .animation(.easeInOut(duration: 0.2), value: isCurrent)
                .animation(.easeInOut(duration: 0.1), value: isHovered)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Token.Radius.md)
                .stroke(
                    isCurrent ? Token.Color.brand.opacity(1.0) : 
                    isHovered ? Token.Color.onSurface.opacity(0.2) : 
                    Color.clear, 
                    lineWidth: isCurrent ? 2 : 1
                )
                .animation(.easeInOut(duration: 0.2), value: isCurrent)
                .animation(.easeInOut(duration: 0.1), value: isHovered)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}