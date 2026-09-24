# 0002 — The default check colour follows the fill

- **Status:** Accepted
- **Date:** 2026-09-24
- **Issues:** #13

## Decision

> **When `checkColor` is `null`, the check follows the fill. On the theme's own
> fill (`activeColor` also `null`) it is `ColorScheme.onPrimary`. On a fill the
> caller chose, it is white or black by `ThemeData.estimateBrightnessForColor`
> of that fill.**

## What it was decided on

#13 established the defect, a white check at 1.7:1 on every dark Material 3
`primary`, and proposed `onPrimary` unconditionally. Reading the issue surfaced
a case its "who notices" list left out: a caller who sets `activeColor` but not
`checkColor`. That includes this package's own `README.md` examples and
`flutter_table_plus`'s `TablePlusCheckboxTheme.colored`. For that caller,
`onPrimary` is paired with a colour the fill no longer is.

Measured WCAG contrast in a dark `fromSeed` theme, today → each option:

| fill | (a) always `onPrimary` | (b) white on any custom fill | (c) brightness estimate | (d) higher-contrast of white/black |
|---|---|---|---|---|
| theme `primary` | 1.7 → 7.7 | 7.7 | 7.7 | 7.7 |
| indigo | 6.9 → **1.9** | 6.9 | 6.9 | 6.9 |
| black | 21 → **1.6** | 21 | 21 | 21 |
| amber | 1.6 → 8.0 | **1.6** | 12.9 | 12.9 |
| blue | 3.1 → 4.2 | 3.1 | 3.1 | 6.7 |
| `primary` written out by hand | 1.7 → 7.7 | **1.7** | 12.3 | 12.3 |

- (a) is what Flutter's own M3 checkbox does. It makes the README's documented
  snippet worse.
- (b) makes nothing worse, but it treats "`activeColor` is null" as meaning "the
  fill is `primary`", and leaves light custom fills invisible.
- (c) makes nothing worse across the 23 fills measured. Mid-tones
  (blue 3.1, green 2.8) stay white, because Material's estimate leans white.
- (d) beats (c) on mid-tones, but it puts a black check on blue, red, teal and
  green, which no reference does.

The prior art was read raw: the SDK at `6655482ec06`
(`_CheckboxDefaultsM3.checkColor` returns `onPrimary` whatever the fill is),
shadcn's `checkbox.tsx` (`bg-primary` paired with `text-primary-foreground`),
and the sibling packages, none of which derives a foreground from a caller's
background. Under this repo's bindings those are examples for visuals, not a
spec.

## Amendment — the overlays follow the fill too

The first version of this record left the hover, focus and splash overlays out:
they still tinted with `primary` under a custom fill (an amber box got a
`#BAC3FF` hover tint), at 8–12% alpha with no measured legibility cost, and it
was not part of what the maintainer was first shown. Shown that as a follow-up,
the maintainer chose to fold it into the same change rather than file it. The
overlays now derive from the same fill as the box, `activeColor ?? primary`, at
their existing alphas, and so does `FlutterCheckboxTile`'s overlay, which reads
its defaults from `checkboxStyle`.

## Decision type

A **judgement**, the maintainer's, made on the table above with all four
options in front of them. It falls only to them. The mechanism (`resolve` alone,
since the top-level `activeColor` is merged into the style first) is a
derivation.

## What this record does NOT cover

- **Disabled colours.** A disabled box is dimmed by `disabledOpacity` (#5), not
  given the M3 disabled check colour.
- **A theme's own overlay colours.** The overlays follow the fill at fixed
  alphas; `ColorScheme` roles such as a state-layer colour are not consulted.
- **Mid-tone contrast.** Blue and green custom fills keep white at about 3:1. (d)
  would lift that, and was declined, not left unmeasured.
