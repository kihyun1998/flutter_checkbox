/// The tristate state machine for a checkbox, as pure functions.
///
/// This module owns the three things that were previously copied across
/// [FlutterCheckbox], [FlutterCheckboxTile], and the animation controller:
///
/// - the value cycle (`next`),
/// - the value-change → animation mapping (`transition`),
/// - the resting controller positions for a value (`restingProgress`).
///
/// It depends on nothing from Flutter's widget/animation layers, so every
/// transition is unit-testable without pumping a widget.
library;

/// The animation a checkbox should run for a value change.
///
/// Deliberately *data*, not an effect: the animation controller layer decides
/// how to apply each case, keeping this module free of controllers.
enum CheckboxTransition {
  /// Value unchanged — do nothing.
  none,

  /// `false → true` — fill the box in.
  fillIn,

  /// `true → false` — fill the box out.
  fillOut,

  /// `false → null` — fill in and morph the checkmark to a dash.
  fillInMorphToDash,

  /// `null → false` — fill out; reset the morph once the fill dismisses.
  fillOutResetMorph,

  /// `true → null` — morph the checkmark to a dash.
  morphToDash,

  /// `null → true` — morph the dash back to a checkmark.
  morphToCheck,
}

/// Pure tristate logic for a checkbox. Not exported by the package barrel.
class CheckboxValue {
  const CheckboxValue._();

  /// The next value in the interaction cycle.
  ///
  /// Tristate: `false → true → null → false`. Binary: `!current`.
  ///
  /// [current] may only be `null` when [tristate] is `true` — the same
  /// precondition the widgets assert at construction.
  static bool? next(bool? current, {required bool tristate}) {
    if (tristate) {
      return switch (current) {
        false => true,
        true => null,
        null => false,
      };
    }
    return !current!;
  }

  /// The [CheckboxTransition] for a change from [oldValue] to [newValue].
  static CheckboxTransition transition(bool? oldValue, bool? newValue) {
    return switch ((oldValue, newValue)) {
      (false, true) => CheckboxTransition.fillIn,
      (true, false) => CheckboxTransition.fillOut,
      (false, null) => CheckboxTransition.fillInMorphToDash,
      (null, false) => CheckboxTransition.fillOutResetMorph,
      (true, null) => CheckboxTransition.morphToDash,
      (null, true) => CheckboxTransition.morphToCheck,
      _ => CheckboxTransition.none,
    };
  }

  /// The resting positions for the fill (`check`) and crossfade (`morph`)
  /// controllers at [value], with no animation — used to snap to the initial
  /// state.
  static ({double check, double morph}) restingProgress(bool? value) {
    return switch (value) {
      true => (check: 1.0, morph: 0.0),
      null => (check: 1.0, morph: 1.0),
      false => (check: 0.0, morph: 0.0),
    };
  }
}
