// The keyboard focus ring (DESIGN.md, Foundations: States).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/focus_ring.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

Widget box([double side = 40]) => SizedBox.square(
  dimension: side,
  child: const ColoredBox(color: Color(0xFF808080)),
);

void main() {
  testWidgets('painted only while focused', (tester) async {
    await tester.pumpWidget(host(FocusRing(focused: false, child: box())));
    expect(find.descendant(of: find.byType(FocusRing), matching: find.byType(CustomPaint)), findsNothing);

    await tester.pumpWidget(host(FocusRing(focused: true, child: box())));
    expect(find.descendant(of: find.byType(FocusRing), matching: find.byType(CustomPaint)), findsOneWidget);
  });

  testWidgets('the ring sits TsuyaState.focusOffset away, filled with the background, in the accent of its mode', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      host(
        TsuyaTheme(
          mode: TsuyaMode.dark,
          child: RepaintBoundary(
            key: key,
            child: ColoredBox(
              color: const Color(0xFF808080),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: FocusRing(focused: true, child: box()),
              ),
            ),
          ),
        ),
      ),
    );
    // the box spans 10..50; the gap 8..10, the ring 6..8 (left edge, middle row)
    const offset = TsuyaState.focusOffset, width = TsuyaState.focusWidth;
    expect(await pixelAt(tester, key, const Offset(10 - offset / 2, 30)), TsuyaColors.dark.bg);
    expect(await pixelAt(tester, key, const Offset(10 - offset - width / 2, 30)), TsuyaColors.dark.accent);
    expect(await pixelAt(tester, key, const Offset(2, 30)), const Color(0xFF808080));
  });

  testWidgets('the ring follows the nearest accent region', (tester) async {
    final key = GlobalKey();
    final pair = AccentPair(light: const Color(0xFF2C9C8B), dark: const Color(0xFF6BBBAE));
    await tester.pumpWidget(
      host(
        RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: const Color(0xFF808080),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Accent(
                pair: pair,
                child: FocusRing(focused: true, child: box()),
              ),
            ),
          ),
        ),
      ),
    );
    const offset = TsuyaState.focusOffset, width = TsuyaState.focusWidth;
    expect(await pixelAt(tester, key, const Offset(10 - offset - width / 2, 30)), pair.light);
  });
}
