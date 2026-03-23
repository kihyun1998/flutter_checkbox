import 'package:flutter/material.dart';
import '../style/checkbox_style.dart';

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
    if (initialValue == true) {
      checkController.value = 1.0;
    } else if (initialValue == null) {
      checkController.value = 1.0;
      morphController.value = 1.0;
    }
  }

  /// Animates to [newValue] from [oldValue].
  ///
  /// Handles all six tristate transitions.
  void updateCheckAnimation(bool? oldValue, bool? newValue) {
    switch ((oldValue, newValue)) {
      case (false, true):
        checkController.forward();
      case (true, false):
        checkController.reverse();
      case (false, null):
        checkController.forward();
        morphController.forward();
      case (null, false):
        checkController.reverse();
        // Reset morph after background animation completes (no visual impact
        // since progress will be 0, but keeps state consistent).
        checkController.addStatusListener(_resetMorphOnDismiss);
      case (true, null):
        morphController.forward();
      case (null, true):
        morphController.reverse();
      default:
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
