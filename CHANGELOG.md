## 0.3.2

### New features

- **`CheckboxStyle.shadows`** — a `List<BoxShadow>?` that casts a drop shadow beneath the checkbox box, so a design-token shadow (shadcn's `shadow-xs`, a tweakcn theme) can reach the box itself. Defaults to `null` = no shadow, so nothing changes unless you set it. Flows through `FlutterCheckboxTile` via `checkboxStyle`; the tile's own `elevation` is a separate, unrelated Material shadow.

  Four semantics worth knowing, all of them chosen to match Flutter rather than CSS, since they sit next to every other shadow in your app:

  - `null` means *no shadow*, not "ask the theme" — `resolve()` leaves it alone. (`copyWith` can only overwrite a nullable field, never reset it, so a theme-supplied default could never be removed.)
  - **Not scaled by `scale`.** Like `borderWidth`, `borderRadius` and `checkStrokeWidth`, shadow offsets and radii stay in logical pixels while `scale` resizes the box.
  - **First entry paints underneath** — Flutter's list order, the reverse of CSS. Reverse a list pasted from CSS.
  - **Not clipped to the box exterior** the way CSS clips an outer `box-shadow`. With the default transparent `inactiveColor` the shadow shows *through* an unchecked box; use `BoxShadow(blurStyle: BlurStyle.outer)`, or an opaque `inactiveColor`, for the CSS look.

  The shadow hugs the box's *outer* edge — the outside of the border stroke — so it stays correct at any `borderWidth`. It affects painting only, never layout, so give a tile enough padding for a large blur.

### Accessibility fixes

Five defects with one root cause: the `InkWell` driving the tap surface brought its own focus node and its own tap semantics, so every control carried a second of each. Collapsing the extra semantics node was what discarded focusability; the extra focus node was never addressed. Both widgets now present as **one** semantics node and **one** Tab stop, in every construction. Recorded in [`docs/adr/0001-one-node-one-focus.md`](docs/adr/0001-one-node-one-focus.md).

- **`FlutterCheckboxTile(focusNode: ...)` no longer throws.** Passing a `FocusNode` to a tile handed the *same* node to two `Focus` widgets, which asserted `'child != this'` ("Tried to make a child into a parent of itself") and left the tile **unactivatable by keyboard** — Space and Enter stopped toggling it. This is a crash reachable from the documented usage.
- **One Tab stop per control, not two.** Both widgets were two stops, because the inner `InkWell` was independently focusable. The symptom was invisible to tests: the second stop nested under the first, so shortcuts still resolved and the focus ring still lit.
- **The control is focusable to assistive tech again** (#7). The `isFocusable` flag and the `focus` action were dropped, so a screen reader could not see the control as focusable or move focus to it. Keyboard activation itself was unaffected, which is why this went unnoticed.
- **A `labelWidget` tile and an unlabelled tile are one node again.** Both shipped **two** semantics nodes with **two** tap actions — a screen reader saw two disjoint elements. This was the defect issue #4 declared fixed; it was never true for these two constructions.
- **A non-interactive control is no longer announced as enabled.** `onChanged: null` is documented as "non-interactive", but the semantics node still reported `enabled: true` with no tap action — a screen reader offered a control that could not be operated. It now reports the interactive state. (An interactive tile is unaffected: its inner checkbox is `onChanged: null` by design and does not drag the tile's own node down.)
- **A tile's `subtitle` is now announced.** A labelled tile dropped its whole subtree from the semantics tree, so visible text was invisible to assistive tech. The tile's accessible name is now the text it renders — `label` (or `labelWidget`) followed by `subtitle`.

**Behaviour change:** a tile's accessible name now comes from its rendered text rather than from `label` alone, so a tile with a subtitle announces both. A `labelWidget` that requires its own semantics node (an embedded link, for example) is out of contract — merging folds it into the single node. Flutter's own `CheckboxListTile` has the same limitation.

## 0.3.1

### Fixes

- **Flutter floor widened** from `>=3.35.0` to `>=3.27.0` (Dart `>=3.6.0 <4.0.0`). 0.3.0 set the floor to the SDK it happened to be built with, but the newest API the code actually uses is `Color.withValues` (Flutter 3.27 / Dart 3.6) — everything else needs only Dart 3.0. The old floor turned away compatible Flutter 3.27–3.34 users for no reason. Pure constraint widening: no API or behaviour change.

## 0.3.0

### New features

- **Checkbox-compatible API** — `FlutterCheckbox` now accepts `activeColor`, `checkColor`, and `semanticLabel` directly on the constructor, mirroring Flutter's built-in `Checkbox`. A top-level color overrides the matching field in `style`; when omitted, `style` (then the theme) supplies it. Migrating from `Checkbox` is mostly a rename.
- **`CheckboxStyle.copyWith`** — returns a copy with selected fields replaced.
- **`CheckboxStyle` overlay fields** — `hoverColor`, `focusColor`, `splashColor`, and `disabledOpacity` moved the previously hard-coded ring/overlay constants into the style, so they resolve in one place and are customizable. Defaults are unchanged (`primary` at 8%/12%, opacity `0.4`).
- **`CheckboxStyle.checkScale`** — sizes the checkmark/dash within the box (about its centre), e.g. `0.7` for a smaller tick with more padding. Independent of `checkStrokeWidth`; defaults to `1.0` (unchanged look).

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
