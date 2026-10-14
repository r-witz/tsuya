// Progress (DESIGN.md, Progress): the bar, its track and radius, the thin variant, a determinate
// value, the indeterminate sweep every 1.2 s kept under reduced motion, and toggling between the two.
// G5: semantics. G9: reduced motion never stops the sweep. G14: right-to-left.
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  testWidgets('a determinate bar: space-4 tall, radius full, named with its value', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Center(
          child: const SizedBox(width: 300, child: Progress(value: 0.42, label: 'Uploading photo.jpg')),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Progress)).height, TsuyaSpace.s4);
    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect((clip.borderRadius as BorderRadius).topLeft.x, TsuyaRadius.full);
    expect(tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor, 0.42);
    final data = tester.getSemantics(find.byType(Progress));
    expect(data.role, SemanticsRole.progressBar);
    expect(data, isSemantics(label: 'Uploading photo.jpg', value: '42 %', minValue: '0', maxValue: '100'));
    semantics.dispose();
  });

  testWidgets('a thin variant is 2 tall', (tester) async {
    await tester.pumpWidget(host(Center(child: const SizedBox(width: 300, child: Progress(value: 0.5, thin: true)))));
    expect(tester.getSize(find.byType(Progress)).height, 2);
  });

  testWidgets('without a value, named with the loading label by default, as a loading spinner', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Center(child: const SizedBox(width: 300, child: Progress()))));
    final data = tester.getSemantics(find.byType(Progress));
    expect(data.role, SemanticsRole.loadingSpinner);
    expect(data.value, isEmpty);
    expect(data, isSemantics(label: TsuyaLabels.en.loading));
    semantics.dispose();
  });

  testWidgets('indeterminate never trips the progress-bar-role validation', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Center(child: const SizedBox(width: 300, child: Progress()))));
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('without a value, a third of the bar sweeps across every 1.2 s, kept under reduced motion', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      host(
        Center(
          child: RepaintBoundary(
            key: key,
            child: const SizedBox(width: 300, child: Progress()),
          ),
        ),
      ),
    );
    // the default `host()` already runs with animations off (reduced motion); the sweep must still move
    await tester.pump(const Duration(milliseconds: 300)); // a quarter of the 1.2 s cycle
    // at a quarter, the third exactly covers the bar's first third (0..100 of 300 px); the untouched track is
    // semi-transparent, so only its alpha (not its premultiplied RGB, which `pixelAt` cannot recover) is checked
    expect(await pixelAt(tester, key, const Offset(50, 2)), TsuyaColors.light.accent);
    expect((await pixelAt(tester, key, const Offset(200, 2))).a, closeTo(TsuyaColors.light.track.a, 0.01));
  });

  testWidgets('right to left, the third sweeps from the right', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      host(
        Center(
          child: RepaintBoundary(
            key: key,
            child: const SizedBox(width: 300, child: Progress()),
          ),
        ),
        direction: TextDirection.rtl,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(await pixelAt(tester, key, const Offset(250, 2)), TsuyaColors.light.accent);
    expect((await pixelAt(tester, key, const Offset(50, 2))).a, closeTo(TsuyaColors.light.track.a, 0.01));
  });

  testWidgets('G9: keeps sweeping under reduced motion', (tester) async {
    await tester.pumpWidget(host(Center(child: const SizedBox(width: 300, child: Progress()))));
    final before = tester.widget<Align>(find.byType(Align)).alignment as Alignment;
    await tester.pump(const Duration(milliseconds: 400));
    final after = tester.widget<Align>(find.byType(Align)).alignment as Alignment;
    expect(after, isNot(before), reason: 'a loading indicator keeps moving even with animations off');
  });

  testWidgets('a value can toggle to and from indeterminate', (tester) async {
    Widget subject(double? value) => host(
      Center(
        child: SizedBox(width: 300, child: Progress(value: value)),
      ),
    );

    await tester.pumpWidget(subject(0.3));
    expect(tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor, 0.3);

    await tester.pumpWidget(subject(null));
    expect(tester.takeException(), isNull);
    // the indeterminate sweep also uses a FractionallySizedBox (the third that travels), now a third wide rather
    // than the stale determinate fraction
    expect(tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor, closeTo(1 / 3, 1e-9));

    await tester.pumpWidget(subject(0.6));
    expect(tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor, 0.6);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a determinate bar runs no ticker; only the indeterminate one does', (tester) async {
    Widget subject(double? value) => host(Progress(value: value), animate: true);
    await tester.pumpWidget(subject(0.4));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(subject(null));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(subject(0.4));
    expect(tester.hasRunningAnimations, isFalse, reason: 'a value arrived: the sweep stops');
  });

  testWidgets('a value outside 0 to 1 is clamped, as the native progress element does', (tester) async {
    final semantics = tester.ensureSemantics();
    for (final (value, factor, text) in [(-0.1, 0.0, '0 %'), (1.5, 1.0, '100 %')]) {
      await tester.pumpWidget(host(Progress(value: value)));
      expect(tester.takeException(), isNull, reason: '$value');
      expect(tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor, factor);
      expect(tester.getSemantics(find.byType(Progress)).value, text);
    }
    semantics.dispose();
  });

  testWidgets('a NaN value is indeterminate, as the native progress element treats an invalid one', (tester) async {
    await tester.pumpWidget(host(const Progress(value: double.nan)));
    expect(tester.takeException(), isNull);
    expect(tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor, closeTo(1 / 3, 1e-9));
  });
}
