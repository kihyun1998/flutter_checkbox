# Interaction

## What it is

The seam both widgets sit on. It owns the one semantics node (checked / mixed /
enabled / label / tap), keyboard activation (`space` and `enter` →
`ActivateIntent`), focus and hover tracking, and the single guarded activation
handler. It leaves the visuals to each widget through a `builder` that receives
`focused`, `hovered` and `activate`.

## Governing decisions

- [ADR 0001 — One node, one focus stop](../../adr/0001-one-node-one-focus.md#decision).
  Its R1–R5 are this territory's construction rules. Read its
  [does-not-cover list](../../adr/0001-one-node-one-focus.md#what-this-record-does-not-cover)
  before treating a neighbouring question as settled.

## Design model

The rules are the ADR's. Two facts it does not state:

- **Three activation paths, one handler.** A pointer tap (through the adapter's
  `InkWell.onTap`), the keyboard (`CallbackAction<ActivateIntent>`) and assistive
  tech (`Semantics.onTap`) all call `_activate`, which does nothing unless
  `_isInteractive`.
- **An unlabelled node's label is `''`, not `null`.** That keeps the node's
  label stable for assertions. See the `matchesSemantics` entry in
  `docs/agents/lessons.md`.

## Code

- `lib/src/widget/checkbox_interaction.dart` — `CheckboxInteraction`,
  `CheckboxInteractionBuilder`, `_CheckboxInteractionState`, `_isInteractive`,
  `_activate`, `MergeSemantics`, `FocusableActionDetector`
- `lib/src/widget/flutter_checkbox.dart` — `canRequestFocus`, the checkbox's
  `InkWell` giving up its own focus node (ADR R3)
- `lib/src/widget/flutter_checkbox_tile.dart` — `canRequestFocus`, the same for
  the tile's `InkWell`
- `test/checkbox_interaction_test.dart`

## Reference behaviour

- [ADR 0001 § The root cause](../../adr/0001-one-node-one-focus.md#the-root-cause)
  pins `InkResponse`'s own `Focus` and `Semantics(onTap:)`, and the built-in's
  `GestureDetector` inside `FocusableActionDetector`. This is the comparison the
  design rests on.
- [ADR 0001 § R4](../../adr/0001-one-node-one-focus.md#decision) — focus
  semantics are left to `Focus`, including the iOS omission of `onFocus`.

## Cross-cutting invariants

- [One node, one stop](../invariant/one-node-one-stop.md)
- [Non-interactive](../invariant/non-interactive.md)

## Blast radius

- [Tile](tile.md) — the tile is the seam's other adapter. It passes
  `semanticLabel: null` so that its rendered text becomes the name (ADR R2).
- [Hover ring](hover-ring.md) — the ring's colour is driven by `focused` and
  `hovered`, and the ring exists only while `activate` is non-null.
- [Tristate value](tristate-value.md) — `_activate` is the sole caller of
  `CheckboxValue.next`.

## Known holes / open

- ADR 0001 leaves two questions open, and no issue tracks either: whether a
  read-only control should use `SemanticsProperties.readOnly` instead of sharing
  `enabled: false` with a disabled one, and whether the tile needs its own
  `semanticLabel` override.
- **`matchesSemantics` misreports in this SDK.** On any mismatch its
  `describeMismatch` throws `Null is not a subtype of String`, which hides the
  real cause. It also rejects unspecified actions, such as the newer `focus`
  action. Assert off `tester.getSemantics(f).getSemanticsData()` instead.
- **`isFocusable` is derived, not a flag:** `flagsCollection.isFocused !=
  Tristate.none`. `SemanticsFlag.isFocusable` is deprecated here and fails
  `flutter analyze`.
- **Assert counts, not presence.** `hasAction(tap)` inspects only the node it
  found, so it passes with two tap nodes. The counting helpers are the ADR's
  proof obligations.
- Real-platform assistive tech (TalkBack / VoiceOver ordering, hints) is outside
  what `flutter_test` can pin.
