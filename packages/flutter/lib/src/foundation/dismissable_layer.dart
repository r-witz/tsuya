// Escape, an outside press, or focus leaving dismiss an overlay (DESIGN.md, Foundations: Accessibility).
// Used by menus, popovers, selects, comboboxes, tooltips and toasts.
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Wraps an overlay's content so it dismisses on Escape, a pointer press outside [child]'s bounds, or — when
/// [modal] is false — focus leaving it (a modal layer traps focus instead, with [FocusTrap], so it never leaves).
/// When several layers are open at once (a popover opening another), only the one opened last reacts; the others
/// wait their turn as it closes.
class DismissableLayer extends StatefulWidget {
  /// A layer around [child] that calls [onDismiss] once, when it should close.
  const DismissableLayer({
    super.key,
    required this.onDismiss,
    this.modal = true,
    this.ambient = false,
    this.closing = false,
    this.opener,
    required this.child,
  });

  /// Called once, when this layer should close.
  final VoidCallback onDismiss;

  /// Whether this layer traps focus elsewhere (a dialog, a sheet): then focus leaving does not, by itself, dismiss
  /// it. Non-modal layers (menus, popovers) also dismiss when focus leaves them.
  final bool modal;

  /// Whether this layer is ambient rather than contextual (a toast): only Escape dismisses it, a press or focus
  /// elsewhere never does, and a press on it is not an outside press for the layers under it.
  final bool ambient;

  /// Whether this layer is on its way out (fading away): it stops answering and leaves the stack, so the layer under
  /// it gets Escape and presses at once, not once it is gone.
  final bool closing;

  /// The control that opened this layer, for Tab, which follows the web where the layer sits right after its opener: a
  /// non-modal layer closes when Tab has nowhere left to go inside it, and focus moves on to the control after
  /// [opener]. Shift+Tab from its first control goes to [opener] with the layer still open; leaving [opener] from
  /// there closes it. Without one, Tab only closes it.
  final FocusNode? opener;

  /// The overlay's content.
  final Widget child;

  /// Whether the layer around [context] is the topmost open one, the one Escape is for; false outside any layer. For
  /// an Escape of its own inside a layer (or on its opener), which must give way to a layer opened after it.
  static bool isTopmost(BuildContext context) =>
      context.findAncestorStateOfType<_DismissableLayerState>()?._topmost ?? false;

  @override
  State<DismissableLayer> createState() => _DismissableLayerState();
}

class _DismissableLayerState extends State<DismissableLayer> {
  // the open layers, outermost first: only the last one reacts to Escape and outside presses
  static final List<_DismissableLayerState> _stack = [];
  final _focusScope = FocusScopeNode(debugLabel: 'DismissableLayer');
  // focus is on the opener (left there on open, or sent back with Shift+Tab): the layer stays open until it leaves
  bool _atOpener = false;
  late final _dismissAction = _DismissAction(this);

  bool get _topmost => _stack.isNotEmpty && identical(_stack.last, this);

  // the layer that answers presses and focus leaving: the last one that is not ambient
  bool get _topmostSolid {
    final solid = _stack.where((layer) => !layer.widget.ambient);
    return solid.isNotEmpty && identical(solid.last, this);
  }

  bool _contains(Offset position) {
    final box = context.findRenderObject();
    return box is RenderBox && box.attached && (Offset.zero & box.size).contains(box.globalToLocal(position));
  }

  @override
  void initState() {
    super.initState();
    _stack.add(this);
    // Tab at the last (first) control of a non-modal layer finds nothing further, instead of looping back into it
    if (!widget.modal) _focusScope.traversalEdgeBehavior = TraversalEdgeBehavior.stop;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onGlobalPointerDown);
    if (!widget.modal && !widget.ambient) {
      _focusScope.addListener(_onFocusChange);
      // opened with focus left on its opener (a click, a select): focus leaving it, not into the layer, closes it
      if (widget.opener?.hasFocus ?? false) {
        _atOpener = true;
        widget.opener!.addListener(_onOpenerFocusChange);
      }
    }
    if (widget.ambient) {
      FocusManager.instance.addLateKeyEventHandler(_onLateKey);
      HardwareKeyboard.instance.addHandler(_onUnfocusedKey);
    }
  }

  // An ambient layer is not where focus is, so Escape reaches it only once nothing around the focus has taken it
  // (the layers under it do not while it is the topmost one), wherever focus is.
  bool _escapes(KeyEvent event) => event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape && _topmost;

  KeyEventResult _onLateKey(KeyEvent event) {
    if (!_escapes(event)) return KeyEventResult.ignored;
    widget.onDismiss();
    return KeyEventResult.handled;
  }

  // the focus system hears no key at all while nothing has focus (a press does not focus a button)
  bool _onUnfocusedKey(KeyEvent event) {
    if (FocusManager.instance.primaryFocus != null || !_escapes(event)) return false;
    widget.onDismiss();
    return true;
  }

  @override
  void didUpdateWidget(DismissableLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.closing) _stack.remove(this);
  }

  @override
  void dispose() {
    if (widget.ambient) {
      FocusManager.instance.removeLateKeyEventHandler(_onLateKey);
      HardwareKeyboard.instance.removeHandler(_onUnfocusedKey);
    }
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onGlobalPointerDown);
    if (_atOpener) widget.opener?.removeListener(_onOpenerFocusChange);
    _stack.remove(this);
    _focusScope.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusScope.hasFocus) _leaveOpener();
    if (_topmostSolid && !_atOpener && !_focusScope.hasFocus) widget.onDismiss();
  }

  void _leaveOpener() {
    if (!_atOpener) return;
    _atOpener = false;
    widget.opener?.removeListener(_onOpenerFocusChange);
  }

  // Shift+Tab (or anything else) took focus off the opener it had been sent back to, and not into the layer
  void _onOpenerFocusChange() {
    if (widget.opener?.hasFocus ?? true) return;
    _leaveOpener();
    if (_topmostSolid && !_focusScope.hasFocus) widget.onDismiss();
  }

  void _onGlobalPointerDown(PointerEvent event) {
    if (event is! PointerDownEvent || widget.ambient || !_topmostSolid) return;
    // inside this layer, or one opened after it (a toast above a dialog): not an outside press
    final from = _stack.indexOf(this);
    if (!_stack.skip(from).any((layer) => layer._contains(event.position))) widget.onDismiss();
  }

  // Tab moves on inside the layer while it can; once it cannot, the layer closes and focus goes on from its opener.
  // Shift+Tab goes to the opener first, the layer open, as the opener sits right before the layer on the web.
  void _tabOut(bool forward) {
    final node = FocusManager.instance.primaryFocus;
    if (node != null && (forward ? node.nextFocus() : node.previousFocus())) return;
    final opener = widget.opener;
    if (!forward && opener != null && (opener.context?.mounted ?? false)) {
      if (!_atOpener) opener.addListener(_onOpenerFocusChange);
      _atOpener = true;
      opener.requestFocus();
      return;
    }
    widget.onDismiss();
    if (opener == null) return;
    // once the layer is out of the tree, so that its own controls (a select's listbox sits under its trigger) are not
    // the ones found next
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!(opener.context?.mounted ?? false)) return;
      opener.requestFocus();
      forward ? opener.nextFocus() : opener.previousFocus();
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  // Escape is mapped outside the scope, not inside it: focus can rest on the scope itself (a dialog with nothing to
  // focus), and a key event only goes up from where focus is.
  @override
  Widget build(BuildContext context) {
    final tabs = !widget.modal && !widget.ambient;
    return Actions(
      actions: <Type, Action<Intent>>{DismissIntent: _dismissAction, if (tabs) _TabOutIntent: _TabOutAction(this)},
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
          if (tabs) ...const {
            SingleActivator(LogicalKeyboardKey.tab): _TabOutIntent(forward: true),
            SingleActivator(LogicalKeyboardKey.tab, shift: true): _TabOutIntent(forward: false),
          },
        },
        child: FocusScope(node: _focusScope, child: widget.child),
      ),
    );
  }
}

class _TabOutIntent extends Intent {
  const _TabOutIntent({required this.forward});

  final bool forward;
}

// Like the dismiss action, only for the topmost layer: a layer opened from this one answers Tab first.
class _TabOutAction extends Action<_TabOutIntent> {
  _TabOutAction(this._state);

  final _DismissableLayerState _state;

  @override
  bool get isActionEnabled => _state._topmost;

  @override
  Object? invoke(_TabOutIntent intent) {
    _state._tabOut(intent.forward);
    return null;
  }
}

// Dismisses the layer it belongs to, but only while that layer is the topmost one: otherwise it is disabled, so the
// key (whichever `Shortcuts` mapped it to `DismissIntent`, here or further up) keeps looking past it, up the tree.
class _DismissAction extends Action<DismissIntent> {
  _DismissAction(this._state);

  final _DismissableLayerState _state;

  @override
  bool get isActionEnabled => _state._topmost;

  @override
  Object? invoke(DismissIntent intent) {
    _state.widget.onDismiss();
    return null;
  }
}
