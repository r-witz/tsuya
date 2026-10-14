// Skeleton and Skeleton.text (DESIGN.md, Skeleton).
// G5: semantics. G9: reduced motion stops the pulse. G14: smoke_test.dart.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  testWidgets('a block at the given size and radius', (tester) async {
    await tester.pumpWidget(host(Center(child: const Skeleton(width: 40, height: 40, radius: TsuyaRadius.full))));
    expect(tester.getSize(find.byType(Skeleton)), const Size(40, 40));
    final decoration = tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration as BoxDecoration;
    expect((decoration.borderRadius! as BorderRadius).topLeft.x, TsuyaRadius.full);
    expect(decoration.color, TsuyaColors.light.fillStrong);
  });

  testWidgets('without width, height or radius: fills its container, a text line tall, the xs radius', (tester) async {
    await tester.pumpWidget(host(Center(child: const SizedBox(width: 200, child: Skeleton()))));
    expect(tester.getSize(find.byType(Skeleton)).width, 200);
    expect(tester.getSize(find.byType(Skeleton)).height, TsuyaType.body.fontSize);
    final decoration = tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration as BoxDecoration;
    expect((decoration.borderRadius! as BorderRadius).topLeft.x, TsuyaRadius.xs);
  });

  testWidgets('hidden from screen readers: no busy flag of its own', (tester) async {
    await tester.pumpWidget(host(const Skeleton()));
    expect(find.byType(ExcludeSemantics), findsOneWidget);

    await tester.pumpWidget(host(const Skeleton.text()));
    expect(find.byType(ExcludeSemantics), findsOneWidget);
  });

  testWidgets('a slow opacity pulse, 0.5 to 1 over 1.6 s', (tester) async {
    await tester.pumpWidget(host(const Skeleton(), animate: true));
    final opacity = tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity;
    expect(opacity.value, 0.5);
    await tester.pump(const Duration(milliseconds: 800));
    expect(opacity.value, greaterThan(0.5));
    expect(opacity.value, lessThan(1));
  });

  testWidgets('G9: the pulse stops under reduced motion, settled fully opaque rather than paused', (tester) async {
    // the default `host()` already runs with animations off (reduced motion)
    await tester.pumpWidget(host(const Skeleton()));
    final opacity = tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity;
    expect(opacity.value, 1);
    await tester.pump(const Duration(milliseconds: 800));
    expect(opacity.value, 1);
  });

  testWidgets('Skeleton.text: 3 lines by default, the last at 60 %, space-8 apart', (tester) async {
    await tester.pumpWidget(host(const SizedBox(width: 200, child: Skeleton.text())));
    expect(find.byType(FadeTransition), findsNWidgets(3)); // the independently pulsing blocks, one per line
    expect(find.byType(SizedBox).evaluate().where((e) => (e.widget as SizedBox).height == TsuyaSpace.s8).length, 2);
    final last = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(last.widthFactor, 0.6);
  });

  testWidgets('Skeleton.text: a custom line count, and a single line stays full width', (tester) async {
    await tester.pumpWidget(host(const SizedBox(width: 200, child: Skeleton.text(lines: 5))));
    expect(find.byType(FadeTransition), findsNWidgets(5));
    expect(find.byType(FractionallySizedBox), findsOneWidget);

    await tester.pumpWidget(host(const SizedBox(width: 200, child: Skeleton.text(lines: 1))));
    expect(find.byType(FadeTransition), findsOneWidget);
    expect(find.byType(FractionallySizedBox), findsNothing);
  });

  testWidgets('the default height is one line at the text scale, like 1em', (tester) async {
    await tester.pumpWidget(
      host(
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 100,
            child: DefaultTextStyle(style: TextStyle(fontSize: 16), child: Skeleton()),
          ),
        ),
        textScale: 2,
      ),
    );
    expect(tester.getSize(find.byType(Skeleton)).height, 32);
  });
}
