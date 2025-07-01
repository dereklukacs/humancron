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
    
    var nextStep: WorkflowStep? {
        guard let workflow = appState.currentWorkflow,
              workflow.steps.indices.contains(appState.currentStep + 1) else { return nil }
        return workflow.steps[appState.currentStep + 1]
    }
    
    var progress: Double {
        guard let workflow = appState.currentWorkflow else { return 0 }
        return Double(appState.currentStep + 1) / Double(workflow.steps.count)
    }
    
    var body: some View {
        VStack(spacing: Token.Spacing.x4) {
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
            
            Divider()
            
            // Current step
            if let step = currentStep {
                VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                    Label {
                        Text("Current Step")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Token.Color.onBackground.opacity(0.6))
                    } icon: {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(Token.Color.brand)
                    }
                    
                    VStack(alignment: .leading, spacing: Token.Spacing.x2) {
                        Text(step.name)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Token.Color.onBackground)
                        
                        Text(step.description)
                            .font(.system(size: 16))
                            .foregroundColor(Token.Color.onBackground.opacity(0.8))
                        
                        if let duration = step.duration {
                            HStack {
                                Image(systemName: "timer")
                                    .font(.system(size: 14))
                                Text("\(Int(duration / 60)) minutes")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(Token.Color.onBackground.opacity(0.6))
                        }
                        
                        if let _ = step.link {
                            HStack {
                                Image(systemName: appState.isLinkOpened(forStep: appState.currentStep) ? "checkmark.circle.fill" : "link.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(appState.isLinkOpened(forStep: appState.currentStep) ? Token.Color.success : Token.Color.onBackground.opacity(0.6))
                                Text(appState.isLinkOpened(forStep: appState.currentStep) ? "Link opened" : "Has link")
                                    .font(.system(size: 14))
                                    .foregroundColor(appState.isLinkOpened(forStep: appState.currentStep) ? Token.Color.success : Token.Color.onBackground.opacity(0.6))
                            }
                        }
                    }
                    .padding(.leading, Token.Spacing.x4)
                }
            }
            
            // Next step preview
            if let nextStep = nextStep {
                VStack(alignment: .leading, spacing: Token.Spacing.x2) {
                    Label {
                        Text("Next")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Token.Color.onBackground.opacity(0.5))
                    } icon: {
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(Token.Color.onBackground.opacity(0.5))
                    }
                    
                    Text(nextStep.name)
                        .font(.system(size: 14))
                        .foregroundColor(Token.Color.onBackground.opacity(0.6))
                        .padding(.leading, Token.Spacing.x4)
                }
            }
            
            Spacer()
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
            case 53: // Escape
                appState.hideApp()
                appState.completeWorkflow()
                return nil
            case 123: // Left arrow - go back
                appState.previousStep()
                return nil
            case 124: // Right arrow - skip/next
                appState.nextStep()
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