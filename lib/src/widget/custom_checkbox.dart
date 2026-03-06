import 'package:flutter/material.dart';
import '../controller/checkbox_animation.dart';
import '../style/checkbox_style.dart';
import 'checkbox_box.dart';
import 'checkbox_label.dart';

/// A highly customizable checkbox widget with built-in label support
/// and pixel-perfect size control.
///
/// Unlike Flutter's built-in [Checkbox], this widget:
/// - Supports an inline [label] or [labelWidget] without wrapping in a [Row].
/// - Allows precise [CheckboxStyle.size] control via [CustomPaint].
/// - Draws the checkmark with a [CustomPainter] for crisp rendering at any size.
/// - Animates the check/uncheck transition with configurable duration and curve.
///
/// {@tool snippet}
/// **Basic usage:**
/// ```dart
/// CustomCheckbox(
///   value: _isChecked,
///   label: 'I agree to the terms',
///   onChanged: (value) => setState(() => _isChecked = value),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// **Custom styled:**
/// ```dart
/// CustomCheckbox(
///   value: _isChecked,
///   style: CheckboxStyle(
///     size: 32,
///     activeColor: Colors.indigo,
///     borderRadius: 16, // circular
///   ),
///   onChanged: (value) => setState(() => _isChecked = value),
/// )
/// ```
/// {@end-tool}
///
/// See also:
/// - [CheckboxStyle], which defines the visual appearance.
/// - [CheckboxBox], the internal rendering widget.
/// - [CheckboxLabel], the internal label widget.
class CustomCheckbox extends StatefulWidget {
  /// Whether the checkbox is checked.
  final bool value;

  /// Called when the user taps the checkbox or its label.
  ///
  /// The callback receives the **new** value (i.e., `!value`).
  /// If `null`, the checkbox is non-interactive.
  final ValueChanged<bool>? onChanged;

  /// A plain text string displayed next to the checkbox.
  ///
  /// For a fully custom label, use [labelWidget] instead.
  /// Cannot be used together with [labelWidget].
  final String? label;

  /// A custom widget displayed next to the checkbox.
  ///
  /// Cannot be used together with [label].
  final Widget? labelWidget;

  /// The text style for the [label].
  ///
  /// Ignored when [labelWidget] is used. If `null`, the font size defaults
  /// to `CheckboxStyle.size * 0.6`.
  final TextStyle? labelStyle;

  /// The horizontal gap between the checkbox box and the label,
  /// in logical pixels.
  ///
  /// Defaults to `8`.
  final double gap;

  /// The visual style of the checkbox.
  ///
  /// Defaults to [CheckboxStyle] with all default values.
  final CheckboxStyle style;

  /// Whether the checkbox is interactive.
  ///
  /// When `false`, the widget is rendered at 40% opacity and
  /// [onChanged] is not called on tap.
  final bool enabled;

  /// Creates a custom checkbox.
  ///
  /// The [value] parameter is required. Provide [onChanged] to make
  /// the checkbox interactive. At most one of [label] or [labelWidget]
  /// may be provided.
  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.labelWidget,
    this.labelStyle,
    this.gap = 8,
    this.style = const CheckboxStyle(),
    this.enabled = true,
  }) : assert(
         label == null || labelWidget == null,
         'Cannot provide both label and labelWidget. Use one or the other.',
       );

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox>
    with SingleTickerProviderStateMixin, CheckboxAnimationMixin {
  late CheckboxStyle _resolvedStyle;

  @override
  void initState() {
    super.initState();
    initCheckAnimation(
      style: widget.style,
      initialValue: widget.value,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolvedStyle = widget.style.resolve(Theme.of(context));
  }

  @override
  void didUpdateWidget(covariant CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      updateCheckAnimation(widget.value);
    }
    if (widget.style != oldWidget.style) {
      _resolvedStyle = widget.style.resolve(Theme.of(context));
    }
  }

  @override
  void dispose() {
    disposeCheckAnimation();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enabled && widget.onChanged != null) {
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = CheckboxBox(
      animation: checkAnimation,
      style: _resolvedStyle,
    );

    final label = CheckboxLabel(
      text: widget.label,
      textStyle: widget.labelStyle,
      fontSize: _resolvedStyle.size * 0.6,
      enabled: widget.enabled,
      child: widget.labelWidget,
    );

    final hasLabel = widget.label != null || widget.labelWidget != null;

    final content = hasLabel
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              box,
              SizedBox(width: widget.gap),
              label,
            ],
          )
        : box;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: widget.enabled ? 1.0 : 0.4,
        child: content,
      ),
    );
  }
}
