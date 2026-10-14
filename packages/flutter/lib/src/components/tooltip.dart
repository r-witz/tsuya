// A short label for a control (DESIGN.md, Tooltip): fine pointers after a delay, keyboard focus at
// once, never on touch; stays while the pointer is over it, with a grace period after leaving either; Escape and a
// press hide it. Inverted colours, radius-xs, padding 4 8, caption type, at most 240 wide, above its trigger.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../foundation/anchored_position.dart';
import '../foundation/presence.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';

/// A short label shown above [child] (DESIGN.md, Tooltip): on a mouse or a pen, after [TsuyaDuration.tooltipDelay];
/// on keyboard focus, at once; never on touch. Stays open while the pointer is over the bubble itself, with a
/// [TsuyaDuration.fast] grace after leaving either; Escape or a press on [child] hides it. With [describe],
/// [message] is attached as [child]'s semantics `tooltip` (set [describe] to false when [child] already carries
/// one of its own, as `Pressable(tooltip:)` does for an icon button repeating its own label). [side] can be any of
/// the four, [AnchorSide.start] and [AnchorSide.end] following the text direction; while not [enabled] it never
/// shows (and goes if it was), with [child] kept in the same place in the tree.
class Tooltip extends StatefulWidget {
  /// Shows [message] above [child] (or on [side], flipped when it does not fit).
  const Tooltip({
    super.key,
    required this.message,
    this.side = AnchorSide.top,
    this.describe = true,
    this.enabled = true,
    required this.child,
  });

  /// The tooltip's text.
  final String message;

  /// The preferred side. Default [AnchorSide.top].
  final AnchorSide side;

  /// Attaches [message] as [child]'s `tooltip` semantics. Default true; false when [child] already carries it.
  final bool describe;

  /// Whether it shows at all. Default true.
  final bool enabled;

  /// The trigger.
  final Widget child;

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> {
  final _overlay = OverlayPortalController();
  final _triggerKey = GlobalKey();
  // the control inside keeps its place in the tab order: Tab leaves this scope for the next control after it
  final _focusScope = FocusScopeNode(debugLabel: 'Tooltip', traversalEdgeBehavior: TraversalEdgeBehavior.parentScope);
  Timer? _timer;
  bool _open = false;
  // The pointer can cross from the trigger to the bubble and stay over it: MouseTracker notifies the entered
  // region before the exited one, so the trigger's exit checks this instead of scheduling a hide unconditionally.
  bool _overBubble = false;

  @override
  void initState() {
    super.initState();
    _focusScope.addListener(_onFocusChange);
    _focusScope.onKeyEvent = _onFocusedEscape;
    HardwareKeyboard.instance.addHandler(_onEscape);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusScope.removeListener(_onFocusChange);
    _focusScope.dispose();
    HardwareKeyboard.instance.removeHandler(_onEscape);
    super.dispose();
  }

  @override
  void didUpdateWidget(Tooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // hiding the portal is not allowed while building
    if (!widget.enabled && _open) WidgetsBinding.instance.addPostFrameCallback((_) => _set(false));
  }

  void _set(bool next) {
    _timer?.cancel();
    if (!mounted || _open == next || (next && !widget.enabled)) return;
    setState(() => _open = next);
    if (next) {
      _overlay.show();
    } else {
      _overlay.hide();
    }
  }

  void _after(Duration delay, bool next) {
    _timer?.cancel();
    if (delay == Duration.zero) {
      _set(next);
    } else {
      _timer = Timer(delay, () => _set(next));
    }
  }

  void _onFocusChange() {
    if (_focusScope.hasFocus) {
      if (FocusManager.instance.highlightMode != FocusHighlightMode.touch) _after(Duration.zero, true);
    } else {
      _after(Duration.zero, false);
    }
  }

  // A tooltip the pointer shows hides on Escape, which goes on to what is around it. One on the control that has the
  // focus consumes it instead (below), so the next Escape is the one that reaches a dialog around it.
  bool _onEscape(KeyEvent event) {
    final hides = event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape && _open;
    if (hides && !_focusScope.hasFocus) _after(Duration.zero, false);
    return false;
  }

  KeyEventResult _onFocusedEscape(FocusNode node, KeyEvent event) {
    final escape = event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape;
    if (!escape || !_open) return KeyEventResult.ignored;
    _after(Duration.zero, false);
    return KeyEventResult.handled;
  }

  // The bubble follows its trigger as it moves (a scroll under a pointer that stays): checked after each frame while
  // open (a callback asks for no frame of its own), rebuilding when the trigger's rect is no longer the one placed.
  Rect? _placedAnchor;
  bool _watching = false;

  void _watchAnchor(Rect placed) {
    _placedAnchor = placed;
    if (_watching) return;
    _watching = true;
    void check(Duration _) {
      final box = _triggerKey.currentContext?.findRenderObject();
      if (!mounted || !_open || box is! RenderBox || !box.attached) {
        _watching = false;
        return;
      }
      if (box.localToGlobal(Offset.zero) & box.size != _placedAnchor) setState(() {});
      WidgetsBinding.instance.addPostFrameCallback(check);
    }

    WidgetsBinding.instance.addPostFrameCallback(check);
  }

  Widget _buildBubble(BuildContext context) {
    final renderObject = _triggerKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return const SizedBox.shrink();
    final anchor = renderObject.localToGlobal(Offset.zero) & renderObject.size;
    _watchAnchor(anchor);
    final theme = TsuyaTheme.of(context);
    // Placed once laid out, by the shared primitive, so a long message shifts to space-16 inside the view rather than
    // hanging off it; it fills the overlay, and only its bubble takes hits.
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _BubbleLayout(anchor: anchor, side: widget.side, direction: Directionality.of(context)),
        child: Presence(
          visible: _open && widget.enabled,
          builder: (context, animation) => FadeTransition(
            opacity: animation,
            child: MouseRegion(
              onEnter: (_) {
                _overBubble = true;
                _timer?.cancel();
              },
              onExit: (_) {
                _overBubble = false;
                _after(TsuyaDuration.fast, false);
              },
              child: ExcludeSemantics(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.text,
                      borderRadius: BorderRadius.circular(TsuyaRadius.xs),
                      // where a forced-colours scheme flattens the fill, an edge keeps it apart from what it covers.
                      border: MediaQuery.highContrastOf(context) ? Border.all(color: theme.colors.bg) : null,
                    ),
                    // a message taller than the room it has is cut off at the bubble's edge
                    child: ClipRect(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: TsuyaSpace.s8, vertical: TsuyaSpace.s4),
                        child: Text(
                          widget.message,
                          style: theme.text(TsuyaType.caption).copyWith(color: theme.colors.bg),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Semantics sits directly around the real child, inside the portal: OverlayPortal wraps its own `child` in a
    // traversal-order marker of its own (for the deferred bubble), which would otherwise be the nearer node.
    final child = widget.describe ? Semantics(tooltip: widget.message, child: widget.child) : widget.child;
    // The overlay portal wraps only the child: its measured box (via `_triggerKey`) and its pointer/focus handling
    // stay outside it, around it, rather than inside its `child` slot.
    final overlay = KeyedSubtree(
      key: _triggerKey,
      child: OverlayPortal(controller: _overlay, overlayChildBuilder: _buildBubble, child: child),
    );
    // MouseRegion only answers a mouse or a stylus (never touch): a fine pointer, exactly as DESIGN.md asks.
    return MouseRegion(
      onEnter: (_) => _after(_open ? Duration.zero : TsuyaDuration.tooltipDelay, true),
      onExit: (_) {
        if (!_overBubble) _after(TsuyaDuration.fast, false);
      },
      child: FocusScope(
        node: _focusScope,
        child: Listener(
          // Listener defers hit-testing to its child by default: a plain child with nothing of its own to hit
          // (an icon, bare text) would never reach `onPointerDown`, so this claims the whole trigger area itself.
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _after(Duration.zero, false),
          child: overlay,
        ),
      ),
    );
  }
}

// Lays the bubble out in the room the shared primitive gives it (240 wide at most, by the bubble itself): above or
// below the trigger, the view's width and the height of the side with more room; beside it, the view's height and the
// width of the side with more room. Then places it by the same primitive: centred on the trigger on its side, flipped
// and shifted to stay space-16 inside the view. A message that does not fit its room is clipped, not let to cover the
// trigger or leave the view.
class _BubbleLayout extends SingleChildLayoutDelegate {
  const _BubbleLayout({required this.anchor, required this.side, required this.direction});

  final Rect anchor;
  final AnchorSide side;
  final TextDirection direction;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // an element that fits nowhere goes on the side with more room, and is told how much there is
    final room = anchoredPosition(
      anchor: anchor,
      size: const Size(double.maxFinite, double.maxFinite),
      viewport: constraints.biggest,
      side: side,
      alignment: AnchorAlign.center,
      direction: direction,
    );
    return BoxConstraints(maxWidth: room.maxWidth, maxHeight: room.maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) => anchoredPosition(
    anchor: anchor,
    size: childSize,
    viewport: size,
    side: side,
    alignment: AnchorAlign.center,
    direction: direction,
  ).offset;

  @override
  bool shouldRelayout(_BubbleLayout old) => anchor != old.anchor || side != old.side || direction != old.direction;
}
