## 0.2.0

- **Accessibility** — screen reader support via `Semantics` (checked state, label, enabled).
- **Keyboard navigation** — Space/Enter toggles the checkbox; Tab moves focus between checkboxes.
- **Focus ring** — visual indicator rendered around the box when focused.
- **Scale** — new `scale` parameter uniformly scales the entire widget (box + label + gap), independent of `CheckboxStyle.size`.
- New parameters: `autofocus` (bool, default `false`), `focusNode` (FocusNode?), `scale` (double, default `1.0`).

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
