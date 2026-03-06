import 'package:flutter/material.dart';
import '../painter/checkbox_painter.dart';
import '../style/checkbox_style.dart';

/// A stateless widget that renders only the checkbox box graphic.
///
/// This widget is a pure visual component with **no tap handling** —
/// interaction is managed by its parent ([CustomCheckbox]).
///
/// It listens to the provided [animation] and repaints via
/// [CheckboxPainter] on every animation tick.
///
/// Not intended for direct use outside of this package. Use
/// [CustomCheckbox] instead.
class CheckboxBox extends StatelessWidget {
  /// The animation driving the check/uncheck transition.
  ///
  /// Expected range is `0.0` (unchecked) to `1.0` (checked).
  final Animation<double> animation;

  /// The fully resolved style used for painting.
  final CheckboxStyle style;

  /// Creates a checkbox box that repaints as [animation] progresses.
  const CheckboxBox({
    super.key,
    required this.animation,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(style.size),
          painter: CheckboxPainter(
            style: style,
            progress: animation.value,
          ),
        );
      },
    );
  }
}
