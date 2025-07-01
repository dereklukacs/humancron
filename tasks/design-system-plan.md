# Humancron Design System — Implementation Plan (High-Level)

## 1. Relevant Background
- The Humancron macOS app is built with SwiftUI and aims for a fast, hot-key-driven workflow experience.
- Consistency and speed of UI development can be improved by extracting common visual primitives (colour, typography, spacing, etc.) into a reusable design system.
- A draft of the design language already exists in `docs/design-system.md`, describing tokens, component hierarchy (atoms → organisms), and documentation expectations.

## 2. Relevant Files
- `docs/design-system.md` – source spec for tokens, component hierarchy, and documentation plan.
- `humancron/Assets.xcassets` – existing colour and asset catalog that will mirror colour tokens.
- `humancron/*.swift` – current application code that will import and use the design system.
- `humancron.xcodeproj` & workspace settings – will need to incorporate the new Swift package.
- Unit-test bundles (`humancronTests`, `humancronUITests`) – will host snapshot and token tests.

## 3. Desired Changes & End Result
- Introduce a standalone Swift Package named **`DesignSystem`** inside the repo.
- Encode design tokens as type-safe enums (`Token.Color`, `Token.Spacing`, …).
- Mirror colour tokens in `Assets.xcassets`; ensure dark/light variants are handled.
- Deliver foundational SwiftUI helpers (e.g., `Typography`, `DSButtonStyle`, `DSSpacer`).
- Provide preview-friendly demo targets and DocC documentation.
- Achieve single-source-of-truth styling so application views can be refactored to the new API with minimal friction.

## 4. Out of Scope
- Non-macOS platform support (iOS, watchOS, visionOS).
- Third-party theming or runtime theming engine.
- Complete refactor of every existing screen to the new design system (will be incremental).
- CI/CD improvements beyond what is required to build and test the new package.

## 5. Checklist

### Phase 1 — Scaffolding & Setup
- [ ] Create `DesignSystem` Swift package inside the monorepo.
- [ ] Add the package to the existing Xcode workspace & schemes.
- [ ] Configure SwiftLint / formatting rules for the new package.
- [ ] Stub empty `Token` namespaces and commit initial structure.

### Phase 2 — Token Implementation
- [ ] Define colour tokens in code and add matching assets (light/dark).
- [ ] Implement spacing, radius, and motion constants.
- [ ] Add basic unit tests to assert token values compile and match asset names.
- [ ] Document token usage with DocC-style comments.

### Phase 3 — Design Primitives
- [ ] Create `Typography` struct / modifiers for each text role.
- [ ] Build reusable `DSColor` & `DSSpacer` helpers.
- [ ] Provide default shadows / elevation helpers.
- [ ] Snapshot-test typography and colour examples.

### Phase 4 — Atom Components
- [ ] Implement `DSButton` (primary / secondary / tertiary styles).
- [ ] Implement `DSTextField`, `DSToggle`, and `DSDivider`.
- [ ] Ensure each atom has SwiftUI Preview coverage.
- [ ] Add XCTSnapshot tests for each component state.

### Phase 5 — Molecules & Organisms
- [ ] Compose `MenuItem`, `ListItem`, and `Card` using atoms.
- [ ] Add dynamic previews demonstrating light/dark and accessibility sizes.
- [ ] Write usage guidelines in DocC articles.

### Phase 6 — Demo & Documentation
- [ ] Create `DesignSystemDemo` app target listing all tokens and components.
- [ ] Integrate DocC generation into the build step.
- [ ] Add README tables for quick-reference of tokens.
- [ ] Publish demo screenshots/gifs to repository documentation.

### Phase 7 — Integration & Adoption
- [ ] Replace hard-coded colours/spacing in the Humancron app with `Token` equivalents.
- [ ] Address any styling regressions discovered via UI tests.
- [ ] Update onboarding documentation for contributors on how to use the design system.
- [ ] Plan follow-up tickets for remaining screens to migrate. 