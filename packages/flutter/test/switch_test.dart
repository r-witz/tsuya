// Switch (DESIGN.md, Switch).
// G3: targets. G5: semantics. G6: keyboard. G9: reduced motion. G14: right-to-left. G7: smoke_test.dart.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

AnimatedContainer _track(WidgetTester tester) => tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));

Container _thumb(WidgetTester tester) =>
    tester.widget<Container>(find.descendant(of: find.byType(AnimatedAlign), matching: find.byType(Container)));

// how far the thumb sits towards the visual right of its track: negative on the left, positive on the right
double _thumbOffset(WidgetTester tester) =>
    tester.getCenter(find.descendant(of: find.byType(AnimatedAlign), matching: find.byType(Container))).dx -
    tester.getCenter(find.byType(AnimatedContainer)).dx;

void main() {
  testWidgets('off: a border-strong track with a thumb-coloured thumb', (tester) async {
    await tester.pumpWidget(host(Switch(value: false, onChanged: (_) {}, label: 'Wi-Fi')));
    expect((_track(tester).decoration! as BoxDecoration).color, TsuyaColors.light.borderStrong);
    expect((_thumb(tester).decoration! as BoxDecoration).color, TsuyaColors.light.thumb);
    expect(_thumbOffset(tester), lessThan(0));
  });

  testWidgets('on: an accent track with an on-accent thumb, slid to the other edge', (tester) async {
    await tester.pumpWidget(host(Switch(value: true, onChanged: (_) {}, label: 'Wi-Fi')));
    expect((_track(tester).decoration! as BoxDecoration).color, TsuyaColors.light.accent);
    expect((_thumb(tester).decoration! as BoxDecoration).color, TsuyaColors.light.onAccent);
    expect(_thumbOffset(tester), greaterThan(0));
  });

  testWidgets('the track is 48 by 28, the thumb 24', (tester) async {
    await tester.pumpWidget(host(Switch(value: false, onChanged: (_) {}, label: 'Wi-Fi')));
    expect(_track(tester).constraints, const BoxConstraints.tightFor(width: 48, height: 28));
    expect(_thumb(tester).constraints, const BoxConstraints.tightFor(width: 24, height: 24));
  });

  testWidgets('without a label, only the track is shown; the caller names it instead', (tester) async {
    await tester.pumpWidget(host(Switch(value: false, onChanged: (_) {})));
    expect(find.text('Wi-Fi'), findsNothing);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('its label is drawn beside the track, in body, and the whole control presses', (tester) async {
    var value = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              Switch(value: value, onChanged: (v) => setState(() => value = v), label: 'Wi-Fi'),
        ),
      ),
    );
    final text = tester.widget<Text>(find.text('Wi-Fi'));
    expect(text.style?.fontSize, 15);
    expect(text.style?.fontWeight, FontWeight.w500);
    final track = tester.getRect(find.byType(AnimatedContainer));
    expect(tester.getTopLeft(find.text('Wi-Fi')).dx - track.right, TsuyaSpace.s12);
    await tester.tap(find.text('Wi-Fi'));
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets('a press toggles the value at once', (tester) async {
    bool value = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              Switch(value: value, onChanged: (v) => setState(() => value = v), label: 'Wi-Fi'),
        ),
      ),
    );
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets('disabled: faded, not pressable', (tester) async {
    await tester.pumpWidget(host(const Switch(value: false, onChanged: null, label: 'Wi-Fi')));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
  });

  testWidgets('G5: announced as a switch named by its label, on or off', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Switch(value: true, onChanged: (_) {}, label: 'Wi-Fi')));
    expect(
      tester.getSemantics(find.byType(Switch)),
      isSemantics(label: 'Wi-Fi', isButton: false, hasToggledState: true, isToggled: true),
    );
    semantics.dispose();
  });

  testWidgets('G6: Space toggles it', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    bool value = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              Switch(value: value, onChanged: (v) => setState(() => value = v), label: 'Wi-Fi', focusNode: focus),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets('G3: the target is 44 on touch platforms, 28 with a mouse', (tester) async {
    try {
      for (final (platform, side) in [(TargetPlatform.android, 44.0), (TargetPlatform.macOS, 28.0)]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          host(
            Center(
              child: Switch(value: false, onChanged: (_) {}, label: 'Wi-Fi'),
            ),
          ),
        );
        expect(tester.getSize(find.byType(Switch)).height, greaterThanOrEqualTo(side), reason: '$platform');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('G9: the thumb slides over the fast duration, at once under reduced motion', (tester) async {
    Duration slide() => tester.widget<AnimatedAlign>(find.byType(AnimatedAlign)).duration;
    await tester.pumpWidget(host(Switch(value: false, onChanged: (_) {}, label: 'Wi-Fi'), animate: true));
    expect(slide(), TsuyaDuration.fast);
    await tester.pumpWidget(host(Switch(value: false, onChanged: (_) {}, label: 'Wi-Fi')));
    expect(slide(), Duration.zero);
  });

  testWidgets('G14: right to left, the thumb rests on the right and slides to the left', (tester) async {
    await tester.pumpWidget(
      host(
        Switch(value: false, onChanged: (_) {}, label: 'Wi-Fi'),
        direction: TextDirection.rtl,
      ),
    );
    expect(_thumbOffset(tester), greaterThan(0));
    await tester.pumpWidget(
      host(
        Switch(value: true, onChanged: (_) {}, label: 'Wi-Fi'),
        direction: TextDirection.rtl,
      ),
    );
    expect(_thumbOffset(tester), lessThan(0));
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
                children: [Switch(value: false, onChanged: (_) {}, label: 'Wi-Fi')],
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
      expect(tester.getSize(find.byType(Switch)).width, 300, reason: '$direction');
    }
  });
}
