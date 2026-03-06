import 'package:flutter/material.dart';
import '../style/checkbox_style.dart';

/// A mixin that extracts checkbox animation logic from the widget [State].
///
/// Apply this mixin to a [State] that also uses
/// [SingleTickerProviderStateMixin]. It manages the [AnimationController]
/// lifecycle (creation, forward/reverse, disposal) so that the widget
/// state only needs to call three methods:
///
/// - [initCheckAnimation] — in `initState`
/// - [updateCheckAnimation] — in `didUpdateWidget`
/// - [disposeCheckAnimation] — in `dispose`
///
/// {@tool snippet}
/// ```dart
/// class _MyState extends State<MyWidget>
///     with SingleTickerProviderStateMixin, CheckboxAnimationMixin {
///   @override
///   void initState() {
///     super.initState();
///     initCheckAnimation(style: style, initialValue: widget.value);
///   }
/// }
/// ```
/// {@end-tool}
mixin CheckboxAnimationMixin<T extends StatefulWidget>
    on SingleTickerProviderStateMixin<T> {
  /// The [AnimationController] driving the check/uncheck transition.
  late AnimationController checkAnimationController;

  /// A curved animation derived from [checkAnimationController].
  ///
  /// The curve is determined by [CheckboxStyle.animationCurve].
  late Animation<double> checkAnimation;

  /// Initializes the animation controller and curved animation.
  ///
  /// Call this in [State.initState]. If [initialValue] is `true`, the
  /// controller is snapped to `1.0` immediately (no animation).
  void initCheckAnimation({
    required CheckboxStyle style,
    required bool initialValue,
  }) {
    checkAnimationController = AnimationController(
      duration: style.animationDuration,
      vsync: this,
    );
    checkAnimation = CurvedAnimation(
      parent: checkAnimationController,
      curve: style.animationCurve,
    );
    if (initialValue) {
      checkAnimationController.value = 1.0;
    }
  }

  /// Animates the checkbox to the checked or unchecked state.
  ///
  /// Pass `true` to animate forward (checked), `false` to reverse (unchecked).
  void updateCheckAnimation(bool value) {
    value
        ? checkAnimationController.forward()
        : checkAnimationController.reverse();
  }

  /// Disposes the [checkAnimationController].
  ///
  /// Call this in [State.dispose] **before** `super.dispose()`.
  void disposeCheckAnimation() {
    checkAnimationController.dispose();
  }
}
