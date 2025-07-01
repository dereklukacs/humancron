# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HumanCron is a macOS desktop application built with SwiftUI that helps users manage recurring workflows and SOPs (Standard Operating Procedures). It functions as a quick launcher similar to Raycast, activated by a global hotkey (Option+Space).

## Development Commands

This is an Xcode project. Common commands:

```bash
# Build the project
xcodebuild -project humancron.xcodeproj -scheme humancron build

# Run tests
xcodebuild -project humancron.xcodeproj -scheme humancron test

# Clean build folder
xcodebuild -project humancron.xcodeproj -scheme humancron clean
```

For development, open `humancron.xcodeproj` in Xcode and use:
- Cmd+B to build
- Cmd+R to run
- Cmd+U to run tests

## Architecture and Key Components

### Project Structure
- `humancron/` - Main application code
  - `humancronApp.swift` - App entry point
  - `ContentView.swift` - Main UI view
  - `Assets.xcassets/` - App resources
  - `humancron.entitlements` - App permissions
- `humancronTests/` - Unit tests using Swift Testing framework
- `humancronUITests/` - UI tests

### Key Technical Requirements
1. **Global Hotkey**: Option+Space to launch the app
2. **System Tray Integration**: Menu bar presence
3. **URL Scheme Handling**: Launch other apps (e.g., `notion-calendar://`)
4. **YAML Parsing**: Workflow configurations stored as YAML files
5. **n8n Integration**: Webhook/API calls for automation
6. **File System Access**: Read user-selected files for workflows

### App Capabilities
The app is sandboxed with limited permissions:
- Read-only access to user-selected files
- No network access by default (will need to be added for n8n integration)

### Design Principles
From spec.md:
- Built for speed - minimize latency
- Hotkeys for everything - keyboard-first design
- Focused design to stay in flow
- Local + plain files first

## Testing Approach

Uses Swift Testing framework (Apple's new testing framework with `@Test` macro):
- Unit tests in `humancronTests/`
- UI tests in `humancronUITests/`

Run individual tests in Xcode by clicking the diamond next to test methods.

## Important Context

The project is in initial state with boilerplate code. Key features to implement:
1. Global hotkey launcher mechanism
2. Workflow selector UI (similar to Raycast)
3. Step-by-step execution interface
4. YAML workflow parser
5. App/URL launching functionality
6. System tray indicator
7. n8n webhook integration

See `spec.md` for detailed requirements and user stories.