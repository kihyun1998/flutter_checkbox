import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// Internal: CheckboxInteraction is the shared activation+semantics seam, not
// exported by the barrel. This is its unit test surface — pumped alone, no
// FlutterCheckbox/Tile adapter involved.
import 'package:flutter_checkbox/src/widget/checkbox_interaction.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

// A minimal adapter: renders a fixed box and wires the exposed activate onto a
// tap, so pointer taps can be exercised too.
CheckboxInteraction box({
  required bool? value,
  bool tristate = false,
  bool enabled = true,
  required ValueChanged<bool?>? onChanged,
  String? semanticLabel,
  bool autofocus = false,
  void Function(bool focused, bool hovered, VoidCallback? activate)? spy,
}) {
  return CheckboxInteraction(
    value: value,
    tristate: tristate,
    enabled: enabled,
    onChanged: onChanged,
    semanticLabel: semanticLabel,
    autofocus: autofocus,
    builder:
        (context, {required focused, required hovered, required activate}) {
          spy?.call(focused, hovered, activate);
          return GestureDetector(
            onTap: activate,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(width: 40, height: 40),
          );
        },
  );
}

void main() {
  group('CheckboxInteraction', () {
    testWidgets('space activates with the next value', (tester) async {
      bool? got;
      await tester.pumpWidget(
        host(box(value: false, autofocus: true, onChanged: (v) => got = v)),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(got, true);
    });

    testWidgets('enter activates', (tester) async {
      bool? got;
      await tester.pumpWidget(
        host(box(value: true, autofocus: true, onChanged: (v) => got = v)),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(got, false);
    });

    testWidgets('pointer tap through the exposed activate', (tester) async {
      bool? got;
      await tester.pumpWidget(
        host(box(value: false, onChanged: (v) => got = v)),
      );
      await tester.tap(find.byType(CheckboxInteraction));
      await tester.pump();
      expect(got, true);
    });

    testWidgets('tristate activation cycles', (tester) async {
      bool? got = true;
      await tester.pumpWidget(
        host(box(value: true, tristate: true, onChanged: (v) => got = v)),
      );
      await tester.tap(find.byType(CheckboxInteraction));
      await tester.pump();
      expect(got, null); // true → null
    });

    testWidgets('semantics exposes checked + enabled + tap on one node', (
      tester,
    ) async {
      await tester.pumpWidget(host(box(value: true, onChanged: (_) {})));

      final d = tester
          .getSemantics(find.byType(CheckboxInteraction))
          .getSemanticsData();
      expect(d.flagsCollection.isChecked, CheckedState.isTrue);
      expect(d.flagsCollection.isEnabled, Tristate.isTrue);
      expect(d.hasAction(SemanticsAction.tap), isTrue);
    });

    testWidgets('indeterminate reports the mixed state', (tester) async {
      await tester.pumpWidget(
        host(box(value: null, tristate: true, onChanged: (_) {})),
      );

      final d = tester
          .getSemantics(find.byType(CheckboxInteraction))
          .getSemanticsData();
      expect(d.flagsCollection.isChecked, CheckedState.mixed);
    });

    testWidgets('non-interactive: no tap action and activate is null', (
      tester,
    ) async {
      bool sawNullActivate = false;
      await tester.pumpWidget(
        host(
          box(
            value: false,
            onChanged: null,
            spy: (f, h, activate) => sawNullActivate = activate == null,
          ),
        ),
      );

      final d = tester
          .getSemantics(find.byType(CheckboxInteraction))
          .getSemanticsData();
      expect(d.hasAction(SemanticsAction.tap), isFalse);
      expect(sawNullActivate, isTrue);
    });

    testWidgets('semanticLabel is applied to the node', (tester) async {
      await tester.pumpWidget(
        host(box(value: false, semanticLabel: 'Accept', onChanged: (_) {})),
      );

      final d = tester
          .getSemantics(find.byType(CheckboxInteraction))
          .getSemanticsData();
      expect(d.label, 'Accept');
    });
  });
}
