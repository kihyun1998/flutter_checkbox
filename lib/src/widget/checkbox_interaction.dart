import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/checkbox_value.dart';

/// Builds the visual for a [CheckboxInteraction], given the current interaction
/// state.
///
/// - [focused] / [hovered] come from the shared [FocusableActionDetector] so the
///   adapter can render a ring, overlay, etc.
/// - [activate] is the guarded value-cycle callback (null when non-interactive).
///   Wire it onto the adapter's own tap surface (e.g. `InkWell.onTap`) so a
///   pointer tap toggles too; keyboard and assistive-tech activation are already
///   handled inside the seam.
typedef CheckboxInteractionBuilder =
    Widget Function(
      BuildContext context, {
      required bool focused,
      required bool hovered,
      required VoidCallback? activate,
    });

/// The shared activation + semantics seam for [FlutterCheckbox] and
/// [FlutterCheckboxTile].
///
/// It owns the parts that are invariant across both widgets — the tristate
/// [Semantics] node, keyboard activation ([LogicalKeyboardKey.space] /
/// [LogicalKeyboardKey.enter] → toggle), focus/hover tracking, and the single
/// guarded activation handler — and leaves the InkWell/ring visuals to each
/// adapter via [builder]. Not exported by the package barrel.
///
/// All three activation paths (pointer via the adapter's tap surface, keyboard,
/// and assistive tech via [Semantics.onTap]) converge on one handler, so the
/// checked state and the tap action always sit on a single semantics node.
class CheckboxInteraction extends StatefulWidget {
  /// The current value. `null` is the indeterminate state (requires [tristate]).
  final bool? value;

  /// Whether the indeterminate (`null`) state is allowed.
  final bool tristate;

  /// Whether the control is interactive. When `false`, [Semantics.enabled] is
  /// `false` and no activation fires.
  final bool enabled;

  /// Called with the next value on activation. `null` makes the control
  /// non-interactive (the composition seam used by [FlutterCheckboxTile]).
  final ValueChanged<bool?>? onChanged;

  /// An accessibility label for the control.
  final String? semanticLabel;

  /// Whether to drop descendant semantics so this seam is a single node.
  ///
  /// Defaults to `true` — the checked state and the tap action must live on
  /// one node (a screen reader should see one control, not a checked node plus
  /// a separate tappable node). Set to `false` only when a descendant provides
  /// the accessible name itself (e.g. the tile's custom `labelWidget`).
  final bool excludeChildSemantics;

  /// Focus control for keyboard activation.
  final FocusNode? focusNode;

  /// Whether to request focus on first build.
  final bool autofocus;

  /// The cursor for the focusable region. The adapter's own tap surface
  /// (innermost) may override it.
  final MouseCursor? mouseCursor;

  /// Builds the visual, given the current interaction state.
  final CheckboxInteractionBuilder builder;

  const CheckboxInteraction({
    super.key,
    required this.value,
    this.tristate = false,
    this.enabled = true,
    required this.onChanged,
    this.semanticLabel,
    this.excludeChildSemantics = true,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
    required this.builder,
  });

  @override
  State<CheckboxInteraction> createState() => _CheckboxInteractionState();
}

class _CheckboxInteractionState extends State<CheckboxInteraction> {
  bool _focused = false;
  bool _hovered = false;

  bool get _isInteractive => widget.enabled && widget.onChanged != null;

  void _activate() {
    if (!_isInteractive) return;
    widget.onChanged!(
      CheckboxValue.next(widget.value, tristate: widget.tristate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activate = _isInteractive ? _activate : null;
    final cursor =
        widget.mouseCursor ??
        (_isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic);

    return Semantics(
      checked: widget.value ?? false,
      mixed: widget.value == null,
      enabled: widget.enabled,
      // Empty (not null) keeps an unlabelled node's label as '' — see the
      // matchesSemantics lesson.
      label: widget.semanticLabel ?? '',
      onTap: activate,
      excludeSemantics: widget.excludeChildSemantics,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: _isInteractive,
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
              _activate();
              return null;
            },
          ),
        },
        child: widget.builder(
          context,
          focused: _focused,
          hovered: _hovered,
          activate: activate,
        ),
      ),
    );
  }
}
