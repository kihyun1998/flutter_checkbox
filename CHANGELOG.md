## 0.2.0

**Breaking change:** `CustomCheckbox` has been replaced by two focused widgets.

### New widgets

- **`FlutterCheckbox`** — pure checkbox graphic with no label. Handles its own keyboard navigation, focus ring, and hover hit area.
- **`FlutterCheckboxTile`** — checkbox + label + tile container with full background, border, shadow, and interaction customization.

### New features

- **Tristate** — `value: bool?` + `tristate: true` enables an indeterminate state (dash `—`). Two-controller animation smoothly crossfades between checkmark and dash.
- **Extended hover hit area** — hover/tap zone matches the full ring area (`size + hoverRingPadding * 2`), not just the box. Layout size is always fixed.
- **`CheckboxPosition`** — `start` / `end` to place the checkbox before or after the label in `FlutterCheckboxTile`.
- **`subtitle` / `subtitleWidget`** — secondary text below the label in `FlutterCheckboxTile`.
- **Tile customization** — `backgroundColor`, `selectedColor`, `disabledColor`, `tileBorderSide`, `tileBorderRadius`, `elevation`, `expandWidth`, `padding`, `margin`.
- **Tile animation** — `tileAnimationDuration` / `tileAnimationCurve` for background color transitions.

### `CheckboxStyle` changes

- Added: `scale`, `morphDuration`, `morphCurve`, `hoverRingPadding`, `hoverRingShape`, `hoverRingBorderRadius`
- Removed: `hoverColor`, `splashColor` (moved to `FlutterCheckboxTile` direct properties)

### Migration

| Before | After |
|---|---|
| `CustomCheckbox(value, onChanged)` | `FlutterCheckbox(value, onChanged)` |
| `CustomCheckbox(value, label, onChanged)` | `FlutterCheckboxTile(value, label, onChanged)` |
| `onChanged: (bool v) => ...` | `onChanged: (bool? v) => ...` |
| `CheckboxStyle(hoverColor: ...)` | `FlutterCheckboxTile(hoverColor: ...)` |

## 0.1.0

- Initial release.
- `CustomCheckbox` widget with built-in label support (`label` / `labelWidget`).
- Pixel-perfect size control via `CheckboxStyle.size`.
- CustomPainter-based rendering with animated checkmark stroke.
- `CheckboxShape` enum — choose between `rectangle` (default) and `circle` shape.
- `CheckboxStyle` for full visual customization (colors, border, radius, stroke width).
- Configurable animation duration and curve.
- Disabled state with reduced opacity.
- Playground example app with live controls.
