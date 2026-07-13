import 'package:flutter/material.dart';
import '../controller/checkbox_animation.dart';
import '../painter/checkbox_painter.dart';
import '../style/checkbox_style.dart';
import 'checkbox_interaction.dart';

/// A customizable checkbox widget with optional tristate support,
/// keyboard navigation, and screen-reader accessibility.
///
/// Unlike Flutter's built-in [Checkbox], this widget:
/// - Draws with [CustomPainter] for crisp rendering at any size.
/// - Supports tristate (`value: null` = indeterminate dash).
/// - Animates both background fill and checkmark ↔ dash crossfade.
///
/// When used inside [FlutterCheckboxTile], pass `onChanged: null` so the
/// tile takes over all interaction; the widget becomes purely visual.
class FlutterCheckbox extends StatefulWidget {
  /// Whether the checkbox is checked.
  ///
  /// Pass `null` for the indeterminate state. Requires [tristate] to be `true`.
  final bool? value;

  /// Called when the user taps or activates the checkbox.
  ///
  /// Receives the next value in the cycle. If `null`, the checkbox is
  /// non-interactive (no hover ring, no focus, no tap).
  final ValueChanged<bool?>? onChanged;

  /// Whether the indeterminate (`null`) state is allowed.
  ///
  /// When `false`, [value] must not be `null`.
  /// Defaults to `false`.
  final bool tristate;

  /// The visual style of the checkbox.
  ///
  /// For the two most common Flutter [Checkbox] properties — [activeColor] and
  /// [checkColor] — you can pass them directly on the constructor instead of
  /// reaching into [style]; see those fields for the precedence rule.
  final CheckboxStyle style;

  /// The background fill color when checked — the top-level counterpart of
  /// Flutter [Checkbox.activeColor].
  ///
  /// When non-null this **overrides** [CheckboxStyle.activeColor]. Resolution
  /// order is: `activeColor` → `style.activeColor` → [ColorScheme.primary].
  final Color? activeColor;

  /// The checkmark/dash stroke color — the top-level counterpart of Flutter
  /// [Checkbox.checkColor].
  ///
  /// When non-null this **overrides** [CheckboxStyle.checkColor]. Resolution
  /// order is: `checkColor` → `style.checkColor` → [Colors.white].
  final Color? checkColor;

  /// A description of the checkbox for accessibility tools, mirroring Flutter
  /// [Checkbox.semanticLabel].
  ///
  /// Announced by screen readers in addition to the checked/mixed state.
  final String? semanticLabel;

  /// Whether the checkbox is interactive.
  ///
  /// When `false`, the widget renders at 40% opacity and [onChanged] is not
  /// called. This is the way to render a **disabled** checkbox.
  ///
  /// Note this differs from Flutter's [Checkbox], which has no `enabled` and
  /// treats `onChanged: null` as disabled. Here `onChanged: null` only makes
  /// the checkbox non-interactive (the composition seam used by
  /// [FlutterCheckboxTile]); for the greyed-out disabled look, use
  /// `enabled: false`.
  final bool enabled;

  /// Whether the checkbox can receive keyboard focus.
  final bool autofocus;

  /// An optional [FocusNode] for controlling focus programmatically.
  final FocusNode? focusNode;

  /// The mouse cursor shown when hovering over the checkbox.
  ///
  /// Defaults to [SystemMouseCursors.click] when interactive,
  /// [SystemMouseCursors.basic] otherwise.
  final MouseCursor? mouseCursor;

  const FlutterCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.tristate = false,
    this.style = const CheckboxStyle(),
    this.activeColor,
    this.checkColor,
    this.semanticLabel,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.mouseCursor,
  }) : assert(
         tristate || value != null,
         'value may only be null when tristate is true.',
       );

  @override
  State<FlutterCheckbox> createState() => _FlutterCheckboxState();
}

class _FlutterCheckboxState extends State<FlutterCheckbox>
    with TickerProviderStateMixin, CheckboxAnimationMixin {
  late CheckboxStyle _resolved;

  @override
  void initState() {
    super.initState();
    initCheckAnimation(style: widget.style, initialValue: widget.value);
  }

  /// Layers the top-level [FlutterCheckbox.activeColor] / [checkColor] over
  /// [style] (top-level wins), then fills theme defaults. Single source of
  /// truth so every re-resolve path stays consistent.
  void _updateResolvedStyle() {
    final merged = widget.style.copyWith(
      activeColor: widget.activeColor ?? widget.style.activeColor,
      checkColor: widget.checkColor ?? widget.style.checkColor,
    );
    _resolved = merged.resolve(Theme.of(context));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateResolvedStyle();
  }

  @override
  void didUpdateWidget(covariant FlutterCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      updateCheckAnimation(old.value, widget.value);
    }
    if (widget.style != old.style ||
        widget.activeColor != old.activeColor ||
        widget.checkColor != old.checkColor) {
      _updateResolvedStyle();
    }
  }

  @override
  void dispose() {
    disposeCheckAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The shared seam owns semantics + keyboard activation + focus/hover;
    // this widget supplies only the box, the ring, and its InkWell.
    return CheckboxInteraction(
      value: widget.value,
      tristate: widget.tristate,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      semanticLabel: widget.semanticLabel,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: widget.mouseCursor,
      builder: (context, {required focused, required hovered, required activate}) {
        final isInteractive = activate != null;
        final hoverColor = _resolved.hoverColor!;
        final splashColor = _resolved.splashColor!;

        // scale is applied to the rendered size so hit area matches visual.
        final scaledSize = _resolved.size * _resolved.scale;

        final box = AnimatedBuilder(
          animation: Listenable.merge([checkAnimation, morphAnimation]),
          builder: (context, _) {
            return CustomPaint(
              size: Size.square(scaledSize),
              painter: CheckboxPainter(
                style: _resolved,
                progress: checkAnimation.value,
                morphProgress: morphAnimation.value,
              ),
            );
          },
        );

        final effectiveRingShape = _resolved.hoverRingShape ?? _resolved.shape;

        // When not interactive (e.g. inside FlutterCheckboxTile), skip the ring
        // entirely so it doesn't consume layout space in the parent tile.
        Widget boxWithOverlay;
        if (!isInteractive) {
          boxWithOverlay = box;
        } else {
          // Fixed ring size (scaledSize + padding*2) so layout never shifts.
          final ringSize =
              (_resolved.size + _resolved.hoverRingPadding * 2) *
              _resolved.scale;
          final ringColor = focused
              ? _resolved.focusColor!
              : hovered
              ? hoverColor
              : Colors.transparent;

          boxWithOverlay = SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: ringSize,
                  height: ringSize,
                  decoration: BoxDecoration(
                    color: ringColor,
                    shape: effectiveRingShape == CheckboxShape.circle
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius: effectiveRingShape == CheckboxShape.rectangle
                        ? BorderRadius.circular(
                            _resolved.hoverRingBorderRadius ??
                                _resolved.borderRadius + 2,
                          )
                        : null,
                  ),
                ),
                box,
              ],
            ),
          );
        }

        final cursor =
            widget.mouseCursor ??
            (isInteractive
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic);

        return InkWell(
          onTap: activate,
          mouseCursor: cursor,
          splashColor: splashColor,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent, // hover is managed by the ring
          customBorder: effectiveRingShape == CheckboxShape.circle
              ? const CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    _resolved.hoverRingBorderRadius ??
                        _resolved.borderRadius + 2,
                  ),
                ),
          child: Opacity(
            opacity: widget.enabled ? 1.0 : _resolved.disabledOpacity,
            child: boxWithOverlay,
          ),
        );
      },
    );
  }
}
