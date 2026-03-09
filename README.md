# flutter_checkbox

A customizable checkbox widget for Flutter with built-in label support, pixel-perfect size control, and smooth animations.

## Why?

Flutter's built-in `Checkbox` has limitations:

- No inline label — requires wrapping with `Row` + `Text` every time.
- Size control is indirect and unpredictable.
- Excessive default padding that's hard to remove.

`flutter_checkbox` solves these with a single, clean widget.

## Features

- **Built-in label** — pass `label` (String) or `labelWidget` (Widget) directly.
- **Exact size control** — `CheckboxStyle.size` sets the box size in logical pixels.
- **CustomPainter rendering** — crisp checkmark at any size, no Icon dependency.
- **Shape options** — `CheckboxShape.rectangle` (default) or `CheckboxShape.circle`.
- **Full style customization** — colors, border width/radius, check stroke width.
- **Animated transitions** — configurable duration and curve.
- **Disabled state** — reduced opacity, tap ignored.

## Installation

```yaml
dependencies:
  flutter_checkbox:
    git:
      url: <your-repo-url>
```

## Usage

### Basic

```dart
CustomCheckbox(
  value: _isChecked,
  label: 'I agree to the terms',
  onChanged: (value) => setState(() => _isChecked = value),
)
```

### Custom style

```dart
CustomCheckbox(
  value: _isChecked,
  label: 'Premium option',
  style: CheckboxStyle(
    size: 32,
    activeColor: Colors.indigo,
    checkColor: Colors.white,
    borderRadius: 8,
    borderWidth: 2.5,
  ),
  onChanged: (value) => setState(() => _isChecked = value),
)
```

### Circle shape

```dart
CustomCheckbox(
  value: _isChecked,
  label: 'Round checkbox',
  style: CheckboxStyle(
    shape: CheckboxShape.circle,
    size: 32,
    activeColor: Colors.teal,
  ),
  onChanged: (value) => setState(() => _isChecked = value),
)
```

### Custom label widget

```dart
CustomCheckbox(
  value: _isChecked,
  labelWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, size: 16),
      SizedBox(width: 4),
      Text('Favorite'),
    ],
  ),
  onChanged: (value) => setState(() => _isChecked = value),
)
```

### Disabled

```dart
CustomCheckbox(
  value: true,
  enabled: false,
  label: 'Read-only',
)
```

## CheckboxStyle

| Property | Type | Default | Description |
|---|---|---|---|
| `shape` | `CheckboxShape` | `rectangle` | Box shape (`rectangle` / `circle`) |
| `size` | `double` | `24` | Box width & height |
| `activeColor` | `Color?` | `ColorScheme.primary` | Checked background |
| `checkColor` | `Color?` | `Colors.white` | Checkmark color |
| `borderColor` | `Color?` | `ColorScheme.outline` | Unchecked border |
| `inactiveColor` | `Color?` | `Colors.transparent` | Unchecked background |
| `borderWidth` | `double` | `2` | Border stroke width |
| `borderRadius` | `double` | `4` | Corner radius |
| `checkStrokeWidth` | `double` | `2.5` | Checkmark stroke width |
| `animationDuration` | `Duration` | `200ms` | Transition duration |
| `animationCurve` | `Curve` | `Curves.easeInOut` | Transition curve |

## Example

Run the playground app:

```bash
cd example
flutter run
```

## License

MIT
