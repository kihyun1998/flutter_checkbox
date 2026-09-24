# Non-interactive

## The fact

`interactive = enabled && onChanged != null`. When it is false, a control has no
tap, no focus stop, no keyboard activation and no hover ring. Its semantics node
says `enabled: false`. **`onChanged: null` is not "disabled"**: it has no 40%
opacity. That look is `enabled: false`, and the two differ only in appearance.

## Why it is cross-cutting

Three sites work the boolean out independently, and none of them calls the
others. The seam has `_isInteractive`. `FlutterCheckbox`'s builder has
`isInteractive = activate != null`. The tile computes its own for the cursor. The
ring and the tile's composition read it from different places, so a change to
the rule has to be made at every site. No territory-to-territory edge makes that
visible.

## Territories it holds in

- [Interaction](../territory/interaction.md) — `_isInteractive` guards
  `_activate`, sets `Semantics.enabled` and sets `FocusableActionDetector.enabled`.
- [Hover ring](../territory/hover-ring.md) — `!isInteractive` skips the ring
  entirely, so it takes no layout.
- [Tile](../territory/tile.md) — the tile passes `onChanged: null` to its inner
  checkbox so that the tile is the one interaction surface. It computes
  `isInteractive` again for its cursor.
- [Tristate value](../territory/tristate-value.md) — `CheckboxValue.next` is
  reachable only through the guarded `_activate`.

## What a violation looks like

- A tile that takes two Tab stops, or announces its inner checkbox separately.
  That is the inner checkbox acting as interactive.
- A non-interactive control announced as operable. Assistive tech says "tap to
  toggle" and nothing happens.
- A tile whose checkbox leaves a gap beside it. That is the ring being laid out
  for a checkbox that can never show it.

## Discovery history

- 0.3.0 — a labelled tile could not be activated by assistive tech at all
  (`excludeSemantics` dropped the tap). The fix put the tap on the tile's node.
- #7 — the node announced `enabled` from the constructor flag rather than from
  interactivity. [ADR 0001 R5](../../adr/0001-one-node-one-focus.md#decision)
  made `enabled` mean `interactive`.
- [ADR 0001](../../adr/0001-one-node-one-focus.md#what-this-record-does-not-cover)
  leaves open how a read-only control is told apart from a disabled one. Both are
  now `enabled: false`.

## Where it will recur

Any new behaviour that should appear only when the control can be operated: a
new overlay, a tooltip, a long-press, a haptic. If it keys off `enabled` alone,
or off `onChanged` alone, it breaks this. Grep `isInteractive` and
`onChanged != null` across `lib/` before adding one.
