# DESIGN.md — shae-objective-c-macos-notes

SHAE Field Manual Design System applied to the Objective-C macOS Notes app.

## Color palette

| Token | Value | Use |
|-------|-------|-----|
| Warm paper | `#F2EEE5` | Window/content background |
| Ink | `#191712` | Primary text, borders |
| Oxide signal | `#B3341B` | Primary action buttons, focus rings |

One oxide-red signal per view: the primary action (e.g. "New note" / "Save").
No gradients, glows, glass cards, shadows, or pills.

## Layout & geometry

- `0px` border radius; flat, physical controls and cards.
- `1px` solid ink borders define text fields, buttons, cards, lists.
- Border-defined cards: `NSBox`/`NSView` with a 1px border, no shadow.
- `4px` spacing base between controls and sections.
- `1280px` max content width (window sizing guidance).
- `44px` minimum touch targets on buttons, list rows, and text fields
  (min height 44pt on macOS).
- No horizontal overflow; NSScrollView used where content may overflow.

## Typography

- Display/headings: **Archivo** (fallback system serif), uppercase short labels only.
- Body: **Instrument Sans** (fallback system sans-serif).
- Labels, metadata, code: **JetBrains Mono** (fallback monospace), tabular numerals.
- NSFont used with Dynamic Type–equivalent sizing where appropriate.

## Motion

- State changes: `140–240ms` (Core Animation / NSViewAnimator).
- Page/sheet transitions: `320ms`.
- Transform/opacity only; `NSView` layer-backed animations respect
  `NSAccessibilityReduceMotion` / `prefers-reduced-motion`.
- No animation libraries for simple UI.

## Accessibility

- WCAG AA contrast: ink on paper; oxide buttons with white text.
- Visible oxide focus rings on all controls (custom `focusRingType` /
  `NSFocusRing`).
- Complete keyboard paths: Tab traversal, Enter/Space activation, mnemonics.
- 44pt touch targets.
- `NSAccessibility` roles and labels on all controls; no reliance on color
  alone (note status shown as text).

## Files

- `src/Notes.h` / `src/Notes.m` — model and store.
- `DESIGN.md` — this document.
