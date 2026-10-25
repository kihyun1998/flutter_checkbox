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
- **The `InkWell` wraps the whole tile**, margin and elevation `Material`
  included: `CheckboxInteraction` → `InkWell` → `Padding(margin)` →
  `Material(elevation)` → `AnimatedContainer`.
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
- **The overlays may be hidden by the tile's own background.** The `InkWell`
  sits above the `AnimatedContainer`, and ink paints on the nearest ancestor
  `Material`, under its children. A non-null `backgroundColor` or
  `selectedColor` would then cover the hover, focus and splash overlays, and the
  tap area and ripple include `margin`. Found by reading at a7b403e; not run,
  since no Flutter SDK was available. Not known before (maintainer, 2026-10-25).
  The `Chrome` tests pin elevation, margin and border, not the overlays.
  Tracked: #18.
- **A custom `labelWidget` gets no disabled styling.** A text `label` takes
  `theme.disabledColor` and the subtitle `Opacity(disabledOpacity)`, but a
  `labelWidget` is used as given. Found by reading at a7b403e. Not known before
  (maintainer, 2026-10-25). Tracked: #19.
