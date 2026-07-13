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

  /// A scale for the checkmark/dash size within the box, about its centre.
  ///
  /// `1.0` (default) is the built-in size; `0.7` draws a smaller tick with more
  /// padding, `1.2` a larger one. Independent of [checkStrokeWidth] — the stroke
  /// keeps its width. Applies to both the checkmark and the indeterminate dash.
  final double checkScale;

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

  /// The overlay colour of the ring while hovered.
  ///
  /// If `null`, defaults to `ColorScheme.primary` at 8% opacity.
  final Color? hoverColor;

  /// The overlay colour of the ring while focused.
  ///
  /// If `null`, defaults to `ColorScheme.primary` at 12% opacity.
  final Color? focusColor;

  /// The splash (ripple) colour on tap.
  ///
  /// If `null`, defaults to `ColorScheme.primary` at 12% opacity.
  final Color? splashColor;

  /// The opacity applied when the checkbox is disabled (`enabled: false`).
  ///
  /// Defaults to `0.4`.
  final double disabledOpacity;

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
    this.checkScale = 1.0,
    this.hoverRingPadding = 4,
    this.hoverRingShape,
    this.hoverRingBorderRadius,
    this.hoverColor,
    this.focusColor,
    this.splashColor,
    this.disabledOpacity = 0.4,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.morphDuration = const Duration(milliseconds: 150),
    this.morphCurve = Curves.easeInOut,
  });

  /// Returns a copy of this style with the given fields replaced.
  ///
  /// Any argument left `null` keeps the current value. Note this means
  /// nullable color fields can only be *overwritten*, not reset to `null` —
  /// which is exactly the merge semantics [FlutterCheckbox] needs when it
  /// layers its top-level `activeColor` / `checkColor` over a `style`.
  CheckboxStyle copyWith({
    CheckboxShape? shape,
    double? size,
    double? scale,
    Color? activeColor,
    Color? checkColor,
    Color? borderColor,
    Color? inactiveColor,
    double? borderWidth,
    double? borderRadius,
    double? checkStrokeWidth,
    double? checkScale,
    double? hoverRingPadding,
    CheckboxShape? hoverRingShape,
    double? hoverRingBorderRadius,
    Color? hoverColor,
    Color? focusColor,
    Color? splashColor,
    double? disabledOpacity,
    Duration? animationDuration,
    Curve? animationCurve,
    Duration? morphDuration,
    Curve? morphCurve,
  }) {
    return CheckboxStyle(
      shape: shape ?? this.shape,
      size: size ?? this.size,
      scale: scale ?? this.scale,
      activeColor: activeColor ?? this.activeColor,
      checkColor: checkColor ?? this.checkColor,
      borderColor: borderColor ?? this.borderColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      checkStrokeWidth: checkStrokeWidth ?? this.checkStrokeWidth,
      checkScale: checkScale ?? this.checkScale,
      hoverRingPadding: hoverRingPadding ?? this.hoverRingPadding,
      hoverRingShape: hoverRingShape ?? this.hoverRingShape,
      hoverRingBorderRadius:
          hoverRingBorderRadius ?? this.hoverRingBorderRadius,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      splashColor: splashColor ?? this.splashColor,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      morphDuration: morphDuration ?? this.morphDuration,
      morphCurve: morphCurve ?? this.morphCurve,
    );
  }

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
      checkScale: checkScale,
      hoverRingPadding: hoverRingPadding,
      hoverRingShape: hoverRingShape,
      hoverRingBorderRadius: hoverRingBorderRadius,
      hoverColor: hoverColor ?? primary.withValues(alpha: 0.08),
      focusColor: focusColor ?? primary.withValues(alpha: 0.12),
      splashColor: splashColor ?? primary.withValues(alpha: 0.12),
      disabledOpacity: disabledOpacity,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      morphDuration: morphDuration,
      morphCurve: morphCurve,
    );
  }
}
