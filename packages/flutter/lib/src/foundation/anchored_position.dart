// Placing a floating element next to an anchor (DESIGN.md, Foundations: Accessibility).
// Pure maths, no BuildContext: recompute it whenever the anchor's rect, the available size or the
// viewport changes (on scroll, on resize) to keep a menu, popover, select panel, combobox panel or tooltip in
// place. Used by menus, popovers, selects, comboboxes and tooltips.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'tokens.g.dart';

/// Which side of the anchor a floating element prefers. [start] and [end] follow the text direction (so they mean
/// before/after, not left/right).
enum AnchorSide {
  /// Above the anchor.
  top,

  /// Below the anchor.
  bottom,

  /// Before the anchor (left in left-to-right, right in right-to-left).
  start,

  /// After the anchor (right in left-to-right, left in right-to-left).
  end,
}

/// Where a floating element aligns along the axis across from [AnchorSide]: horizontal for [AnchorSide.top] and
/// [AnchorSide.bottom], vertical for [AnchorSide.start] and [AnchorSide.end].
enum AnchorAlign {
  /// The edge nearest the anchor's own start.
  start,

  /// Centred on the anchor.
  center,

  /// The edge nearest the anchor's own end.
  end,
}

/// Where [anchoredPosition] places a floating element: its [offset] inside the viewport, the [maxHeight] and
/// [maxWidth] it should be constrained to so it does not overflow, and the [side] actually used (after any flip).
@immutable
class AnchoredPosition {
  /// A placement.
  const AnchoredPosition({required this.offset, required this.maxHeight, required this.maxWidth, required this.side});

  /// The top-left corner of the floating element, in the same coordinates as the `anchor` and `viewport` given to
  /// [anchoredPosition].
  final Offset offset;

  /// The height the floating element should be constrained to.
  final double maxHeight;

  /// The width the floating element should be constrained to: the view's width less the margin on both sides above or
  /// below the anchor, and beside it (on [AnchorSide.start] or [AnchorSide.end]) the room there is on that side, which
  /// is less than the element's own width only when neither side has room for it.
  final double maxWidth;

  /// The side it ended up on (the preferred one, or its opposite after a flip).
  final AnchorSide side;
}

/// The widest a floating element can be and still sit [margin] inside [viewport] on both sides: the view's width less
/// 2 × [margin]. Constrain a panel (menu, popover, select, combobox, tooltip) to it, then place it with
/// [anchoredPosition], whose shift keeps it [margin] from the edge.
double anchoredMaxWidth(Size viewport, {double margin = TsuyaSpace.s16}) => math.max(0.0, viewport.width - 2 * margin);

enum _Edge { top, bottom, left, right }

_Edge _resolve(AnchorSide side, bool rtl) => switch (side) {
  AnchorSide.top => _Edge.top,
  AnchorSide.bottom => _Edge.bottom,
  AnchorSide.start => rtl ? _Edge.right : _Edge.left,
  AnchorSide.end => rtl ? _Edge.left : _Edge.right,
};

AnchorSide _unresolve(_Edge edge, bool rtl) => switch (edge) {
  _Edge.top => AnchorSide.top,
  _Edge.bottom => AnchorSide.bottom,
  _Edge.left => rtl ? AnchorSide.end : AnchorSide.start,
  _Edge.right => rtl ? AnchorSide.start : AnchorSide.end,
};

_Edge _opposite(_Edge edge) => switch (edge) {
  _Edge.top => _Edge.bottom,
  _Edge.bottom => _Edge.top,
  _Edge.left => _Edge.right,
  _Edge.right => _Edge.left,
};

bool _isVertical(_Edge edge) => edge == _Edge.top || edge == _Edge.bottom;

double _roomAt(_Edge edge, Rect anchor, Size viewport) => switch (edge) {
  _Edge.top => anchor.top,
  _Edge.bottom => viewport.height - anchor.bottom,
  _Edge.left => anchor.left,
  _Edge.right => viewport.width - anchor.right,
};

/// Where to place a floating element of [size] next to [anchor], inside a 0,0-origin [viewport]: preferring [side]
/// a [gap] away, flipped to the opposite side when [size] does not fit there but does on the other, aligned across
/// from it by [alignment], then shifted so it stays at least [margin] inside the viewport. [direction] resolves
/// [AnchorSide.start]/[AnchorSide.end] and a horizontal [AnchorAlign.start]/[AnchorAlign.end]. Beside the anchor, an
/// element too wide for either side goes on the one with more room, no wider than that room (a [gap] from the anchor
/// and [margin] inside the viewport): see [AnchoredPosition.maxWidth].
AnchoredPosition anchoredPosition({
  required Rect anchor,
  required Size size,
  required Size viewport,
  AnchorSide side = AnchorSide.bottom,
  AnchorAlign alignment = AnchorAlign.start,
  TextDirection direction = TextDirection.ltr,
  double gap = TsuyaSpace.s4,
  double margin = TsuyaSpace.s16,
}) {
  final rtl = direction == TextDirection.rtl;
  var edge = _resolve(side, rtl);
  final mainSize = _isVertical(edge) ? size.height : size.width;
  if (_roomAt(edge, anchor, viewport) - gap - margin < mainSize) {
    final opposite = _opposite(edge);
    if (_roomAt(opposite, anchor, viewport) > _roomAt(edge, anchor, viewport)) edge = opposite;
  }

  final vertical = _isVertical(edge);
  final maxHeight = vertical
      ? math.max(0.0, _roomAt(edge, anchor, viewport) - gap - margin)
      : math.max(0.0, viewport.height - 2 * margin);
  final height = math.min(size.height, maxHeight);
  final maxWidth = vertical
      ? math.max(0.0, viewport.width - 2 * margin)
      : math.max(0.0, _roomAt(edge, anchor, viewport) - gap - margin);
  final width = math.min(size.width, maxWidth);

  final mainOffset = switch (edge) {
    _Edge.top => anchor.top - gap - height,
    _Edge.bottom => anchor.bottom + gap,
    _Edge.left => anchor.left - gap - width,
    _Edge.right => anchor.right + gap,
  };

  final crossSize = vertical ? size.width : height;
  final anchorCrossStart = vertical ? anchor.left : anchor.top;
  final anchorCrossEnd = vertical ? anchor.right : anchor.bottom;
  final viewportCrossEnd = vertical ? viewport.width : viewport.height;
  // a horizontal cross axis (placing above/below) follows the text direction; a vertical one (placing beside) does not
  final crossRtl = vertical && rtl;
  var cross = switch (alignment) {
    AnchorAlign.start => crossRtl ? anchorCrossEnd - crossSize : anchorCrossStart,
    AnchorAlign.end => crossRtl ? anchorCrossStart : anchorCrossEnd - crossSize,
    AnchorAlign.center => anchorCrossStart + (anchorCrossEnd - anchorCrossStart - crossSize) / 2,
  };
  final crossMax = math.max(margin, viewportCrossEnd - margin - crossSize);
  cross = cross.clamp(margin, crossMax);

  final offset = vertical ? Offset(cross, mainOffset) : Offset(mainOffset, cross);
  return AnchoredPosition(offset: offset, maxHeight: maxHeight, maxWidth: maxWidth, side: _unresolve(edge, rtl));
}
