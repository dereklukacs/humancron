import SwiftUI
import DesignSystem

struct WorkflowExecutionView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var eventMonitor: Any?
    
    var currentStep: WorkflowStep? {
        guard let workflow = appState.currentWorkflow,
              workflow.steps.indices.contains(appState.currentStep) else { return nil }
        return workflow.steps[appState.currentStep]
    }
    
    var progress: Double {
        guard let workflow = appState.currentWorkflow else { return 0 }
        return Double(appState.currentStep) / Double(workflow.steps.count)
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
                    
                    Text("\(appState.currentStep + 1) of \(appState.currentWorkflow?.steps.count ?? 0)")
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
            
            Divider()
                .padding(.bottom, Token.Spacing.x3)
            
            // Checklist of all steps
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: Token.Spacing.x2) {
                        if let workflow = appState.currentWorkflow {
                            ForEach(Array(workflow.steps.enumerated()), id: \.element.id) { index, step in
                                ChecklistStepRow(
                                    step: step,
                                    stepNumber: index + 1,
                                    isCompleted: index < appState.currentStep,
                                    isCurrent: index == appState.currentStep,
                                    isLinkOpened: appState.isLinkOpened(forStep: index)
                                )
                                .id(index)
                                .onTapGesture {
                                    // Allow clicking on steps to jump to them
                                    appState.currentStep = index
                                }
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
            case 36: // Enter only
                if !event.modifierFlags.contains(.command) {
                    // If step has a link and it hasn't been opened yet, open it
                    if let link = currentStep?.link, !appState.isLinkOpened(forStep: appState.currentStep) {
                        openLink(link)
                        appState.markLinkAsOpened(forStep: appState.currentStep)
                        // Hide the app so user can interact with the opened link
                        appState.hideApp()
                    } else {
                        // Otherwise, advance to next step
                        appState.nextStep()
                    }
                    return nil
                }
            case 49: // Spacebar - same as Enter for opening links
                if let link = currentStep?.link, !appState.isLinkOpened(forStep: appState.currentStep) {
                    openLink(link)
                    appState.markLinkAsOpened(forStep: appState.currentStep)
                    // Hide the app so user can interact with the opened link
                    appState.hideApp()
                } else {
                    // Otherwise, advance to next step
                    appState.nextStep()
                }
                return nil
            case 53: // Escape
                appState.hideApp()
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
            default:
                break
            }
            
            return event
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
    let step: WorkflowStep
    let stepNumber: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let isLinkOpened: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: Token.Spacing.x3) {
            // Step indicator - fixed size for both states
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
            
            // Step content
            HStack(spacing: Token.Spacing.x2) {
                Text(step.name)
                    .font(.system(size: 16, weight: isCurrent ? .semibold : .medium))
                    .foregroundColor(isCompleted ? Token.Color.onBackground.opacity(0.5) : Token.Color.onBackground)
                    .strikethrough(isCompleted, color: Token.Color.onBackground.opacity(0.5))
                
                // Always reserve space for link indicator
                Group {
                    if let _ = step.link {
                        Image(systemName: isLinkOpened ? "checkmark.circle.fill" : "link.circle")
                            .font(.system(size: 14))
                            .foregroundColor(isLinkOpened ? Token.Color.success : Token.Color.onBackground.opacity(0.5))
                    } else {
                        // Invisible spacer to maintain consistent width
                        Color.clear
                            .frame(width: 14, height: 14)
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
        .background(
            RoundedRectangle(cornerRadius: Token.Radius.md)
                .fill(isCurrent ? Token.Color.brand.opacity(0.1) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isCurrent)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Token.Radius.md)
                .stroke(Token.Color.brand.opacity(isCurrent ? 1.0 : 0.0), lineWidth: 2)
                .animation(.easeInOut(duration: 0.2), value: isCurrent)
        )
    }
}