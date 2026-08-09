# 0001 — One node, one focus stop

- **Status:** Accepted
- **Date:** 2026-08-09
- **Supersedes:** the acceptance criterion of issue #4 ("tile and checkbox
  expose identical merged semantics … tap on one node"), which was never true
  for two of the six constructions.
- **Issues:** #7 (the trigger), #4, and the 0.3.0 semantics work.

## Why this is a record and not another issue

Accessibility in this package has now been decided **three times** — `MergeSemantics`
in 0.3.0, `excludeChildSemantics` on the extracted seam in #4, and the lost
`isFocusable` in #7 — and each decision reinterpreted the last. Working #7
produced three of the promotion triggers in `theflow.md`:

1. the same participants (`label` × `labelWidget` × tile × `InkWell` × `Focus`)
   were being decided again in a new combination;
2. two artifacts inside the repo required opposite things — the `tapNodeCount == 1`
   contract versus the two-tap-node behaviour two constructions actually shipped;
3. an earlier issue's stated premise (#4's acceptance criterion) was **measured
   false** before work could start.

An issue records one decision. What was missing is the rule that makes *every*
combination resolvable without a new decision, so that is what this record holds.

## What was measured

`main` at the time of writing, walking the real semantics tree and the real
`FocusManager` tree (nodes / tap / isFocusable / focus action):

| construction | nodes | tap | focusable | focus action |
|---|---|---|---|---|
| `FlutterCheckbox` + `semanticLabel` | 1 | 1 | **0** | **0** |
| `FlutterCheckbox` bare | 1 | 1 | **0** | **0** |
| `FlutterCheckbox` disabled | 1 | 0 | 0 | 0 |
| tile, `label` | 1 | 1 | **0** | **0** |
| tile, no label | **2** | **2** | 2 | 2 |
| tile, `labelWidget` | **2** | **2** | 2 | 2 |
| tile, `label` + `subtitle` | 1 | 1 | 0 | 0 — **subtitle silently dropped** |

Plus: **two Tab stops** on every control, and `FlutterCheckboxTile(focusNode:)`
throwing `'child != this'` and leaving the control unactivatable by keyboard.

Five defects, one mechanism.

## The root cause

`InkResponse` builds **its own `Focus`** (`material/ink_well.dart:1390`) and
**its own `Semantics(onTap:)`** (`:1401`). Because we drove the tap surface with
`InkWell`, every control carried a second focus node and a second tap
annotation. Collapsing the second *semantics* node is what `excludeSemantics`
was introduced to do — and `excludeSemantics` discards everything the subtree
contributes, including the `isFocusable` flag and the `focus` action that
`Focus` publishes (`widgets/focus_scope.dart:716-728`). The second *focus* node
was never addressed at all.

Flutter's own checkbox has neither problem because it uses a bare
`GestureDetector` inside `FocusableActionDetector`, with no exclusion and no
merge (`widgets/toggleable.dart:378-395`, `material/checkbox.dart:615`).

## Decision

> **A `flutter_checkbox` control is exactly one node to assistive tech and
> exactly one stop to the keyboard. Every piece of text the user can see inside
> it is part of that node's name. Nothing inside it is separately focusable.**

Five construction rules implement the invariant. None of them is a
per-construction predicate — that is the point.

**R1 — Merge, never exclude.** The seam wraps its `Semantics` in
`MergeSemantics`. Merging is idempotent over arity: 0, 1 or N annotated
descendants collapse identically, so it needs no flag. It also *keeps* what
descendants contribute instead of discarding it. `excludeChildSemantics` is
deleted.

**R2 — The name is rendered once, declared never twice.**
`SemanticsConfiguration.absorb` concatenates labels, so the seam sets
`semanticLabel` **iff no descendant renders that name**. `FlutterCheckbox`
renders no text, so it passes `semanticLabel`. `FlutterCheckboxTile` renders its
own name, so it passes `null` and the merged `label`/`labelWidget`/`subtitle`
become the name.

**R3 — One focus node, and it belongs to the seam.** Both `InkWell`s take
`canRequestFocus: false`, and the tile no longer forwards `widget.focusNode` to
its `InkWell`. Their `Semantics(onTap:)` is deliberately left alone: under R1 it
merges onto the same node, and keeping it means assistive-tech activation still
ripples and fires `Feedback.forTap`.

**R4 — Focus semantics stay where the framework computes them.** The seam
declares no `focusable` / `focused` / `onFocus` and owns no `FocusNode`. `Focus`
already publishes all three correctly — including the deliberate iOS omission of
`onFocus` (`focus_scope.dart:723`, flutter/flutter#150030), the directional-mode
`canRequestFocus` behaviour, and primary-versus-descendant focus. R1 lifts them
onto the single node for free.

R4 is the load-bearing inversion. The obvious fix for #7 — declare `focusable:`
on the outer node — hand-rolls what the reference already publishes, on the one
layer where `theflow.md`'s tie-breaker gives the reference **unconditional**
authority. It was measured wrong on iOS and in directional navigation.

**R5 — Non-interactive is announced as non-interactive.** The node's `enabled`
state is `interactive`, not the `enabled` constructor flag. `onChanged: null` is
a documented contract ("non-interactive"), so a control nobody can operate must
not be announced as operable — a screen-reader user would be told they can act
and then nothing happens. Measured: the tile's inner `FlutterCheckbox` is
`onChanged: null` by design, and under R1 its node does **not** drag an
interactive tile's own node to disabled.

## How every combination resolves

For `{bare, tile} × {label, labelWidget, neither} × {enabled, disabled} ×
{onChanged null, non-null}` — `label` + `labelWidget` together is already barred
by an assert — every quantity derives from one boolean,
`interactive = enabled && onChanged != null`:

| quantity | value | depends on the label shape? |
|---|---|---|
| shipped semantics nodes | `1` | no |
| tap actions | `interactive ? 1 : 0` | no |
| `isFocusable` / focus action | `interactive ? 1 : 0` | no |
| keyboard focus stops | `interactive ? 1 : 0` | no |
| node name | rendered text if any, else `semanticLabel`, else `''` | **yes — only here** |
| `enabled` state | `interactive` | no |
| `checked` / `mixed` | from `value` | no |

The label shape influences exactly one row. That is why no predicate keyed on
`label` or `labelWidget` can be correct: it was being used to decide rows it has
no bearing on.

## Consequences

- A tile's `subtitle` is now announced as part of the control's name.
- A `labelWidget` now supplies the name rather than sitting on a second node.
- One Tab stop per control instead of two.
- `FlutterCheckboxTile(focusNode:)` no longer throws.
- **Out of contract:** a `labelWidget` that needs its own semantics node (a link
  inside the label, say) cannot be supported — merging swallows it. This is the
  same limitation the reference documents for `CheckboxListTile`
  (`material/checkbox_list_tile.dart:113-123`). Document it; do not add a
  predicate to half-support it.

## Proof obligations this creates

- `tapNodeCount` must skip `isMergedIntoParent` nodes. Before this record it
  counted nodes the engine never ships, so it would have rejected the
  framework's own solution — a false red.
- A `focusStopCount` helper is required for any interaction change. A second
  focus node nests *under* the seam's, so shortcuts still resolve and the ring
  still lights: no semantics assertion can see it.

## What this record does NOT cover

State this explicitly so the next pass does not read neighbours as decided.

- **The tristate cycle** and `CheckboxValue` — decided in `CLAUDE.md`, untouched.
- **`onChanged: null` as the composition seam** — this record *consumes* that
  decision; it does not reopen it, and it must not be read as deciding that
  `onChanged: null` means *disabled*. `FlutterCheckbox.enabled` keeps that
  distinction.
- **How a read-only control is *distinguished* from a disabled one.** R5 makes
  both announce `enabled: false`, which is honest (neither can be operated) and
  matches the built-in. Whether the read-only case deserves the separate
  `SemanticsProperties.readOnly` encoding is not decided here — only that
  claiming `enabled: true` was wrong.
- **Visual focus indication** — ring colour, geometry, layout consumption and the
  `scale` interaction stay "our design wins" territory.
- **Whether `FlutterCheckboxTile` should gain its own `semanticLabel` override.**
  R2 makes the tile's name come from rendered text; whether callers need an
  escape hatch is an open API question.
- **Real-platform assistive-tech behaviour** — TalkBack/VoiceOver ordering and
  hint text are outside what `flutter_test` can pin. The contract here is the
  `SemanticsData` a headless run can read plus the focus-node tree.
- **The SDK floor policy** — its own record-worthy area.

## Decision type

The **mechanism** (R1–R4) is a derivation from the two corpora and falls to a
better derivation. The **scope** — fixing all five defects in one change rather
than only #7, accepting that a tile's announced name changes — was the
maintainer's call, made against the measured table above, and is theirs to
reverse.
