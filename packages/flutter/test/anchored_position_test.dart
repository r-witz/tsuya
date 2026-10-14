// The pure maths of placing a floating element next to an anchor.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/anchored_position.dart';

void main() {
  const viewport = Size(400, 800);

  test('below the anchor, aligned to its start, by default (gap 4, margin 16)', () {
    const anchor = Rect.fromLTWH(50, 100, 80, 40);
    final result = anchoredPosition(anchor: anchor, size: const Size(120, 200), viewport: viewport);
    expect(result.offset, const Offset(50, 144));
    expect(result.maxHeight, 640);
    expect(result.side, AnchorSide.bottom);
  });

  test('flips to the opposite side when it does not fit but the opposite does', () {
    const anchor = Rect.fromLTWH(50, 700, 80, 40); // only 60 below, 700 above
    final result = anchoredPosition(anchor: anchor, size: const Size(120, 200), viewport: viewport);
    expect(result.side, AnchorSide.top);
    expect(result.offset, const Offset(50, 496)); // anchor.top (700) - gap (4) - height (200)
    expect(result.maxHeight, 680); // anchor.top (700) - gap (4) - margin (16)
  });

  test('stays on the preferred side when neither fits but it has more room than the opposite', () {
    const anchor = Rect.fromLTWH(50, 300, 80, 40); // 460 below, 300 above; content needs 500
    final result = anchoredPosition(anchor: anchor, size: const Size(120, 500), viewport: viewport);
    expect(result.side, AnchorSide.bottom);
    expect(result.offset.dy, 344);
  });

  test('shifts to stay margin (16) inside the viewport when the aligned edge would overflow', () {
    const anchor = Rect.fromLTWH(350, 100, 30, 40);
    final result = anchoredPosition(anchor: anchor, size: const Size(150, 80), viewport: viewport);
    expect(result.offset.dx, 234); // 400 - 16 (margin) - 150 (width)
  });

  test('centred alignment centres the floating element on the anchor', () {
    const anchor = Rect.fromLTWH(50, 100, 80, 40);
    final result = anchoredPosition(
      anchor: anchor,
      size: const Size(120, 200),
      viewport: viewport,
      alignment: AnchorAlign.center,
    );
    expect(result.offset.dx, 30); // anchor centre (90) - half the floating width (60)
  });

  test('start and end resolve against the text direction; vertical alignment does not mirror', () {
    const anchor = Rect.fromLTWH(200, 300, 60, 40);
    final result = anchoredPosition(
      anchor: anchor,
      size: const Size(100, 50),
      viewport: viewport,
      side: AnchorSide.start,
      direction: TextDirection.rtl,
    );
    expect(result.side, AnchorSide.start, reason: 'it fits, so no flip');
    expect(result.offset, const Offset(264, 300)); // placed after anchor.right (260) + gap (4), top-aligned
    expect(result.maxHeight, 768); // viewport height (800) - 2 × margin (16): not bounded by the anchor here
  });

  test('a custom gap and margin are honoured', () {
    const anchor = Rect.fromLTWH(50, 100, 80, 40);
    final result = anchoredPosition(anchor: anchor, size: const Size(120, 200), viewport: viewport, gap: 10, margin: 0);
    expect(result.offset, const Offset(50, 150));
  });
}
