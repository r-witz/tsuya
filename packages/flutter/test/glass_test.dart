// Glass scope merging and fallbacks (DESIGN.md, The material: Glass, Fallbacks).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

Color _firstFill(WidgetTester tester, Finder ancestor) {
  final box = tester.widgetList<DecoratedBox>(find.descendant(of: ancestor, matching: find.byType(DecoratedBox))).first;
  return (box.decoration as BoxDecoration).color!;
}

void main() {
  group('GlassScope', () {
    testWidgets('composes with the scope above; an inner scope changes only what it sets', (tester) async {
      late ({bool neutral, bool reduce}) inner;
      await tester.pumpWidget(
        host(
          GlassScope(
            reduce: true,
            child: GlassScope(
              neutral: true,
              child: Builder(
                builder: (c) {
                  inner = GlassScope.of(c);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(inner, (neutral: true, reduce: true));
    });

    testWidgets('leaving a field unset keeps the value from the scope above', (tester) async {
      late ({bool neutral, bool reduce}) inner;
      await tester.pumpWidget(
        host(
          GlassScope(
            neutral: true,
            reduce: true,
            child: GlassScope(
              neutral: false,
              child: Builder(
                builder: (c) {
                  inner = GlassScope.of(c);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(inner, (neutral: false, reduce: true));
    });

    testWidgets('high contrast reduces glass even without an explicit scope', (tester) async {
      late ({bool neutral, bool reduce}) scope;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (c) {
              scope = GlassScope.of(c);
              return const SizedBox();
            },
          ),
          highContrast: true,
        ),
      );
      expect(scope.reduce, isTrue);
    });

    testWidgets('without any scope, glass is tinted and not reduced', (tester) async {
      late ({bool neutral, bool reduce}) scope;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (c) {
              scope = GlassScope.of(c);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(scope, (neutral: false, reduce: false));
    });
  });

  group('Glass', () {
    testWidgets('blurs its backdrop by default', (tester) async {
      await tester.pumpWidget(host(const Glass(child: SizedBox(width: 80, height: 80))));
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(_firstFill(tester, find.byType(Glass)).a, closeTo(TsuyaGlass.opacity, 0.001));
    });

    testWidgets('falls back to an opaque, unblurred fill when transparency is reduced', (tester) async {
      await tester.pumpWidget(
        host(GlassScope(reduce: true, child: const Glass(child: SizedBox(width: 80, height: 80)))),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      expect(_firstFill(tester, find.byType(Glass)).a, 1.0);
    });

    testWidgets('shadow none paints only the edge; md and lg also paint an outer shadow', (tester) async {
      await tester.pumpWidget(host(const Glass(child: SizedBox(width: 40, height: 40))));
      expect(find.descendant(of: find.byType(Glass), matching: find.byType(CustomPaint)), findsOneWidget);

      await tester.pumpWidget(host(const Glass(shadow: GlassShadow.md, child: SizedBox(width: 40, height: 40))));
      expect(find.descendant(of: find.byType(Glass), matching: find.byType(CustomPaint)), findsNWidgets(2));
    });

    testWidgets('no lit line along the top: the top row is the fill; the shaded line stays at the bottom', (
      tester,
    ) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        host(
          mode: TsuyaMode.dark,
          Center(
            child: RepaintBoundary(
              key: key,
              child: const GlassScope(reduce: true, child: Glass(child: SizedBox(width: 80, height: 40))),
            ),
          ),
        ),
      );
      final inside = await pixelAt(tester, key, const Offset(40, 20));
      expect(await pixelAt(tester, key, const Offset(40, 0)), inside);
      expect(await pixelAt(tester, key, const Offset(40, 39)), isNot(inside));
    });

    testWidgets('fillOf has no tint outside any accent region, or inside a neutral one', (tester) async {
      late Color noRegion;
      late Color neutralRegion;
      late Color tintedRegion;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (c) {
              noRegion = Glass.fillOf(c);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpWidget(
        host(
          Accent(
            pair: AccentPair.neutral,
            child: Builder(
              builder: (c) {
                neutralRegion = Glass.fillOf(c);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        host(
          Accent(
            pair: AccentPair(light: const Color(0xFF01786A), dark: const Color(0xFF32A190)),
            child: Builder(
              builder: (c) {
                tintedRegion = Glass.fillOf(c);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(noRegion, TsuyaColors.light.glass);
      expect(neutralRegion, TsuyaColors.light.glass);
      expect(tintedRegion, isNot(TsuyaColors.light.glass));
    });
  });

  group('ControlGlass', () {
    testWidgets('blurs its backdrop by default', (tester) async {
      await tester.pumpWidget(host(const ControlGlass(child: SizedBox(width: 40, height: 40))));
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('falls back to TsuyaColors.surface, unblurred, when transparency is reduced', (tester) async {
      await tester.pumpWidget(
        host(GlassScope(reduce: true, child: const ControlGlass(child: SizedBox(width: 40, height: 40)))),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      final coloredBox = tester.widget<ColoredBox>(
        find.descendant(of: find.byType(ControlGlass), matching: find.byType(ColoredBox)).first,
      );
      expect(coloredBox.color, TsuyaColors.light.surface);
    });
  });
}
