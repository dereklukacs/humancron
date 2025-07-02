# HumanCron

A macOS productivity app that helps users execute recurring workflows and standard operating procedures (SOPs) with speed and efficiency. Built as a native Swift application with a focus on keyboard-driven interactions and minimal latency.

## Overview

HumanCron is designed for knowledge workers who perform repetitive tasks that require human judgment and context. Unlike traditional automation tools, HumanCron acts as an intelligent checklist that guides users through multi-step workflows while providing quick access to relevant applications and resources.

## Key Features

### 🚀 Quick Launch Interface
- **Global Hotkey**: Launch instantly with `Option+Space` from anywhere in macOS
- **Raycast-style UI**: Fast, keyboard-driven interface for selecting and executing workflows
- **Minimal Latency**: Native Swift implementation ensures instant response times

### 📋 Workflow Management
- **YAML-based Workflows**: Define workflows in plain text files for easy version control
- **Step-by-Step Execution**: Guide through complex procedures with visual progress tracking
- **Smart Task States**: Mark steps as completed, track opened links, and monitor progress
- **Workflow History**: Track when workflows were last run and maintain execution history

### ⌨️ Keyboard-First Design
- **Full Keyboard Navigation**: Navigate between steps with arrow keys
- **Smart Shortcuts**: 
  - `Enter` - Toggle step completion
  - `Space` - Open associated links
  - `Cmd+Enter` - Complete and advance with automation
  - `Shift+P` - Toggle window pinning
  - `Escape` - Hide window
- **Search with Fuzzy Matching**: Quickly find workflows by name or description

### 🔗 Deep Application Integration
- **URL Scheme Support**: Launch any application with custom URL schemes (e.g., `notion-calendar://`)
- **Favicon Fetching**: Visual indicators for web-based workflow steps
- **Link Tracking**: Know which resources you've already accessed in your workflow

### 🎯 Focus Features
- **Window Pinning**: Keep the workflow window visible while working in other apps
- **Auto-Hide**: Window automatically hides when switching to other applications
- **Progress Persistence**: Pause and resume workflows without losing state
- **System Tray Integration**: Quick access and status monitoring from the menu bar

## Technical Stack

### Core Technologies
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Platform**: macOS 14.0+ (Sonoma)
- **Architecture**: MVVM with Combine framework

### Key Components

#### Services Layer
- `AppStateManager`: Central state management with `@Published` properties for reactive UI updates
- `WorkflowService`: YAML parsing and workflow file management
- `ModernHotkeyService`: Global hotkey registration using Carbon framework
- `SystemTrayService`: Menu bar integration and quick actions
- `LinkOpenerService`: URL scheme handling and application launching
- `FaviconService`: Asynchronous favicon fetching with caching

#### UI Architecture
- **Custom Window Management**: Borderless, floating window with custom drag areas
- **Visual Effects**: Native `NSVisualEffectView` for authentic macOS blur effects
- **Responsive Animations**: Smooth transitions using SwiftUI's animation system
- **Dark Mode Support**: Full integration with macOS appearance settings

#### Data Persistence
- **File-based Storage**: Workflows stored in `~/.humancron/workflows/`
- **UserDefaults**: Settings and preferences persistence
- **In-Memory Caching**: Favicon and workflow state caching for performance

### Notable Implementation Details

1. **Event Handling**: Custom `NSEvent` monitors for global keyboard shortcuts without consuming system events
2. **Window Focus Management**: Intelligent focus restoration to previous applications
3. **Accessibility**: Full VoiceOver support and keyboard navigation
4. **Performance**: Lazy loading of workflows and asynchronous resource fetching
5. **Security**: Sandboxed application with minimal permissions (user-selected file access only)

## Project Structure

```
humancron/
├── humancron/
│   ├── humancronApp.swift          # App entry point
│   ├── ContentView.swift           # Main window container
│   ├── Views/
│   │   ├── WorkflowSelectorView.swift
│   │   ├── WorkflowExecutionView.swift
│   │   └── Components/
│   ├── Services/
│   │   ├── AppStateManager.swift
│   │   ├── WorkflowService.swift
│   │   └── ...
│   └── Models/
│       └── Workflow.swift
├── DesignSystem/                   # Reusable design tokens
└── humancronTests/                # Unit and UI tests
```

## Development Highlights

This project demonstrates several advanced macOS development techniques:

- **Custom Window Chrome**: Implementation of a completely custom window appearance while maintaining native feel
- **Global Event Handling**: Secure handling of system-wide keyboard events
- **Reactive State Management**: Comprehensive use of Combine and SwiftUI's state management
- **Performance Optimization**: Efficient handling of file I/O and network requests
- **Native Integration**: Deep integration with macOS features while respecting platform conventions

## Future Enhancements

- **n8n Integration**: Webhook support for triggering automated workflows
- **Advanced Search**: Full-text search within workflow steps
- **Workflow Templates**: Pre-built workflows for common tasks
- **Analytics**: Usage tracking and productivity insights
- **Multi-window Support**: Run multiple workflows simultaneously

---

