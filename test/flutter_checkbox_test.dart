import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_checkbox/flutter_checkbox.dart';

Widget buildApp(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

Finder findCheckboxPaint() {
  return find.descendant(
    of: find.byType(CustomCheckbox),
    matching: find.byType(CustomPaint),
  );
}

void main() {
  group('Rendering', () {
    testWidgets('renders without label', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(value: false, onChanged: (_) {}),
      ));

      expect(find.byType(CustomCheckbox), findsOneWidget);
      expect(findCheckboxPaint(), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('renders with text label', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(value: false, label: 'Agree', onChanged: (_) {}),
      ));

      expect(find.text('Agree'), findsOneWidget);
    });

    testWidgets('renders with custom label widget', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: false,
          labelWidget: const Icon(Icons.star),
          onChanged: (_) {},
        ),
      ));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('Size', () {
    testWidgets('default size is 24', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(value: false, onChanged: (_) {}),
      ));

      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(24));
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: false,
          style: const CheckboxStyle(size: 48),
          onChanged: (_) {},
        ),
      ));

      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(48));
    });

    testWidgets('small size renders correctly', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: true,
          style: const CheckboxStyle(size: 12),
          onChanged: (_) {},
        ),
      ));

      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(12));
    });

    testWidgets('large size renders correctly', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: true,
          style: const CheckboxStyle(size: 80),
          onChanged: (_) {},
        ),
      ));

      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(80));
    });
  });

  group('Interaction', () {
    testWidgets('tap toggles value from false to true', (tester) async {
      bool value = false;
      await tester.pumpWidget(buildApp(
        StatefulBuilder(
          builder: (context, setState) {
            return CustomCheckbox(
              value: value,
              onChanged: (v) => setState(() => value = v),
            );
          },
        ),
      ));

      await tester.tap(find.byType(CustomCheckbox));
      await tester.pump();
      expect(value, true);
    });

    testWidgets('tap toggles value from true to false', (tester) async {
      bool value = true;
      await tester.pumpWidget(buildApp(
        StatefulBuilder(
          builder: (context, setState) {
            return CustomCheckbox(
              value: value,
              onChanged: (v) => setState(() => value = v),
            );
          },
        ),
      ));

      await tester.tap(find.byType(CustomCheckbox));
      await tester.pump();
      expect(value, false);
    });

    testWidgets('tapping label also toggles', (tester) async {
      bool value = false;
      await tester.pumpWidget(buildApp(
        StatefulBuilder(
          builder: (context, setState) {
            return CustomCheckbox(
              value: value,
              label: 'Click me',
              onChanged: (v) => setState(() => value = v),
            );
          },
        ),
      ));

      await tester.tap(find.text('Click me'));
      await tester.pump();
      expect(value, true);
    });

    testWidgets('disabled checkbox ignores tap', (tester) async {
      bool value = false;
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: value,
          enabled: false,
          onChanged: (v) => value = v,
        ),
      ));

      await tester.tap(find.byType(CustomCheckbox));
      await tester.pump();
      expect(value, false);
    });

    testWidgets('null onChanged makes checkbox non-interactive', (tester) async {
      await tester.pumpWidget(buildApp(
        const CustomCheckbox(value: false),
      ));

      await tester.tap(find.byType(CustomCheckbox));
      await tester.pump();
    });
  });

  group('Animation', () {
    testWidgets('animation runs on value change', (tester) async {
      bool value = false;
      await tester.pumpWidget(buildApp(
        StatefulBuilder(
          builder: (context, setState) {
            return CustomCheckbox(
              value: value,
              onChanged: (v) => setState(() => value = v),
            );
          },
        ),
      ));

      await tester.tap(find.byType(CustomCheckbox));
      // mid-animation
      await tester.pump(const Duration(milliseconds: 100));
      expect(findCheckboxPaint(), findsOneWidget);

      // animation complete
      await tester.pumpAndSettle();
      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('reverse animation on uncheck', (tester) async {
      bool value = true;
      await tester.pumpWidget(buildApp(
        StatefulBuilder(
          builder: (context, setState) {
            return CustomCheckbox(
              value: value,
              onChanged: (v) => setState(() => value = v),
            );
          },
        ),
      ));

      await tester.tap(find.byType(CustomCheckbox));
      await tester.pumpAndSettle();
      expect(value, false);
    });
  });

  group('Style', () {
    testWidgets('applies custom colors without error', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: true,
          style: const CheckboxStyle(
            activeColor: Colors.red,
            checkColor: Colors.yellow,
            borderColor: Colors.blue,
            inactiveColor: Colors.grey,
          ),
          onChanged: (_) {},
        ),
      ));

      await tester.pumpAndSettle();
      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('applies custom border radius and width', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: false,
          style: const CheckboxStyle(
            borderRadius: 12,
            borderWidth: 3,
          ),
          onChanged: (_) {},
        ),
      ));

      expect(findCheckboxPaint(), findsOneWidget);
    });

    testWidgets('circular checkbox with borderRadius = size/2', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: true,
          style: const CheckboxStyle(size: 30, borderRadius: 15),
          onChanged: (_) {},
        ),
      ));

      await tester.pumpAndSettle();
      final paint = tester.widget<CustomPaint>(findCheckboxPaint());
      expect(paint.size, const Size.square(30));
    });
  });

  group('Disabled state', () {
    testWidgets('renders with reduced opacity', (tester) async {
      await tester.pumpWidget(buildApp(
        const CustomCheckbox(value: false, enabled: false),
      ));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.4);
    });

    testWidgets('enabled renders full opacity', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(value: false, onChanged: (_) {}),
      ));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1.0);
    });
  });

  group('Label', () {
    testWidgets('custom labelStyle is applied', (tester) async {
      const style = TextStyle(fontSize: 20, color: Colors.red);
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: false,
          label: 'Styled',
          labelStyle: style,
          onChanged: (_) {},
        ),
      ));

      final text = tester.widget<Text>(find.text('Styled'));
      expect(text.style?.fontSize, 20);
      expect(text.style?.color, Colors.red);
    });

    testWidgets('custom gap is respected', (tester) async {
      await tester.pumpWidget(buildApp(
        CustomCheckbox(
          value: false,
          label: 'Gap test',
          gap: 20,
          onChanged: (_) {},
        ),
      ));

      final sizedBox = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(CustomCheckbox),
          matching: find.byType(SizedBox),
        ),
      ).where((sb) => sb.width == 20);
      expect(sizedBox.length, 1);
    });
  });

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
      expect(style.borderWidth, 2);
      expect(style.borderRadius, 4);
      expect(style.checkStrokeWidth, 2.5);
      expect(style.animationDuration, const Duration(milliseconds: 200));
      expect(style.animationCurve, Curves.easeInOut);
    });
  });
}
