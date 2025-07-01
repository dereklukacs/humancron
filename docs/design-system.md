# Humancron Design System

> A minimal, code-first design system that enables rapid, consistent UI development for the Humancron macOS app.

---

## 1 · Token Management Strategy

• Create a Swift package named **`DesignSystem`** inside the repository.  
• Expose a top-level enum **`Token`** with nested namespaces for each token family (`Color`, `Typography`, `Spacing`, …).  
• Keep values in code (type-safe) and mirror colour assets in **`Assets.xcassets`**.  
• If external tools ever need the tokens, add an optional JSON export step in CI.

```swift
public enum Token {
  public enum Color {
    public static let brand        = Color("BrandPrimary")
    public static let accent       = Color("Accent")
    public static let background   = Color("Background")
    public static let surface      = Color("Surface")
    public static let onBackground = Color("OnBackground")
    public static let onSurface    = Color("OnSurface")
    // …
  }

  public enum Spacing {
    public static let zero:  CGFloat = 0
    public static let x1:    CGFloat = 4
    public static let x2:    CGFloat = 8
    public static let x3:    CGFloat = 12
    public static let x4:    CGFloat = 16
    public static let x6:    CGFloat = 24
    public static let x8:    CGFloat = 32
  }

  public enum Radius {
    public static let none:  CGFloat = 0
    public static let sm:    CGFloat = 4
    public static let md:    CGFloat = 8
    public static let lg:    CGFloat = 16
  }

  public enum Motion {
    public static let fast:  Double  = 0.10
    public static let normal:Double  = 0.30
    public static let slow:  Double  = 0.50
  }
}
```

---

## 2 · Design Tokens

### 2.1 Colour
• Brand / Accent / Success / Warning / Error / Info  
• Background / Surface / ElevatedSurface  
• On-* colours for readable text (onBackground, onSurface, …)  
• Divider / Stroke / Overlay tints

### 2.2 Typography Scale (SF Pro)
| Role            | Size | Weight |
|-----------------|------|--------|
| Display Large   | 32   | Bold   |
| Display Small   | 24   | Bold   |
| Title           | 20   | Semibold |
| Headline        | 17   | Semibold |
| Body            | 15   | Regular |
| Body Small      | 13   | Regular |
| Caption         | 11   | Regular |

### 2.3 Spacing
`0, 4, 8, 12, 16, 24, 32, 40, 48, 64` (points)

### 2.4 Radii
`0, 4, 8, 16` (points)

### 2.5 Elevation / Shadow
| Level | Y | Blur | Opacity |
|-------|---|------|---------|
| 0     | 0 | 0    | 0% |
| 1     | 1 | 3    | 20% |
| 2     | 2 | 6    | 15% |
| 3     | 4 | 12   | 10% |

### 2.6 Motion Durations
`fast 100 ms`, `normal 300 ms`, `slow 500 ms`

---

## 3 · Design Primitives
1. Typography styles (SF Pro stack)  
2. Colour palette & semantic roles  
3. Spacing scale  
4. Elevation & shadow rules  
5. Corner radii  
6. Iconography (SF Symbols + custom)  
7. Layout grid (8-pt base, flexible columns)  
8. Motion & easing curves (ease-in-out)  

---

## 4 · Atoms (Single-responsibility UI elements)
• Text  
• Icon  
• Button (Primary / Secondary / Tertiary)  
• Divider  
• Badge  
• ProgressIndicator  
• TextField  
• Toggle / Checkbox  
• ShortcutHint (⌘ + label)  

---

## 5 · Molecules (Composed of atoms)
• MenuItem (Icon + Label + ShortcutHint)  
• ListItem (leading icon, title, subtitle, trailing accessory)  
• Card / Panel  
• SearchBar / CommandBar  
• StepIndicator (progress dots)  
• StatusBarItem (systray badge)  
• HotkeyOverlayRow  

---

## 6 · Organisms (Complex UI sections)
• RoutineSelectorOverlay (list of SOPs + quick search)  
• WorkflowProgressView (current step, next step, controls)  
• PreferencesForm (tabs + inputs)  
• SysTrayPopover (compact workflow status)  
• OnboardingFlow (multi-page)  

---

## 7 · Templates & Pages
1. **Main Window** – workflow progress + controls  
2. **Selector Overlay** – launches via ⌥ Space  
3. **System Tray Popover** – minimal status & quick actions  
4. **Preferences Window** – general, hotkeys, integrations  
5. **Onboarding Wizard** – first-run setup  

---

## 8 · Demonstration & Documentation Plan
1. **Storybook-style catalogue using SwiftUI Previews**  
   • `DesignSystemDemo` app target lists tokens, atoms, molecules, organisms.  
   • Group previews into folders for fast navigation.
2. **Swift DocC**  
   • Generate API docs for the `DesignSystem` package (tokens & components).  
   • Serve via Xcode or host static site on GitHub Pages.
3. **Automated visual regression**  
   • Snapshot tests (XCTest) for every component state.
4. **README badges**  
   • Add quick-reference tables for tokens in `README.md`.

---

*Keep the system lean—add new tokens/components only when a real duplication emerges.* 