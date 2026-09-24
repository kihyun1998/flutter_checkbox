# One node, one stop

## The fact

Every construction of either widget ships **one** semantics node and at most
**one** keyboard focus stop, and it has a stop only when interactive. The rule
and its construction rules R1–R5 are
[ADR 0001](../../adr/0001-one-node-one-focus.md#decision). This note only maps
where it has to hold.

Checkable form: walk the shipped semantics tree and count tap nodes, skipping
`isMergedIntoParent`. Walk the `FocusManager` tree and count focus stops
(`focusStopCount`). Both must be ≤ 1, and each must be 0 when non-interactive.

## Why it is cross-cutting

The node and the stop are built in one place, the seam. They are *broken* in
others: any `InkWell`, `Focus`, `Semantics` or label widget an adapter adds
under the seam can add a second node or a second stop. The seam cannot see what
its builder returns, and nothing calls back to check.

## Territories it holds in

- [Interaction](../territory/interaction.md) — `MergeSemantics` over one
  `Semantics`, and the only `FocusableActionDetector`.
- [Tile](../territory/tile.md) — its `InkWell` takes `canRequestFocus: false`,
  and its rendered label and subtitle merge in as the name.
- The checkbox's own `InkWell` in `flutter_checkbox.dart` also takes
  `canRequestFocus: false`. It is filed under
  [Interaction](../territory/interaction.md)'s code, not under the ring it sits
  beside.

## What a violation looks like

- Tab stops twice on one control. No semantics assertion can see this: the second
  node nests under the seam's, so shortcuts still resolve and the ring still
  lights.
- A screen reader reads two elements, or the name twice ("Accept Accept terms").
- A tile subtitle that is never announced.

## Discovery history

Decided three times, each decision reinterpreting the last:

- 0.3.0 — state and tap on separate nodes. `MergeSemantics` was added.
- #4 — extracting the seam swapped the merge for `excludeSemantics` and
  reintroduced a second tap node. A count caught it.
- #7 — `excludeSemantics` dropped `isFocusable`. That turned out to be five
  defects from one mechanism, `InkResponse`'s own `Focus`, and was promoted to
  ADR 0001.

## Where it will recur

Any widget added *inside* the seam's `builder` that carries its own focus or
semantics: `InkWell`, `InkResponse`, `GestureDetector` with semantics, `Focus`,
`TextButton`, or a `labelWidget` with a link. The test is whether it builds a
`Focus` or a `Semantics` of its own. If it does, set `canRequestFocus: false`
and rely on the merge, and assert both counts.
