// One tab stop for a group of controls (DESIGN.md, Foundations: States). Used by segmented
// controls, radio groups, tabs, tab bars, menus, listboxes and toolbars.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'type_ahead.dart';

/// Manages one [FocusNode] per item so a group behaves as a single tab stop: arrow keys move which item has focus
/// (following [axis] and the ambient [Directionality]), Home and End jump to the ends, [wrap] makes the ends
/// adjacent, and typed characters jump to the next item whose [labelOf] starts with them. Call [builder] with the
/// nodes already configured (only the active one is a tab stop) and lay the items out yourself.
class RovingFocus extends StatefulWidget {
  /// A group of [count] items.
  const RovingFocus({
    super.key,
    required this.count,
    required this.builder,
    this.axis = Axis.horizontal,
    this.wrap = true,
    this.labelOf,
    this.disabledOf,
    this.disabledFocusable = false,
    this.initialIndex = 0,
  });

  /// How many items the group has.
  final int count;

  /// Builds the group from the focus node of each item (index 0 to [count] − 1, in order) and the active index.
  final Widget Function(BuildContext context, List<FocusNode> nodes, int activeIndex) builder;

  /// The direction the arrow keys move in.
  final Axis axis;

  /// Whether moving past either end goes to the other end.
  final bool wrap;

  /// The label of each item, for type-ahead; without it, typing does not move the focus.
  final String Function(int index)? labelOf;

  /// Whether an item is disabled: excluded from arrows, Home, End and type-ahead, unless [disabledFocusable] is
  /// true. Without one, no item is disabled.
  final bool Function(int index)? disabledOf;

  /// Whether a disabled item still takes focus, as a disabled menu item does (announced as disabled rather than
  /// skipped). Default false.
  final bool disabledFocusable;

  /// The active item (the tab stop, where the arrows start): the item focused first, and followed when it changes,
  /// so a group whose selection the app changes keeps its tab stop on the selected item. The focus itself does not
  /// move.
  final int initialIndex;

  @override
  State<RovingFocus> createState() => _RovingFocusState();
}

class _RovingFocusState extends State<RovingFocus> {
  late List<FocusNode> _nodes;
  late int _active = _resolveActive(widget.initialIndex);
  final _typeAhead = TypeAhead();

  /// Whether item [index] takes part in arrows, Home, End and type-ahead: always, unless [RovingFocus.disabledOf]
  /// marks it disabled and [RovingFocus.disabledFocusable] is false.
  bool _reachable(int index) => widget.disabledFocusable || !(widget.disabledOf?.call(index) ?? false);

  int _firstReachable() {
    for (var i = 0; i < widget.count; i++) {
      if (_reachable(i)) return i;
    }
    return 0;
  }

  int _lastReachable() {
    for (var i = widget.count - 1; i >= 0; i--) {
      if (_reachable(i)) return i;
    }
    return widget.count - 1;
  }

  int _clampIndex(int index, int count) => count == 0 ? 0 : index.clamp(0, count - 1);

  // the preferred index, clamped to range, else the first reachable item
  int _resolveActive(int preferred) {
    final clamped = _clampIndex(preferred, widget.count);
    return widget.count == 0 || _reachable(clamped) ? clamped : _firstReachable();
  }

  @override
  void initState() {
    super.initState();
    _nodes = _build();
  }

  FocusNode _node(int i) =>
      FocusNode(debugLabel: 'roving $i', skipTraversal: i != _active)..addListener(() => _onFocusChange(i));

  List<FocusNode> _build() => [for (var i = 0; i < widget.count; i++) _node(i)];

  void _onFocusChange(int index) {
    if (_nodes[index].hasFocus && _active != index) setState(() => _active = index);
  }

  @override
  void didUpdateWidget(RovingFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    final countChanged = widget.count != oldWidget.count;
    if (!countChanged && widget.initialIndex == oldWidget.initialIndex) return;
    // keep the existing nodes (and so the focus), adding or removing only the difference
    if (countChanged) {
      for (var i = widget.count; i < _nodes.length; i++) {
        _nodes[i].dispose();
      }
      _nodes = [..._nodes.take(widget.count)];
    }
    _active = _resolveActive(widget.initialIndex != oldWidget.initialIndex ? widget.initialIndex : _active);
    for (var i = _nodes.length; i < widget.count; i++) {
      _nodes.add(_node(i));
    }
    for (var i = 0; i < _nodes.length; i++) {
      _nodes[i].skipTraversal = i != _active;
    }
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _moveTo(int index) {
    if (_nodes.isEmpty || index == _active || !_reachable(index)) return;
    setState(() {
      _nodes[_active].skipTraversal = true;
      _active = index;
      _nodes[_active].skipTraversal = false;
    });
    _nodes[_active].requestFocus();
  }

  void _move(int delta) {
    final count = _nodes.length;
    if (count == 0) return;
    var next = _active;
    for (var step = 0; step < count; step++) {
      next = widget.wrap ? (next + delta + count) % count : next + delta;
      if (next < 0 || next >= count) return;
      if (_reachable(next)) break;
    }
    _moveTo(next);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final forward = widget.axis == Axis.horizontal
        ? (rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight)
        : LogicalKeyboardKey.arrowDown;
    final backward = widget.axis == Axis.horizontal
        ? (rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft)
        : LogicalKeyboardKey.arrowUp;
    final key = event.logicalKey;
    if (key == forward) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == backward) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _moveTo(_firstReachable());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _moveTo(_lastReachable());
      return KeyEventResult.handled;
    }
    final labelOf = widget.labelOf;
    if (labelOf != null && isTypeAheadKey(event)) {
      final reachable = [
        for (var i = 0; i < widget.count; i++)
          if (_reachable(i)) i,
      ];
      final labels = [for (final i in reachable) labelOf(i)];
      final target = _typeAhead.type(event.character!, labels, reachable.indexOf(_active));
      if (target != null) {
        _moveTo(reachable[target]);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onKeyEvent: _handleKey,
    // This node only routes key events for the group: it never gets its own semantics node, so a strict composite
    // role (DESIGN.md, Tabs: `SemanticsRole.tabBar`) sees its items as direct children, not through an empty one.
    includeSemantics: false,
    child: widget.builder(context, _nodes, _active),
  );
}
