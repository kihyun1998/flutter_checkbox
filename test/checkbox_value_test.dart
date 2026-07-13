import 'package:flutter_test/flutter_test.dart';
// Internal import: CheckboxValue is package-internal domain logic (not exported
// by the barrel). Unit-testable with no widget pump — that is the whole point.
import 'package:flutter_checkbox/src/controller/checkbox_value.dart';

void main() {
  group('CheckboxValue.next', () {
    test('binary mode toggles', () {
      expect(CheckboxValue.next(false, tristate: false), true);
      expect(CheckboxValue.next(true, tristate: false), false);
    });

    test('tristate cycles false → true → null → false', () {
      expect(CheckboxValue.next(false, tristate: true), true);
      expect(CheckboxValue.next(true, tristate: true), null);
      expect(CheckboxValue.next(null, tristate: true), false);
    });
  });

  group('CheckboxValue.transition', () {
    test('maps each value change to its animation transition', () {
      expect(CheckboxValue.transition(false, true), CheckboxTransition.fillIn);
      expect(CheckboxValue.transition(true, false), CheckboxTransition.fillOut);
      expect(
        CheckboxValue.transition(false, null),
        CheckboxTransition.fillInMorphToDash,
      );
      expect(
        CheckboxValue.transition(null, false),
        CheckboxTransition.fillOutResetMorph,
      );
      expect(
        CheckboxValue.transition(true, null),
        CheckboxTransition.morphToDash,
      );
      expect(
        CheckboxValue.transition(null, true),
        CheckboxTransition.morphToCheck,
      );
    });

    test('is a no-op when the value is unchanged', () {
      expect(CheckboxValue.transition(false, false), CheckboxTransition.none);
      expect(CheckboxValue.transition(true, true), CheckboxTransition.none);
      expect(CheckboxValue.transition(null, null), CheckboxTransition.none);
    });
  });

  group('CheckboxValue.restingProgress', () {
    test('maps a value to the controller rest positions (no animation)', () {
      expect(CheckboxValue.restingProgress(false), (check: 0.0, morph: 0.0));
      expect(CheckboxValue.restingProgress(true), (check: 1.0, morph: 0.0));
      expect(CheckboxValue.restingProgress(null), (check: 1.0, morph: 1.0));
    });
  });
}
