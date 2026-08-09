import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_checkbox/flutter_checkbox.dart';
// Internal import: the resolved style lives on the painter, which is the
// structural seam these parity tests assert against (not part of the barrel).
import 'package:flutter_checkbox/src/painter/checkbox_painter.dart';

/// Reads the merged semantics data for [finder].
///
/// Assert flags/actions off this directly rather than via `matchesSemantics`,
/// which throws inside its own describeMismatch on any mismatch in this SDK.
SemanticsData semanticsOf(WidgetTester tester, Finder finder) =>
    tester.getSemantics(finder).getSemanticsData();

/// Counts how many semantics nodes under [finder] carry a tap action.
///
/// The a11y contract is exactly one — the checked state and the tap must sit on
/// a single node. `getSemantics(...).hasAction(tap)` alone does NOT catch a
/// split (it only checks the found node), so count them.
///
/// Counts only nodes the engine actually **ships**. A node with
/// `isMergedIntoParent` is folded into its parent's data and never reaches the
/// platform, so counting it reports a split that no screen reader can observe —
/// which would reject `MergeSemantics`, the framework's own way of collapsing a
/// control. Stop at `mergeAllDescendantsIntoThisNode` for the same reason.
int tapNodeCount(WidgetTester tester, Finder finder) {
  int walk(SemanticsNode n) {
    if (n.isMergedIntoParent) return 0;
    var c = n.getSemanticsData().hasAction(SemanticsAction.tap) ? 1 : 0;
    if (n.mergeAllDescendantsIntoThisNode) return c;
    n.visitChildren((child) {
      c += walk(child);
      return true;
    });
    return c;
  }

  return walk(tester.getSemantics(finder));
}

/// Counts the keyboard focus stops **inside** [finder].
///
/// The contract is one stop per control. Nothing in the semantics tree can see
/// this: a second focus node nested under the first still resolves the same
/// `Shortcuts`, so space/enter keep working and the ring keeps lighting — the
/// only visible symptom is that Tab stops twice on one checkbox. Walk the real
/// [FocusManager] tree instead, restricted to elements under [finder].
int focusStopCount(WidgetTester tester, Finder finder) {
  final root = tester.element(finder);
  final subtree = <Element>{};
  void collect(Element e) {
    subtree.add(e);
    e.visitChildren(collect);
  }

  collect(root);

  var n = 0;
  void walk(FocusNode f) {
    final ctx = f.context;
    if (f.canRequestFocus &&
        !f.skipTraversal &&
        ctx is Element &&
        subtree.contains(ctx)) {
      n++;
    }
    for (final child in f.children) {
      walk(child);
    }
  }

  for (final child in FocusScope.of(root).children) {
    walk(child);
  }
  return n;
}

/// Whether the node declares focusability.
///
/// Derived, not a flag: `isFocusable` is `isFocused != Tristate.none`, so a node
/// that declares no focused state at all is not focusable.
bool declaresFocusable(SemanticsData d) =>
    d.flagsCollection.isFocused != Tristate.none;

Widget buildApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

/// A single opaque shadow — opaque so `paints..rrect(color:)` can identify it.
const kShadow = [
  BoxShadow(color: Color(0xFF123456), offset: Offset(0, 1), blurRadius: 2),
];

/// The rounded rect the shadow of a default-styled box must be cast from.
///
/// The border stroke is *centred* on the inset rect, so the box's outer visual
/// edge is the full rect with a radius of `borderRadius + borderWidth / 2` —
/// not `borderRadius`. Stated independently of the implementation on purpose.
RRect shadowRRectFor(
  Rect box, {
  required double borderRadius,
  required double borderWidth,
  Offset offset = Offset.zero,
  double spread = 0,
}) =>
    RRect.fromRectAndRadius(
      box.shift(offset).inflate(spread),
      Radius.circular(borderRadius + borderWidth / 2),
    );

Finder findCheckboxPaint() {
  return find.descendant(
    of: find.byType(FlutterCheckbox),
    matching: find.byType(CustomPaint),
  );
}

/// Reads the resolved [CheckboxStyle] off the rendered painter.
CheckboxStyle resolvedStyle(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(findCheckboxPaint());
  return (paint.painter as CheckboxPainter).style;
}

void main() {
  // ── FlutterCheckbox ────────────────────────────────────────────────────────

  group('FlutterCheckbox / Rendering', () {
    testWidgets('renders without label', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: false, onChanged: (_) {})),
      );

      expect(find.byType(FlutterCheckbox), findsOneWidget);
      expect(findCheckboxPaint(), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });
  });

  group('FlutterCheckbox / Size', () {
    testWidgets('default size is 24', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: false, onChanged: (_) {})),
      );

      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(24));
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: false,
            style: const CheckboxStyle(size: 48),
            onChanged: (_) {},
          ),
        ),
      );

      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(48));
    });

    testWidgets('small size renders correctly', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            style: const CheckboxStyle(size: 12),
            onChanged: (_) {},
          ),
        ),
      );

      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(12));
    });

    testWidgets('large size renders correctly', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            style: const CheckboxStyle(size: 80),
            onChanged: (_) {},
          ),
        ),
      );

      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(80));
    });
  });

  group('FlutterCheckbox / Interaction', () {
    testWidgets('tap toggles false → true', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckbox(
                value: value,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pump();
      expect(value, true);
    });

    testWidgets('tap toggles true → false', (tester) async {
      bool? value = true;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckbox(
                value: value,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pump();
      expect(value, false);
    });

    testWidgets('disabled ignores tap', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: value,
            enabled: false,
            onChanged: (v) => value = v,
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pump();
      expect(value, false);
    });

    testWidgets('null onChanged makes checkbox non-interactive', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const FlutterCheckbox(value: false)));
      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pump();
    });
  });

  group('FlutterCheckbox / Tristate', () {
    testWidgets('tristate cycles false → true → null → false', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckbox(
                value: value,
                tristate: true,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pump();
      expect(value, true);

      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pump();
      expect(value, null);

      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pump();
      expect(value, false);
    });

    testWidgets('renders indeterminate state without error', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(value: null, tristate: true, onChanged: (_) {}),
        ),
      );

      await tester.pumpAndSettle();
      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('assert fires when value is null and tristate is false', (
      tester,
    ) async {
      expect(
        () => FlutterCheckbox(value: null, onChanged: (_) {}),
        throwsAssertionError,
      );
    });
  });

  group('FlutterCheckbox / Animation', () {
    testWidgets('animation runs on value change', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckbox(
                value: value,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pump(const Duration(milliseconds: 100));
      expect(findCheckboxPaint(), findsOneWidget);

      await tester.pumpAndSettle();
      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('reverse animation on uncheck', (tester) async {
      bool? value = true;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckbox(
                value: value,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pumpAndSettle();
      expect(value, false);
    });

    // Drive each tristate transition directly by re-pumping with a new value,
    // exercising every branch of CheckboxAnimationMixin.updateCheckAnimation.
    testWidgets('animates false → null (fill + morph forward)', (tester) async {
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: false, tristate: true)),
      );
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: null, tristate: true)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('animates null → true (morph reverse)', (tester) async {
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: null, tristate: true)),
      );
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: true, tristate: true)),
      );
      await tester.pumpAndSettle();
      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('animates null → false (fill out, then resets morph)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: null, tristate: true)),
      );
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: false, tristate: true)),
      );
      // Settle so the fill controller dismisses and _resetMorphOnDismiss fires.
      await tester.pumpAndSettle();
      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('morph animation runs on true → null transition', (
      tester,
    ) async {
      bool? value = true;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckbox(
                value: value,
                tristate: true,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckbox));
      await tester.pump(const Duration(milliseconds: 75));
      expect(findCheckboxPaint(), findsOneWidget);

      await tester.pumpAndSettle();
      expect(value, null);
    });
  });

  group('FlutterCheckbox / Style', () {
    testWidgets('applies custom colors without error', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            style: const CheckboxStyle(
              activeColor: Colors.red,
              checkColor: Colors.yellow,
              borderColor: Colors.blue,
              inactiveColor: Colors.grey,
            ),
            onChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('applies custom border radius and width', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: false,
            style: const CheckboxStyle(borderRadius: 12, borderWidth: 3),
            onChanged: (_) {},
          ),
        ),
      );

      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('checkScale flows to the painter', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            style: const CheckboxStyle(checkScale: 0.5),
            onChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(resolvedStyle(tester).checkScale, 0.5);
    });

    testWidgets('circle shape renders correctly', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            style: const CheckboxStyle(shape: CheckboxShape.circle, size: 30),
            onChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(30));
    });
  });

  group('FlutterCheckbox / Shadow', () {
    testWidgets('shadows flow to the painter', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const FlutterCheckbox(
              value: false, style: CheckboxStyle(shadows: kShadow)),
        ),
      );
      expect(resolvedStyle(tester).shadows, kShadow);
    });

    testWidgets('casts from the box outer edge, under the box', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const FlutterCheckbox(
              value: false, style: CheckboxStyle(shadows: kShadow)),
        ),
      );

      // Default style: 24 box, borderWidth 2, borderRadius 4.
      final expected = shadowRRectFor(
        const Rect.fromLTWH(0, 0, 24, 24),
        borderRadius: 4,
        borderWidth: 2,
        offset: const Offset(0, 1),
      );

      expect(
        findCheckboxPaint(),
        paints
          // the shadow, first — so the box lands on top of it
          ..rrect(rrect: expected, color: const Color(0xFF123456))
          // then the box fill, on the inset rect at the unadjusted radius
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              const Rect.fromLTWH(1, 1, 22, 22),
              const Radius.circular(4),
            ),
          ),
      );
    });

    testWidgets('circle shape casts a circle', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const FlutterCheckbox(
            value: false,
            style: CheckboxStyle(shape: CheckboxShape.circle, shadows: kShadow),
          ),
        ),
      );

      // Outer edge of a stroked circle = the full rect's inscribed circle.
      expect(
        findCheckboxPaint(),
        paints
          ..circle(x: 12, y: 13, radius: 12, color: const Color(0xFF123456)),
      );
    });

    testWidgets('scale does not scale the shadow', (tester) async {
      // `scale` multiplies the box footprint only — borderWidth, borderRadius
      // and checkStrokeWidth are all unscaled, and the shadow follows them.
      await tester.pumpWidget(
        buildApp(
          const FlutterCheckbox(
            value: false,
            style: CheckboxStyle(scale: 2, shadows: kShadow),
          ),
        ),
      );

      expect(
        findCheckboxPaint(),
        paints
          ..rrect(
            rrect: shadowRRectFor(
              const Rect.fromLTWH(0, 0, 48, 48),
              borderRadius: 4,
              borderWidth: 2,
              offset: const Offset(0, 1), // NOT (0, 2)
            ),
            color: const Color(0xFF123456),
          ),
      );
    });

    testWidgets('offset and spreadRadius are honoured', (tester) async {
      const shadow = [
        BoxShadow(
          color: Color(0xFF00FF00),
          offset: Offset(3, -2),
          spreadRadius: 5,
        ),
      ];
      await tester.pumpWidget(
        buildApp(
          const FlutterCheckbox(
              value: false, style: CheckboxStyle(shadows: shadow)),
        ),
      );

      expect(
        findCheckboxPaint(),
        paints
          ..rrect(
            rrect: shadowRRectFor(
              const Rect.fromLTWH(0, 0, 24, 24),
              borderRadius: 4,
              borderWidth: 2,
              offset: const Offset(3, -2),
              spread: 5,
            ),
            color: const Color(0xFF00FF00),
          ),
      );
    });

    testWidgets('multiple shadows paint first-listed underneath', (
      tester,
    ) async {
      const shadows = [
        BoxShadow(color: Color(0xFF111111), blurRadius: 1),
        BoxShadow(color: Color(0xFF222222), blurRadius: 8),
      ];
      await tester.pumpWidget(
        buildApp(
          const FlutterCheckbox(
            value: false,
            style: CheckboxStyle(shadows: shadows),
          ),
        ),
      );

      expect(
        findCheckboxPaint(),
        paints
          ..rrect(color: const Color(0xFF111111))
          ..rrect(color: const Color(0xFF222222)),
      );
    });

    testWidgets('null shadows paint nothing extra', (tester) async {
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: false)),
      );

      // The very first rrect is the box fill, not a shadow.
      expect(
        findCheckboxPaint(),
        paints
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              const Rect.fromLTWH(1, 1, 22, 22),
              const Radius.circular(4),
            ),
          ),
      );
    });

    testWidgets('BlurStyle.outer stays clipped when shadows are disabled', (
      tester,
    ) async {
      // debugDisableShadows (on by default in flutter_test) drops the mask
      // filter, which would turn an `outer` shadow into a solid fill *over* the
      // checkbox. The guard is a clipRect — without it every consumer's own
      // widget tests would render an opaque block.
      expect(debugDisableShadows, isTrue);
      await tester.pumpWidget(
        buildApp(
          const FlutterCheckbox(
            value: false,
            style: CheckboxStyle(
              shadows: [
                BoxShadow(
                  color: Color(0xFF123456),
                  blurRadius: 6,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        findCheckboxPaint(),
        paints
          ..clipRect(rect: const Rect.fromLTWH(0, 0, 24, 24))
          ..rrect(color: const Color(0xFF123456)),
      );
    });

    testWidgets('really blurs when shadows are enabled', (tester) async {
      // Restored in the body, not a tearDown: the binding asserts painting
      // debug vars are unset *before* tearDown callbacks run.
      debugDisableShadows = false;
      try {
        await tester.pumpWidget(
          buildApp(
            const FlutterCheckbox(
              value: false,
              style: CheckboxStyle(shadows: kShadow),
            ),
          ),
        );

        expect(
          findCheckboxPaint(),
          paints..rrect(color: const Color(0xFF123456), hasMaskFilter: true),
        );
      } finally {
        debugDisableShadows = true;
      }
    });

    testWidgets('the tile forwards shadows to its checkbox', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const FlutterCheckboxTile(
            value: false,
            label: 'Accept',
            checkboxStyle: CheckboxStyle(shadows: kShadow),
          ),
        ),
      );
      expect(resolvedStyle(tester).shadows, kShadow);
      expect(
        findCheckboxPaint(),
        paints..rrect(color: const Color(0xFF123456)),
      );
    });
  });

  group('FlutterCheckbox / Flutter API parity', () {
    testWidgets('top-level activeColor overrides style.activeColor', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            activeColor: Colors.red,
            style: const CheckboxStyle(activeColor: Colors.blue),
            onChanged: (_) {},
          ),
        ),
      );

      // Precedence, not merge: the top-level param wins over the style's.
      expect(resolvedStyle(tester).activeColor, Colors.red);
    });

    testWidgets('top-level checkColor overrides style.checkColor', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            checkColor: Colors.black,
            style: const CheckboxStyle(checkColor: Colors.yellow),
            onChanged: (_) {},
          ),
        ),
      );

      expect(resolvedStyle(tester).checkColor, Colors.black);
    });

    testWidgets('falls back to style color when no top-level override', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            style: const CheckboxStyle(activeColor: Colors.green),
            onChanged: (_) {},
          ),
        ),
      );

      expect(resolvedStyle(tester).activeColor, Colors.green);
    });

    testWidgets('falls back to theme when neither is set', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: true, onChanged: (_) {})),
      );

      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: FlutterCheckbox(value: true, onChanged: (_) {}),
            ),
          ),
        ),
      );
      expect(resolvedStyle(tester).activeColor, theme.colorScheme.primary);
    });

    testWidgets('semanticLabel is exposed to accessibility', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            semanticLabel: 'Accept terms',
            onChanged: (_) {},
          ),
        ),
      );

      // Assert the label directly off the node — `matchesSemantics` crashes on
      // any mismatch in this SDK (its describeMismatch casts a null failure).
      final node = tester.getSemantics(find.byType(FlutterCheckbox));
      expect(node.label, 'Accept terms');
    });

    testWidgets('top-level color updates on rebuild', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            activeColor: Colors.red,
            onChanged: (_) {},
          ),
        ),
      );
      expect(resolvedStyle(tester).activeColor, Colors.red);

      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            activeColor: Colors.purple,
            onChanged: (_) {},
          ),
        ),
      );
      // didUpdateWidget must re-resolve when the top-level color changes.
      expect(resolvedStyle(tester).activeColor, Colors.purple);
    });
  });

  group('FlutterCheckbox / Disabled state', () {
    testWidgets('renders with reduced opacity', (tester) async {
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: false, enabled: false)),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.4);
    });

    testWidgets('enabled renders full opacity', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: false, onChanged: (_) {})),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1.0);
    });
  });

  group('FlutterCheckbox / Accessibility', () {
    testWidgets('Semantics when checked exposes state + tap on one node', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: true, onChanged: (_) {})),
      );

      // The checked state and the tap action must live on the SAME node, or a
      // screen reader sees "checked" and "tappable" as two disjoint elements.
      final d = semanticsOf(tester, find.byType(FlutterCheckbox));
      expect(d.flagsCollection.isChecked, CheckedState.isTrue);
      expect(d.flagsCollection.isEnabled, Tristate.isTrue);
      expect(d.hasAction(SemanticsAction.tap), isTrue);
    });

    testWidgets('exposes exactly one tap node (no split)', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: true, onChanged: (_) {})),
      );
      expect(tapNodeCount(tester, find.byType(FlutterCheckbox)), 1);
    });

    testWidgets('Semantics when unchecked', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: false, onChanged: (_) {})),
      );

      final d = semanticsOf(tester, find.byType(FlutterCheckbox));
      expect(d.flagsCollection.isChecked, CheckedState.isFalse);
      expect(d.flagsCollection.isEnabled, Tristate.isTrue);
      expect(d.hasAction(SemanticsAction.tap), isTrue);
    });

    testWidgets('Semantics reflects disabled state', (tester) async {
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: false, enabled: false)),
      );

      final d = semanticsOf(tester, find.byType(FlutterCheckbox));
      expect(d.flagsCollection.isEnabled, Tristate.isFalse);
      // A disabled checkbox must not advertise a tap action.
      expect(d.hasAction(SemanticsAction.tap), isFalse);
    });

    testWidgets('Semantics mixed flag for indeterminate', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(value: null, tristate: true, onChanged: (_) {}),
        ),
      );

      final d = semanticsOf(tester, find.byType(FlutterCheckbox));
      expect(d.flagsCollection.isChecked, CheckedState.mixed);
    });
  });

  // One node to assistive tech, one stop to the keyboard — for every
  // construction. See docs/adr/0001-one-node-one-focus.md.
  group('A11y contract / one node', () {
    testWidgets('checkbox is focusable and exposes the focus action', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: true,
            onChanged: (_) {},
            semanticLabel: 'Accept',
          ),
        ),
      );

      final d = semanticsOf(tester, find.byType(FlutterCheckbox));
      expect(d.label, 'Accept');
      expect(declaresFocusable(d), isTrue);
      expect(d.hasAction(SemanticsAction.focus), isTrue);
      expect(tapNodeCount(tester, find.byType(FlutterCheckbox)), 1);
    });

    testWidgets('a bare checkbox is focusable too', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: true, onChanged: (_) {})),
      );
      final d = semanticsOf(tester, find.byType(FlutterCheckbox));
      expect(declaresFocusable(d), isTrue);
      expect(d.hasAction(SemanticsAction.focus), isTrue);
    });

    testWidgets('a disabled checkbox is neither focusable nor tappable', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(value: true, onChanged: (_) {}, enabled: false),
        ),
      );
      final d = semanticsOf(tester, find.byType(FlutterCheckbox));
      expect(declaresFocusable(d), isFalse);
      expect(d.hasAction(SemanticsAction.focus), isFalse);
      expect(d.hasAction(SemanticsAction.tap), isFalse);
    });

    testWidgets('an unlabelled tile is one node, not two', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckboxTile(value: true, onChanged: (_) {})),
      );
      expect(tapNodeCount(tester, find.byType(FlutterCheckboxTile)), 1);
      final d = semanticsOf(tester, find.byType(FlutterCheckboxTile));
      expect(declaresFocusable(d), isTrue);
    });

    testWidgets('a labelWidget tile is one node and the widget names it', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: true,
            onChanged: (_) {},
            labelWidget: const Text('Accept terms'),
          ),
        ),
      );
      expect(tapNodeCount(tester, find.byType(FlutterCheckboxTile)), 1);
      final d = semanticsOf(tester, find.byType(FlutterCheckboxTile));
      expect(d.label, contains('Accept terms'));
      expect(declaresFocusable(d), isTrue);
    });

    testWidgets('a subtitle is announced, not dropped', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: true,
            onChanged: (_) {},
            label: 'Accept',
            subtitle: 'terms and conditions',
          ),
        ),
      );
      final d = semanticsOf(tester, find.byType(FlutterCheckboxTile));
      // Visible text inside the control must reach assistive tech.
      expect(d.label, contains('Accept'));
      expect(d.label, contains('terms and conditions'));
      // ...and exactly once. The tile renders its name, so declaring it as a
      // semanticLabel too makes absorb concatenate it twice ("Accept Accept
      // terms and conditions"), which `contains` alone would not catch.
      expect(
        RegExp('Accept').allMatches(d.label).length,
        1,
        reason: 'the name must not be announced twice',
      );
      expect(tapNodeCount(tester, find.byType(FlutterCheckboxTile)), 1);
    });
  });

  group('A11y contract / one focus stop', () {
    testWidgets('a checkbox is a single Tab stop', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: true, onChanged: (_) {})),
      );
      expect(focusStopCount(tester, find.byType(FlutterCheckbox)), 1);
    });

    testWidgets('a tile is a single Tab stop', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(value: true, onChanged: (_) {}, label: 'A'),
        ),
      );
      expect(focusStopCount(tester, find.byType(FlutterCheckboxTile)), 1);
    });

    testWidgets('a tile accepts a caller FocusNode without reparenting it', (
      tester,
    ) async {
      // Regression: the tile used to hand the SAME node to both its own
      // FocusableActionDetector and the InkWell's internal Focus, which threw
      // 'child != this' and left the control unactivatable by keyboard.
      final node = FocusNode();
      addTearDown(node.dispose);
      bool? value = false;

      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) => FlutterCheckboxTile(
              value: value,
              label: 'Accept',
              focusNode: node,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );

      // Fixed-count pumps, never pumpAndSettle: while this is red the focus
      // tree is left inconsistent and settling would spin forever.
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      // Drain every pending exception, not just the first — the reparenting
      // assertion fires on each rebuild, and anything left behind is reported
      // against whichever test runs next.
      final errors = <Object>[];
      for (Object? e = tester.takeException();
          e != null;
          e = tester.takeException()) {
        errors.add(e);
      }

      expect(errors, isEmpty,
          reason: 'a caller FocusNode must not be reparented');
      expect(value, isTrue, reason: 'keyboard activation must still work');
    });
  });

  group('FlutterCheckbox / Focus & Keyboard', () {
    testWidgets('Space key toggles checkbox', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckbox(
                value: value,
                autofocus: true,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(value, true);
    });

    testWidgets('Enter key toggles checkbox', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckbox(
                value: value,
                autofocus: true,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, true);
    });

    testWidgets('disabled ignores keyboard', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(
            value: value,
            enabled: false,
            onChanged: (v) => value = v,
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(value, false);
    });

    testWidgets('accepts custom FocusNode', (tester) async {
      final focusNode = FocusNode();
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckbox(
                value: value,
                focusNode: focusNode,
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(value, true);

      focusNode.dispose();
    });
  });

  // ── FlutterCheckboxTile ────────────────────────────────────────────────────

  group('FlutterCheckboxTile / Rendering', () {
    testWidgets('renders with text label', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(value: false, label: 'Agree', onChanged: (_) {}),
        ),
      );

      expect(find.text('Agree'), findsOneWidget);
    });

    testWidgets('renders with custom label widget', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: false,
            labelWidget: const Icon(Icons.star),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: false,
            label: 'Main',
            subtitle: 'Sub',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Sub'), findsOneWidget);
    });
  });

  group('FlutterCheckboxTile / Interaction', () {
    testWidgets('tap toggles value', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckboxTile(
                value: value,
                label: 'Click me',
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckboxTile));
      await tester.pump();
      expect(value, true);
    });

    testWidgets('tapping label also toggles', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckboxTile(
                value: value,
                label: 'Click me',
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Click me'));
      await tester.pump();
      expect(value, true);
    });

    testWidgets('disabled tile ignores tap', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: value,
            label: 'Disabled',
            enabled: false,
            onChanged: (v) => value = v,
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckboxTile));
      await tester.pump();
      expect(value, false);
    });
  });

  group('FlutterCheckboxTile / Tristate', () {
    testWidgets('tristate cycles correctly', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        buildApp(
          StatefulBuilder(
            builder: (context, setState) {
              return FlutterCheckboxTile(
                value: value,
                tristate: true,
                label: 'Tristate',
                onChanged: (v) => setState(() => value = v),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(FlutterCheckboxTile));
      await tester.pump();
      expect(value, true);

      await tester.tap(find.byType(FlutterCheckboxTile));
      await tester.pump();
      expect(value, null);

      await tester.tap(find.byType(FlutterCheckboxTile));
      await tester.pump();
      expect(value, false);
    });

    testWidgets('assert fires when value is null and tristate is false', (
      tester,
    ) async {
      expect(
        () => FlutterCheckboxTile(value: null, label: 'x', onChanged: (_) {}),
        throwsAssertionError,
      );
    });
  });

  group('FlutterCheckboxTile / Layout', () {
    testWidgets('custom gap is respected', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: false,
            label: 'Gap test',
            gap: 20,
            onChanged: (_) {},
          ),
        ),
      );

      final sizedBoxes = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(FlutterCheckboxTile),
              matching: find.byType(SizedBox),
            ),
          )
          .where((sb) => sb.width == 20);
      expect(sizedBoxes.length, 1);
    });

    testWidgets('checkboxPosition end places checkbox after label', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: false,
            label: 'End',
            checkboxPosition: CheckboxPosition.end,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(FlutterCheckboxTile), findsOneWidget);
    });
  });

  group('FlutterCheckboxTile / Chrome', () {
    testWidgets('elevation renders a raised Material', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: false,
            label: 'Elevated',
            elevation: 4,
            onChanged: (_) {},
          ),
        ),
      );

      final materials = tester.widgetList<Material>(find.byType(Material));
      expect(materials.any((m) => m.elevation == 4), isTrue);
    });

    testWidgets('margin wraps the tile in padding', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: false,
            label: 'Margined',
            margin: const EdgeInsets.all(11),
            onChanged: (_) {},
          ),
        ),
      );

      final paddings = tester.widgetList<Padding>(
        find.descendant(
          of: find.byType(FlutterCheckboxTile),
          matching: find.byType(Padding),
        ),
      );
      expect(
        paddings.any((p) => p.padding == const EdgeInsets.all(11)),
        isTrue,
      );
    });

    testWidgets('tileBorderSide renders without error', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(
            value: false,
            label: 'Bordered',
            tileBorderSide: const BorderSide(color: Colors.red, width: 2),
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.byType(FlutterCheckboxTile), findsOneWidget);
    });

    testWidgets('disabled tile still renders its subtitle', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const FlutterCheckboxTile(
            value: false,
            label: 'Main',
            subtitle: 'Sub',
            enabled: false,
          ),
        ),
      );

      expect(find.text('Sub'), findsOneWidget);
    });
  });

  group('FlutterCheckboxTile / Accessibility', () {
    testWidgets('Semantics exposes label, state and tap on one node', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(value: true, label: 'Agree', onChanged: (_) {}),
        ),
      );

      // A labelled tile must remain activatable by assistive tech — the tap
      // action has to sit on the same node as the label and checked state.
      final d = semanticsOf(tester, find.byType(FlutterCheckboxTile));
      expect(d.label, 'Agree');
      expect(d.flagsCollection.isChecked, CheckedState.isTrue);
      expect(d.hasAction(SemanticsAction.tap), isTrue);
      expect(tapNodeCount(tester, find.byType(FlutterCheckboxTile)), 1);
    });
  });

  // ── CheckboxStyle ──────────────────────────────────────────────────────────

  group('CheckboxStyle', () {
    test('resolve fills null colors from theme', () {
      final theme = ThemeData.light();
      const style = CheckboxStyle();
      final resolved = style.resolve(theme);

      expect(resolved.activeColor, theme.colorScheme.primary);
      expect(resolved.checkColor, Colors.white);
      expect(resolved.borderColor, theme.colorScheme.outline);
      expect(resolved.inactiveColor, Colors.transparent);
    });

    test('resolve preserves explicit colors', () {
      final theme = ThemeData.light();
      const style = CheckboxStyle(
        activeColor: Colors.red,
        checkColor: Colors.yellow,
      );
      final resolved = style.resolve(theme);

      expect(resolved.activeColor, Colors.red);
      expect(resolved.checkColor, Colors.yellow);
    });

    test('copyWith overrides only the given fields', () {
      const style = CheckboxStyle(activeColor: Colors.red, size: 30);
      final copy = style.copyWith(checkColor: Colors.blue);

      expect(copy.checkColor, Colors.blue);
      expect(copy.activeColor, Colors.red); // untouched
      expect(copy.size, 30); // untouched
    });

    test('resolve fills overlay colors from theme', () {
      final theme = ThemeData.light();
      final p = theme.colorScheme.primary;
      final resolved = const CheckboxStyle().resolve(theme);

      expect(resolved.hoverColor, p.withValues(alpha: 0.08));
      expect(resolved.focusColor, p.withValues(alpha: 0.12));
      expect(resolved.splashColor, p.withValues(alpha: 0.12));
    });

    test('resolve preserves explicit overlay colors', () {
      final resolved = const CheckboxStyle(
        hoverColor: Color(0xFF00FF00),
        splashColor: Color(0xFF0000FF),
      ).resolve(ThemeData.light());

      expect(resolved.hoverColor, const Color(0xFF00FF00));
      expect(resolved.splashColor, const Color(0xFF0000FF));
    });

    test('disabledOpacity defaults to 0.4 and is overridable', () {
      expect(const CheckboxStyle().disabledOpacity, 0.4);
      expect(const CheckboxStyle(disabledOpacity: 0.6).disabledOpacity, 0.6);
      expect(
        const CheckboxStyle().copyWith(disabledOpacity: 0.5).disabledOpacity,
        0.5,
      );
    });

    test('checkScale defaults to 1.0 and is overridable', () {
      expect(const CheckboxStyle().checkScale, 1.0);
      expect(const CheckboxStyle(checkScale: 0.7).checkScale, 0.7);
      expect(const CheckboxStyle().copyWith(checkScale: 1.3).checkScale, 1.3);
    });

    test('resolve preserves checkScale', () {
      final resolved = const CheckboxStyle(
        checkScale: 0.6,
      ).resolve(ThemeData.light());
      expect(resolved.checkScale, 0.6);
    });

    test('shadows default to null and are overridable', () {
      expect(const CheckboxStyle().shadows, isNull);
      expect(const CheckboxStyle(shadows: kShadow).shadows, kShadow);
      expect(const CheckboxStyle().copyWith(shadows: kShadow).shadows, kShadow);
    });

    test('resolve preserves shadows', () {
      final resolved = const CheckboxStyle(
        shadows: kShadow,
      ).resolve(ThemeData.light());
      expect(resolved.shadows, kShadow);
    });

    test('resolve does not invent a shadow', () {
      // `null` means *no shadow*, not "ask the theme" — the colour fields are
      // the ones resolve() fills. copyWith cannot reset a field back to null,
      // so a resolved default here would be permanently unremovable.
      expect(const CheckboxStyle().resolve(ThemeData.light()).shadows, isNull);
    });

    test('default values are correct', () {
      const style = CheckboxStyle();
      expect(style.size, 24);
      expect(style.scale, 1.0);
      expect(style.borderWidth, 2);
      expect(style.borderRadius, 4);
      expect(style.checkStrokeWidth, 2.5);
      expect(style.animationDuration, const Duration(milliseconds: 200));
      expect(style.animationCurve, Curves.easeInOut);
      expect(style.morphDuration, const Duration(milliseconds: 150));
      expect(style.morphCurve, Curves.easeInOut);
    });
  });
}
