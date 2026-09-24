# CLAUDE.md

## Working discipline — thegraph

Substantive changes (bug fix / feature / behavior change) follow the
**`thegraph`** skill — run `/thegraph` at the start. What it reads here:
`docs/agents/thegraph.md` (the outside sources this is built against), the
territory map at `docs/map/README.md`, the decision records in `docs/adr/`, and
per-incident evidence in `docs/agents/lessons.md`.

## Identity & invariants (the boundary)

`flutter_checkbox` is two customizable checkbox widgets — **`FlutterCheckbox`**
and **`FlutterCheckboxTile`** — with tristate, a tile layout, a hover ring,
keyboard navigation, and animation, drawn with a `CustomPainter` for crisp
rendering at any size.

- **Controlled — the caller owns the state.** `value` (`bool?`; `null` =
  indeterminate, requires `tristate`) and `onChanged` belong to the caller. The
  widget **never stores** the value: it computes the next value in the cycle
  (`false → true → null → false`) and calls `onChanged`; the caller re-passes it.
- **`onChanged: null` = non-interactive** — no hover ring, no focus, no tap. The
  ring is *skipped entirely* so it consumes no layout. `FlutterCheckboxTile`
  passes `null` so the **tile is the single interaction surface** — do not
  double-wire tap.
- **The widget owns everything visual + interaction plumbing:** the painter, the
  fill + checkmark↔dash morph animation, the hover ring, focus/keyboard
  (`space`/`enter` → `ActivateIntent`), `Semantics` (`checked`/`mixed`/`enabled`),
  style resolution against `Theme`, and the tristate cycle.
- **`scale` applies to the *rendered* size** so the hit area matches the visual —
  never scale one without the other.

`CONTEXT.md` does not exist yet — created lazily when a term collides. There is
**no CI**; these local gates are the only ones:

```
flutter analyze                                   # also reaches example/lib
dart format --output=none --set-exit-if-changed .
flutter test                                      # test/ only
flutter pub publish --dry-run                     # 0 warnings, on a clean tree
python3 scripts/check_map.py --selftest && python3 scripts/check_map.py
```

The SDK floor is hand-reasoned because nothing checks it — see
`docs/map/territory/publishing.md`.

## Comments

A comment says what the code is. Why it is this way, what it deliberately leaves
out, the trap and the measured value go to the territory note under `docs/map/`;
history goes to the commit message. Comments written before this rule still carry
the rest: never delete one whose content the map does not yet hold — move it
first (`decant`).

## Changes and releases

- Work branch → PR → squash merge into `main`. Run the gates before opening the
  PR, and link the issue in its body.
- A merge that changes behaviour adds its `CHANGELOG.md` entry under the open
  next-version section, opening one if there is none.
- Releases are batched and the call is the maintainer's. An agent may propose
  one; **`flutter pub publish` is run by the maintainer, never by an agent.**
- Pre-1.0 semver: breaking → `0.(x+1).0`; features and fixes → `0.x.(y+1)`.
- Consumers: derive them by scanning `../*/pubspec.yaml` for `flutter_checkbox`;
  link one with `dependency_overrides: {flutter_checkbox: {path: <this repo>}}`.

## Agent skills

### Issue tracker

Issues and PRDs live as GitHub issues (`gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical triage roles, label strings equal to their names. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` + `docs/adr/` at the repo root (created lazily). See `docs/agents/domain.md`.
