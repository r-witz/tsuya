// The accent region (DESIGN.md, The material: Accent).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

final _pair = AccentPair(light: const Color(0xFF01786A), dark: const Color(0xFF32A190));

Color? _accent;
Widget _probe() => Builder(
  builder: (context) {
    _accent = Accent.of(context);
    return const SizedBox();
  },
);

void main() {
  testWidgets('outside any region, the accent is the neutral accent (the text colour)', (tester) async {
    await tester.pumpWidget(host(_probe()));
    expect(_accent, TsuyaColors.light.accent);
  });

  testWidgets('an accent region gives its pair for the nearest mode', (tester) async {
    await tester.pumpWidget(host(Accent(pair: _pair, child: _probe())));
    expect(_accent, _pair.light);
  });

  testWidgets("a nested region of the other mode takes the pair's colour for that mode", (tester) async {
    await tester.pumpWidget(
      host(
        Accent(
          pair: _pair,
          child: TsuyaTheme(mode: TsuyaMode.dark, child: _probe()),
        ),
      ),
    );
    expect(_accent, _pair.dark);
  });

  testWidgets('pairOf returns the nearest pair, or null outside any region', (tester) async {
    AccentPair? pair;
    Widget probePair() => Builder(
      builder: (context) {
        pair = Accent.pairOf(context);
        return const SizedBox();
      },
    );
    await tester.pumpWidget(host(probePair()));
    expect(pair, isNull);
    await tester.pumpWidget(host(Accent(pair: _pair, child: probePair())));
    expect(pair, _pair);
  });

  testWidgets('a new accent cross-fades over TsuyaDuration.accent, or changes at once with reduced motion', (
    tester,
  ) async {
    final other = AccentPair(light: const Color(0xFF7A3FB0), dark: const Color(0xFFB474EA));
    Widget app(AccentPair pair, {required bool animate}) => host(
      Accent(pair: pair, child: _probe()),
      animate: animate,
    );

    await tester.pumpWidget(app(_pair, animate: true));
    await tester.pumpWidget(app(other, animate: true));
    await tester.pump(TsuyaDuration.accent ~/ 2);
    expect(_accent, isNot(anyOf(_pair.light, other.light)), reason: 'half-way through the cross-fade');
    await tester.pumpAndSettle();
    expect(_accent, other.light);

    await tester.pumpWidget(app(_pair, animate: false));
    await tester.pump();
    expect(_accent, _pair.light, reason: 'instant under reduced motion');
  });
}
