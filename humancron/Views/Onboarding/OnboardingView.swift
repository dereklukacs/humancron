import SwiftUI
import DesignSystem

struct OnboardingView: View {
    @StateObject private var settings = SettingsService.shared
    @State private var currentStep = 0
    @State private var hasAccessibilityPermission = false
    @Environment(\.dismiss) private var dismiss
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background with blur effect to match main app
            Color.clear
                .background(VisualEffectBackground())
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom title bar
                HStack {
                    Text("Welcome to HumanCron")
                        .textStyle(.headline)
                        .foregroundColor(Token.Color.onSurface)
                    
                    Spacer()
                    
                    // Close button
                    Button(action: {
                        AppStateManager.shared.closeOnboarding()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Token.Color.onSurface.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Token.Spacing.x4)
                .padding(.vertical, Token.Spacing.x3)
                .background(WindowDragView())
                
                // Progress indicator
                ProgressBar(currentStep: currentStep, totalSteps: 4)
                    .padding(.horizontal, Token.Spacing.x4)
                    .padding(.top, Token.Spacing.x1)
                
                // Content
                Group {
                    switch currentStep {
                    case 0:
                        WelcomeStep()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    case 1:
                        PermissionsStep(hasAccessibilityPermission: $hasAccessibilityPermission)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    case 2:
                        WorkflowSetupStep()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    case 3:
                        CompletionStep()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        DSButton("Back", style: .secondary) {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if currentStep < 3 {
                        DSButton("Next", style: .primary) {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    } else {
                        DSButton("Get Started", style: .primary) {
                            completeOnboarding()
                        }
                    }
                }
                .padding(.horizontal, Token.Spacing.x4)
                .padding(.bottom, Token.Spacing.x3)
            }
        }
        .frame(width: 700, height: 540)
        .background(Color.clear)
        .onReceive(timer) { _ in
            hasAccessibilityPermission = AXIsProcessTrusted()
        }
    }
    
    private func completeOnboarding() {
        settings.hasCompletedOnboarding = true
        AppStateManager.shared.closeOnboarding()
        
        // Show the app after onboarding
        AppStateManager.shared.showApp()
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: Token.Spacing.x2) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Token.Color.brand : Token.Color.divider)
                    .frame(height: 4)
            }
        }
    }
}

struct WelcomeStep: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: Token.Spacing.x4) {
                Image(systemName: "clock.badge.checkmark")
                    .font(.system(size: 60))
                    .foregroundColor(Token.Color.brand)
                
                VStack(spacing: Token.Spacing.x2) {
                    Text("Welcome to HumanCron")
                        .textStyle(.title)
                        .multilineTextAlignment(.center)
                    
                    Text("Your personal workflow assistant")
                        .textStyle(.body)
                        .foregroundColor(Token.Color.onSurface.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: Token.Spacing.x4) {
                    FeatureRow(
                        icon: "keyboard",
                        title: "Quick Access",
                        description: "Launch with a global hotkey from anywhere"
                    )
                    
                    FeatureRow(
                        icon: "checklist",
                        title: "Step-by-Step Workflows",
                        description: "Execute your routines with guided steps"
                    )
                    
                    FeatureRow(
                        icon: "link",
                        title: "Smart Automation",
                        description: "Open apps and links automatically"
                    )
                }
                .frame(maxWidth: 240)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .padding(.horizontal, Token.Spacing.x6)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Token.Spacing.x3) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Token.Color.brand)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .textStyle(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

struct PermissionsStep: View {
    @Binding var hasAccessibilityPermission: Bool
    
    var body: some View {
        VStack(spacing: Token.Spacing.x4) {
            Spacer()
            
            Image(systemName: "keyboard.badge.eye")
                .font(.system(size: 80))
                .foregroundColor(Token.Color.brand)
            
            Text("Accessibility Permission")
                .textStyle(.displayLarge)
            
            Text("HumanCron needs accessibility permissions to respond to your global hotkey")
                .textStyle(.body)
                .foregroundColor(Token.Color.onSurface.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Token.Spacing.x6)
            
            VStack(spacing: Token.Spacing.x3) {
                DSButton("Grant Permission", style: .primary) {
                    checkAndRequestPermission()
                }
                
                if hasAccessibilityPermission {
                    Label("Permission granted", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text("You can change this later in System Settings > Privacy & Security > Accessibility")
                .textStyle(.caption)
                .foregroundColor(Token.Color.onSurface.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Token.Spacing.x6)
            
            Spacer()
        }
        .padding(Token.Spacing.x4)
    }
    
    private func checkAndRequestPermission() {
        hasAccessibilityPermission = ModernHotkeyService.shared.requestAccessibilityPermissions()
        
        if !hasAccessibilityPermission {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
}

struct WorkflowSetupStep: View {
    @StateObject private var settings = SettingsService.shared
    @State private var willCreateSamples = true
    
    var body: some View {
        VStack(spacing: Token.Spacing.x4) {
            Spacer()
            
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(Token.Color.brand)
            
            Text("Set Up Workflows")
                .textStyle(.displayLarge)
            
            Text("Workflows are YAML files that define your step-by-step routines")
                .textStyle(.body)
                .foregroundColor(Token.Color.onSurface.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Token.Spacing.x6)
            
            VStack(alignment: .leading, spacing: Token.Spacing.x3) {
                Label("Workflow Directory", systemImage: "folder")
                    .textStyle(.headline)
                
                Text(settings.effectiveWorkflowsDirectory)
                    .textStyle(.body)
                    .fontDesign(.monospaced)
                    .foregroundColor(Token.Color.onSurface.opacity(0.7))
                    .padding(Token.Spacing.x2)
                    .background(
                        RoundedRectangle(cornerRadius: Token.Radius.sm)
                            .fill(Token.Color.surface)
                    )
                
                DSToggle("Create example workflows to get started", isOn: $willCreateSamples)
            }
            .padding(.horizontal, Token.Spacing.x6)
            
            Spacer()
        }
        .padding(Token.Spacing.x4)
        .onChange(of: willCreateSamples) { _, newValue in
            if newValue {
                createExampleWorkflows()
            }
        }
    }
    
    private func createExampleWorkflows() {
        let workflowsDir = settings.effectiveWorkflowsDirectory
        let fileManager = FileManager.default
        
        // Ensure directory exists
        try? fileManager.createDirectory(atPath: workflowsDir, withIntermediateDirectories: true)
        
        // Only create if not already created
        if !settings.hasCreatedSampleWorkflows {
            let examples = [
                (
                    name: "daily-review.yaml",
                    content: """
                    name: "Daily Review"
                    description: "Start your day with a quick review"
                    steps:
                      - name: "Check Calendar"
                        description: "Review today's meetings and events"
                        link: "https://calendar.google.com"
                        
                      - name: "Review Tasks"
                        description: "Check your task list for today"
                        
                      - name: "Check Messages"
                        description: "Scan important messages"
                        link: "slack://"
                        
                      - name: "Set Daily Focus"
                        description: "Choose your main focus for today"
                    """
                ),
                (
                    name: "weekly-planning.yaml",
                    content: """
                    name: "Weekly Planning"
                    description: "Plan your upcoming week"
                    steps:
                      - name: "Review Last Week"
                        description: "Look at what you accomplished"
                        
                      - name: "Check Upcoming Calendar"
                        description: "Review next week's schedule"
                        link: "https://calendar.google.com"
                        
                      - name: "Set Weekly Goals"
                        description: "Define 3-5 key objectives"
                        
                      - name: "Plan Key Tasks"
                        description: "Break down goals into tasks"
                    """
                )
            ]
            
            for (filename, content) in examples {
                let path = "\(workflowsDir)/\(filename)"
                if !fileManager.fileExists(atPath: path) {
                    try? content.write(toFile: path, atomically: true, encoding: .utf8)
                }
            }
            
            settings.hasCreatedSampleWorkflows = true
        }
    }
}

struct CompletionStep: View {
    @StateObject private var settings = SettingsService.shared
    
    var body: some View {
        VStack(spacing: Token.Spacing.x3) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("You're All Set!")
                .textStyle(.title)
            
            Text("HumanCron is ready to help you stay productive")
                .textStyle(.body)
                .foregroundColor(Token.Color.onSurface.opacity(0.7))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: Token.Spacing.x2) {
                HotkeyReminder(hotkey: settings.globalHotkey)
                
                DSDivider()
                
                VStack(alignment: .leading, spacing: Token.Spacing.x1) {
                    Text("Quick Tips:")
                        .textStyle(.body)
                        .fontWeight(.medium)
                    
                    Label("Press Enter to advance to the next step", systemImage: "return")
                        .textStyle(.caption)
                    
                    Label("Press Cmd+Enter to advance and open links", systemImage: "command")
                        .textStyle(.caption)
                    
                    Label("Press Escape to close the app", systemImage: "escape")
                        .textStyle(.caption)
                }
            }
            .padding(Token.Spacing.x3)
            .background(
                RoundedRectangle(cornerRadius: Token.Radius.md)
                    .fill(Token.Color.surface)
            )
            .padding(.horizontal, Token.Spacing.x4)
            
            Spacer()
        }
        .padding(Token.Spacing.x4)
    }
}

struct HotkeyReminder: View {
    let hotkey: String
    
    var body: some View {
        HStack {
            Image(systemName: "keyboard")
                .font(.system(size: 20))
                .foregroundColor(Token.Color.brand)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Launch HumanCron anytime with:")
                    .textStyle(.caption)
                Text(hotkey.uppercased())
                    .textStyle(.body)
                    .fontDesign(.monospaced)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

