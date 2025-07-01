# Humancron Design System

A minimal, code-first design system that enables rapid, consistent UI development for the Humancron macOS app.

## Installation

The DesignSystem is included as a local Swift package in the Humancron project. It's already integrated into the Xcode workspace.

## Usage

```swift
import DesignSystem

// Use tokens
Text("Hello")
    .foregroundColor(Token.Color.onBackground)
    .padding(Token.Spacing.x4)

// Use typography
Text("Title")
    .textStyle(.headline)

// Use components
DSButton("Save", style: .primary) {
    // Action
}
```

## Token Reference

### Colors

| Token | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|--------|
| `Token.Color.brand` | Blue (#4078D9) | Light Blue (#669AE5) | Primary brand color |
| `Token.Color.accent` | Red (#F25C5C) | Light Red (#FA7F7F) | Accent actions |
| `Token.Color.success` | Green (#45BA5C) | Light Green (#66CC7A) | Success states |
| `Token.Color.warning` | Yellow (#FAC02E) | Light Yellow (#FAD159) | Warning states |
| `Token.Color.error` | Red (#E64242) | Light Red (#F26B6B) | Error states |
| `Token.Color.info` | Blue (#4099F2) | Light Blue (#66B2FA) | Info states |
| `Token.Color.background` | Off-white (#FAFAFA) | Dark (#1C1C1F) | Main background |
| `Token.Color.surface` | White | Dark Gray (#262629) | Cards, panels |
| `Token.Color.elevatedSurface` | White | Lighter Gray (#333338) | Elevated elements |
| `Token.Color.onBackground` | Dark (#1C1C1F) | Off-white (#FAFAFA) | Text on background |
| `Token.Color.onSurface` | Dark (#1C1C1F) | Off-white (#FAFAFA) | Text on surface |
| `Token.Color.onBrand` | White | White | Text on brand color |
| `Token.Color.divider` | Black 12% | White 12% | Divider lines |
| `Token.Color.stroke` | Black 20% | White 20% | Borders |
| `Token.Color.overlay` | Black 50% | Black 70% | Modal overlays |

### Typography

| Style | Size | Weight | Usage |
|-------|------|--------|--------|
| `.displayLarge` | 32pt | Bold | Large headers |
| `.displaySmall` | 24pt | Bold | Section headers |
| `.title` | 20pt | Semibold | Page titles |
| `.headline` | 17pt | Semibold | Section titles |
| `.body` | 15pt | Regular | Body text |
| `.bodySmall` | 13pt | Regular | Secondary text |
| `.caption` | 11pt | Regular | Captions, labels |

### Spacing

| Token | Value | Usage |
|-------|-------|--------|
| `Token.Spacing.zero` | 0 | No spacing |
| `Token.Spacing.x1` | 4pt | Minimal spacing |
| `Token.Spacing.x2` | 8pt | Tight spacing |
| `Token.Spacing.x3` | 12pt | Small spacing |
| `Token.Spacing.x4` | 16pt | Default spacing |
| `Token.Spacing.x6` | 24pt | Medium spacing |
| `Token.Spacing.x8` | 32pt | Large spacing |
| `Token.Spacing.x10` | 40pt | Extra large spacing |
| `Token.Spacing.x12` | 48pt | Huge spacing |
| `Token.Spacing.x16` | 64pt | Maximum spacing |

### Corner Radius

| Token | Value | Usage |
|-------|-------|--------|
| `Token.Radius.none` | 0 | No rounding |
| `Token.Radius.sm` | 4pt | Small elements |
| `Token.Radius.md` | 8pt | Default rounding |
| `Token.Radius.lg` | 16pt | Large elements |

### Motion

| Token | Duration | Usage |
|-------|----------|--------|
| `Token.Motion.fast` | 100ms | Quick transitions |
| `Token.Motion.normal` | 300ms | Default animations |
| `Token.Motion.slow` | 500ms | Emphasis animations |

### Elevation

| Level | Y Offset | Blur | Opacity | Usage |
|-------|----------|------|---------|--------|
| `.zero` | 0 | 0 | 0% | No elevation |
| `.one` | 1pt | 3pt | 20% | Cards, buttons |
| `.two` | 2pt | 6pt | 15% | Elevated cards |
| `.three` | 4pt | 12pt | 10% | Modals, popovers |

## Components

### Atoms

- **DSButton** - Primary, secondary, and tertiary button styles
- **DSTextField** - Text input with secure field option
- **DSToggle** - Switch toggle with label
- **DSDivider** - Horizontal or vertical divider
- **ShortcutHint** - Keyboard shortcut display

### Molecules

- **MenuItem** - Menu item with icon, label, and optional shortcut
- **ListItem** - List row with leading/trailing elements
- **Card** - Container with elevation and padding

### Helpers

- **DSSpacer** - Spacer with token-based sizing
- **Typography modifiers** - `.textStyle(_:)` for consistent text
- **Color modifiers** - `.dsForeground(_:)`, `.dsBackground(_:)`
- **Elevation modifier** - `.elevation(_:)` for shadows

## Building

```bash
# Build the package
make build

# Run tests
make test

# Generate documentation
make docs
```

## Examples

### Basic Button
```swift
DSButton("Save Changes", style: .primary) {
    saveAction()
}
```

### Menu Item with Shortcut
```swift
MenuItem(
    icon: "calendar",
    label: "Check Calendar",
    shortcut: ["⌘", "1"]
) {
    openCalendar()
}
```

### Card with Content
```swift
Card(elevation: .two) {
    VStack(alignment: .leading, spacing: Token.Spacing.x3) {
        Text("Daily Standup")
            .textStyle(.headline)
        Text("Review progress")
            .textStyle(.body)
    }
}
```