// Checkbox (DESIGN.md, Checkbox).
// G3: targets. G5: semantics. G6: keyboard. G7, G9, G14: smoke_test.dart.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

BoxDecoration _fill(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration;

BoxDecoration? _border(WidgetTester tester) {
  final decoration = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).foregroundDecoration;
  return decoration == null ? null : decoration as BoxDecoration;
}

void main() {
  testWidgets('unchecked: no fill, a border-strong hairline, no mark', (tester) async {
    await tester.pumpWidget(host(Checkbox(value: false, onChanged: (_) {}, label: 'Remember me')));
    expect(_fill(tester).color, isNull);
    expect(_border(tester)!.border!.top.color, TsuyaColors.light.borderStrong);
    expect(_border(tester)!.border!.top.width, 1.5);
    expect(find.byType(CustomPaint), findsNothing);
  });

  testWidgets('checked: accent fill with a mark; unaffected by the label spacing', (tester) async {
    await tester.pumpWidget(host(Checkbox(value: true, onChanged: (_) {}, label: 'Remember me')));
    expect(_fill(tester).color, TsuyaColors.light.accent);
    expect(_border(tester), isNull);
    expect(find.byType(CustomPaint), findsOneWidget);
  });

  testWidgets('the label sits space-12 after the box', (tester) async {
    await tester.pumpWidget(host(Checkbox(value: false, onChanged: (_) {}, label: 'Remember me')));
    final gap = tester.getTopLeft(find.text('Remember me')).dx - tester.getTopRight(find.byType(AnimatedContainer)).dx;
    expect(gap, TsuyaSpace.s12);
  });

  testWidgets('a press toggles the value', (tester) async {
    bool? value = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              Checkbox(value: value, onChanged: (v) => setState(() => value = v), label: 'Remember me'),
        ),
      ),
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(value, isTrue);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(value, isFalse);
  });

  testWidgets('tristate: a press on mixed checks it, and a press never sets mixed, as on the web', (tester) async {
    final seen = <bool?>[];
    bool? value;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Checkbox(
            value: value,
            onChanged: (v) => setState(() {
              value = v;
              seen.add(v);
            }),
            label: 'Remember me',
            tristate: true,
          ),
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsOneWidget, reason: 'mixed shows a mark (a dash)');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(value, isTrue, reason: 'mixed goes to checked');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(value, isFalse);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(value, isTrue);
    expect(seen, [true, false, true], reason: 'no press reports null: the app sets mixed');
  });

  testWidgets('disabled: faded, not pressable', (tester) async {
    await tester.pumpWidget(host(const Checkbox(value: false, onChanged: null, label: 'Remember me')));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
  });

  testWidgets('G5: announced as a checkbox named by its label, checked or mixed', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Checkbox(value: true, onChanged: (_) {}, label: 'Remember me')));
    expect(
      tester.getSemantics(find.byType(Checkbox)),
      isSemantics(label: 'Remember me', isButton: false, hasCheckedState: true, isChecked: true),
    );

    await tester.pumpWidget(host(Checkbox(value: null, onChanged: (_) {}, label: 'Remember me', tristate: true)));
    expect(
      tester.getSemantics(find.byType(Checkbox)),
      isSemantics(label: 'Remember me', hasCheckedState: true, isChecked: false, isCheckStateMixed: true),
    );
    semantics.dispose();
  });

  testWidgets('G6: Space toggles it', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    bool? value = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Checkbox(
            value: value,
            onChanged: (v) => setState(() => value = v),
            label: 'Remember me',
            focusNode: focus,
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets('G3: the row is at least target tall, on touch platforms or with a mouse', (tester) async {
    try {
      for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          host(
            Center(
              child: Checkbox(value: false, onChanged: (_) {}, label: 'Remember me'),
            ),
          ),
        );
        expect(
          tester.getSize(find.byType(Checkbox)).height,
          greaterThanOrEqualTo(TsuyaSize.target),
          reason: '$platform',
        );
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('a column that stretches it keeps the control and label at the start edge, as on the web', (
    tester,
  ) async {
    for (final direction in TextDirection.values) {
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Checkbox(value: false, onChanged: (_) {}, label: 'Remember me')],
              ),
            ),
          ),
          direction: direction,
        ),
      );
      final ltr = direction == TextDirection.ltr;
      final control = tester.getRect(find.byType(AnimatedContainer).last);
      expect(ltr ? control.left : 300 - control.right, 0, reason: '$direction');
      // the whole row stays pressable, as the label element fills the column on the web
      expect(tester.getSize(find.byType(Checkbox)).width, 300, reason: '$direction');
    }
  });
}
