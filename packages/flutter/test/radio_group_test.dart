// RadioGroup (DESIGN.md, RadioGroup).
// G3: targets. G5: semantics. G6: keyboard. G7, G9, G14: smoke_test.dart.
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide RadioGroup;
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

const _options = [
  RadioOption(value: 'sm', label: 'Small'),
  RadioOption(value: 'md', label: 'Medium'),
  RadioOption(value: 'lg', label: 'Large'),
];

AnimatedContainer _circle(WidgetTester tester, int index) =>
    tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).elementAt(index);

Finder _row(String label) => find.ancestor(of: find.text(label), matching: find.byType(Pressable));

void main() {
  testWidgets('unselected radios: no fill, a border-strong hairline, no dot', (tester) async {
    await tester.pumpWidget(host(RadioGroup<String>(label: 'Size', value: 'md', onChanged: (_) {}, options: _options)));
    final circle = _circle(tester, 0);
    expect((circle.decoration! as BoxDecoration).color, isNull);
    expect((circle.foregroundDecoration! as BoxDecoration).border!.top.color, TsuyaColors.light.borderStrong);
    expect((circle.foregroundDecoration! as BoxDecoration).border!.top.width, 1.5);
  });

  testWidgets('the selected radio is accent-filled with an on-accent dot', (tester) async {
    await tester.pumpWidget(host(RadioGroup<String>(label: 'Size', value: 'md', onChanged: (_) {}, options: _options)));
    final circle = _circle(tester, 1);
    expect((circle.decoration! as BoxDecoration).color, TsuyaColors.light.accent);
    expect(circle.foregroundDecoration, isNull);
    final dot = (circle.child! as Center).child! as Container;
    expect(dot.constraints, const BoxConstraints.tightFor(width: 8, height: 8));
    expect((dot.decoration! as BoxDecoration).color, TsuyaColors.light.onAccent);
  });

  testWidgets('tapping an option selects it', (tester) async {
    String value = 'md';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => RadioGroup<String>(
            label: 'Size',
            value: value,
            onChanged: (v) => setState(() => value = v),
            options: _options,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Large'));
    await tester.pump();
    expect(value, 'lg');
  });

  testWidgets('G6: arrow keys both move and select, as native radios do', (tester) async {
    String value = 'sm';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => RadioGroup<String>(
            label: 'Size',
            value: value,
            onChanged: (v) => setState(() => value = v),
            options: _options,
          ),
        ),
      ),
    );
    Focus.of(tester.element(find.text('Small'))).requestFocus();
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.pump();
    expect(value, 'md', reason: 'moving focus down already selects the next option');
  });

  testWidgets('G5: the group is a radio group named by its label; each option is one radio of it', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(RadioGroup<String>(label: 'Size', value: 'md', onChanged: (_) {}, options: _options)));
    expect(tester.getSemantics(find.byType(RadioGroup<String>)), isSemantics(label: 'Size'));
    expect(tester.getSemantics(find.byType(RadioGroup<String>)).role, SemanticsRole.radioGroup);
    expect(
      tester.getSemantics(_row('Medium')),
      isSemantics(
        label: 'Medium',
        isButton: false,
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('G3: each option is at least 44 on touch platforms, 24 with a mouse', (tester) async {
    try {
      for (final (platform, side) in [(TargetPlatform.android, 44.0), (TargetPlatform.macOS, 24.0)]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          host(
            Center(
              child: RadioGroup<String>(label: 'Size', value: 'md', onChanged: (_) {}, options: _options),
            ),
          ),
        );
        expect(tester.getSize(_row('Small')).height, greaterThanOrEqualTo(side), reason: '$platform');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
