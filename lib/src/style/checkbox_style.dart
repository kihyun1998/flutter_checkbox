import 'package:flutter/material.dart';

/// The shape of the checkbox box.
enum CheckboxShape {
  /// A rectangle with configurable [CheckboxStyle.borderRadius].
  rectangle,

  /// A circle. [CheckboxStyle.borderRadius] is ignored.
  circle,
}

/// An immutable data class that holds all visual properties for [FlutterCheckbox].
class CheckboxStyle {
  /// The shape of the checkbox box.
  ///
  /// Defaults to [CheckboxShape.rectangle].
  final CheckboxShape shape;

  /// The width and height of the checkbox box in logical pixels.
  ///
  /// Defaults to `24`.
  final double size;

  /// A uniform scale factor applied to the entire widget.
  ///
  /// Independent of [size]. Defaults to `1.0`.
  final double scale;

  /// The background fill color when the checkbox is checked.
  ///
  /// If `null`, defaults to [ColorScheme.primary].
  final Color? activeColor;

  /// The color of the checkmark/dash stroke.
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
  /// Defaults to `4`. Only applies when [shape] is [CheckboxShape.rectangle].
  final double borderRadius;

  /// The stroke width of the checkmark/dash path in logical pixels.
  ///
  /// Defaults to `2.5`.
  final double checkStrokeWidth;

  /// Extra space added around the box for the hover/focus ring.
  ///
  /// The ring renders at `size + hoverRingPadding * 2`.
  /// Defaults to `4`.
  final double hoverRingPadding;

  /// Shape of the hover/focus ring.
  ///
  /// `null` (default) follows the checkbox shape — circle box → circle ring,
  /// rectangle box → rounded-rect ring.
  final CheckboxShape? hoverRingShape;

  /// Corner radius of the hover/focus ring when its shape is rectangle.
  ///
  /// `null` (default) uses `borderRadius + 2`.
  /// Ignored when the effective ring shape is [CheckboxShape.circle].
  final double? hoverRingBorderRadius;

  /// The duration of the check/uncheck animation (background fill).
  ///
  /// Defaults to `Duration(milliseconds: 200)`.
  final Duration animationDuration;

  /// The easing curve applied to the check/uncheck animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  /// The duration of the checkmark ↔ dash crossfade animation.
  ///
  /// Defaults to `Duration(milliseconds: 150)`.
  final Duration morphDuration;

  /// The easing curve applied to the checkmark ↔ dash crossfade.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve morphCurve;

  const CheckboxStyle({
    this.shape = CheckboxShape.rectangle,
    this.size = 24,
    this.scale = 1.0,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.inactiveColor,
    this.borderWidth = 2,
    this.borderRadius = 4,
    this.checkStrokeWidth = 2.5,
    this.hoverRingPadding = 4,
    this.hoverRingShape,
    this.hoverRingBorderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.morphDuration = const Duration(milliseconds: 150),
    this.morphCurve = Curves.easeInOut,
  });

  /// Returns a new [CheckboxStyle] with all `null` colors replaced by
  /// theme-derived defaults.
  CheckboxStyle resolve(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    return CheckboxStyle(
      shape: shape,
      size: size,
      scale: scale,
      activeColor: activeColor ?? primary,
      checkColor: checkColor ?? Colors.white,
      borderColor: borderColor ?? theme.colorScheme.outline,
      inactiveColor: inactiveColor ?? Colors.transparent,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      checkStrokeWidth: checkStrokeWidth,
      hoverRingPadding: hoverRingPadding,
      hoverRingShape: hoverRingShape,
      hoverRingBorderRadius: hoverRingBorderRadius,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      morphDuration: morphDuration,
      morphCurve: morphCurve,
    );
  }
}
