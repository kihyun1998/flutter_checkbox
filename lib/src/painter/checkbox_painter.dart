import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../style/checkbox_style.dart';

/// A [CustomPainter] that draws the checkbox graphic on a [Canvas].
///
/// This painter is a pure rendering layer — it receives a fully resolved
/// [CheckboxStyle] and an animation [progress] value, then draws the
/// rounded-rect background, border, and checkmark path accordingly.
///
/// Used internally by [CheckboxBox]. Not intended for direct use.
class CheckboxPainter extends CustomPainter {
  /// The fully resolved style containing colors, sizes, and radii.
  final CheckboxStyle style;

  /// The animation progress from `0.0` (unchecked) to `1.0` (checked).
  ///
  /// Controls both the background color interpolation and the visible
  /// length of the checkmark stroke.
  final double progress;

  /// Creates a painter that draws a checkbox at the given [progress].
  CheckboxPainter({required this.style, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final s = style;
    final rect = Offset.zero & size;

    _drawBackground(canvas, rect, s);
    if (progress > 0) {
      _drawCheckmark(canvas, rect, s);
    }
  }

  /// Draws the background fill and border.
  ///
  /// Delegates to circle or rounded-rect drawing based on
  /// [CheckboxStyle.shape]. The background color interpolates from
  /// [CheckboxStyle.inactiveColor] to [CheckboxStyle.activeColor]
  /// based on [progress].
  void _drawBackground(Canvas canvas, Rect rect, CheckboxStyle s) {
    final bgColor = Color.lerp(s.inactiveColor!, s.activeColor!, progress)!;
    final currentBorderColor = Color.lerp(
      s.borderColor!,
      s.activeColor!,
      progress,
    )!;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = currentBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.borderWidth;

    final insetRect = rect.deflate(s.borderWidth / 2);

    switch (s.shape) {
      case CheckboxShape.circle:
        final center = insetRect.center;
        final radius = insetRect.shortestSide / 2;
        canvas.drawCircle(center, radius, bgPaint);
        canvas.drawCircle(center, radius, borderPaint);
      case CheckboxShape.rectangle:
        final rrect = RRect.fromRectAndRadius(
          insetRect,
          Radius.circular(s.borderRadius),
        );
        canvas.drawRRect(rrect, bgPaint);
        canvas.drawRRect(rrect, borderPaint);
    }
  }

  /// Draws the checkmark stroke, progressively revealed by [progress].
  ///
  /// The checkmark is defined by three proportional control points within
  /// the bounding [rect], forming a standard check shape. The visible
  /// portion of the path is clipped to `totalLength * progress`.
  void _drawCheckmark(Canvas canvas, Rect rect, CheckboxStyle s) {
    final paint = Paint()
      ..color = s.checkColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.checkStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = rect.width;
    final cy = rect.height;

    final p1 = Offset(cx * 0.22, cy * 0.50);
    final p2 = Offset(cx * 0.42, cy * 0.70);
    final p3 = Offset(cx * 0.78, cy * 0.32);

    final metric = _buildCheckPath(p1, p2, p3);
    final drawLength = metric.length * progress;
    final animatedPath = metric.extractPath(0, drawLength);

    canvas.drawPath(animatedPath, paint);
  }

  /// Builds a two-segment path (p1→p2→p3) and returns its [ui.PathMetric]
  /// for length-based extraction.
  ui.PathMetric _buildCheckPath(Offset p1, Offset p2, Offset p3) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy);

    return path.computeMetrics().first;
  }

  @override
  bool shouldRepaint(covariant CheckboxPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.style != style;
  }
}
