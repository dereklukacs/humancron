# Humancron Implementation Plan

## Overview
This plan outlines the development of Humancron, a macOS desktop application for managing recurring workflows and SOPs. The app is activated via global hotkey (Option+Space) and provides a fast, keyboard-driven interface for executing step-by-step routines.

## Phase 1: Core Infrastructure (Week 1)

### 1.1 Global Hotkey System
- [ ] Implement global hotkey registration (Option+Space)
- [ ] Create hotkey manager service
- [ ] Handle app activation/deactivation
- [ ] Add customizable hotkey settings
- [ ] Test hotkey conflicts with other apps

### 1.2 System Tray Integration
- [ ] Create menu bar icon and menu
- [ ] Show current workflow status
- [ ] Add quick access to preferences
- [ ] Implement "quit" functionality
- [ ] Display active workflow indicator

### 1.3 Window Management
- [ ] Create overlay window (appears above other apps)
- [ ] Implement show/hide animations
- [ ] Handle window focus properly
- [ ] Add escape key to dismiss
- [ ] Center window on active screen

## Phase 2: Workflow Engine (Week 2)

### 2.1 YAML Workflow Parser
- [ ] Define workflow YAML schema
- [ ] Create Swift models for workflows
- [ ] Implement YAML parser
- [ ] Add validation for workflow files
- [ ] Create example workflow templates

### 2.2 Workflow Storage
- [ ] Set up default workflows directory (~/.humancron/workflows/)
- [ ] Implement file watcher for changes
- [ ] Create workflow loading system
- [ ] Add error handling for invalid files
- [ ] Support workflow subdirectories

### 2.3 Workflow Execution Engine
- [ ] Create workflow state manager
- [ ] Implement step navigation (next/previous)
- [ ] Add progress tracking
- [ ] Handle workflow completion
- [ ] Support workflow reset/restart

## Phase 3: User Interface (Week 3)

### 3.1 Workflow Selector
- [ ] Build search/filter functionality
- [ ] Implement keyboard navigation (arrow keys)
- [ ] Add fuzzy search matching
- [ ] Display workflow metadata (steps count, last run)
- [ ] Create empty state for no workflows

### 3.2 Step Execution View
- [ ] Create step display interface
- [ ] Show current step details
- [ ] Display next step preview
- [ ] Add progress indicator
- [ ] Implement step timer (optional)

### 3.3 Keyboard Controls
- [ ] Enter - advance to next step
- [ ] Cmd+Enter - advance and trigger automation
- [ ] Arrow keys - navigate workflows/steps
- [ ] Escape - close app
- [ ] Cmd+R - restart current workflow
- [ ] Cmd+S - skip current step

## Phase 4: Automation Features (Week 4)

### 4.1 Application Launcher
- [ ] Implement URL scheme handling
- [ ] Support app:// protocol launching
- [ ] Add support for common apps (Calendar, Slack, etc.)
- [ ] Handle missing applications gracefully
- [ ] Create app launcher service

### 4.2 Link Opening
- [ ] Implement web link opening
- [ ] Support multiple link types (http, https, custom schemes)
- [ ] Add link validation
- [ ] Handle default browser settings
- [ ] Queue multiple links per step

### 4.3 n8n Integration
- [ ] Create n8n webhook service
- [ ] Add authentication configuration
- [ ] Implement webhook triggers
- [ ] Handle webhook responses
- [ ] Add error handling and retries

## Phase 5: Settings & Preferences (Week 5)

### 5.1 Preferences Window
- [ ] Create preferences UI using design system
- [ ] General settings tab
- [ ] Hotkeys configuration tab
- [ ] Integrations tab (n8n setup)
- [ ] Workflows directory selection

### 5.2 Configuration Storage
- [ ] Implement UserDefaults wrapper
- [ ] Store hotkey preferences
- [ ] Save n8n credentials securely (Keychain)
- [ ] Remember window position/size
- [ ] Export/import settings

### 5.3 First-Run Experience
- [ ] Create onboarding flow
- [ ] Set up default workflows
- [ ] Configure initial hotkey
- [ ] Explain core concepts
- [ ] Add sample workflows

## Phase 6: Polish & Optimization (Week 6)

### 6.1 Performance
- [ ] Optimize app launch time
- [ ] Implement lazy loading for workflows
- [ ] Add caching for parsed workflows
- [ ] Profile and optimize memory usage
- [ ] Minimize CPU usage when idle

### 6.2 Error Handling
- [ ] Add comprehensive error logging
- [ ] Create user-friendly error messages
- [ ] Implement crash reporting
- [ ] Add workflow validation warnings
- [ ] Handle edge cases gracefully

### 6.3 Testing
- [ ] Unit tests for workflow engine
- [ ] UI tests for critical paths
- [ ] Integration tests for automations
- [ ] Performance benchmarks
- [ ] Manual QA checklist

## Technical Architecture

### Core Technologies
- **SwiftUI** - UI framework
- **Combine** - Reactive programming for state management
- **UserDefaults** - Settings storage
- **Keychain** - Secure credential storage
- **FileManager** - Workflow file management
- **NSWorkspace** - App launching
- **NSEvent** - Global hotkey monitoring

### Key Services
```
HotkeyService - Global hotkey registration and handling
WorkflowService - Loading, parsing, and managing workflows
ExecutionService - Running workflows and tracking state
AutomationService - Launching apps and opening links
ConfigurationService - Managing app settings
SystemTrayService - Menu bar integration
```

### Workflow YAML Schema
```yaml
name: "Daily Planning"
description: "Review calendar and plan the day"
hotkey: "cmd+1"  # Optional workflow-specific hotkey
steps:
  - name: "Check Calendar"
    description: "Review today's meetings and events"
    link: "notion-calendar://"
    duration: 180  # Optional duration in seconds
    
  - name: "Review Tasks"
    description: "Check Linear for today's priorities"
    link: "https://linear.app/team/inbox"
    automations:
      - type: "n8n"
        webhook: "https://n8n.example.com/webhook/daily-tasks"
        
  - name: "Update Status"
    description: "Post daily plan to Slack"
    link: "slack://channel?team=T123&id=C456"
```

## Success Criteria
1. App launches in < 200ms when triggered by hotkey
2. Smooth keyboard navigation throughout
3. Zero mouse requirement for core workflows
4. Workflows reload automatically when files change
5. Graceful handling of all error states
6. Native macOS look and feel using design system

## Future Enhancements (Post-Launch)
- [ ] Workflow statistics and analytics
- [ ] Workflow sharing/marketplace
- [ ] Mobile companion app
- [ ] Advanced automation rules
- [ ] Workflow templates library
- [ ] Multi-step undo/redo
- [ ] Workflow scheduling
- [ ] Team collaboration features