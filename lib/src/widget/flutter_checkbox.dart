import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/checkbox_animation.dart';
import '../painter/checkbox_painter.dart';
import '../style/checkbox_style.dart';

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
  final CheckboxStyle style;

  /// Whether the checkbox is interactive.
  ///
  /// When `false`, the widget renders at 40% opacity and [onChanged] is not called.
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
  bool _focused = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    initCheckAnimation(style: widget.style, initialValue: widget.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolved = widget.style.resolve(Theme.of(context));
  }

  @override
  void didUpdateWidget(covariant FlutterCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      updateCheckAnimation(old.value, widget.value);
    }
    if (widget.style != old.style) {
      _resolved = widget.style.resolve(Theme.of(context));
    }
  }

  @override
  void dispose() {
    disposeCheckAnimation();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onChanged == null) return;
    if (widget.tristate) {
      // Cycle: false → true → null → false
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
    final isInteractive = widget.enabled && widget.onChanged != null;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hoverColor = primary.withValues(alpha: 0.08);
    final splashColor = primary.withValues(alpha: 0.12);

    // scale is applied to the actual rendered size so hit area matches visual.
    final scaledSize = _resolved.size * _resolved.scale;

    // Checkbox box painter.
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
      // The ring SizedBox defines both the hit area and hover/focus zone.
      // Its size is always fixed (scaledSize + padding*2) so layout never shifts.
      final ringSize =
          (_resolved.size + _resolved.hoverRingPadding * 2) * _resolved.scale;
      final ringColor = _focused
          ? primary.withValues(alpha: 0.12)
          : _hovered
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
        (isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic);

    return Semantics(
      checked: widget.value ?? false,
      mixed: widget.value == null,
      enabled: widget.enabled,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: isInteractive,
        onFocusChange: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
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
            opacity: widget.enabled ? 1.0 : 0.4,
            child: boxWithOverlay,
          ),
        ),
      ),
    );
  }
}
