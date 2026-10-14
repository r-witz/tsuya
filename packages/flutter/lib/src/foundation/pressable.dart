// The base of every control (DESIGN.md, Foundations: States).
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'focus_ring.dart';
import 'motion.dart';
import 'opener_focus.dart';
import 'theme.dart';
import 'tokens.g.dart';
import 'touch_platform.dart';

/// How a [Pressable] answers a press.
enum PressFeedback {
  /// Scales to [TsuyaState.pressedScale]: buttons, icon buttons, chips.
  shrink,

  /// [TsuyaColors.fill] behind it while pressed or hovered: rows, menu items.
  highlight,

  /// Nothing: the control shows its own change, like a switch or a segment.
  none,
}

/// The shared behaviour of every control: press feedback, the focus ring in keyboard highlight mode,
/// Enter and Space, fading and unfocusing when disabled, and a target of at least [TsuyaSize.target] on touch
/// platforms or [TsuyaSize.targetPointer] with a mouse, the drawing centred in it. Announced as a button, a toggle
/// ([toggled]) or a radio ([checked]), with [label] when [child] carries no text of its own.
class Pressable extends StatefulWidget {
  /// A pressable region around [child]; disabled when [onPressed] is null.
  const Pressable({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.label,
    this.selected,
    this.toggled,
    this.checked,
    this.mixed,
    this.inMutuallyExclusiveGroup = false,
    this.expanded,
    this.value,
    this.role,
    this.feedback = PressFeedback.shrink,
    this.alignment = Alignment.center,
    this.quiet = false,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.focusOnPress = false,
  });

  /// Called on a press; null disables the control.
  final VoidCallback? onPressed;

  /// What is drawn.
  final Widget child;

  /// The shape the press highlight and the focus ring follow.
  final BorderRadius borderRadius;

  /// What a screen reader announces, when [child] carries no text of its own (an icon's meaning).
  final String? label;

  /// Marks it as the selected item of a set (a tab, a chip in a single-selection group).
  final bool? selected;

  /// Marks it as a two-state toggle (an icon button acting as a toggle).
  final bool? toggled;

  /// Marks it as a checkbox or radio, checked, unchecked or (with [mixed]) indeterminate.
  final bool? checked;

  /// Marks a tristate [checked] control as half-checked rather than fully checked or unchecked.
  final bool? mixed;

  /// Groups it with the other controls where exactly one is [checked] (a radio, a chip in a single-selection
  /// group); never set for a checkbox.
  final bool inMutuallyExclusiveGroup;

  /// Marks it as open or closed (a select or combobox trigger, a disclosure).
  final bool? expanded;

  /// The current value announced after [label] (a select or combobox trigger's chosen option).
  final String? value;

  /// The semantics role it is announced with, replacing the default (a button, or a toggle or radio from [toggled]
  /// and [checked]) — a select or combobox trigger, say.
  final SemanticsRole? role;

  /// How it answers a press.
  final PressFeedback feedback;

  /// Where the drawing sits in the target when the constraints are tight (a column that stretches it): centred for
  /// a button or an icon, at the start for a labelled checkbox or switch, whose row hugs the start on the web.
  final AlignmentGeometry alignment;

  /// A control with no fill of its own: [TsuyaColors.fill] behind it on hover, whatever [feedback] is.
  final bool quiet;

  /// A tooltip for this control's own semantics node (an icon button's label, shown on fine pointers): set here,
  /// rather than through a wrapping tooltip widget, so it stays on the one node instead of a separate boundary.
  final String? tooltip;

  /// The node to track focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses it as soon as it is built.
  final bool autofocus;

  /// Whether a press focuses it, as a click does a native control on the web: for the items of a group with roving
  /// focus (a radio, a tab, a segment), whose arrow keys then go on from the one pressed. The keyboard ring does not
  /// show for a press, only for the keys that follow.
  final bool focusOnPress;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  static const _keys = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;
  // focused by a press (`focusOnPress`): no keyboard ring until focus leaves and comes back, as `:focus-visible` on the web
  bool _pressFocused = false;

  bool get _enabled => widget.onPressed != null;

  void _press(bool pressed) {
    if (pressed != _pressed) setState(() => _pressed = pressed);
  }

  @override
  void didUpdateWidget(Pressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final still = reducedMotion(context);
    final highlight = widget.feedback == PressFeedback.highlight ? _pressed || _hovered : widget.quiet && _hovered;
    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        color: highlight && _enabled ? theme.colors.fill : null,
        borderRadius: widget.borderRadius,
      ),
      child: widget.child,
    );
    if (widget.feedback == PressFeedback.shrink) {
      result = AnimatedScale(
        scale: _pressed && !still ? TsuyaState.pressedScale : 1,
        duration: TsuyaDuration.fast,
        curve: TsuyaEasing.standard,
        child: result,
      );
    }
    result = FocusRing(focused: _focused && !_pressFocused, borderRadius: widget.borderRadius, child: result);
    if (!_enabled) result = Opacity(opacity: TsuyaState.disabledOpacity, child: result);
    result = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: touchPlatform ? TsuyaSize.target : TsuyaSize.targetPointer,
        minHeight: touchPlatform ? TsuyaSize.target : TsuyaSize.targetPointer,
      ),
      child: Align(alignment: widget.alignment, widthFactor: 1, heightFactor: 1, child: result),
    );
    return Semantics(
      container: true,
      button: widget.role == null && widget.toggled == null && widget.checked == null,
      toggled: widget.toggled,
      checked: widget.checked,
      mixed: widget.mixed,
      inMutuallyExclusiveGroup: widget.inMutuallyExclusiveGroup ? true : null,
      expanded: widget.expanded,
      value: widget.value,
      role: widget.role,
      selected: widget.selected,
      enabled: _enabled,
      label: widget.label,
      tooltip: widget.tooltip,
      child: FocusableActionDetector(
        enabled: _enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        shortcuts: _keys,
        actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onPressed?.call())},
        onFocusChange: (focused) {
          if (!focused) _pressFocused = false;
        },
        onShowFocusHighlight: (focused) => setState(() => _focused = focused),
        onShowHoverHighlight: (hovered) => setState(() => _hovered = hovered),
        mouseCursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: Builder(
          builder: (focusContext) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _enabled
                ? (_) {
                    if (widget.focusOnPress) {
                      _pressFocused = true;
                      Focus.maybeOf(focusContext, createDependency: false)?.requestFocus();
                    }
                    _press(true);
                  }
                : null,
            onTapUp: _enabled ? (_) => _press(false) : null,
            onTapCancel: _enabled ? () => _press(false) : null,
            // a press does not focus the control, but what it opens gives focus back to it
            onTap: _enabled
                ? () => OpenerFocus.pressing(Focus.maybeOf(focusContext, createDependency: false), widget.onPressed!)
                : null,
            child: result,
          ),
        ),
      ),
    );
  }
}
