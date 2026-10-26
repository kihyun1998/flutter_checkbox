# Tile

## What it is

`FlutterCheckboxTile`: a checkbox with a label and a subtitle, laid out in a row
with an animated background, border, elevation and margin. The whole tile is one
control. Its inner `FlutterCheckbox` is purely visual, and the tile's own
`InkWell` is the one surface that is tapped.

## Governing decisions

- [ADR 0001 — One node, one focus stop](../../adr/0001-one-node-one-focus.md#decision).
  R2 (the tile's rendered text is its name) and R3 (the tile's `InkWell` gives
  up its focus node) are tile rules.

The single-interaction-surface rule is a `CLAUDE.md` invariant. No record holds it.

## Design model

- **The inner checkbox gets `onChanged: null`.** The tile passes it, so the
  checkbox has no ring, no focus and no tap. Do not wire a second tap onto it.
  This diverges from `CheckboxListTile` on purpose: that widget wires
  `onChanged` to its inner checkbox too (the first map's reading, 2026-09-24).
  The rule was re-confirmed while building the seam (#4, 3131e2a).
- **The name is rendered, never declared.** The tile gives the seam
  `semanticLabel: null`. `label` / `labelWidget` and the subtitle merge onto the
  single node as its name (ADR R2).
- **A disabled tile dims its label column with one `Opacity`**
  (`checkboxStyle.disabledOpacity`). That covers the label and the subtitle in
  every form: text, `labelStyle`, `labelWidget`, `subtitleWidget`. The inner
  checkbox dims itself and sits outside that `Opacity`.
  - Nothing inside the column dims again. The default label keeps its enabled
    colour, and the subtitle has no `Opacity` of its own. Nested opacities
    multiply: a second one shows the subtitle at 0.16 (measured, #19).
  - The `Opacity` stays in the tree when enabled, at 1.0, so toggling `enabled`
    does not reparent a `labelWidget` and lose its state.
  - **The maintainer's call** (#19 triage, 2026-10-26). Shown against three
    rejected options:
    - dimming only custom labels, so two mechanisms remain;
    - `ListTile`'s `DefaultTextStyle(color: disabledColor)`, which leaves
      explicit colours, icons and images undimmed;
    - documenting it as the caller's job.
  - Until #19, a text `label` took `theme.disabledColor`, the subtitle took
    `Opacity`, and a `labelWidget` or a `labelStyle` label was not dimmed at all.
- **Background by state:** disabled → `disabledColor`, `value == true` →
  `selectedColor`, otherwise `backgroundColor`. An indeterminate tile uses
  `backgroundColor`.
- **Label type derives from the checkbox's `size`** (× 0.6 for the label,
  × 0.5 for the subtitle), not from `size * scale`, so a scaled checkbox keeps
  its unscaled label.
- **`checkboxPosition: end` with `expandWidth`** uses `Expanded`, so the label
  pushes the checkbox to the trailing edge. Otherwise it uses `Flexible`.
- **The tile works out interactivity itself for its cursor**
  (`widget.enabled && widget.onChanged != null`), apart from the seam's
  `_isInteractive`. See [Non-interactive](../invariant/non-interactive.md).
- **The nesting:** `Padding(margin)` → `CheckboxInteraction` →
  `Material(elevation)` (only when `elevation > 0`) → `AnimatedContainer`
  (background, border, radius) → `Material(transparency)` → `InkWell` →
  `AnimatedPadding(padding)` → row (#18).
  - **Ink paints on the nearest ancestor `Material`, under that Material's
    children.** The transparent `Material` sits *above* the background so the
    overlays show over it. With the ink on any `Material` above the
    `AnimatedContainer`, an opaque `backgroundColor` / `selectedColor` /
    `disabledColor` hides every overlay. That held until #18 (measured:
    hovered pixel = background).
  - **`margin` sits outside the seam, not just outside the `InkWell`.** The
    seam's `FocusableActionDetector` carries the cursor and the `hovered` state,
    and its `Semantics` sets the node's rect. With the margin outside the
    `InkWell` only, the margin still shows a click cursor. This was the
    maintainer's call, shown against that alternative (#18 confirm,
    2026-10-26).
  - `Container` insets its child by the border width, so the ink stays inside
    `tileBorderSide`.
  - `padding` lives inside the `InkWell`, so the padded area stays tappable.
    `AnimatedPadding` keeps the animation `AnimatedContainer` used to give it.
  - **A pixel test of the ink has to capture from a boundary above the
    `Scaffold`.** A `RepaintBoundary` under it leaves out the ink's `Material`
    and reads `0x00000000` even where the overlay shows (#18 triage).
- **`label` and `labelWidget` are mutually exclusive, and so are `subtitle` and
  `subtitleWidget`.** Both are asserted.

## Code

- `lib/src/widget/flutter_checkbox_tile.dart` — `FlutterCheckboxTile`,
  `_FlutterCheckboxTileState`, `labelColumn`, `tileColor`, `AnimatedContainer`,
  `checkbox`
- `lib/src/style/checkbox_position.dart` — `CheckboxPosition`

## Reference behaviour

- [ADR 0001 § Consequences](../../adr/0001-one-node-one-focus.md#consequences)
  cites `CheckboxListTile`'s documented limitation. A `labelWidget` that needs
  its own semantics node cannot have one: merging swallows it.

## Cross-cutting invariants

- [One node, one stop](../invariant/one-node-one-stop.md)
- [Non-interactive](../invariant/non-interactive.md)

## Blast radius

- [Interaction](interaction.md) — the tile is one of the seam's two adapters.
  Any change there changes what the tile announces and how it takes focus.
- [Hover ring](hover-ring.md) — the inner checkbox's ring is skipped, so the
  tile's layout depends on that skip.
- [Style resolution](style-resolution.md) — overlay defaults, label sizes and
  subtitle opacity all come from `checkboxStyle`.
- [Publishing](publishing.md) — `withValues` in the subtitle colour counts
  toward the SDK floor.

## Known holes / open

- **Out of contract:** a `labelWidget` containing its own interactive semantics
  (a link) is swallowed by the merge (ADR 0001).
- The tile has no `semanticLabel` escape hatch. ADR 0001 leaves that open and no
  issue tracks it.
