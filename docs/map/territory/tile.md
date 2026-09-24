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
  `onChanged` to its inner checkbox too. The rule was re-confirmed while building
  the seam (#4).
- **The name is rendered, never declared.** The tile gives the seam
  `semanticLabel: null`. `label` / `labelWidget` and the subtitle merge onto the
  single node as its name (ADR R2).
- **Background by state:** disabled → `disabledColor`, `value == true` →
  `selectedColor`, otherwise `backgroundColor`. An indeterminate tile uses
  `backgroundColor`.
- **Label type derives from the checkbox's `size`** (× 0.6 for the label,
  × 0.5 for the subtitle), not from `size * scale`, so a scaled checkbox keeps
  its unscaled label.
- **`checkboxPosition: end` with `expandWidth`** uses `Expanded`, so the label
  pushes the checkbox to the trailing edge. Otherwise it uses `Flexible`.
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
