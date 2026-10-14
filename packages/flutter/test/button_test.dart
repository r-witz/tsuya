// Button (DESIGN.md, Button).
// G3: targets. G5: semantics. G6: keyboard. G7, G9, G14: smoke_test.dart.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

BoxDecoration _body(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration;

BoxDecoration _border(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).foregroundDecoration! as BoxDecoration;

void main() {
  testWidgets('kind defaults to secondary (fill, hairline, text), size to md', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: Button(label: 'Continue', onPressed: () {}),
        ),
      ),
    );
    final decoration = _body(tester);
    expect(decoration.color, TsuyaColors.light.fill);
    expect(_border(tester).border!.top.color, TsuyaColors.light.border);
    expect(decoration.borderRadius, BorderRadius.circular(TsuyaSize.controlMd / 2));
    final text = tester.widget<Text>(find.text('Continue'));
    expect(text.style!.color, TsuyaColors.light.text);
    expect(tester.getSize(find.byType(Button)).height, TsuyaSize.controlMd);
  });

  testWidgets('primary: the accent filled, on-accent text; danger: danger filled, on-status text', (tester) async {
    await tester.pumpWidget(host(Button(label: 'Save', onPressed: () {}, kind: ButtonKind.primary)));
    expect(_body(tester).color, TsuyaColors.light.accent);
    expect(tester.widget<Text>(find.text('Save')).style!.color, TsuyaColors.light.onAccent);

    await tester.pumpWidget(host(Button(label: 'Delete', onPressed: () {}, kind: ButtonKind.danger)));
    expect(_body(tester).color, TsuyaColors.light.danger);
    expect(tester.widget<Text>(find.text('Delete')).style!.color, TsuyaColors.light.onStatus);
  });

  testWidgets('ghost: no fill until hover; glass: control glass', (tester) async {
    await tester.pumpWidget(host(Button(label: 'Cancel', onPressed: () {}, kind: ButtonKind.ghost)));
    expect(_body(tester).color, isNull);

    await tester.pumpWidget(host(Button(label: 'Cancel', onPressed: () {}, kind: ButtonKind.glass)));
    expect(find.byType(ControlGlass), findsOneWidget);
  });

  testWidgets('an icon sits space-8 from the label', (tester) async {
    await tester.pumpWidget(
      host(
        Button(
          label: 'Play',
          onPressed: () {},
          icon: const SizedBox(key: Key('icon'), width: 4, height: 4),
        ),
      ),
    );
    final gap = tester.getTopLeft(find.text('Play')).dx - tester.getTopRight(find.byKey(const Key('icon'))).dx;
    expect(gap, TsuyaSpace.s8);
  });

  testWidgets('block grows to fill the width it is given; otherwise it shrinks to its content', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: const Button(label: 'Continue', onPressed: null, block: true),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Button)).width, 300);

    await tester.pumpWidget(
      host(
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Button(label: 'Go', onPressed: () {}),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Button)).width, lessThan(300));
  });

  group('loading', () {
    testWidgets('shows a spinner, keeps the width, ignores presses, no press-shrink', (tester) async {
      const label = 'A rather long label for this button';
      await tester.pumpWidget(
        host(
          Center(
            child: Button(label: label, onPressed: () {}),
          ),
        ),
      );
      final width = tester.getSize(find.byType(Button)).width;
      expect(find.byType(Spinner), findsNothing);

      var presses = 0;
      await tester.pumpWidget(
        host(
          Center(
            child: Button(label: label, onPressed: () => presses++, loading: true),
          ),
        ),
      );
      expect(tester.getSize(find.byType(Button)).width, closeTo(width, 0.5));
      expect(find.byType(Spinner), findsOneWidget);
      await tester.tap(find.byType(Button));
      expect(presses, 0);
      expect(find.byType(AnimatedScale), findsNothing);
    });

    testWidgets('G5: the loading label merges with the button label', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(host(Button(label: 'Save', onPressed: () {}, loading: true)));
      expect(
        tester.getSemantics(find.byType(Button)),
        isSemantics(label: 'Save\n${TsuyaLabels.en.loading}', isButton: true, isEnabled: true, isFocusable: true),
      );
      semantics.dispose();
    });
  });

  testWidgets('disabled: faded, not pressable, not focusable', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(host(Button(label: 'Save', onPressed: null, focusNode: focus)));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isFalse);
  });

  testWidgets('G6: Enter and Space press it', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    var presses = 0;
    await tester.pumpWidget(host(Button(label: 'Save', onPressed: () => presses++, focusNode: focus)));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(presses, 2);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('G5: announced as a button named by its label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Button(label: 'Save', onPressed: () {})));
    expect(
      tester.getSemantics(find.byType(Button)),
      isSemantics(label: 'Save', isButton: true, hasEnabledState: true, isEnabled: true),
    );
    semantics.dispose();
  });

  testWidgets('G3: the target is 44 on touch platforms, 24 with a mouse', (tester) async {
    try {
      for (final (platform, side) in [(TargetPlatform.android, 44.0), (TargetPlatform.macOS, 24.0)]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          host(
            Center(
              child: Button(label: 'Ok', onPressed: () {}, size: ButtonSize.sm),
            ),
          ),
        );
        expect(tester.getSize(find.byType(Button)).height, greaterThanOrEqualTo(side), reason: '$platform');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
