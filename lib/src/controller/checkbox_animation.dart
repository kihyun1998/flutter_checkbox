import 'package:flutter/material.dart';
import '../style/checkbox_style.dart';
import 'checkbox_value.dart';

/// A mixin that manages the two [AnimationController]s needed by
/// [FlutterCheckbox]:
///
/// - `checkController` — drives background fill (0.0 = unchecked, 1.0 = checked).
/// - `morphController` — drives checkmark ↔ dash crossfade (0.0 = check, 1.0 = dash).
///
/// Requires [TickerProviderStateMixin] on the same [State].
mixin CheckboxAnimationMixin<T extends StatefulWidget>
    on TickerProviderStateMixin<T> {
  late AnimationController checkController;
  late AnimationController morphController;

  late Animation<double> checkAnimation;
  late Animation<double> morphAnimation;

  void initCheckAnimation({
    required CheckboxStyle style,
    required bool? initialValue,
  }) {
    checkController = AnimationController(
      duration: style.animationDuration,
      vsync: this,
    );
    morphController = AnimationController(
      duration: style.morphDuration,
      vsync: this,
    );

    checkAnimation = CurvedAnimation(
      parent: checkController,
      curve: style.animationCurve,
    );
    morphAnimation = CurvedAnimation(
      parent: morphController,
      curve: style.morphCurve,
    );

    // Snap to initial state without animation.
    final rest = CheckboxValue.restingProgress(initialValue);
    checkController.value = rest.check;
    morphController.value = rest.morph;
  }

  /// Animates to [newValue] from [oldValue].
  ///
  /// Classification of the change lives in [CheckboxValue.transition] (pure,
  /// unit-tested); this method only applies the resulting effect to the live
  /// controllers.
  void updateCheckAnimation(bool? oldValue, bool? newValue) {
    switch (CheckboxValue.transition(oldValue, newValue)) {
      case CheckboxTransition.fillIn:
        checkController.forward();
      case CheckboxTransition.fillOut:
        checkController.reverse();
      case CheckboxTransition.fillInMorphToDash:
        checkController.forward();
        morphController.forward();
      case CheckboxTransition.fillOutResetMorph:
        checkController.reverse();
        // Reset morph after background animation completes (no visual impact
        // since progress will be 0, but keeps state consistent).
        checkController.addStatusListener(_resetMorphOnDismiss);
      case CheckboxTransition.morphToDash:
        morphController.forward();
      case CheckboxTransition.morphToCheck:
        morphController.reverse();
      case CheckboxTransition.none:
        break;
    }
  }

  void _resetMorphOnDismiss(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      morphController.value = 0.0;
      checkController.removeStatusListener(_resetMorphOnDismiss);
    }
  }

  void disposeCheckAnimation() {
    checkController.dispose();
    morphController.dispose();
  }
}
