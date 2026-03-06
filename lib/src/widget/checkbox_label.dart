import 'package:flutter/material.dart';

/// A stateless widget that renders the label area next to a checkbox.
///
/// Supports two modes:
/// - **Text mode**: pass a [text] string for automatic [Text] rendering.
/// - **Widget mode**: pass a [child] for fully custom label content.
///
/// Only one of [text] or [child] may be provided. If neither is set,
/// this widget renders [SizedBox.shrink].
///
/// Not intended for direct use outside of this package. Use
/// [CustomCheckbox.label] or [CustomCheckbox.labelWidget] instead.
class CheckboxLabel extends StatelessWidget {
  /// A plain text string to display as the label.
  ///
  /// Mutually exclusive with [child].
  final String? text;

  /// A custom widget to display as the label.
  ///
  /// Mutually exclusive with [text]. When provided, [textStyle] and
  /// [fontSize] are ignored.
  final Widget? child;

  /// The text style applied to the [text] label.
  ///
  /// If `null`, a default style is derived from [fontSize] and the
  /// ambient [ThemeData].
  final TextStyle? textStyle;

  /// The default font size used when [textStyle] is `null`.
  ///
  /// Typically set proportionally to [CheckboxStyle.size].
  final double fontSize;

  /// Whether the label should appear in its enabled visual state.
  ///
  /// When `false`, the text color falls back to [ThemeData.disabledColor].
  final bool enabled;

  /// Creates a checkbox label.
  ///
  /// At most one of [text] or [child] may be non-null.
  const CheckboxLabel({
    super.key,
    this.text,
    this.child,
    this.textStyle,
    required this.fontSize,
    this.enabled = true,
  }) : assert(
         text == null || child == null,
         'Cannot provide both text and child. Use one or the other.',
       );

  /// Whether this label has any content to display.
  bool get hasLabel => text != null || child != null;

  @override
  Widget build(BuildContext context) {
    if (child != null) return child!;
    if (text == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Text(
      text!,
      style: textStyle ??
          TextStyle(
            fontSize: fontSize,
            color: enabled ? theme.textTheme.bodyMedium?.color : theme.disabledColor,
          ),
    );
  }
}
