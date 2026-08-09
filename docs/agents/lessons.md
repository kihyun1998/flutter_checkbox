# theflow lessons (flutter_checkbox)

War-stories indexed by theflow step. Each entry is a concrete precedent where a
step (or a skipped step) cost something real — they keep the bindings in
`theflow.md` from reading as abstractions. Add one the first time a rule earns
its teeth.

---

## Step 4 (proof) — `matchesSemantics` is a proof tool that misreads itself; and state+tap must share one node

**When:** 0.3.0 — hoisting the common `Checkbox` colours to the top level.

**What happened:** The existing `Accessibility` tests used `matchesSemantics(...)`.
They were **already red before any change** — in this SDK the matcher's own
`describeMismatch` throws `Null is not a subtype of String` on *any* mismatch, so
the crash hid the real cause, and the matcher over-asserts the *absence* of
unspecified actions (a newer `focus` action tripped it). A `git stash` of the
lib changes proved the failures pre-existed — without that check I'd have blamed
my own diff (the "report only what you verified" habit stopped a false
self-diagnosis).

Instrumenting a throwaway probe that walked the real semantics tree (Step 1 —
"observe the runtime value, don't read the code") revealed the actual defect:
the **checked state** sat on one node and the **tap action** on a child
`InkWell` node — a screen reader saw two disjoint elements. `FlutterCheckboxTile`
was worse: `excludeSemantics: label != null` dropped the tap action entirely, so
a labelled tile was **impossible to activate** with assistive tech.

**Fixes:** `MergeSemantics` on `FlutterCheckbox`; `Semantics(onTap:)` on the tile.
Tests rewritten off `tester.getSemantics(f).getSemanticsData()` (`flagsCollection.isChecked`
→ `CheckedState`, `isEnabled` → `Tristate`, `hasAction(SemanticsAction.tap)`).

**Rule earned:** the Step 4 semantics bullet — never `matchesSemantics` here;
assert state *and* tap on one node. "Unconfirmed ≠ a real defect in my diff" —
verify a red test pre-existed before owning it.

**Follow-up (#4, the `CheckboxInteraction` seam):** extracting the semantics into
the seam re-introduced the split on the *no-label* checkbox — swapping
`MergeSemantics` for `Semantics(onTap:) + excludeSemantics` left the child
`InkWell`'s tap on a **second** node. The existing `getSemantics(...).hasAction(tap)`
test passed anyway: it only checks the *found* node, not that there is exactly
one. A probe that **counted** tap nodes across the tree caught it (`tap=2`). Rule:
assert the *count* (`tapNodeCount == 1`), not just presence — and drive
one-node-vs-keep-descendants with an explicit `excludeChildSemantics` flag
(default one-node; keep descendants only when a `labelWidget` owns the name).

---

## Step 3 / 5 (test trust, completeness) — the metric that would have rejected the right answer, and two lenses that agreed from opposite stances

**When:** #7 — the lost `isFocusable`, which turned out to be five defects.

**What happened:** The obvious fix (declare `focusable:` on the outer node) was
the issue's own suggestion and my candidate. Two lenses — one hunting gaps, one
briefed to refute me — independently reached the opposite conclusion: every part
of that fix was compensation for a `Focus` widget we did not need, because
`InkResponse` builds its own (`ink_well.dart:1390`). Removing *that* made the
exclusion, the owned `FocusNode` and the hand-declared focus semantics all
unnecessary. The candidate was also measurably wrong on iOS (where `Focus`
deliberately omits `onFocus`) and in directional navigation — both of which the
framework already handles and we would have re-derived badly, on the one layer
where the tie-breaker gives the framework unconditional authority.

**Two things nearly went wrong quietly:**

1. **`tapNodeCount` counted nodes the engine never ships.** It walked
   `isMergedIntoParent` children, which are folded into the parent and never
   reach the platform. Against `MergeSemantics` — the framework's own way of
   collapsing a control — it reports a split that no screen reader can observe.
   The metric would have produced a **false red against the correct answer**.
   (Third instance of the `.pubignore` meta-lesson below; the first two rejected
   nothing, this one would have.)
2. **Two mutations did not go red.** `excludeFromSemantics: true` on the InkWell
   turned out to be genuinely redundant once merge was in place — deleted, and
   keeping the InkWell's semantics means AT activation still ripples. The other
   was a **weak test**: asserting `label` *contains* the name passes happily when
   the name is announced twice ("Accept Accept terms"). Strengthened to count
   occurrences.

**Rules earned:** count only shipped nodes; `focusStopCount` is a required proof
method for interaction changes because no semantics assertion can see a second
Tab stop; and when a mutation fails to go red, decide *which* of "the code is
redundant" or "the test is weak" it is — both happened here, in the same pass.

**Promoted:** `docs/adr/0001-one-node-one-focus.md`.

---

## Step 1 / 5 (references, completeness) — hand-rolling what the framework already paints breaks only in *consumers'* test suites

**When:** #8 — `CheckboxStyle.shadows`.

**What happened:** The issue proposed, and I initially accepted, drawing each
`BoxShadow` by hand in `CheckboxPainter` (`toPaint()` + `shift().inflate()` +
`drawRRect`). Reading Flutter's actual `_BoxDecorationPainter._paintShadows`
(`painting/box_decoration.dart:448-469`) showed a debug-only branch a
from-first-principles version has no reason to invent: when `debugDisableShadows`
is set, `toPaint()` drops the mask filter, which turns a `BlurStyle.outer` shadow
into a **solid fill covering the whole box** — so Flutter wraps the draw in a
`save()/clipRect()/restore()`.

`debugDisableShadows` is `true` in **every** `flutter_test` run. So the hand-rolled
version renders correctly in the app and paints an opaque block over the checkbox
in every consumer's own widget tests. Mutation-tested: swapping the delegation for
the hand-rolled loop passes *every* geometry test and fails only the
`BlurStyle.outer` one.

**Fix:** `_drawShadows` builds a shadow-only `BoxDecoration` and calls
`createBoxPainter().paint(...)` — inheriting Flutter's geometry *and* its guard.
The one thing no option avoids: the border stroke is centred, so the box's outer
edge is `borderRadius + borderWidth / 2`, not `borderRadius`.

**Rules earned:** (1) when the framework already paints the thing, delegate — the
value is the edge cases you would not think to enumerate, not the twelve lines
saved. (2) A geometry-only test suite is not discriminating for a painting change;
assert the debug-mode behaviour too. (3) The Step 1 note that a *summary* of a
reference drops method bodies applies to first-principles derivation as well: both
produce the happy path and neither produces the guard.

**Also surfaced:** the `dart format --set-exit-if-changed` gate is red on `main`
under Flutter 3.44.8 (5 files) — the repo was formatted by an older Dart
formatter. Verify a red gate pre-existed before owning it (same rule as the
`matchesSemantics` story above).

---

## Step 6 / 7 (surfaces, gates) — a `.pubignore` silently ships what `.gitignore` hides; a bad probe filter gives a false green

**When:** 0.3.0 — resolving the `docs/` top-level-directory publish warning.

**What happened:** Adding a `.pubignore` to exclude `docs/`/`CLAUDE.md` switches
pub from git-based file listing to a **filesystem walk that ignores `.gitignore`**.
My first verification grepped the dry-run for `/build/` and concluded "git
listing still active" — but the regex missed the tree's `├── build` and the
`.dill` files, a **false green from a bad filter**. Re-reading the *actual* file
list showed the package would ship **87 MB of `build/*.dill`** build cache.

**Fix:** a complete `.pubignore` that re-lists every `.gitignore` build/dev
exclude (`build/`, `.dart_tool/`, `pubspec.lock`, …) alongside the agent/example
excludes. Dry-run: 0 warnings, 24 KB archive.

**Rule earned:** Step 6's `.pubignore` note (re-list `.gitignore`'s excludes or
they ship). And the meta-lesson behind theflow's "instrument a probe and **read
the number**": a probe with a wrong filter is worse than no probe — it
manufactures false confidence. Read the raw output, not a grep of it.
