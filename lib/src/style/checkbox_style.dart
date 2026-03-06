import 'package:flutter/material.dart';

/// An immutable data class that holds all visual properties for [CustomCheckbox].
///
/// This class is purely declarative and contains no widget or rendering logic.
/// Pass it to [CustomCheckbox.style] to customize appearance.
///
/// {@tool snippet}
/// ```dart
/// CustomCheckbox(
///   value: true,
///   style: CheckboxStyle(
///     size: 32,
///     activeColor: Colors.indigo,
///     borderRadius: 8,
///   ),
///   onChanged: (v) {},
/// )
/// ```
/// {@end-tool}
///
/// All color properties default to `null` and are resolved from the current
/// [ThemeData] via [resolve] before rendering.
class CheckboxStyle {
  /// The width and height of the checkbox box in logical pixels.
  ///
  /// Defaults to `24`.
  final double size;

  /// The background fill color when the checkbox is checked.
  ///
  /// If `null`, defaults to [ColorScheme.primary].
  final Color? activeColor;

  /// The color of the checkmark stroke.
  ///
  /// If `null`, defaults to [Colors.white].
  final Color? checkColor;

  /// The border color when the checkbox is unchecked.
  ///
  /// If `null`, defaults to [ColorScheme.outline].
  final Color? borderColor;

  /// The background fill color when the checkbox is unchecked.
  ///
  /// If `null`, defaults to [Colors.transparent].
  final Color? inactiveColor;

  /// The width of the border stroke in logical pixels.
  ///
  /// Defaults to `2`.
  final double borderWidth;

  /// The corner radius of the checkbox box in logical pixels.
  ///
  /// Defaults to `4`. Set to `size / 2` for a circular shape.
  final double borderRadius;

  /// The stroke width of the checkmark path in logical pixels.
  ///
  /// Defaults to `2.5`.
  final double checkStrokeWidth;

  /// The duration of the check/uncheck animation.
  ///
  /// Defaults to `Duration(milliseconds: 200)`.
  final Duration animationDuration;

  /// The easing curve applied to the check/uncheck animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  /// Creates a checkbox style with the given visual properties.
  ///
  /// All color parameters default to `null` and will be resolved from the
  /// ambient [ThemeData] at render time.
  const CheckboxStyle({
    this.size = 24,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.inactiveColor,
    this.borderWidth = 2,
    this.borderRadius = 4,
    this.checkStrokeWidth = 2.5,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  });

  /// Returns a new [CheckboxStyle] with all `null` colors replaced by
  /// theme-derived defaults.
  ///
  /// This is called internally by [CustomCheckbox] during build — you
  /// typically do not need to call this yourself.
  CheckboxStyle resolve(ThemeData theme) {
    return CheckboxStyle(
      size: size,
      activeColor: activeColor ?? theme.colorScheme.primary,
      checkColor: checkColor ?? Colors.white,
      borderColor: borderColor ?? theme.colorScheme.outline,
      inactiveColor: inactiveColor ?? Colors.transparent,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      checkStrokeWidth: checkStrokeWidth,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
    );
  }
}
