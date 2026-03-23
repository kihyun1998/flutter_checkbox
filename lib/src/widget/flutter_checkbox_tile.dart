import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/checkbox_position.dart';
import '../style/checkbox_style.dart';
import 'checkbox_label.dart';
import 'flutter_checkbox.dart';

/// A tile widget that combines a [FlutterCheckbox] with a label and an
/// interactive tile container.
///
/// The tap area covers the entire tile. Background color transitions smoothly
/// between [backgroundColor] and [selectedColor] using [AnimatedContainer].
class FlutterCheckboxTile extends StatefulWidget {
  // ── value & callback ──────────────────────────────────────────────────────

  /// Whether the checkbox is checked. Pass `null` for indeterminate state
  /// (requires [tristate] to be `true`).
  final bool? value;

  /// Called when the user taps the tile or its label.
  final ValueChanged<bool?>? onChanged;

  /// Whether the indeterminate (`null`) state is allowed.
  final bool tristate;

  // ── checkbox style ────────────────────────────────────────────────────────

  /// Visual style applied to the inner [FlutterCheckbox].
  final CheckboxStyle checkboxStyle;

  // ── label ─────────────────────────────────────────────────────────────────

  /// Plain text label. Cannot be used with [labelWidget].
  final String? label;

  /// Custom label widget. Cannot be used with [label].
  final Widget? labelWidget;

  /// Text style for [label].
  final TextStyle? labelStyle;

  /// Secondary text shown below the label. Cannot be used with [subtitleWidget].
  final String? subtitle;

  /// Custom subtitle widget. Cannot be used with [subtitle].
  final Widget? subtitleWidget;

  /// Text style for [subtitle].
  final TextStyle? subtitleStyle;

  /// Gap between the checkbox and the label column.
  final double gap;

  // ── layout ────────────────────────────────────────────────────────────────

  /// Which side of the label the checkbox appears on.
  final CheckboxPosition checkboxPosition;

  /// When `true` (default), the tile expands to fill available width.
  /// When `false`, the tile wraps its content.
  final bool expandWidth;

  /// Padding inside the tile.
  final EdgeInsetsGeometry? padding;

  /// Margin outside the tile.
  final EdgeInsetsGeometry? margin;

  /// Size constraints for the tile.
  final BoxConstraints? constraints;

  // ── tile background ───────────────────────────────────────────────────────

  /// Tile background color when unchecked.
  final Color? backgroundColor;

  /// Tile background color when checked.
  final Color? selectedColor;

  /// Tile background color when disabled.
  final Color? disabledColor;

  // ── tile border ───────────────────────────────────────────────────────────

  /// Tile corner radius.
  final BorderRadius? tileBorderRadius;

  /// Tile border. Use [BorderSide] to control color, width, and style.
  final BorderSide? tileBorderSide;

  // ── tile animation ────────────────────────────────────────────────────────

  /// Duration of the tile background color transition.
  final Duration tileAnimationDuration;

  /// Curve of the tile background color transition.
  final Curve tileAnimationCurve;

  // ── interaction ───────────────────────────────────────────────────────────

  /// Overlay color when hovering over the tile.
  final Color? hoverColor;

  /// Ripple color on tap.
  final Color? splashColor;

  /// Highlight color while the tap is held.
  final Color? highlightColor;

  /// Overlay color when the tile is focused.
  final Color? focusColor;

  // ── shadow ────────────────────────────────────────────────────────────────

  /// Shadow elevation of the tile.
  final double elevation;

  // ── misc ──────────────────────────────────────────────────────────────────

  /// Mouse cursor shown when hovering.
  final MouseCursor? mouseCursor;

  /// Whether the tile is interactive.
  final bool enabled;

  /// Focus node for programmatic focus control.
  final FocusNode? focusNode;

  /// Whether to request focus on first build.
  final bool autofocus;

  const FlutterCheckboxTile({
    super.key,
    required this.value,
    this.onChanged,
    this.tristate = false,
    this.checkboxStyle = const CheckboxStyle(),
    this.label,
    this.labelWidget,
    this.labelStyle,
    this.subtitle,
    this.subtitleWidget,
    this.subtitleStyle,
    this.gap = 8,
    this.checkboxPosition = CheckboxPosition.start,
    this.expandWidth = true,
    this.padding,
    this.margin,
    this.constraints,
    this.backgroundColor,
    this.selectedColor,
    this.disabledColor,
    this.tileBorderRadius,
    this.tileBorderSide,
    this.tileAnimationDuration = const Duration(milliseconds: 200),
    this.tileAnimationCurve = Curves.easeInOut,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.focusColor,
    this.elevation = 0,
    this.mouseCursor,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
  }) : assert(
         label == null || labelWidget == null,
         'Cannot provide both label and labelWidget.',
       ),
       assert(
         subtitle == null || subtitleWidget == null,
         'Cannot provide both subtitle and subtitleWidget.',
       ),
       assert(
         tristate || value != null,
         'value may only be null when tristate is true.',
       );

  @override
  State<FlutterCheckboxTile> createState() => _FlutterCheckboxTileState();
}

class _FlutterCheckboxTileState extends State<FlutterCheckboxTile> {
  bool _focused = false;

  void _handleTap() {
    if (!widget.enabled || widget.onChanged == null) return;
    if (widget.tristate) {
      final next = switch (widget.value) {
        false => true,
        true => null,
        null => false,
      };
      widget.onChanged!(next);
    } else {
      widget.onChanged!(!widget.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final isInteractive = widget.enabled && widget.onChanged != null;

    final hoverColor = widget.hoverColor ?? primary.withValues(alpha: 0.08);
    final splashColor = widget.splashColor ?? primary.withValues(alpha: 0.12);
    final focusColor = widget.focusColor ?? primary.withValues(alpha: 0.12);
    final cursor =
        widget.mouseCursor ??
        (isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic);

    // Resolve tile background color based on state.
    final Color? tileColor = !widget.enabled
        ? widget.disabledColor
        : (widget.value == true
              ? widget.selectedColor
              : widget.backgroundColor);

    // Inner checkbox — purely visual (onChanged: null, tile handles interaction).
    final checkbox = FlutterCheckbox(
      value: widget.value,
      onChanged: null,
      tristate: widget.tristate,
      style: widget.checkboxStyle,
      enabled: widget.enabled,
    );

    // Label column (label + optional subtitle).
    final hasLabel = widget.label != null || widget.labelWidget != null;
    final hasSubtitle =
        widget.subtitle != null || widget.subtitleWidget != null;

    Widget? labelColumn;
    if (hasLabel || hasSubtitle) {
      final labelWidget = hasLabel
          ? CheckboxLabel(
              text: widget.label,
              textStyle: widget.labelStyle,
              fontSize: widget.checkboxStyle.size * 0.6,
              enabled: widget.enabled,
              child: widget.labelWidget,
            )
          : null;

      final subtitleWidget = hasSubtitle
          ? DefaultTextStyle.merge(
              style:
                  widget.subtitleStyle ??
                  TextStyle(
                    fontSize: widget.checkboxStyle.size * 0.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              child: Opacity(
                opacity: widget.enabled ? 1.0 : 0.4,
                child: widget.subtitleWidget ?? Text(widget.subtitle!),
              ),
            )
          : null;

      labelColumn = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelWidget != null) labelWidget,
          if (subtitleWidget != null) ...[
            const SizedBox(height: 2),
            subtitleWidget,
          ],
        ],
      );
    }

    // Arrange checkbox and label based on checkboxPosition.
    final children = <Widget>[
      checkbox,
      if (labelColumn != null) ...[
        SizedBox(width: widget.gap),
        // Use Expanded when position=end + expandWidth so the label fills
        // remaining space and pushes the checkbox to the trailing edge.
        if (widget.checkboxPosition == CheckboxPosition.end &&
            widget.expandWidth)
          Expanded(child: labelColumn)
        else
          Flexible(child: labelColumn),
      ],
    ];

    final row = Row(
      mainAxisSize: widget.expandWidth ? MainAxisSize.max : MainAxisSize.min,
      children: widget.checkboxPosition == CheckboxPosition.start
          ? children
          : children.reversed.toList(),
    );

    // Tile border.
    final border = widget.tileBorderSide != null
        ? Border.fromBorderSide(widget.tileBorderSide!)
        : null;

    // Animated tile background.
    Widget tile = AnimatedContainer(
      duration: widget.tileAnimationDuration,
      curve: widget.tileAnimationCurve,
      width: widget.expandWidth ? double.infinity : null,
      padding: widget.padding,
      constraints: widget.constraints,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: widget.tileBorderRadius,
        border: border,
      ),
      child: row,
    );

    // Elevation via Material.
    if (widget.elevation > 0) {
      tile = Material(
        elevation: widget.elevation,
        borderRadius: widget.tileBorderRadius,
        color: Colors.transparent,
        child: tile,
      );
    }

    // Margin.
    if (widget.margin != null) {
      tile = Padding(padding: widget.margin!, child: tile);
    }

    return Semantics(
      checked: widget.value ?? false,
      mixed: widget.value == null,
      enabled: widget.enabled,
      label: widget.label,
      excludeSemantics: widget.label != null,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: isInteractive,
        onFocusChange: (v) => setState(() => _focused = v),
        mouseCursor: cursor,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handleTap();
              return null;
            },
          ),
        },
        child: InkWell(
          onTap: isInteractive ? _handleTap : null,
          hoverColor: hoverColor,
          splashColor: splashColor,
          highlightColor: widget.highlightColor,
          focusColor: focusColor,
          focusNode: _focused ? widget.focusNode : null,
          borderRadius: widget.tileBorderRadius,
          child: tile,
        ),
      ),
    );
  }
}
