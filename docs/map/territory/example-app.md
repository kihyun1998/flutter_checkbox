# Example app

## What it is

A playground app in `example/` that renders `FlutterCheckbox` and
`FlutterCheckboxTile` with every style field on a control. It is the only place
the package is *seen*. Tests pin draw calls and semantics, not pixels, so any
visual claim is proved by running it.

## Governing decisions

**None.**

## Design model

- **A separate package, permanently linked.** `example/pubspec.yaml` depends on
  the root through `path: ../`, so `cd example && flutter run` exercises the
  working tree with no linking step.
- **No tests, on purpose.** It once had a smoke test that no gate ran. That test
  rotted red, asserting a title the app no longer rendered, and was deleted
  rather than gated. `flutter test` at the root runs `test/` only.
- **`flutter analyze` at the root does reach `example/lib`.** This was verified
  by planting a type error in it.
- **The shadow presets are shadcn/ui tokens translated**, with the layer order
  reversed from CSS. Flutter paints the first entry underneath.
- **The playground shows the derived defaults.** Active and check colours
  each have a null entry ("Theme", "Default") and a "Dark theme" switch flips
  the seed scheme's brightness, so both halves of ADR 0002 can be seen. The
  brightness lives in a top-level `_brightness` notifier.

## Code

- `example/lib/main.dart` — `PlaygroundApp`, `_brightness`,
  `_PlaygroundPageState`,
  `_buildControlsPanel`, `_buildCheckboxPreview`, `_buildTilePreview`,
  `_shadowPresets`
- `example/pubspec.yaml`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Style resolution](style-resolution.md) — a new style field is invisible
  until the playground gets a control for it.
- [Publishing](publishing.md) — `.pubignore` decides which of `example/` ships.
  pub.dev renders the Dart sources.

## Known holes / open

- `example/pubspec.yaml` declares Dart `^3.9.2`, above the package's own floor,
  so the example cannot be used to try the package at its floor.
- A test added under `example/` would not be run by any gate.
