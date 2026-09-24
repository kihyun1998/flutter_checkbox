# Style resolution

## What it is

`CheckboxStyle`: the one value object that holds every visual number and colour
for the box, the ring, the overlays and the animation. `resolve(ThemeData)` turns
it into a copy with every theme-derived `null` filled in. Every other territory
reads the resolved copy.

## Governing decisions

- [ADR 0002 — The default check colour follows the fill](../../adr/0002-default-check-colour-follows-the-fill.md#decision).
  It governs the defaults that follow the fill: `checkColor` and the three
  overlay colours. Read its
  [does-not-cover list](../../adr/0002-default-check-colour-follows-the-fill.md#what-this-record-does-not-cover)
  before extending it further.

The rest has no record. "A plain value object resolved once, no
`WidgetStateProperty`" came from #5 (moving the overlay colours into `resolve`),
which is an issue, not a record.

## Design model

Read from the source, apart from the colours that follow the fill, which ADR
0002 records.

- **Two kinds of `null`.** For colour fields, `null` means "derive it":
  `resolve` fills them from the theme, and `checkColor` and the overlays from
  the fill. For
  `shadows`, `null` means *none*, and `resolve` leaves it alone, because
  `copyWith` cannot reset a field to `null` and a theme default could never be
  removed.
- **`copyWith` can only overwrite.** `FlutterCheckbox` depends on that: it layers
  its top-level `activeColor` / `checkColor` over `style` through `copyWith`, and
  the top-level value wins.
- **Overlay defaults are the fill at fixed alphas.** Hover, focus and splash
  resolve here from `activeColor ?? primary`, the same colour the box is filled
  with (ADR 0002). The tile reads them from here too (#5), so the constants have
  one home.
- **The default check follows the fill.** `_defaultCheckColor` returns
  `onPrimary` on the theme's own fill, and white or black by
  `ThemeData.estimateBrightnessForColor` on a caller's `activeColor`. It can be
  decided inside `resolve` because `FlutterCheckbox` merges its top-level
  `activeColor` into the style first.
- **No `operator ==`.** Every `style != old.style` in `lib/` compares identity.
  A parent that builds a new `CheckboxStyle(...)` each frame re-resolves and
  repaints each frame. That is correct but not free.
- **No `WidgetStateProperty`.** The built-in resolves `fillColor` and
  `overlayColor` per state. Here every state's value is a plain field, resolved
  once. That is a deliberate divergence (#5), not a gap.

## Code

- `lib/src/style/checkbox_style.dart` — `CheckboxStyle`, `CheckboxShape`,
  `copyWith`, `resolve`, `_defaultCheckColor`
- `lib/src/widget/flutter_checkbox.dart` — `_updateResolvedStyle`,
  `didChangeDependencies`
- `lib/src/widget/flutter_checkbox_tile.dart` — `_FlutterCheckboxTileState`,
  `overlay`

## Reference behaviour

- The check colour was compared with Flutter's M3 checkbox at SDK
  `6655482ec06` (`_CheckboxDefaultsM3.checkColor` in `material/checkbox.dart`
  returns `onPrimary` whatever the fill), and with shadcn's `checkbox.tsx`. The
  comparison and why it was not followed are in
  [ADR 0002](../../adr/0002-default-check-colour-follows-the-fill.md#what-it-was-decided-on).

## Cross-cutting invariants

**None.**

## Blast radius

- [Box painting](box-painting.md) — it reads every resolved colour with `!`.
- [Hover ring](hover-ring.md) — ring padding, shape, radius and colours.
- [Animation](animation.md) — durations and curves, read once at `initState`.
- [Tile](tile.md) — the tile resolves the style itself for its overlay defaults.
  Its label and subtitle font sizes derive from `size`.
- [Publishing](publishing.md) — `README.md`'s `CheckboxStyle` table documents
  every field. `withValues` here is one of the calls setting the SDK floor.
- [Example app](example-app.md) — the playground exposes the style's fields as
  controls.

## Known holes / open

- **Mid-tone custom fills keep a white check at about 3:1** (blue 3.1, green
  2.8), because Material's brightness estimate leans white. The band is fills
  with relative luminance between 0.179, where black starts to out-contrast
  white, and 0.337, where the estimate switches to black. The test on
  `Colors.blue` asserts that the band exists before asserting white. This was
  declined in ADR 0002, not missed.
- **An equality test on styles is vacuous if written with `const`.** Dart makes
  identical `const` constructions one instance, so `const a == const b` passes
  with no `operator ==` at all. Build the values at runtime and assert
  `identical(a, b)` is false first.
