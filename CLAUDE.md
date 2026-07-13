# CLAUDE.md

## Working discipline — theflow

Substantive changes (bug fix / feature / behavior change) follow the **`theflow`**
skill — run `/theflow` at the start. This repo's bindings (module map, reference
routing, boundary rule, proof methods, surfaces, gate matrix) live in
**`docs/agents/theflow.md`**; per-incident evidence, once any exists, in
`docs/agents/lessons.md`. Read the bindings before starting.

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

`CONTEXT.md` / `docs/adr/` do not exist yet — created lazily when a term collides
or a decision is made. There is **no CI** yet, and the `flutter` environment
floor is currently dishonest (see `docs/agents/theflow.md` Step 7).
