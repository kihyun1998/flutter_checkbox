# thegraph bindings — flutter_checkbox

What a person knows that no file here answers. Appended to when a run asks the
same thing twice; never rebuilt.

## What this project is

See `CLAUDE.md` § Identity & invariants.

## References

| Source | Informs | Reached by | Binding |
|---|---|---|---|
| Flutter `material/checkbox.dart`, `checkbox_list_tile.dart` — tristate cycle, a11y flags, focus wiring, animation timing | how it works | installed SDK tree (`$FLUTTER_ROOT/packages/flutter/lib/src/`) — raw; the installed version, not the `>=3.27` floor | **spec** for semantics + keyboard activation; example for visuals, API shape and structure |
| Flutter `FocusableActionDetector`, `Actions` / `Shortcuts`, `Semantics`, `InkWell`, `CustomPainter`, `BoxDecoration` | how it works | same tree — raw | spec |
| shadcn/ui checkbox — visual defaults (border weight, radius, shadow) | how it works | `shadcn-ui/ui` GitHub tree, `apps/v4/registry/new-york-v4/ui/checkbox.tsx` — raw (ui.shadcn.com is **summarized**) | example |
| `../flutter_dropdown_button`, `../flutter_table_plus`, `../just_tooltip` — `*Style` value objects + `resolve(Theme)` | how it works | local checkouts — raw | example |
| pub.dev package API | what has shipped | `https://pub.dev/api/packages/flutter_checkbox` — raw JSON | spec |

No *where files go* source: `lib/src/<role>/` is this repo's own.
