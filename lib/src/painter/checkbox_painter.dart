import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../style/checkbox_style.dart';

/// A [CustomPainter] that draws the checkbox graphic on a [Canvas].
class CheckboxPainter extends CustomPainter {
  final CheckboxStyle style;

  /// Animation progress for background fill: `0.0` (unchecked) → `1.0` (checked).
  final double progress;

  /// Animation progress for checkmark ↔ dash crossfade:
  /// `0.0` = checkmark, `1.0` = dash.
  final double morphProgress;

  CheckboxPainter({
    required this.style,
    required this.progress,
    required this.morphProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    _drawBackground(canvas, rect, style);
    if (progress > 0) {
      _drawContent(canvas, rect, style);
    }
  }

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

  /// Draws checkmark and/or dash, crossfading between them via [morphProgress].
  void _drawContent(Canvas canvas, Rect rect, CheckboxStyle s) {
    if (morphProgress < 1.0) {
      _drawCheckmark(canvas, rect, s, opacity: 1.0 - morphProgress);
    }
    if (morphProgress > 0.0) {
      _drawDash(canvas, rect, s, opacity: morphProgress);
    }
  }

  void _drawCheckmark(
    Canvas canvas,
    Rect rect,
    CheckboxStyle s, {
    required double opacity,
  }) {
    final paint = Paint()
      ..color = s.checkColor!.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.checkStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = rect.width;
    final cy = rect.height;

    final p1 = Offset(cx * 0.22, cy * 0.50);
    final p2 = Offset(cx * 0.42, cy * 0.70);
    final p3 = Offset(cx * 0.78, cy * 0.32);

    final metric = _buildPath([p1, p2, p3]);
    final drawLength = metric.length * progress;
    canvas.drawPath(metric.extractPath(0, drawLength), paint);
  }

  void _drawDash(
    Canvas canvas,
    Rect rect,
    CheckboxStyle s, {
    required double opacity,
  }) {
    final paint = Paint()
      ..color = s.checkColor!.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.checkStrokeWidth
      ..strokeCap = StrokeCap.round;

    final cx = rect.width;
    final cy = rect.height;

    final p1 = Offset(cx * 0.25, cy * 0.50);
    final p2 = Offset(cx * 0.75, cy * 0.50);

    final metric = _buildPath([p1, p2]);
    final drawLength = metric.length * progress;
    canvas.drawPath(metric.extractPath(0, drawLength), paint);
  }

  ui.PathMetric _buildPath(List<Offset> points) {
    assert(points.length >= 2);
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    return path.computeMetrics().first;
  }

  @override
  bool shouldRepaint(covariant CheckboxPainter old) {
    return old.progress != progress ||
        old.morphProgress != morphProgress ||
        old.style != style;
  }
}
