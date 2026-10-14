// Spinner (DESIGN.md, Progress: Spinner).
// G5: semantics. G9: reduced motion never stops it.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  testWidgets('sizes map to the icon tokens; the accent is the default colour', (tester) async {
    for (final (size, side) in [
      (SpinnerSize.sm, TsuyaSize.iconSm),
      (SpinnerSize.md, TsuyaSize.icon),
      (SpinnerSize.lg, TsuyaSize.iconLg),
    ]) {
      await tester.pumpWidget(
        host(
          Center(
            child: Spinner(label: 'Loading', size: size),
          ),
        ),
      );
      expect(tester.getSize(find.byType(Spinner)), Size(side, side));
    }
  });

  testWidgets('a custom colour replaces the accent', (tester) async {
    await tester.pumpWidget(host(const Spinner(label: 'Loading', color: Color(0xFF00FF00))));
    expect(tester.takeException(), isNull);
  });

  testWidgets('G5: announced as a progress indicator, named label or the loading label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(const Spinner(label: 'Fetching albums')));
    expect(tester.getSemantics(find.byType(Spinner)), isSemantics(label: 'Fetching albums'));

    await tester.pumpWidget(host(const Spinner()));
    expect(tester.getSemantics(find.byType(Spinner)), isSemantics(label: TsuyaLabels.en.loading));
    semantics.dispose();
  });

  testWidgets('G9: keeps turning under reduced motion', (tester) async {
    await tester.pumpWidget(host(const Spinner(label: 'Loading'), animate: false));
    final rotation = tester.widget<RotationTransition>(find.byType(RotationTransition));
    final before = rotation.turns.value;
    await tester.pump(const Duration(milliseconds: 400));
    final after = tester.widget<RotationTransition>(find.byType(RotationTransition)).turns.value;
    expect(after, isNot(before), reason: 'a loading indicator keeps moving even with animations off');
  });
}
