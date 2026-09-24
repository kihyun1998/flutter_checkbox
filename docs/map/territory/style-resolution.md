# Style resolution

## What it is

`CheckboxStyle`: the one value object that holds every visual number and colour
for the box, the ring, the overlays and the animation. `resolve(ThemeData)` turns
it into a copy with every theme-derived `null` filled in. Every other territory
reads the resolved copy.

## Governing decisions

**None.** "A plain value object resolved once, no `WidgetStateProperty`" came
from #5 (moving the overlay colours into `resolve`). That is an issue, not a record.

## Design model

Read from the source; nothing above it records the rules.

- **Two kinds of `null`.** For colour fields, `null` means "ask the theme".
  `resolve` fills them. For `shadows`, `null` means *none*, and `resolve` leaves
  it alone, because `copyWith` cannot reset a field to `null` and a theme default
  could never be removed.
- **`copyWith` can only overwrite.** `FlutterCheckbox` depends on that: it layers
  its top-level `activeColor` / `checkColor` over `style` through `copyWith`, and
  the top-level value wins.
- **Overlay defaults are `primary` at fixed alphas.** hover, focus and splash
  resolve here. The tile reads them from here too (#5), so the constants have one
  home.
- **`checkColor` does not follow the theme.** It defaults to `Colors.white`
  while `activeColor` follows `primary`. The pair's contrast is not guaranteed
  (#13).
- **No `operator ==`.** Every `style != old.style` in `lib/` compares identity.
  A parent that builds a new `CheckboxStyle(...)` each frame re-resolves and
  repaints each frame. That is correct but not free.
- **No `WidgetStateProperty`.** The built-in resolves `fillColor` and
  `overlayColor` per state. Here every state's value is a plain field, resolved
  once. That is a deliberate divergence (#5), not a gap.

## Code

- `lib/src/style/checkbox_style.dart` — `CheckboxStyle`, `CheckboxShape`,
  `copyWith`, `resolve`
- `lib/src/widget/flutter_checkbox.dart` — `_updateResolvedStyle`,
  `didChangeDependencies`
- `lib/src/widget/flutter_checkbox_tile.dart` — `_FlutterCheckboxTileState`,
  `overlay`

## Reference behaviour

**None.**

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

- **The default check is near-invisible on a light `primary`**, which every dark
  M3 theme has. Tracked: #13.
- **An equality test on styles is vacuous if written with `const`.** Dart makes
  identical `const` constructions one instance, so `const a == const b` passes
  with no `operator ==` at all. Build the values at runtime and assert
  `identical(a, b)` is false first.
- `FlutterCheckbox.enabled`'s doc comment says 40% opacity. The value is
  `disabledOpacity`, which callers can set.
