# Hover ring

## What it is

The translucent shape behind the box that shows hover and focus. It takes up
layout space: an interactive checkbox is the ring's size, not the box's. It does
not exist at all when the checkbox is non-interactive.

## Governing decisions

**None.** [ADR 0001](../../adr/0001-one-node-one-focus.md#what-this-record-does-not-cover)
names visual focus indication (ring colour, geometry, layout consumption and the
`scale` interaction) as outside its scope. It is adjacent, not governing. The
layout-consuming ring is a `CLAUDE.md` invariant, not a record.

## Design model

Read from the source; nothing above it records the rules.

- **The ring's size is fixed**, `(size + hoverRingPadding * 2) * scale`,
  whether or not it is showing, so hovering never shifts layout. It is painted
  `Colors.transparent` when neither focused nor hovered.
- **Focus beats hover.** The colour is `focusColor` if focused, otherwise
  `hoverColor` if hovered.
- **The shape follows the box unless overridden.** `hoverRingShape ?? shape`,
  with a rectangle radius of `hoverRingBorderRadius ?? borderRadius + 2`. The
  same shape clips the `InkWell` splash.
- **The `InkWell`'s own hover is off** (`hoverColor: Colors.transparent`). The
  ring *is* the hover.
- **Rendered size = hit area.** `scale` multiplies both the box
  (`scaledSize`) and the ring, and nothing else sizes the tappable region. This
  is a `CLAUDE.md` invariant. Only this widget's layout holds it, so it lives
  here rather than as an invariant note.
- **This diverges from the built-in on purpose.** The built-in `Checkbox` draws
  a fixed 18dp box, and `MaterialTapTargetSize` moves only its hit area. The
  built-in's overlay paints outside layout and always exists. Here the ring is
  layout and is skipped when non-interactive. Neither difference is a defect,
  and no record holds either one.

## Code

- `lib/src/widget/flutter_checkbox.dart` — `_FlutterCheckboxState`, `ringSize`,
  `ringColor`, `effectiveRingShape`, `boxWithOverlay`, `scaledSize`
- `lib/src/style/checkbox_style.dart` — `hoverRingPadding`, `hoverRingShape`,
  `hoverRingBorderRadius`

## Reference behaviour

**None.** The built-in's overlay paints outside layout and always exists. That
difference is deliberate, not compared-and-pinned.

## Cross-cutting invariants

- [Non-interactive](../invariant/non-interactive.md)

## Blast radius

- [Interaction](interaction.md) — `focused`, `hovered` and `activate` come from
  the seam.
- [Style resolution](style-resolution.md) — the ring colours and the default
  radius are resolved there.
- [Box painting](box-painting.md) — the ring's default shape and radius track
  the box's.
- [Tile](tile.md) — inside a tile the ring is skipped, so a change to when it
  is skipped changes the tile's layout.

## Known holes / open

- Ring geometry and hover/focus colours have no assertion on pixels. The example
  app is the proof.
