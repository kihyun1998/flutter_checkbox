# Tristate value

## What it is

The value cycle and nothing else. Given the current value and whether the
indeterminate state is allowed, it computes the next value. Given an old and new
value, it names the animation that change calls for. It holds no value: the
caller owns `value`, and the widgets only ever hand the next one to `onChanged`.

## Governing decisions

**None.** The cycle is stated as an invariant in
[`CLAUDE.md` § Identity & invariants](../../../CLAUDE.md#identity--invariants-the-boundary),
which is not a decision record. [ADR 0001](../../adr/0001-one-node-one-focus.md#what-this-record-does-not-cover)
names the tristate cycle as outside its scope. It is adjacent, not governing.

## Design model

Read from the source; nothing above it records the rules.

- **Cycle.** Tristate: `false → true → null → false`. Binary: `!current`.
- **Precondition.** `null` only when `tristate`. Both widget constructors assert
  it. `CheckboxValue.next` does not check it: the binary branch's `!` throws on a
  `null` that got past the assert.
- **Transitions are data, not effects.** `transition` maps the six real changes
  (plus "unchanged") to a `CheckboxTransition`. The animation layer applies the
  effect, so the machine never touches a controller.
- **Resting positions.** `restingProgress` gives the controller positions for a
  value with no animation: the first frame, and nothing else.
- **The caller owns the value.** Nothing in `lib/` stores it. A widget computes
  `next` and calls `onChanged`, and the new value arrives back through
  `didUpdateWidget`. That round trip is why the animation reacts to
  `widget.value` changing rather than to a tap.

## Code

- `lib/src/controller/checkbox_value.dart` — `CheckboxValue`, `next`,
  `transition`, `restingProgress`, `CheckboxTransition`
- `lib/src/widget/checkbox_interaction.dart` — `_activate`, the only caller of
  `next`
- `test/checkbox_value_test.dart` — unit tests with no pump

## Reference behaviour

**None.** The cycle has never been checked against the built-in
`material/checkbox.dart` and recorded with a pin.

## Cross-cutting invariants

- [Non-interactive](../invariant/non-interactive.md) — `next` is reached only
  through the seam's guarded `_activate`.

## Blast radius

- [Animation](animation.md) — every `CheckboxTransition` case is handled in
  `updateCheckAnimation`. A new case, or a changed mapping, changes what it drives.
- [Interaction](interaction.md) — the seam is the sole caller. It also derives
  `checked` / `mixed` from the same `value`.
- [Tile](tile.md) — the tile colours itself from `value == true`, so a change to
  what the values mean reaches the tile's background.

## Known holes / open

- The precondition sits in the widgets, not in `next`. A third caller would
  inherit no guard.
