# Map — flutter_checkbox

<!-- grill-map build stamp: 8e5a943 -->
<!-- grill-map synced at: a7b403e (2026-10-25) -->

A linked note graph that answers two questions no issue, record or file answers:

1. **"If I touch this, what else moves?"** Open the territory you are touching and
   work through its `## Blast radius` as a checklist, then its
   `## Cross-cutting invariants`.
2. **"What is this derived from?"** In the same note, `## Governing decisions`
   says why, and `## Design model` says what the rules are. A `**None.**` there is
   the answer, not a gap in the note.

## Why this layer exists

The package's accessibility was decided three times, each decision
reinterpreting the last: `MergeSemantics` in 0.3.0, `excludeSemantics` on the
extracted seam in #4, and the lost `isFocusable` in #7. Each fix was right about
the site it stood on, and nothing pointed from that site to the others. That fact
now has a node: [One node, one stop](invariant/one-node-one-stop.md).

## Reading protocol

- **Read before the work.** In `thegraph` this is `read-it`'s territory step: find
  the territories the change lands in before the design is committed.
- **Write after it**, as part of the change:
  1. **Coverage.** Is every territory the change touched listed here, and is its
     blast radius still right?
  2. **Promotion.** Is the fact this fix revealed also true outside this
     territory? Here the test is a grep: does it hold at every site that computes
     interactivity (`isInteractive`, `onChanged != null`), or at every widget
     inside a `CheckboxInteraction` builder? If it does, an invariant note lands
     with the fix.

## Conventions

- Territories overlap. A fact that holds in several places is an invariant note,
  not a copy in each territory.
- An empty section stays and carries `**None.**`. The sentinel appears under
  several headings, so every query for it names the heading.
- `## Code` names symbols, never line numbers.
- Links are plain relative markdown, so they work on GitHub and in Obsidian.
- A value another artifact owns (a record's status, a count, an issue's state)
  is linked, not restated.
- Every claim carries its evidence (a symbol, a commit, a record) or its source
  and date, so a stated reason reads apart from a checked one.

## What the map cannot answer

- **Issues and source files are not nodes.** They appear as text inside notes.
  The open backlog is `gh issue list`, not this folder.
- **Pixels.** Every visual claim is proved by running the example
  ([Example app](territory/example-app.md)), and a note can only say so.
- **Reference comparisons.** The repo has no store of pinned external facts, so
  most `## Reference behaviour` sections are `**None.**`. The pins that do exist
  sit in the decision records under `docs/adr/`.

## The repo in one paragraph

Two widgets, `FlutterCheckbox` and `FlutterCheckboxTile`, sit on one shared seam,
`CheckboxInteraction`, which owns the single semantics node, the single focus
stop and the guarded activation handler. The checkbox adds a `CustomPainter` box
driven by two animation controllers, and a hover ring around it. The tile adds a
row with a label, a subtitle and an animated background, and makes its inner
checkbox purely visual. Every visual value lives in one `CheckboxStyle`,
resolved against the `Theme` once. The value cycle is a pure module that holds no
value. Territories are finer than files: `flutter_checkbox.dart` alone carries
the ring, the painting call and the animation wiring.

## Coverage, and what an absent note means

This map covers the whole package: every file under `lib/` and `test/`, the
example and the publish surface. **An absent note is therefore a gap, not a
deliberate state.** A new territory is owed when a change adds a public type or a
rendering concern that no note's `## What it is` covers, or when something in the
repo commits to one (a decision record, an issue with a design).

Out of scope, on purpose: the agent tooling (`scripts/check_map.py`, its config
`.checkup.json`, and `docs/agents/`) and the decision records themselves. None of
it ships; `.pubignore` keeps it out of the package.

**The largest gap is the other side of the boundary.** `flutter_table_plus` and
`flutter_dropdown_button` consume this package
([ADR 0002](../adr/0002-default-check-colour-follows-the-fill.md#what-it-was-decided-on),
#17), but no checkout of either was readable when this map was written, so no
note reads their call sites. A change to a default or to the public surface is
checked against them by hand ([Publishing](territory/publishing.md)).

## Nodes

Territories: [Tristate value](territory/tristate-value.md) ·
[Animation](territory/animation.md) · [Box painting](territory/box-painting.md) ·
[Interaction](territory/interaction.md) · [Hover ring](territory/hover-ring.md) ·
[Style resolution](territory/style-resolution.md) · [Tile](territory/tile.md) ·
[Publishing](territory/publishing.md) · [Example app](territory/example-app.md)

Invariants: [Non-interactive](invariant/non-interactive.md) ·
[One node, one stop](invariant/one-node-one-stop.md)

```sh
rg -lU '## Governing decisions\r?\n\r?\n\*\*None\.\*\*' docs/map/territory/   # nobody decided
rg -lU '## Reference behaviour\r?\n\r?\n\*\*None\.\*\*' docs/map/territory/   # nobody checked
ls docs/map/territory/ docs/map/invariant/                                     # the roster
```
