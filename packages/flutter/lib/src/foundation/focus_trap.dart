// Trapping and restoring focus for a modal region (DESIGN.md, Foundations: Accessibility).
// Used by dialogs, sheets and command palettes.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Traps keyboard focus inside [child] (Tab and Shift+Tab cycle through it and never leave), moves it in on
/// mount — to [initialFocus] when given, otherwise the first focusable descendant — and restores it to whatever
/// held it before, once this is removed from the tree.
class FocusTrap extends StatefulWidget {
  /// A trap around [child].
  const FocusTrap({super.key, this.initialFocus, this.opener, this.closing = false, required this.child});

  /// The descendant to focus first; without one, the first focusable descendant in reading order.
  final FocusNode? initialFocus;

  /// The control to give the focus back to, when it is not the one holding it as this mounts (a control pressed
  /// with a mouse or a finger does not hold it). Falls back to the node that held it once this mounts, when it is
  /// gone by then.
  final FocusNode? opener;

  /// Whether the region is on its way out (fading away): the opener gets focus back now, as a native dialog's does
  /// as it closes, so a key pressed while it fades reaches what is under it, not a region about to go.
  final bool closing;

  /// The trapped region.
  final Widget child;

  @override
  State<FocusTrap> createState() => _FocusTrapState();
}

class _FocusTrapState extends State<FocusTrap> {
  final _scope = FocusScopeNode(debugLabel: 'FocusTrap');
  FocusNode? _opener;

  @override
  void initState() {
    super.initState();
    _opener = FocusManager.instance.primaryFocus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      (widget.initialFocus ?? _firstControl()).requestFocus();
    });
  }

  // The first control in reading order, looking through nested scopes (the dismissable layer's own is focusable, but
  // landing on it would leave focus on no control); the trap's own scope when it holds none.
  FocusNode _firstControl() {
    final policy = ReadingOrderTraversalPolicy();
    FocusNode? node = policy.findFirstFocus(_scope);
    while (node is FocusScopeNode && node != _scope) {
      final inner = policy.findFirstFocus(node);
      if (inner == node) break;
      node = inner;
    }
    return node ?? _scope;
  }

  @override
  void didUpdateWidget(FocusTrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.closing && !oldWidget.closing) _restore();
  }

  bool _restored = false;

  void _restore() {
    if (_restored) return;
    _restored = true;
    for (final opener in [widget.opener, _opener]) {
      if (opener != null && (opener.context?.mounted ?? false)) {
        opener.requestFocus();
        break;
      }
    }
  }

  @override
  void dispose() {
    _restore();
    _scope.dispose();
    super.dispose();
  }

  KeyEventResult _trapTab(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.tab) return KeyEventResult.ignored;
    // controls only: a nested scope (the dismissable layer's own) is focusable but is not an edge of the trap
    final nodes = _scope.traversalDescendants.where((node) => node is! FocusScopeNode).toList();
    if (nodes.isEmpty) return KeyEventResult.ignored;
    final forward = !HardwareKeyboard.instance.isShiftPressed;
    // the primary focus, not the scope's focusedChild: that is the outermost node holding it (a Focus wrapped around
    // a group of controls, a dialog's actions, is not itself one of them)
    final current = FocusManager.instance.primaryFocus;
    if (forward && current == nodes.last) {
      nodes.first.requestFocus();
      return KeyEventResult.handled;
    }
    if (!forward && current == nodes.first) {
      nodes.last.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => FocusScope(node: _scope, onKeyEvent: _trapTab, child: widget.child);
}
