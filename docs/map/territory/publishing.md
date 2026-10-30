# Publishing

## What it is

What reaches pub.dev, and the checks that stand in front of it: the declared SDK
floor, the file list `.pubignore` lets through, the `README.md` and
`CHANGELOG.md` that pub.dev renders, and the local gates. There is no CI. An
archive cannot be un-published, only retracted, so nothing here is fixed after
the fact.

## Governing decisions

**None.** The SDK floor policy has been decided twice in opposite directions.
b82ffc3 (#2) raised `flutter` to `>=3.35.0`, and 0383573 (0.3.1) widened it back
to `>=3.27.0`. Neither is a record. The policy the second one chose is stated in
the `pubspec.yaml` comment beside the floor.

## Design model

- **The floor is the newest framework API the code calls**, not the SDK it was
  built with. Today that is `Color.withValues`. Any territory that calls a newer
  API moves the floor, and nothing tells it so.
- **A `.pubignore` switches pub to walking the file system**, which stops it
  honouring `.gitignore`. Every build artefact `.gitignore` hides has to be listed
  again, or it ships. It nearly shipped 87 MB of `build/*.dill` in 0.3.0. The
  file's own header comment says so too.
- Before a release, run `pub-ready`.
- **Doc comments ship.** dartdoc renders them as the pub.dev API reference, so
  a doc comment that describes old behaviour is a published contract.
- **Pre-1.0 semver.** Breaking → `0.(x+1).0`; features and fixes →
  `0.x.(y+1)`.
- **Consumers are derived, not listed.** Scan `../*/pubspec.yaml` for
  `flutter_checkbox`; link one with
  `dependency_overrides: {flutter_checkbox: {path: <this repo>}}`.
- **The `README.md` install snippet pins a version.** It belongs to the release
  bump, not to the change that adds a feature. It sat at `^0.3.1` through the
  whole 0.3.2 cycle (#12).
- **Dependabot watches the root `pubspec.yaml` only** (`.github/dependabot.yml`,
  #17). The only dependency it can raise is the dev `flutter_lints`. It uses
  `increase-if-necessary`, and the root commits no lockfile, so a PR opens only
  when a release falls outside the caret. At `0.x` every minor release does. So
  each PR is a floor decision for consumers, not a chore. The PRs stay one per
  dependency so that each one is a single release decision. There is no
  `github-actions` entry because the repo has no workflow. `needs-triage` is
  applied because the repo already has that label. Two values are the
  maintainer's call, and only the maintainer can reverse them (#17 confirm,
  2026-10-26):
  - **Root only, no `/example` entry.** They were shown the siblings'
    grouped monthly `/example` entry and the tracked `example/pubspec.lock`.
    So nothing watches `example/` dependencies (`cupertino_icons`, its
    `flutter_lints`).
  - **`weekly`, overriding the issue's `monthly`.** They were shown that all six
    sibling-chain packages run their root on `weekly`.
- **Dot-directories never ship, `.pubignore` or not.** pub's built-in ignore
  rules start with `.*` (`_basicIgnoreRules` in `dart-lang/pub`
  `lib/src/package.dart`, read 2026-10-26). So `.github/` needs no `.pubignore`
  line. Measured during #17: with `.github/dependabot.yml` present,
  `flutter pub publish --dry-run` listed no `.github/`.

## Code

- `pubspec.yaml` — `environment`, `version`, `dev_dependencies`
- `.pubignore`
- `.github/dependabot.yml`
- `README.md`, `CHANGELOG.md`
- the gate commands: `flutter analyze`, `dart format`, `flutter test`,
  `flutter pub publish --dry-run`

## Reference behaviour

**None.** The floor was reasoned from the SDK checkout's history (`git log -S` on
the API, then `git tag --contains`), not recorded against a pinned revision.

## Cross-cutting invariants

**None.**

## Blast radius

- [Style resolution](style-resolution.md) — `README.md` documents every
  `CheckboxStyle` field. A field added or renamed there is a README change here.
- [Example app](example-app.md) — `.pubignore` keeps `example/lib` and drops
  the platform scaffolding. A new file under `example/` needs a decision about
  whether it ships.

## Known holes / open

- **No gate checks the floor.** `flutter analyze` and `flutter test` run on the
  installed SDK, and pub.dev does not build at the floor. A floor that is too
  low compiles for no one below the real minimum (#2). One that is too high turns
  users away for nothing (0.3.1).
- **Nothing checks the `README.md` version pin** against `pubspec.yaml`.
- **`flutter analyze` rewrites the tracked `example/pubspec.lock`**, because it
  resolves `./example`. A gate run leaves a diff that nobody wrote.
- **`dart format` was red on `main` under a newer SDK** (5 files, recorded
  during #8). That was a formatter version drift, not code.
- **A Dependabot config error shows only on GitHub.** The schema check catches
  shape errors. Whether it runs at all shows only in the repo's Dependabot
  status after the merge.
