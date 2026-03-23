# flutter_checkbox

A customizable checkbox widget for Flutter with tristate support, tile layout, pixel-perfect size control, and smooth animations.

## Why?

Flutter's built-in `Checkbox` has limitations:

- No inline label — requires wrapping with `Row` + `Text` every time.
- Size control is indirect and unpredictable.
- Excessive default padding that's hard to remove.
- No tristate animation or tile layout out of the box.

`flutter_checkbox` solves these with two focused widgets.

## Widgets

- **`FlutterCheckbox`** — pure checkbox graphic. Use when you need just the box.
- **`FlutterCheckboxTile`** — checkbox + label + tile container. Use when you need a tappable row.

## Features

- **Tristate** — `null` value renders an animated indeterminate dash with crossfade.
- **Extended hover area** — hit/hover zone covers the full ring area, not just the box.
- **`FlutterCheckboxTile`** — label, subtitle, tile background, border, shadow, animations.
- **Exact size control** — `CheckboxStyle.size` in logical pixels, `scale` for proportional resize.
- **Shape options** — `CheckboxShape.rectangle` or `CheckboxShape.circle`.
- **Hover ring** — configurable padding, shape, and border radius, independent of the box.
- **Keyboard navigation** — Space/Enter toggles; Tab navigates focus.
- **Screen reader support** — `Semantics` exposes checked, mixed, enabled, and label.
- **Disabled state** — reduced opacity, tap and keyboard ignored.

## Installation

```yaml
dependencies:
  flutter_checkbox:
    git:
      url: <your-repo-url>
```

## Usage

### FlutterCheckbox

```dart
FlutterCheckbox(
  value: _isChecked,
  onChanged: (value) => setState(() => _isChecked = value!),
)
```

### FlutterCheckboxTile

```dart
FlutterCheckboxTile(
  value: _isChecked,
  label: 'I agree to the terms',
  onChanged: (value) => setState(() => _isChecked = value!),
)
```

### Custom style

```dart
FlutterCheckbox(
  value: _isChecked,
  style: CheckboxStyle(
    size: 32,
    activeColor: Colors.indigo,
    borderRadius: 8,
    borderWidth: 2.5,
  ),
  onChanged: (value) => setState(() => _isChecked = value!),
)
```

### Circle shape

```dart
FlutterCheckbox(
  value: _isChecked,
  style: CheckboxStyle(
    shape: CheckboxShape.circle,
    size: 32,
    activeColor: Colors.teal,
  ),
  onChanged: (value) => setState(() => _isChecked = value!),
)
```

### Tristate

```dart
FlutterCheckbox(
  value: _value,        // bool? — null = indeterminate dash
  tristate: true,
  onChanged: (value) => setState(() => _value = value),
  // cycles: false → true → null → false
)
```

### Tile with subtitle and custom background

```dart
FlutterCheckboxTile(
  value: _isChecked,
  label: 'Premium option',
  subtitle: 'Includes all features',
  selectedColor: Colors.indigo.shade50,
  tileBorderRadius: BorderRadius.circular(8),
  tileBorderSide: BorderSide(color: Colors.indigo.shade200),
  checkboxStyle: CheckboxStyle(activeColor: Colors.indigo),
  onChanged: (value) => setState(() => _isChecked = value!),
)
```

### Checkbox at trailing edge

```dart
FlutterCheckboxTile(
  value: _isChecked,
  label: 'Select item',
  checkboxPosition: CheckboxPosition.end,
  expandWidth: true,
  onChanged: (value) => setState(() => _isChecked = value!),
)
```

### Scale

```dart
FlutterCheckbox(
  value: _isChecked,
  style: CheckboxStyle(size: 24, scale: 0.75),
  onChanged: (value) => setState(() => _isChecked = value!),
)
```

`scale` proportionally resizes the box, hover ring, and hit area together.

### Disabled

```dart
FlutterCheckboxTile(
  value: true,
  enabled: false,
  label: 'Read-only',
)
```

### Accessibility / keyboard

```dart
FlutterCheckbox(
  value: _isChecked,
  autofocus: true,
  focusNode: _myFocusNode,
  onChanged: (value) => setState(() => _isChecked = value!),
)
```

## CheckboxStyle

| Property | Type | Default | Description |
|---|---|---|---|
| `shape` | `CheckboxShape` | `rectangle` | Box shape |
| `size` | `double` | `24` | Box width & height in logical pixels |
| `scale` | `double` | `1.0` | Proportional scale (affects box, ring, and hit area) |
| `activeColor` | `Color?` | `ColorScheme.primary` | Checked background |
| `checkColor` | `Color?` | `Colors.white` | Checkmark / dash color |
| `borderColor` | `Color?` | `ColorScheme.outline` | Unchecked border |
| `inactiveColor` | `Color?` | `Colors.transparent` | Unchecked background |
| `borderWidth` | `double` | `2` | Border stroke width |
| `borderRadius` | `double` | `4` | Corner radius (rectangle only) |
| `checkStrokeWidth` | `double` | `2.5` | Checkmark / dash stroke width |
| `animationDuration` | `Duration` | `200ms` | Check/uncheck animation |
| `animationCurve` | `Curve` | `Curves.easeInOut` | Check/uncheck curve |
| `morphDuration` | `Duration` | `150ms` | Checkmark ↔ dash crossfade |
| `morphCurve` | `Curve` | `Curves.easeInOut` | Crossfade curve |
| `hoverRingPadding` | `double` | `4` | Space between box edge and ring edge |
| `hoverRingShape` | `CheckboxShape?` | `null` (follows box) | Ring shape override |
| `hoverRingBorderRadius` | `double?` | `null` (borderRadius + 2) | Ring corner radius override |

## FlutterCheckbox

| Property | Type | Default | Description |
|---|---|---|---|
| `value` | `bool?` | required | Checked state. `null` = indeterminate |
| `onChanged` | `ValueChanged<bool?>?` | `null` | Callback. `null` = non-interactive |
| `tristate` | `bool` | `false` | Allow `null` value |
| `style` | `CheckboxStyle` | `CheckboxStyle()` | Visual style |
| `enabled` | `bool` | `true` | When `false`, renders at 40% opacity |
| `autofocus` | `bool` | `false` | Request focus on first build |
| `focusNode` | `FocusNode?` | `null` | External focus control |
| `mouseCursor` | `MouseCursor?` | `null` | Defaults to `click` / `basic` |

## FlutterCheckboxTile

| Property | Type | Default | Description |
|---|---|---|---|
| `value` | `bool?` | required | Checked state |
| `onChanged` | `ValueChanged<bool?>?` | `null` | Callback |
| `tristate` | `bool` | `false` | Allow `null` value |
| `checkboxStyle` | `CheckboxStyle` | `CheckboxStyle()` | Checkbox style |
| `label` | `String?` | `null` | Text label |
| `labelWidget` | `Widget?` | `null` | Custom label widget |
| `labelStyle` | `TextStyle?` | `null` | Label text style |
| `subtitle` | `String?` | `null` | Secondary text below label |
| `subtitleWidget` | `Widget?` | `null` | Custom subtitle widget |
| `subtitleStyle` | `TextStyle?` | `null` | Subtitle text style |
| `gap` | `double` | `8` | Space between checkbox and label |
| `checkboxPosition` | `CheckboxPosition` | `start` | `start` or `end` |
| `expandWidth` | `bool` | `true` | Fill available width |
| `padding` | `EdgeInsetsGeometry?` | `null` | Inner padding |
| `margin` | `EdgeInsetsGeometry?` | `null` | Outer margin |
| `constraints` | `BoxConstraints?` | `null` | Size constraints |
| `backgroundColor` | `Color?` | `null` | Default tile background |
| `selectedColor` | `Color?` | `null` | Tile background when checked |
| `disabledColor` | `Color?` | `null` | Tile background when disabled |
| `tileBorderRadius` | `BorderRadius?` | `null` | Tile corner radius |
| `tileBorderSide` | `BorderSide?` | `null` | Tile border |
| `tileAnimationDuration` | `Duration` | `200ms` | Background color transition |
| `tileAnimationCurve` | `Curve` | `Curves.easeInOut` | Background transition curve |
| `hoverColor` | `Color?` | `primary @ 8%` | Hover overlay |
| `splashColor` | `Color?` | `primary @ 12%` | Tap ripple |
| `highlightColor` | `Color?` | `null` | Held tap highlight |
| `focusColor` | `Color?` | `primary @ 12%` | Focus overlay |
| `elevation` | `double` | `0` | Shadow elevation |
| `enabled` | `bool` | `true` | Interactive state |
| `autofocus` | `bool` | `false` | Request focus on first build |
| `focusNode` | `FocusNode?` | `null` | External focus control |
| `mouseCursor` | `MouseCursor?` | `null` | Cursor override |

## Migration from 0.1.0

| Before | After |
|---|---|
| `CustomCheckbox(value, onChanged)` | `FlutterCheckbox(value, onChanged)` |
| `CustomCheckbox(value, label, onChanged)` | `FlutterCheckboxTile(value, label, onChanged)` |
| `onChanged: (bool v) => ...` | `onChanged: (bool? v) => ...` |
| `CheckboxStyle(hoverColor: ...)` | `FlutterCheckboxTile(hoverColor: ...)` |

## Example

Run the playground app:

```bash
cd example
flutter run
```

## License

MIT
