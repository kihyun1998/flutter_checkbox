# theflow bindings (flutter_checkbox)

Project-specific data for the `theflow` skill — reasoning bindings, module map,
reference routing, boundary rule, proof methods, surfaces, gates. The skill holds
the portable *method*; this file holds the *bindings*.

Identity lives in `CLAUDE.md`. `CONTEXT.md` does not exist yet (created lazily).
War-stories are recorded in `docs/agents/lessons.md`, indexed by theflow step —
read it before proving a semantics or packaging change.

---

## Reasoning bindings (project-wide)

These govern every step, so they sit above the per-step sections.

### Named prior art

| Prior art | Cross-checked for |
|---|---|
| Flutter SDK `material/checkbox.dart` + `material/checkbox_list_tile.dart` | tristate cycle, a11y flags, focus/keyboard wiring, animation timing |
| Flutter SDK `FocusableActionDetector` / `Actions` / `Shortcuts` / `Semantics` | interaction plumbing |
| shadcn/ui checkbox | visual defaults only (border weight, radius, shadow — see #8) |
| Sibling packages under `../` (`flutter_dropdown_button`, `flutter_table_plus`, `just_tooltip`) | house style for `*Style` value objects + `resolve(Theme)` |

### Tie-breaker — when prior art and our own evidence disagree

**Our design wins, except in accessibility.** This package exists *because* the
built-in `Checkbox` cannot be customized far enough, so on visuals, public API
shape, and internal structure the built-in is a cross-check, never an authority.

**The one exception: semantics and keyboard-activation contracts — Flutter's
built-in checkbox wins unconditionally.** What a screen reader expects is a
framework convention, not our taste; diverging there produces a control assistive
tech cannot operate, and `lessons.md` records that happening twice.

### Deliberate-divergence list

Where we do *not* follow the built-in, on purpose. Step 5's reference-free
restatement test is checked against this list — a lens proposing the built-in's
design back is **not** reporting a defect if it lands here.

| We do | Built-in does | What decided it |
|---|---|---|
| `scale` scales the **rendered size and the hit area together** | 18dp fixed box; `MaterialTapTargetSize` moves only the hit area | `CLAUDE.md` invariant; issue #1 (Tick size). No ADR. |
| `FlutterCheckboxTile` passes `onChanged: null` inward — the **tile is the single interaction surface** | `CheckboxListTile` wires `onChanged` to the inner checkbox too | `CLAUDE.md` invariant; re-confirmed while building the `CheckboxInteraction` seam (#4). No ADR. |
| `CheckboxStyle` is a plain value object resolved once via `resolve(Theme)` — **no `WidgetStateProperty`** | `fillColor` / `overlayColor` are per-state properties | issue #5 (moved overlay colours into `CheckboxStyle.resolve`). No ADR. |
| The **hover ring consumes layout**, and is skipped entirely when `onChanged == null` | splash/overlay paints outside layout and always exists | `CLAUDE.md` invariant. No ADR. |

**Zero records exist** (`docs/adr/` is empty — see Step 6). Every row above is
decided by a `CLAUDE.md` invariant or an issue, not by a decision record.

---

## Crate / module map

Single Flutter package, **no runtime dependencies**. Barrel
`lib/flutter_checkbox.dart` exports `FlutterCheckbox`, `FlutterCheckboxTile`,
`CheckboxStyle`, `CheckboxPosition`.

| Module (`lib/src/`) | Role | Public? |
|---|---|---|
| `widget/flutter_checkbox.dart` | the controlled checkbox — painter + animation + ring + focus/keyboard + semantics | ✅ |
| `widget/flutter_checkbox_tile.dart` | tile layout wrapping `FlutterCheckbox` with `onChanged: null` (the tile owns interaction) | ✅ |
| `widget/checkbox_interaction.dart` | `CheckboxInteraction` — shared seam: tristate `Semantics` (checked/tap on one node) + keyboard activation + focus/hover, exposing state via a `builder`. Both widgets adapt onto it | internal |
| `painter/checkbox_painter.dart` | `CustomPainter` — box fill + checkmark/dash, paints at `size * scale` | internal |
| `controller/checkbox_value.dart` | `CheckboxValue` — pure tristate machine: `next` (cycle), `transition` (change → animation), `restingProgress` (snap). No State/Ticker/context; unit-tested without a pump | internal |
| `controller/checkbox_animation.dart` | `CheckboxAnimationMixin` — `checkAnimation` (fill) + `morphAnimation` (check ↔ dash crossfade); classifies changes via `CheckboxValue.transition`, applies the effect | internal |
| `style/checkbox_style.dart` | `CheckboxStyle` (size, scale, shape, borderRadius, checkScale, hoverRing*, overlay colours, disabledOpacity) + `resolve(Theme)` | ✅ |
| `style/checkbox_position.dart` | `CheckboxPosition` (tile) | ✅ |

### Membership — what the top-level commands do and don't reach

`example/` is a **separate package** (`example/pubspec.yaml`, depending on the
root via `path: ../`). Measured, not assumed:

- `flutter analyze` **does** reach `example/lib/` — verified by planting a type
  error in `example/lib/main.dart`; the root run reported it.
- `flutter test` runs **`test/` only** (76 tests). **`example/` deliberately has
  no tests.** It had one smoke test that no gate ever ran; by the time it was
  found it had rotted red (it asserted a `'CustomCheckbox Playground'` string the
  app stopped rendering) — deleted rather than gated. The example is a *visual*
  instrument, proved by running it, not by asserting on it. If a test is ever
  added back there, it needs a gate line here or it rots the same way.

---

## Step 1 — reference routing table

| Change type | Real source to read |
|---|---|
| **Painting** | Flutter SDK `CustomPainter` / `CustomPaint` source; `shouldRepaint` semantics |
| **Interaction** (focus / keyboard / hover) | Flutter SDK `FocusableActionDetector`, `InkWell`, `Actions`/`Shortcuts`, `Semantics` |
| **Parity / semantics** | Flutter's built-in `material/checkbox.dart` — for the tristate cycle and the a11y flags (`checked`/`mixed`) it sets. Per the tie-breaker above, this one is authoritative, not advisory |
| **Visual defaults** | shadcn/ui checkbox, as a cross-check only (#8) |
| **API introduced-in version** | in the SDK checkout — `cd "$(dirname "$(dirname "$(which flutter)")")"` — run `git log -S "<sig>" -- <path>` then `git tag --contains <first commit>`. Derive the path; do not hardcode it (it differs per machine). The SDK floor is hand-reasoned and no gate checks it (Step 7) |
| **Published state** | `curl -s https://pub.dev/api/packages/flutter_checkbox` |

## Step 1 — the project's own map

**None.** This repo keeps no dependency / territory graph — a single package with
eight source files and no runtime dependencies does not have a graph worth
maintaining, and the module map above is the whole territory. Recorded as a
deliberate answer, not an unfilled slot: do not go looking for one at Step 1.

## Step 2 — boundary rule

- **Controlled — the caller owns `value` + `onChanged`.** The widget never
  stores the value; it computes the next value in the tristate cycle
  (`false → true → null → false`) and calls `onChanged`. The caller re-passes it.
- **The widget owns** the painter, the fill + morph animation, the hover ring,
  focus/keyboard (`space`/`enter` → `ActivateIntent`), `Semantics`, style
  resolution against `Theme`, and `scale → rendered size` (so hit area = visual).
- **`onChanged: null` is the composition seam** — it makes the checkbox purely
  visual (ring/focus/tap skipped) so `FlutterCheckboxTile` can be the single
  interaction surface. Do not add a second tap handler on the inner checkbox.

## Step 4 — proof method per layer

- **Pure logic** (`CheckboxValue`) — plain unit tests, no `pump`, no `WidgetTester`.
  That is the point of the module; if a change needs a pump to test, it belongs
  in the widget layer instead.
- **Widget tests** at the public seam: pump, tap / send `space`+`enter`, and
  assert `onChanged` fired with the **right next value** (cover the full tristate
  cycle). Assert the `onChanged: null` path fires nothing and shows no ring.
- **Semantics is a contract** — assert `checked` / `mixed` / `enabled` flags, not
  just the pixels. Flutter's built-in checkbox is the reference for what to set.
  - **Do not use `matchesSemantics` in this SDK** — on any mismatch its
    `describeMismatch` throws `Null is not a subtype of String`, hiding the real
    cause, and it over-asserts the *absence* of unspecified actions (a newer
    `focus` action trips it). Assert off `tester.getSemantics(f).getSemanticsData()`
    instead: `flagsCollection.isChecked` is a `CheckedState` enum, `isEnabled` a
    `Tristate` enum (both from `dart:ui`), and `hasAction(SemanticsAction.tap)`.
  - **State + tap must sit on one node — assert the *count*, not the presence.**
    A composite control (state on the `Semantics` node, tap on a child `InkWell`)
    reads to a screen reader as two disjoint elements. `getSemantics(...).hasAction(tap)`
    only inspects the node it found, so it passes with two tap nodes in the tree;
    walk the tree and assert `tapNodeCount == 1`. See `docs/agents/lessons.md`.
- **Animation** — pump through the duration; the check↔dash crossfade is
  `morphAnimation`, the fill is `checkAnimation`.
- **Painter** — `shouldRepaint` must fire on style / progress change; visuals
  have **no golden CI**, so verify by running the example (`cd example && flutter run`).
- **Equality** (`CheckboxStyle`) — build values at runtime and assert
  `identical(a, b)` is false *first* (Dart normalizes same-arg `const` to one
  instance, so `const a == const b` passes on identity even without `operator ==`).

### Traps a headless run misses

**Draw calls are assertable; pixels are not.** `flutter_test`'s `paints` matcher
replays a render object's display list, so geometry *is* pinnable —
`expect(findCheckboxPaint(), paints..rrect(rrect: …, color: …)..circle(…))`
proves shape, size, colour, and **z-order** (calls must match in order, extras
between them are ignored). Prefer it to eyeballing whenever the claim is a
number: it caught the `borderRadius + borderWidth / 2` outer-edge adjustment
in #8, which no amount of looking would have.

Two caveats:

- **`debugDisableShadows` is `true` in every `flutter_test` run.** It nulls
  `BoxShadow.toPaint()`'s mask filter, so blur is invisible to a headless run and
  `BlurStyle.outer` degrades to a solid fill unless the painter clips. To assert
  `hasMaskFilter: true`, set it `false` and restore it **inside the test body** —
  the binding asserts painting debug vars are unset *before* `tearDown` runs.
- **What stays example-only:** actual blur softness, how the box shadow reads
  against the hover ring, and whether a shadow spills awkwardly out of a tile.
  Ring geometry and morph smoothness are likewise unasserted today. A green
  `flutter test` still says nothing about how the widget *looks*.

For a visual check without a device, a throwaway `matchesGoldenFile` test with
`--update-goldens` renders a PNG you can look at, then delete (text renders as
blocks — `flutter_tester` has no real font).

## Step 5 — unconditional completeness triggers

The completeness pass runs on these paths **regardless** of the enumeration-risk
judgement, however small the diff looks. These are also the only paths where the
second, *refuting* lens is worth its cost.

1. **Publish / packaging** — `.pubignore`, and `pubspec.yaml`'s `environment:`
   and `version:`. A pub.dev archive **cannot be un-published**, and both
   controls have already shipped a defect: the `>=1.17.0` floor lie (#2) and the
   `.pubignore` walk that nearly shipped 87 MB of `build/*.dill`.
2. **Accessibility / semantics** — `lib/src/widget/checkbox_interaction.dart`
   and the `Semantics` wiring in both widgets. A defect here reaches the user as
   "the control cannot be operated at all", and the existing tests have twice
   passed straight through one (#4 tap-node split, #7 lost `isFocusable`).

## Step 6 — behavior-describing surfaces

- **`README.md`** — the "Why?" comparison to the built-in `Checkbox` and the
  feature list are a public contract; keep them in step with the API.
- **`CHANGELOG.md`** — **snapshotted by pub.dev at publish time.** Open a new
  version section; a correction after publish does not reach the users who
  already read it.
- **dartdoc** — the class/field docs (e.g. the `tristate` / `onChanged: null`
  contracts) ship as the pub.dev API reference.
- **`pubspec.yaml`** — the toolchain-floor manifest (`environment:`). See Step 7.
- **`example/lib/main.dart`** — ships in the package and renders on pub.dev; a
  new public field that the example never demonstrates is half-shipped.
- **`.pubignore`** — it switches pub from git-based listing to a **filesystem
  walk that ignores `.gitignore`**, so it must re-list every build/dev artifact
  `.gitignore` hides (`build/`, `.dart_tool/`, `pubspec.lock`, …) or they ship.
  Any new exclude pattern must preserve those. Verify with `flutter pub publish
  --dry-run` (0 warnings, ~24 KB archive).
- Glossary candidates for a future `CONTEXT.md`: *tristate* / *indeterminate*,
  *morph* (check ↔ dash), *hover ring*, *scale*, *checkScale*.

### Decision records — destination and what earns one

- **Destination: `docs/adr/NNNN-slug.md`**, single-context at the repo root, per
  the convention already declared in `docs/agents/domain.md`. The directory does
  not exist yet; create it with the first promotion. `.pubignore` already excludes
  `docs/`, so records never affect package size.
- **Areas that already carry a record: none — 0 accepted, 0 proposed.** Check
  this list before proposing a spine; today every area is unclaimed.
- **Record-worthy here** (areas whose decisions have already been re-litigated,
  so a promotion has somewhere obvious to land):
  - **Semantics / a11y — re-decided three times already** (0.3.0 `MergeSemantics`
    → #4 `excludeChildSemantics` on the extracted seam → #7 the lost
    `isFocusable`/focus action). This is the standing promotion candidate: the
    rule that would make *every* combination of label / labelWidget / tile /
    disabled resolvable by construction has never been written down.
  - **SDK floor policy** — decided twice in opposite directions (#2 raised it,
    0.3.1 widened it back to `>=3.27.0`).
- **Tracker parent/child: available.** GitHub sub-issues, with the `gh api`
  procedure and the task-list fallback documented in `docs/agents/issue-tracker.md`
  — so both the follow-up tree and a spine's roster have a native mechanism. No
  project-specific exception to how a spine links or where its write-back lands.

## Step 7 — gate matrix

**There is no CI.** These local gates are the only gates:

```
flutter analyze                                    # covers lib/ AND example/lib/ (verified)
dart format --output=none --set-exit-if-changed .
flutter test                                       # test/ only — 76 tests
flutter pub publish --dry-run                      # 0 warnings, on a clean tree
```

- **No blind spot in the gate matrix** — `example/` carries no tests by design
  (see the module map), and `flutter analyze` already covers `example/lib/`.
  Adding a test under `example/` re-opens the hole; add a gate line with it.
- **`flutter analyze` mutates the tree.** It resolves `./example`, which rewrites
  the tracked `example/pubspec.lock`. Check `git status` after a gate run before
  concluding you changed something.
- **The `flutter` environment floor is hand-reasoned and ungated.** Current:
  `sdk: ">=3.6.0 <4.0.0"` with `flutter: ">=3.27.0"` (widened in 0.3.1) — the
  floor is the highest API the code actually uses, `Color.withValues`, which
  landed in Flutter 3.27 / Dart 3.6. **The standing caveat when changing any SDK
  floor:** no gate catches a wrong floor — `flutter analyze` / `flutter test` use
  the *installed* SDK, and pub.dev does not build at the floor. Reconcile the
  Flutter and Dart bounds by hand against the real Dart→Flutter version mapping.
  A floor that is too *low* lets a user resolve the package and then fail to
  compile (that was #2); too *high* excludes users for nothing.
- `flutter pub publish` is irreversible (retract only) — **the agent does not run
  it; the user does.**

### Branch / PR convention

**Work branch → PR → squash merge into `main`.** With no CI and no reviewer, the
PR is the only place the diff is read as a whole, and the squash commit is the
revert unit. Run the local gates above *before* opening the PR. Link the issue
number in the PR body.

### Release judgement

**Batched, and the call is the user's.** Merges accumulate on `main`; a release
gathers several closed issues into one version bump. The agent may *propose*
"this is a good point to release" and the user may decline — proposing is not
deciding, and `flutter pub publish` is run by the user either way.

Pre-1.0 semver: a breaking change bumps `0.(x+1).0`; features and fixes bump
`0.x.(y+1)`. Open the `CHANGELOG.md` section as part of the release, not per merge.

### Downstream loop

- **Link mechanism:** a path dependency. `example/` is *permanently* linked
  (`flutter_checkbox: {path: ../}`), so the Step 4 full-suite round-trip is just
  `cd example && flutter run` — no linking step. An external consumer links with
  `dependency_overrides: {flutter_checkbox: {path: /Volumes/T7/GitHub/flutter_checkbox}}`.
- **The consumer list is not stored here** — derive it on the spot in the
  after-merge downstream loop (scan `../*/pubspec.yaml` for `flutter_checkbox`).

## War-story index

`docs/agents/lessons.md` — concrete precedents, indexed by step. Currently:

- **Step 4** — `matchesSemantics` misreads itself in this SDK; state + tap must
  share one node, and the assertion must count nodes (0.3.0, follow-up #4).
- **Step 6 / 7** — `.pubignore` silently ships what `.gitignore` hides; a probe
  with a bad filter gives a false green (0.3.0).
