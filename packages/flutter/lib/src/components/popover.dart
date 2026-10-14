// Small interactive content anchored to its opener (DESIGN.md, Popover).

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/anchored_position.dart';
import '../foundation/dismissable_layer.dart';
import '../foundation/overlay_show.dart';
import '../foundation/tokens.g.dart';
import 'menu_panel.dart';
import 'opener_button.dart';

/// A secondary button that opens a popover (DESIGN.md, Popover): a non-modal panel of [builder]'s content, padded
/// [TsuyaSpace.s16], under the button at its start edge (above when there is no room). Opened from the keyboard,
/// focus moves to the first control inside, or to the panel; Escape closes it and focus returns to the button, and
/// so does an outside press or focus leaving. Named by [label].
class Popover extends StatefulWidget {
  /// A popover button labelled [label] showing [builder]'s content; [icon] is optional, before the label.
  const Popover({
    super.key,
    this.icon,
    required this.label,
    required this.builder,
    this.side = AnchorSide.bottom,
    this.align = AnchorAlign.start,
    this.focusNode,
    this.autofocus = false,
  });

  /// Before the label; never read itself.
  final Widget? icon;

  /// The button's one-line label, which also names the panel.
  final String label;

  /// The panel's content.
  final WidgetBuilder builder;

  /// Which side of the button it prefers.
  final AnchorSide side;

  /// How it aligns across from [side].
  final AnchorAlign align;

  /// The node to track the button's focus with, when the caller manages one.
  final FocusNode? focusNode;

  /// Focuses the button as soon as it is built.
  final bool autofocus;

  /// Shows a popover of [builder]'s content anchored to [anchor]'s own render box, named [label] for a screen
  /// reader. Focus moves into it when [byKeyboard] (by default, while the last input was the keyboard).
  static Future<void> show(
    BuildContext anchor, {
    required WidgetBuilder builder,
    String? label,
    AnchorSide side = AnchorSide.bottom,
    AnchorAlign align = AnchorAlign.start,
    bool? byKeyboard,
  }) => _present(anchor, builder: builder, label: label, side: side, align: align, byKeyboard: byKeyboard);

  // [escape] receives what closes the popover as Escape does, and whether Escape is for it now (no layer opened after
  // it, a toast say), for an opener that keeps focus while it is open.
  static Future<void> _present(
    BuildContext anchor, {
    required WidgetBuilder builder,
    String? label,
    AnchorSide side = AnchorSide.bottom,
    AnchorAlign align = AnchorAlign.start,
    bool? byKeyboard,
    FocusScopeNode? scope,
    void Function(VoidCallback close, bool Function() topmost)? escape,
  }) {
    final anchorBox = anchor.findRenderObject();
    if (anchorBox is! RenderBox || !anchorBox.attached) return Future<void>.value();
    final opener = FocusManager.instance.primaryFocus;
    final keyboard = byKeyboard ?? FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    return showTsuyaOverlay<void>(
      context: anchor,
      modal: false,
      anchorBox: anchorBox,
      transitionDuration: TsuyaDuration.fast,
      builder: (context, animation, wrap, close) {
        // Escape hands focus back to the opener; an outside press or focus leaving (the layer's own dismissals)
        // leave it where the user put it.
        void onEscape() {
          if (opener != null && (opener.context?.mounted ?? false)) opener.requestFocus();
          close();
        }

        // a context inside the popover's layer, once built
        BuildContext? layer;
        bool topmost() {
          final context = layer;
          return context != null && context.mounted && DismissableLayer.isTopmost(context);
        }

        escape?.call(onEscape, topmost);

        return _PopoverOverlay(
          anchorBox: anchorBox,
          label: label,
          side: side,
          align: align,
          byKeyboard: keyboard,
          scope: scope,
          animation: animation,
          wrap: (child) => wrap(
            Builder(
              builder: (context) {
                layer = context;
                return Shortcuts(
                  shortcuts: const {SingleActivator(LogicalKeyboardKey.escape): DismissIntent()},
                  child: Actions(actions: {DismissIntent: _EscapeAction(topmost, onEscape)}, child: child),
                );
              },
            ),
          ),
          builder: builder,
        );
      },
    );
  }

  @override
  State<Popover> createState() => _PopoverState();
}

// Escape in the panel, or on the opener while the popover is open (a press leaves focus there), while no layer opened
// after the popover (a toast) is the one Escape is for: disabled then, so the key goes on to that layer.
class _EscapeAction extends Action<DismissIntent> {
  _EscapeAction(this._enabled, this._escape);

  final bool Function() _enabled;
  final VoidCallback _escape;

  @override
  bool get isActionEnabled => _enabled();

  @override
  Object? invoke(DismissIntent intent) {
    _escape();
    return null;
  }
}

class _TabInIntent extends Intent {
  const _TabInIntent();
}

class _PopoverState extends State<Popover> {
  FocusNode? _ownFocusNode;
  bool _open = false;
  VoidCallback? _escape;
  bool Function()? _topmost;
  // a press with a pointer is opening it (the keyboard is not), which leaves focus on the opener, as a click does
  bool _byPointer = false;
  final _panelScope = FocusScopeNode(debugLabel: 'Popover', traversalEdgeBehavior: TraversalEdgeBehavior.stop);
  late final _escapeAction = _EscapeAction(() => _escape != null && (_topmost?.call() ?? false), () => _escape?.call());

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode(debugLabel: 'Popover'));

  @override
  void dispose() {
    _ownFocusNode?.dispose();
    _panelScope.dispose();
    super.dispose();
  }

  void _show() {
    if (_open) return;
    // requested here so the opener reliably has focus for Popover.show to restore it to
    _focusNode.requestFocus();
    setState(() => _open = true);
    Popover._present(
      context,
      builder: widget.builder,
      label: widget.label,
      side: widget.side,
      align: widget.align,
      byKeyboard: !_byPointer,
      scope: _panelScope,
      escape: (close, topmost) {
        _escape = close;
        _topmost = topmost;
      },
    ).whenComplete(() {
      _escape = null;
      _topmost = null;
      if (mounted) setState(() => _open = false);
    });
  }

  // Tab on the opener while the popover is open (a press leaves focus there) goes into the panel, which sits right after
  // the opener on the web: to its first control, else the popover closes and focus goes on.
  void _tabIn() {
    final first = ReadingOrderTraversalPolicy().findFirstFocus(_panelScope);
    // the scope itself when nothing inside can take focus
    if (first != null && first != _panelScope) {
      first.requestFocus();
      return;
    }
    _escape?.call();
    _focusNode.nextFocus();
  }

  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: const {
      SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      SingleActivator(LogicalKeyboardKey.tab): _TabInIntent(),
    },
    child: Actions(
      // declared only while open: a `Shortcuts` further up (a dialog's) looks for its action from the focused
      // widget, and would stop at this one even disabled
      actions: {
        if (_open) DismissIntent: _escapeAction,
        if (_open) _TabInIntent: CallbackAction<_TabInIntent>(onInvoke: (_) => _tabIn()),
      },
      child: Listener(
        onPointerDown: (_) => _byPointer = true,
        onPointerUp: (_) => scheduleMicrotask(() => _byPointer = false),
        onPointerCancel: (_) => _byPointer = false,
        child: OpenerButton(
          icon: widget.icon,
          label: widget.label,
          open: _open,
          onPressed: _show,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
        ),
      ),
    ),
  );
}

// A guess at the panel's size before the first frame measures the real one; only its height can change which side
// it opens on, and the corrected placement follows one frame later.
const _estimate = Size(240, 160);

/// The panel of a [Popover] (DESIGN.md, Popover): an [AnchoredPanel], a dialog with its own focus scope.
class _PopoverOverlay extends StatefulWidget {
  /// The panel of a popover anchored to [anchorBox], focusing its first control when [byKeyboard].
  const _PopoverOverlay({
    required this.anchorBox,
    required this.label,
    required this.side,
    required this.align,
    required this.byKeyboard,
    this.scope,
    required this.animation,
    required this.wrap,
    required this.builder,
  });

  /// The opener's box, which the panel sits against.
  final RenderBox anchorBox;

  /// Names the panel, a dialog, for a screen reader.
  final String? label;

  /// The side of the opener the panel prefers.
  final AnchorSide side;

  /// How the panel lines up with the opener along that side.
  final AnchorAlign align;

  /// The focus scope of the panel's content, when the opener needs it (Tab on the opener enters the panel through it).
  final FocusScopeNode? scope;

  /// Opened from the keyboard: focus moves to the panel's first control.
  final bool byKeyboard;

  /// The overlay's show and hide animation, which fades the panel.
  final Animation<double> animation;

  /// Wraps the panel in the overlay's layer (`showTsuyaOverlay`) and the popover's Escape.
  final Widget Function(Widget child) wrap;

  /// The panel's content.
  final WidgetBuilder builder;

  @override
  State<_PopoverOverlay> createState() => _PopoverOverlayState();
}

class _PopoverOverlayState extends State<_PopoverOverlay> {
  FocusScopeNode? _ownScope;
  FocusScopeNode get _scope =>
      widget.scope ??
      (_ownScope ??= FocusScopeNode(debugLabel: 'Popover', traversalEdgeBehavior: TraversalEdgeBehavior.stop));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.byKeyboard) return;
      (ReadingOrderTraversalPolicy().findFirstFocus(_scope) ?? _scope).requestFocus();
    });
  }

  @override
  void dispose() {
    _ownScope?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      AnchoredPanel(
        anchor: widget.anchorBox,
        side: widget.side,
        align: widget.align,
        estimate: _estimate,
        padding: TsuyaSpace.s16,
        opacity: widget.animation,
        wrap: widget.wrap,
        child: Semantics(
          role: SemanticsRole.dialog,
          label: widget.label,
          explicitChildNodes: true,
          child: FocusScope(
            node: _scope,
            child: Builder(builder: widget.builder),
          ),
        ),
      ),
    ],
  );
}
