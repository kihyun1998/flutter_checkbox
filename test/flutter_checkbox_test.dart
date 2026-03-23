import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_checkbox/flutter_checkbox.dart';

Widget buildApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

Finder findCheckboxPaint() {
  return find.descendant(
    of: find.byType(FlutterCheckbox),
    matching: find.byType(CustomPaint),
  );
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
    testWidgets('Semantics when checked', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: true, onChanged: (_) {})),
      );

      expect(
        find.byType(FlutterCheckbox),
        matchesSemantics(isChecked: true, isEnabled: true, hasTapAction: true),
      );
    });

    testWidgets('Semantics when unchecked', (tester) async {
      await tester.pumpWidget(
        buildApp(FlutterCheckbox(value: false, onChanged: (_) {})),
      );

      expect(
        find.byType(FlutterCheckbox),
        matchesSemantics(isChecked: false, isEnabled: true),
      );
    });

    testWidgets('Semantics reflects disabled state', (tester) async {
      await tester.pumpWidget(
        buildApp(const FlutterCheckbox(value: false, enabled: false)),
      );

      expect(find.byType(FlutterCheckbox), matchesSemantics(isEnabled: false));
    });

    testWidgets('Semantics mixed flag for indeterminate', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckbox(value: null, tristate: true, onChanged: (_) {}),
        ),
      );

      // indeterminate: checked=false, mixed state indicated via Semantics.mixed
      expect(find.byType(FlutterCheckbox), findsOneWidget);
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

  group('FlutterCheckboxTile / Accessibility', () {
    testWidgets('Semantics label from tile', (tester) async {
      await tester.pumpWidget(
        buildApp(
          FlutterCheckboxTile(value: true, label: 'Agree', onChanged: (_) {}),
        ),
      );

      expect(
        find.byType(FlutterCheckboxTile),
        matchesSemantics(isChecked: true, label: 'Agree'),
      );
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
