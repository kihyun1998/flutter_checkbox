# Animation

## What it is

Two controllers and the effect each value change has on them. `checkController`
drives the fill, from unchecked (0) to checked (1). `morphController` drives the
crossfade from checkmark (0) to dash (1). Their curved values are what the
painter receives as `progress` and `morphProgress`.

## Governing decisions

**None.**

## Design model

Read from the source; nothing above it records the rules.

- **Classification is not done here.** The mixin asks `CheckboxValue.transition`
  what a change is and only applies it. See [Tristate value](tristate-value.md).
- **The first frame snaps.** `initCheckAnimation` sets both controllers to
  `restingProgress(initialValue)` with no animation.
- **Leaving indeterminate resets the morph late.** `null → false` reverses the
  fill and resets `morphController` only once the fill is dismissed. At that
  point nothing is drawn, so the reset cannot be seen.
- **Driven by the caller's value.** `_FlutterCheckboxState.didUpdateWidget`
  animates when `widget.value` changes, so an animation runs because the caller
  re-passed a value, not because anything was tapped.
- **Durations and curves are read once.** `initCheckAnimation` builds the
  controllers from the style at `initState`. `didUpdateWidget` never updates them.

## Code

- `lib/src/controller/checkbox_animation.dart` — `CheckboxAnimationMixin`,
  `initCheckAnimation`, `updateCheckAnimation`, `_resetMorphOnDismiss`,
  `disposeCheckAnimation`, `checkAnimation`, `morphAnimation`
- `lib/src/widget/flutter_checkbox.dart` — `_FlutterCheckboxState`,
  `didUpdateWidget`, `AnimatedBuilder`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Tristate value](tristate-value.md) — the switch in `updateCheckAnimation`
  covers every `CheckboxTransition`, so a new case lands here.
- [Box painting](box-painting.md) — the painter reads `progress` for the fill
  lerp *and* for how much of the check or dash path is drawn, and `morphProgress`
  for the crossfade. A change to either range or meaning changes the drawing.
- [Style resolution](style-resolution.md) — `animationDuration`,
  `animationCurve`, `morphDuration` and `morphCurve` come from `CheckboxStyle`.

## Known holes / open

- **Changing a duration or curve after the first build has no effect**, because
  the controllers are never rebuilt. Found by reading, not by running it.
- The painter's `progress` does two jobs, fill colour and stroke length. A
  separate stroke animation would need a third controller, and nothing in the
  data model has one.
