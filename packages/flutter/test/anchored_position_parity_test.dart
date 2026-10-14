// Parity between anchoredPosition() (Flutter) and place() (packages/core/src/primitives/anchored.ts): for
// the same inputs they must give the same x, y, side, maxHeight and maxWidth. This table was
// produced mechanically by running the real place() with `node --experimental-strip-types` over a grid of anchors
// near every edge, sizes that fit and that do not, every side and alignment, and both text directions — viewport
// 400×800, gap 4, margin 16 throughout. Row 0 is the reviewer's reproduction of the flip-ignores-margin bug.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/anchored_position.dart';

// anchor(left, top, width, height), size(width, height), side, align, rtl -> expected x, y, side, maxHeight
typedef _Case = (
  double,
  double,
  double,
  double,
  double,
  double,
  AnchorSide,
  AnchorAlign,
  bool,
  double,
  double,
  AnchorSide,
  double,
);

const _viewport = Size(400, 800);
const _gap = 4.0;
const _margin = 16.0;

// Produced by place() of packages/core/src/primitives/anchored.ts.
const _cases = <_Case>[
  (100, 650, 80, 50, 200, 90, AnchorSide.bottom, AnchorAlign.start, false, 100, 556, AnchorSide.top, 630),
  (180, 20, 80, 50, 100, 60, AnchorSide.top, AnchorAlign.start, false, 180, 74, AnchorSide.bottom, 710),
  (180, 20, 80, 50, 100, 60, AnchorSide.bottom, AnchorAlign.start, false, 180, 74, AnchorSide.bottom, 710),
  (180, 20, 80, 50, 100, 60, AnchorSide.start, AnchorAlign.start, false, 76, 20, AnchorSide.start, 768),
  (180, 20, 80, 50, 100, 60, AnchorSide.end, AnchorAlign.start, false, 264, 20, AnchorSide.end, 768),
  (180, 20, 80, 50, 120, 220, AnchorSide.top, AnchorAlign.start, false, 180, 74, AnchorSide.bottom, 710),
  (180, 20, 80, 50, 120, 220, AnchorSide.bottom, AnchorAlign.start, false, 180, 74, AnchorSide.bottom, 710),
  (180, 20, 80, 50, 120, 220, AnchorSide.start, AnchorAlign.start, false, 56, 20, AnchorSide.start, 768),
  (180, 20, 80, 50, 120, 220, AnchorSide.end, AnchorAlign.start, false, 264, 20, AnchorSide.end, 768),
  (180, 20, 80, 50, 260, 60, AnchorSide.top, AnchorAlign.start, false, 124, 74, AnchorSide.bottom, 710),
  (180, 20, 80, 50, 260, 60, AnchorSide.bottom, AnchorAlign.start, false, 124, 74, AnchorSide.bottom, 710),
  (180, 20, 80, 50, 260, 60, AnchorSide.start, AnchorAlign.start, false, 16, 20, AnchorSide.start, 768),
  (180, 20, 80, 50, 260, 60, AnchorSide.end, AnchorAlign.start, false, 16, 20, AnchorSide.start, 768),
  (180, 740, 80, 40, 100, 60, AnchorSide.top, AnchorAlign.start, false, 180, 676, AnchorSide.top, 720),
  (180, 740, 80, 40, 100, 60, AnchorSide.bottom, AnchorAlign.start, false, 180, 676, AnchorSide.top, 720),
  (180, 740, 80, 40, 100, 60, AnchorSide.start, AnchorAlign.start, false, 76, 724, AnchorSide.start, 768),
  (180, 740, 80, 40, 100, 60, AnchorSide.end, AnchorAlign.start, false, 264, 724, AnchorSide.end, 768),
  (180, 740, 80, 40, 120, 220, AnchorSide.top, AnchorAlign.start, false, 180, 516, AnchorSide.top, 720),
  (180, 740, 80, 40, 120, 220, AnchorSide.bottom, AnchorAlign.start, false, 180, 516, AnchorSide.top, 720),
  (180, 740, 80, 40, 120, 220, AnchorSide.start, AnchorAlign.start, false, 56, 564, AnchorSide.start, 768),
  (180, 740, 80, 40, 120, 220, AnchorSide.end, AnchorAlign.start, false, 264, 564, AnchorSide.end, 768),
  (180, 740, 80, 40, 260, 60, AnchorSide.top, AnchorAlign.start, false, 124, 676, AnchorSide.top, 720),
  (180, 740, 80, 40, 260, 60, AnchorSide.bottom, AnchorAlign.start, false, 124, 676, AnchorSide.top, 720),
  (180, 740, 80, 40, 260, 60, AnchorSide.start, AnchorAlign.start, false, 16, 724, AnchorSide.start, 768),
  (180, 740, 80, 40, 260, 60, AnchorSide.end, AnchorAlign.start, false, 16, 724, AnchorSide.start, 768),
  (20, 350, 60, 50, 100, 60, AnchorSide.top, AnchorAlign.start, false, 20, 286, AnchorSide.top, 330),
  (20, 350, 60, 50, 100, 60, AnchorSide.bottom, AnchorAlign.start, false, 20, 404, AnchorSide.bottom, 380),
  (20, 350, 60, 50, 100, 60, AnchorSide.start, AnchorAlign.start, false, 84, 350, AnchorSide.end, 768),
  (20, 350, 60, 50, 100, 60, AnchorSide.end, AnchorAlign.start, false, 84, 350, AnchorSide.end, 768),
  (20, 350, 60, 50, 120, 220, AnchorSide.top, AnchorAlign.start, false, 20, 126, AnchorSide.top, 330),
  (20, 350, 60, 50, 120, 220, AnchorSide.bottom, AnchorAlign.start, false, 20, 404, AnchorSide.bottom, 380),
  (20, 350, 60, 50, 120, 220, AnchorSide.start, AnchorAlign.start, false, 84, 350, AnchorSide.end, 768),
  (20, 350, 60, 50, 120, 220, AnchorSide.end, AnchorAlign.start, false, 84, 350, AnchorSide.end, 768),
  (20, 350, 60, 50, 260, 60, AnchorSide.top, AnchorAlign.start, false, 20, 286, AnchorSide.top, 330),
  (20, 350, 60, 50, 260, 60, AnchorSide.bottom, AnchorAlign.start, false, 20, 404, AnchorSide.bottom, 380),
  (20, 350, 60, 50, 260, 60, AnchorSide.start, AnchorAlign.start, false, 84, 350, AnchorSide.end, 768),
  (20, 350, 60, 50, 260, 60, AnchorSide.end, AnchorAlign.start, false, 84, 350, AnchorSide.end, 768),
  (330, 350, 60, 50, 100, 60, AnchorSide.top, AnchorAlign.start, false, 284, 286, AnchorSide.top, 330),
  (330, 350, 60, 50, 100, 60, AnchorSide.bottom, AnchorAlign.start, false, 284, 404, AnchorSide.bottom, 380),
  (330, 350, 60, 50, 100, 60, AnchorSide.start, AnchorAlign.start, false, 226, 350, AnchorSide.start, 768),
  (330, 350, 60, 50, 100, 60, AnchorSide.end, AnchorAlign.start, false, 226, 350, AnchorSide.start, 768),
  (330, 350, 60, 50, 120, 220, AnchorSide.top, AnchorAlign.start, false, 264, 126, AnchorSide.top, 330),
  (330, 350, 60, 50, 120, 220, AnchorSide.bottom, AnchorAlign.start, false, 264, 404, AnchorSide.bottom, 380),
  (330, 350, 60, 50, 120, 220, AnchorSide.start, AnchorAlign.start, false, 206, 350, AnchorSide.start, 768),
  (330, 350, 60, 50, 120, 220, AnchorSide.end, AnchorAlign.start, false, 206, 350, AnchorSide.start, 768),
  (330, 350, 60, 50, 260, 60, AnchorSide.top, AnchorAlign.start, false, 124, 286, AnchorSide.top, 330),
  (330, 350, 60, 50, 260, 60, AnchorSide.bottom, AnchorAlign.start, false, 124, 404, AnchorSide.bottom, 380),
  (330, 350, 60, 50, 260, 60, AnchorSide.start, AnchorAlign.start, false, 66, 350, AnchorSide.start, 768),
  (330, 350, 60, 50, 260, 60, AnchorSide.end, AnchorAlign.start, false, 66, 350, AnchorSide.start, 768),
  (180, 380, 80, 40, 100, 60, AnchorSide.top, AnchorAlign.start, false, 180, 316, AnchorSide.top, 360),
  (180, 380, 80, 40, 100, 60, AnchorSide.bottom, AnchorAlign.start, false, 180, 424, AnchorSide.bottom, 360),
  (180, 380, 80, 40, 100, 60, AnchorSide.start, AnchorAlign.start, false, 76, 380, AnchorSide.start, 768),
  (180, 380, 80, 40, 100, 60, AnchorSide.end, AnchorAlign.start, false, 264, 380, AnchorSide.end, 768),
  (180, 380, 80, 40, 120, 220, AnchorSide.top, AnchorAlign.start, false, 180, 156, AnchorSide.top, 360),
  (180, 380, 80, 40, 120, 220, AnchorSide.bottom, AnchorAlign.start, false, 180, 424, AnchorSide.bottom, 360),
  (180, 380, 80, 40, 120, 220, AnchorSide.start, AnchorAlign.start, false, 56, 380, AnchorSide.start, 768),
  (180, 380, 80, 40, 120, 220, AnchorSide.end, AnchorAlign.start, false, 264, 380, AnchorSide.end, 768),
  (180, 380, 80, 40, 260, 60, AnchorSide.top, AnchorAlign.start, false, 124, 316, AnchorSide.top, 360),
  (180, 380, 80, 40, 260, 60, AnchorSide.bottom, AnchorAlign.start, false, 124, 424, AnchorSide.bottom, 360),
  (180, 380, 80, 40, 260, 60, AnchorSide.start, AnchorAlign.start, false, 16, 380, AnchorSide.start, 768),
  (180, 380, 80, 40, 260, 60, AnchorSide.end, AnchorAlign.start, false, 16, 380, AnchorSide.start, 768),
  (20, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.start, false, 20, 296, AnchorSide.top, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.start, true, 16, 296, AnchorSide.top, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.center, false, 16, 296, AnchorSide.top, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.center, true, 16, 296, AnchorSide.top, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.end, false, 16, 296, AnchorSide.top, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.end, true, 20, 296, AnchorSide.top, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.start, false, 20, 424, AnchorSide.bottom, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.start, true, 16, 424, AnchorSide.bottom, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.center, false, 16, 424, AnchorSide.bottom, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.center, true, 16, 424, AnchorSide.bottom, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.end, false, 16, 424, AnchorSide.bottom, 360),
  (20, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.end, true, 20, 424, AnchorSide.bottom, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.start, false, 234, 296, AnchorSide.top, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.start, true, 230, 296, AnchorSide.top, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.center, false, 234, 296, AnchorSide.top, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.center, true, 234, 296, AnchorSide.top, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.end, false, 230, 296, AnchorSide.top, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.end, true, 234, 296, AnchorSide.top, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.start, false, 234, 424, AnchorSide.bottom, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.start, true, 230, 424, AnchorSide.bottom, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.center, false, 234, 424, AnchorSide.bottom, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.center, true, 234, 424, AnchorSide.bottom, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.end, false, 230, 424, AnchorSide.bottom, 360),
  (320, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.end, true, 234, 424, AnchorSide.bottom, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.start, false, 180, 296, AnchorSide.top, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.start, true, 90, 296, AnchorSide.top, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.center, false, 135, 296, AnchorSide.top, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.center, true, 135, 296, AnchorSide.top, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.end, false, 90, 296, AnchorSide.top, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.top, AnchorAlign.end, true, 180, 296, AnchorSide.top, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.start, false, 180, 424, AnchorSide.bottom, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.start, true, 90, 424, AnchorSide.bottom, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.center, false, 135, 424, AnchorSide.bottom, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.center, true, 135, 424, AnchorSide.bottom, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.end, false, 90, 424, AnchorSide.bottom, 360),
  (180, 380, 60, 40, 150, 80, AnchorSide.bottom, AnchorAlign.end, true, 180, 424, AnchorSide.bottom, 360),
  (180, 20, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.start, false, 86, 20, AnchorSide.start, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.start, true, 244, 20, AnchorSide.start, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.center, false, 86, 16, AnchorSide.start, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.center, true, 244, 16, AnchorSide.start, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.end, false, 86, 16, AnchorSide.start, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.end, true, 244, 16, AnchorSide.start, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.start, false, 244, 20, AnchorSide.end, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.start, true, 86, 20, AnchorSide.end, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.center, false, 244, 16, AnchorSide.end, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.center, true, 86, 16, AnchorSide.end, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.end, false, 244, 16, AnchorSide.end, 768),
  (180, 20, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.end, true, 86, 16, AnchorSide.end, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.start, false, 86, 634, AnchorSide.start, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.start, true, 244, 634, AnchorSide.start, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.center, false, 86, 634, AnchorSide.start, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.center, true, 244, 634, AnchorSide.start, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.end, false, 86, 630, AnchorSide.start, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.end, true, 244, 630, AnchorSide.start, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.start, false, 244, 634, AnchorSide.end, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.start, true, 86, 634, AnchorSide.end, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.center, false, 244, 634, AnchorSide.end, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.center, true, 86, 634, AnchorSide.end, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.end, false, 244, 630, AnchorSide.end, 768),
  (180, 740, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.end, true, 86, 630, AnchorSide.end, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.start, false, 86, 380, AnchorSide.start, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.start, true, 244, 380, AnchorSide.start, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.center, false, 86, 325, AnchorSide.start, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.center, true, 244, 325, AnchorSide.start, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.end, false, 86, 270, AnchorSide.start, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.start, AnchorAlign.end, true, 244, 270, AnchorSide.start, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.start, false, 244, 380, AnchorSide.end, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.start, true, 86, 380, AnchorSide.end, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.center, false, 244, 325, AnchorSide.end, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.center, true, 86, 325, AnchorSide.end, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.end, false, 244, 270, AnchorSide.end, 768),
  (180, 380, 60, 40, 90, 150, AnchorSide.end, AnchorAlign.end, true, 86, 270, AnchorSide.end, 768),
  // neither side fits and the chosen (preferred, more-room) side is itself too small for the floating element
  (180, 400, 80, 10, 100, 395, AnchorSide.top, AnchorAlign.start, false, 180, 16, AnchorSide.top, 380),
  (180, 400, 80, 10, 100, 395, AnchorSide.top, AnchorAlign.center, false, 170, 16, AnchorSide.top, 380),
  (180, 380, 60, 40, 90, 900, AnchorSide.start, AnchorAlign.start, false, 86, 16, AnchorSide.start, 768),
  (180, 380, 60, 40, 90, 900, AnchorSide.start, AnchorAlign.center, false, 86, 16, AnchorSide.start, 768),
  (180, 380, 60, 40, 90, 900, AnchorSide.end, AnchorAlign.end, true, 86, 16, AnchorSide.end, 768),
];

// anchor(left, top, width, height), size(width, height), side, rtl -> expected x, side, maxWidth; also produced by place().
// Beside the anchor the width is capped at the room on the side chosen; above or below it, at the viewport less margins.
const _widths = <(double, double, double, double, double, double, AnchorSide, bool, double, AnchorSide, double)>[
  (180, 20, 80, 50, 260, 60, AnchorSide.start, false, 16, AnchorSide.start, 160),
  (180, 20, 80, 50, 260, 60, AnchorSide.end, false, 16, AnchorSide.start, 160),
  (180, 20, 80, 50, 100, 60, AnchorSide.end, false, 264, AnchorSide.end, 120),
  (180, 20, 80, 50, 260, 60, AnchorSide.start, true, 16, AnchorSide.end, 160),
  (20, 350, 60, 50, 260, 60, AnchorSide.start, false, 84, AnchorSide.end, 300),
  (180, 20, 80, 50, 260, 60, AnchorSide.bottom, false, 124, AnchorSide.bottom, 368),
];

void main() {
  for (final (i, c) in _cases.indexed) {
    final (ax, ay, aw, ah, sw, sh, side, align, rtl, x, y, outSide, maxHeight) = c;
    test('case $i: anchor($ax,$ay,$aw,$ah) size($sw,$sh) $side $align rtl=$rtl', () {
      final result = anchoredPosition(
        anchor: Rect.fromLTWH(ax, ay, aw, ah),
        size: Size(sw, sh),
        viewport: _viewport,
        side: side,
        alignment: align,
        direction: rtl ? TextDirection.rtl : TextDirection.ltr,
        gap: _gap,
        margin: _margin,
      );
      expect(result.offset, Offset(x, y), reason: 'x,y of case $i');
      expect(result.side, outSide, reason: 'side of case $i');
      expect(result.maxHeight, maxHeight, reason: 'maxHeight of case $i');
    });
  }

  for (final (i, c) in _widths.indexed) {
    final (ax, ay, aw, ah, sw, sh, side, rtl, x, outSide, maxWidth) = c;
    test('width case $i: anchor($ax,$ay,$aw,$ah) size($sw,$sh) $side rtl=$rtl', () {
      final result = anchoredPosition(
        anchor: Rect.fromLTWH(ax, ay, aw, ah),
        size: Size(sw, sh),
        viewport: _viewport,
        side: side,
        direction: rtl ? TextDirection.rtl : TextDirection.ltr,
        gap: _gap,
        margin: _margin,
      );
      expect(result.offset.dx, x, reason: 'x of width case $i');
      expect(result.side, outSide, reason: 'side of width case $i');
      expect(result.maxWidth, maxWidth, reason: 'maxWidth of width case $i');
    });
  }
}
