## 0.3.0

### New features

- **Checkbox-compatible API** — `FlutterCheckbox` now accepts `activeColor`, `checkColor`, and `semanticLabel` directly on the constructor, mirroring Flutter's built-in `Checkbox`. A top-level color overrides the matching field in `style`; when omitted, `style` (then the theme) supplies it. Migrating from `Checkbox` is mostly a rename.
- **`CheckboxStyle.copyWith`** — returns a copy with selected fields replaced.
- **`CheckboxStyle` overlay fields** — `hoverColor`, `focusColor`, `splashColor`, and `disabledOpacity` moved the previously hard-coded ring/overlay constants into the style, so they resolve in one place and are customizable. Defaults are unchanged (`primary` at 8%/12%, opacity `0.4`).

### Accessibility fixes

- **`FlutterCheckbox`** — the checked/mixed/enabled state and the tap action were emitted on two separate semantics nodes. They are now merged (`MergeSemantics`) onto one node, so a screen reader announces and activates the checkbox as a single control.
- **`FlutterCheckboxTile`** — a tile with a `label` excluded its descendants' semantics to avoid a duplicate label, which also dropped the tap action — leaving the tile impossible to activate with assistive tech. The tap action is now provided on the tile's own semantics node.

### Fixes

- **Declared Flutter floor corrected** from `>=1.17.0` (a `flutter create` default) to `>=3.35.0`, the real minimum: the package requires Dart `^3.9.2` (first shipped with Flutter 3.35) and uses `Color.withValues` (Flutter 3.27+). The old floor let incompatible SDKs resolve the package and then fail to compile.

### Notes

- Disable a checkbox with `enabled: false` (unlike Flutter's `Checkbox`, `onChanged: null` only makes it non-interactive — it is the composition seam `FlutterCheckboxTile` relies on).

## 0.2.1

- Pass an explicit `mouseCursor` to the inner `InkWell` in `FlutterCheckbox` and `FlutterCheckboxTile`. The effective cursor was already resolved on the outer `FocusableActionDetector`, but newer Flutter versions resolve the cursor on the innermost `MouseRegion`, which caused user-provided `mouseCursor` overrides to be ignored on the hover area. The InkWell now reuses the same resolved cursor, so `widget.mouseCursor` overrides and the disabled fallback behave consistently across Flutter versions.

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
