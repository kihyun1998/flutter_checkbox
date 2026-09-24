# Box painting

## What it is

Drawing the box on a raw `Canvas`: the drop shadows, the fill and border, then
the checkmark and the dash crossfading into each other. It paints at whatever
size it is handed. The widget hands it the size multiplied by `scale`.

## Governing decisions

**None.**

## Design model

Read from the source; nothing above it records the rules.

- **Paint order:** shadows, then background and border, then content. Content is
  skipped entirely at `progress == 0`.
- **The fill and the border both lerp toward `activeColor`** with `progress`, from
  `inactiveColor` and `borderColor` respectively.
- **The border stroke is centred on a rect inset by `borderWidth / 2`.** The
  box's outer visual edge is therefore the full rect, with corner radius
  `borderRadius + borderWidth / 2`. That is the radius shadows are cast from (#8).
- **Shadows delegate to Flutter's own box painter.** A shadow-only
  `BoxDecoration` is painted through `createBoxPainter`, never drawn by hand. The
  reason is a debug-only clip: `debugDisableShadows` is `true` in every
  `flutter_test` run, and without that clip a `BlurStyle.outer` shadow becomes a
  solid block over the checkbox, in consumers' tests too (#8).
- **Stroke geometry is fixed fractions of the box**, scaled about the centre by
  `checkScale` (#1). The check is three points and the dash is two. Both are drawn
  up to `progress` of their path length.
- **Nothing here is scaled by `scale`**: `borderWidth`, `borderRadius`,
  `checkStrokeWidth` and shadow offsets stay in logical pixels while the box
  grows.
- **The painter reads resolved colours with `!`.** Handing it an unresolved
  `CheckboxStyle` throws.

## Code

- `lib/src/painter/checkbox_painter.dart` — `CheckboxPainter`, `paint`,
  `_drawShadows`, `_drawBackground`, `_drawContent`, `_drawCheckmark`,
  `_drawDash`, `_buildPath`, `shouldRepaint`
- `lib/src/widget/flutter_checkbox.dart` — `CustomPaint`, `scaledSize`

## Reference behaviour

- The shadow guard: Flutter's `_BoxDecorationPainter._paintShadows` in
  `painting/box_decoration.dart`, read for #8. The read and its mutation test are
  in the `CheckboxStyle.shadows` entry of `docs/agents/lessons.md`. No SDK version
  was pinned.

## Cross-cutting invariants

**None.**

## Blast radius

- [Style resolution](style-resolution.md) — every value painted comes from the
  resolved style, and the `!` reads fail on an unresolved one.
- [Animation](animation.md) — `progress` and `morphProgress` are its outputs.
- [Hover ring](hover-ring.md) — the ring's default corner radius is
  `borderRadius + 2` and its default shape follows `shape`. A change to how the box
  is drawn can separate it from its ring.
- [Example app](example-app.md) — the only place the drawing is seen. Tests pin
  draw calls, not pixels.
- [Publishing](publishing.md) — `Color.withValues` here is one of the calls
  that sets the SDK floor.

## Known holes / open

- **Draw calls can be asserted even though pixels cannot.** The `paints`
  matcher replays the display list, so shape, size, colour and z-order can be
  pinned. That is how the `borderRadius + borderWidth / 2` edge was caught (#8).
  To assert a mask filter, set `debugDisableShadows = false` and restore it
  *inside the test body*. The binding checks debug variables before `tearDown`
  runs.
- **What a headless run cannot see:** blur softness, how a shadow reads against
  the ring, and morph smoothness. These are proved only by running the example.
- `shouldRepaint` compares `style` by identity (see
  [Style resolution](style-resolution.md)). It is correct, but a re-resolved
  style always repaints.
