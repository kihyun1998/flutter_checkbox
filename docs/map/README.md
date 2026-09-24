# Map — flutter_checkbox

<!-- grill-map build stamp: eb0cd67 -->

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

## What the map cannot answer

- **Issues and source files are not nodes.** They appear as text inside notes.
  The open backlog is `gh issue list`, not this folder.
- **Pixels.** Every visual claim is proved by running the example
  ([Example app](territory/example-app.md)), and a note can only say so.
- **Reference comparisons.** The repo has no store of pinned external facts, so
  most `## Reference behaviour` sections are `**None.**`. The pins that do exist
  sit in the decision records under `docs/adr/`.

## Measured when this map was written (at 4c46353)

- **M1 — public surface:** 5 exported types and 66 public constructor fields,
  plus `CheckboxStyle.copyWith` and `CheckboxStyle.resolve`. One decision record
  governs the semantics and focus slice of them. Painting, style, ring, tile,
  animation and the value cycle have none.
- **M2 — mentioned vs about:** ADR 0001 is *about* accessibility. It *mentions*
  the tristate cycle, `onChanged: null`, visual focus indication and the SDK
  floor, each explicitly as not covered.
- **M3 — file size:** no `lib/` file holds more than 30% of the layer. The
  largest is the tile, at 26%. The territories are finer than the files anyway,
  because `flutter_checkbox.dart` carries the ring, the painting call and the
  animation wiring.
- **M4 — forward-looking prose:** three sentences claimed no decision records
  exist after ADR 0001 landed: one in `CLAUDE.md` and two in the bindings file of
  the retired `theflow` skill. All three were removed when the map landed. ADR
  0001's two open questions have no issue.
- **M5 — backlog:** one open issue, #13, in
  [Style resolution](territory/style-resolution.md).

## Coverage, and what an absent note means

This pass covers the whole package: every file under `lib/`, the example and the
publish surface. **An absent note is therefore a gap, not a deliberate state.**
A new territory is owed when a change adds a public type or a rendering concern
that no note's `## What it is` covers.

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
