# theflow bindings (flutter_checkbox)

Project-specific data for the `theflow` skill — module map, reference routing,
boundary rule, proof methods, surfaces, gates. The skill holds the portable
*method*; this file holds the *bindings*.

Identity lives in `CLAUDE.md`. `CONTEXT.md` / `docs/adr/` do not exist yet
(created lazily). No war-stories recorded yet — add `docs/agents/lessons.md`,
indexed by theflow step, the first time a skipped step costs something.

## Crate / module map

Single Flutter package, **no external dependencies**. Barrel
`lib/flutter_checkbox.dart` exports `FlutterCheckbox`, `FlutterCheckboxTile`,
`CheckboxStyle`, `CheckboxPosition`.

| Module (`lib/src/`) | Role | Public? |
|---|---|---|
| `widget/flutter_checkbox.dart` | the controlled checkbox — painter + animation + ring + focus/keyboard + semantics | ✅ |
| `widget/flutter_checkbox_tile.dart` | tile layout wrapping `FlutterCheckbox` with `onChanged: null` (the tile owns interaction) | ✅ |
| `widget/checkbox_label.dart` | the tile's label | internal |
| `painter/checkbox_painter.dart` | `CustomPainter` — box fill + checkmark/dash, paints at `size * scale` | internal |
| `controller/checkbox_animation.dart` | `CheckboxAnimationMixin` — `checkAnimation` (fill) + `morphAnimation` (check ↔ dash crossfade) | internal |
| `style/checkbox_style.dart` | `CheckboxStyle` (size, scale, shape, borderRadius, hoverRing*) + `resolve(Theme)` | ✅ |
| `style/checkbox_position.dart` | `CheckboxPosition` (tile) | ✅ |

## Step 1 — reference routing table

| Change type | Real source to read |
|---|---|
| **Painting** | Flutter SDK `CustomPainter` / `CustomPaint` source; `shouldRepaint` semantics |
| **Interaction** (focus / keyboard / hover) | Flutter SDK `FocusableActionDetector`, `InkWell`, `Actions`/`Shortcuts`, `Semantics` |
| **Parity / semantics** | Flutter's built-in `material/checkbox.dart` — for tristate cycle and the a11y flags (`checked`/`mixed`) it sets |
| **API introduced-in version** | `cd /d/flutter && git log -S "<sig>"` + `git tag --contains` — this repo already ships an API newer than its declared floor (Step 7) |
| **Published state** | `curl -s https://pub.dev/api/packages/flutter_checkbox` |

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

- **Widget tests** at the public seam: pump, tap / send `space`+`enter`, and
  assert `onChanged` fired with the **right next value** (cover the full tristate
  cycle). Assert the `onChanged: null` path fires nothing and shows no ring.
- **Semantics is a contract** — assert `checked` / `mixed` / `enabled` flags, not
  just the pixels. Flutter's built-in checkbox is the reference for what to set.
- **Animation** — pump through the duration; the check↔dash crossfade is
  `morphAnimation`, the fill is `checkAnimation`.
- **Painter** — `shouldRepaint` must fire on style / progress change; visuals
  have **no golden CI**, so verify by running the example.
- **Equality** (`CheckboxStyle`) — build values at runtime and assert
  `identical(a, b)` is false *first* (Dart normalizes same-arg `const` to one
  instance, so `const a == const b` passes on identity even without `operator ==`).

## Step 6 — behavior-describing surfaces

- **`README.md`** — the "Why?" comparison to the built-in `Checkbox` and the
  feature list are a public contract; keep them in step with the API.
- **`CHANGELOG.md`** — pub.dev snapshots at publish; open a new version.
- **dartdoc** — the class/field docs (e.g. the `tristate` / `onChanged: null`
  contracts) ship as the pub.dev API reference.
- **`.pubignore`** — if present, it disables git-based file listing; the pub.dev
  archive cannot be un-published.
- Glossary candidates for a future `CONTEXT.md`: *tristate* / *indeterminate*,
  *morph* (check ↔ dash), *hover ring*, *scale*.

## Step 7 — gate matrix

**There is no CI.** These local gates are the only gates:

```
flutter analyze
dart format --output=none --set-exit-if-changed .
flutter test
flutter pub publish --dry-run     # 0 warnings, on a clean tree
```

- **The `flutter` environment floor is dishonest — a real defect.**
  `pubspec.yaml` declares `flutter: ">=1.17.0"` (a `flutter create` template
  default), but `flutter_checkbox.dart` uses `Color.withValues(alpha:)`, which is
  **Flutter 3.27+**. A 1.17–3.26 user gets a compile error. The Dart floor
  (`sdk: ^3.9.2`) already implies a much newer Flutter, so the two disagree. Fix
  the floor to the real minimum (≥ 3.27, and reconcile with the Dart bound) — no
  one else catches this: `flutter analyze` uses the *installed* SDK and pub.dev
  does not build at the floor. Track it as an issue before touching it (Step 1).
- `flutter pub publish` is irreversible (retract only) — **the agent does not run
  it; the user does.**
- Adopting the fleet's agent-skills scaffold (`docs/agents/issue-tracker.md`,
  `triage-labels.md`, `domain.md`) and a CI workflow is a separate, unmade
  decision — this repo has neither yet.
