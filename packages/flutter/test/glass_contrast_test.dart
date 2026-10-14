// G1: text keeps 4.5:1 on rendered glass. G11: content passing under a glass bar shows through it.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  // the worst cases found by the token-level check: the lightest accent over white in dark mode, the
  // darkest over black in light mode.
  for (final (mode, accent, content) in [
    (TsuyaMode.dark, const Color(0xFFB6B6B6), const Color(0xFFFFFFFF)),
    (TsuyaMode.light, const Color(0xFF990337), const Color(0xFF000000)),
  ]) {
    testWidgets('text keeps 4.5:1 on glass tinted by an extreme accent over $content ($mode)', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        host(
          RepaintBoundary(
            key: key,
            child: TsuyaTheme(
              mode: mode,
              child: Accent(
                pair: AccentPair(light: accent, dark: accent),
                child: Stack(
                  children: [
                    Positioned.fill(child: ColoredBox(color: content)),
                    const Positioned(
                      left: 50,
                      top: 50,
                      width: 200,
                      height: 100,
                      child: Glass(child: SizedBox.expand()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final glass = await pixelAt(tester, key, const Offset(150, 100));
      final colors = mode == TsuyaMode.dark ? TsuyaColors.dark : TsuyaColors.light;
      expect(glass, isNot(content), reason: 'the glass is drawn');
      expect(contrast(colors.text, glass), greaterThanOrEqualTo(4.5));
      expect(contrast(colors.textMuted, glass), greaterThanOrEqualTo(4.5));
    });
  }

  testWidgets('G11: content passing under a glass bar shows through it', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      host(
        RepaintBoundary(
          key: key,
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: Color(0xFFFF0000))),
              const Positioned(left: 20, top: 20, width: 200, height: 60, child: Glass(child: SizedBox.expand())),
            ],
          ),
        ),
      ),
    );
    final glass = await pixelAt(tester, key, const Offset(120, 50));
    expect(glass.r, greaterThan(glass.g + 0.04), reason: 'red should be clearly above green: $glass');
    expect(glass.r, greaterThan(glass.b + 0.04), reason: 'red should be clearly above blue: $glass');
  });

  testWidgets('no BackdropGroup is used (each glass reads its own backdrop)', (tester) async {
    await tester.pumpWidget(
      host(
        Column(
          children: [
            const Glass(child: SizedBox(width: 80, height: 40)),
            const Glass(child: SizedBox(width: 80, height: 40)),
          ],
        ),
      ),
    );
    expect(find.byType(BackdropGroup), findsNothing);
    expect(find.byType(BackdropFilter), findsNWidgets(2));
  });
}
