// Slider (DESIGN.md, Slider).
// G3: targets. G5: semantics. G6: keyboard. G14: right-to-left. G7, G9: smoke_test.dart.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

Widget _slider({
  double value = 10,
  ValueChanged<double>? onChanged,
  ValueChanged<double>? onChangeEnd,
  double min = 0,
  double max = 100,
  double? step,
  String Function(double)? valueLabel,
  FocusNode? focusNode,
}) => Center(
  child: SizedBox(
    width: 200,
    child: Slider(
      value: value,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      label: 'Volume',
      min: min,
      max: max,
      step: step,
      valueLabel: valueLabel,
      focusNode: focusNode,
    ),
  ),
);

void main() {
  testWidgets('the track is in track, the fill in the accent, the thumb in thumb with a hairline ring', (tester) async {
    await tester.pumpWidget(host(_slider(onChanged: (_) {})));
    final bars = tester.widgetList<Container>(find.byType(Container)).toList();
    expect((bars[0].decoration! as BoxDecoration).color, TsuyaColors.light.track);
    expect((bars[1].decoration! as BoxDecoration).color, TsuyaColors.light.accent);
    final thumb = bars[2].decoration! as BoxDecoration;
    expect(thumb.color, TsuyaColors.light.thumb);
    expect(thumb.border!.top.color, TsuyaColors.light.borderStrong);
    expect(thumb.boxShadow, TsuyaShadows.light.sm);
  });

  testWidgets('is target tall', (tester) async {
    await tester.pumpWidget(host(_slider(onChanged: (_) {})));
    expect(tester.getSize(find.byType(Slider)).height, TsuyaSize.target);
  });

  testWidgets('pressing the track sets the value from that position', (tester) async {
    double? value;
    await tester.pumpWidget(host(_slider(onChanged: (v) => value = v)));
    final topLeft = tester.getTopLeft(find.byType(Slider));
    final height = tester.getSize(find.byType(Slider)).height;
    // 200 wide, a 20 thumb: 180 usable; pressing at x=100 is (100 - 10) / 180 = 50 % of the 0-100 range.
    final gesture = await tester.startGesture(topLeft + Offset(100, height / 2));
    await tester.pump();
    expect(value, closeTo(50, 0.5));
    await gesture.up();
  });

  testWidgets('dragging updates continuously; releasing ends it', (tester) async {
    double? last;
    double? ended;
    await tester.pumpWidget(host(_slider(onChanged: (v) => last = v, onChangeEnd: (v) => ended = v)));
    final topLeft = tester.getTopLeft(find.byType(Slider));
    final height = tester.getSize(find.byType(Slider)).height;
    final gesture = await tester.startGesture(topLeft + Offset(10, height / 2));
    await tester.pump();
    expect(last, closeTo(0, 0.5));
    await gesture.moveTo(topLeft + Offset(190, height / 2));
    await tester.pump();
    expect(last, closeTo(100, 0.5));
    await gesture.up();
    await tester.pump();
    expect(ended, closeTo(100, 0.5));
  });

  testWidgets('a tap inside a scrollable ends what it changed, once', (tester) async {
    final events = <String>[];
    await tester.pumpWidget(
      host(
        ListView(
          children: [
            Slider(
              value: 0.2,
              onChanged: (v) => events.add('changed $v'),
              onChangeEnd: (v) => events.add('end $v'),
              label: 'Volume',
            ),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(Slider));
    await tester.pump();
    expect(events, ['changed 0.5', 'end 0.5']);
  });

  testWidgets('a press that the scrollable takes over ends what it changed, once', (tester) async {
    final events = <String>[];
    await tester.pumpWidget(
      host(
        ListView(
          children: [
            Slider(
              value: 0.2,
              onChanged: (v) => events.add('changed $v'),
              onChangeEnd: (v) => events.add('end $v'),
              label: 'Volume',
            ),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );
    final gesture = await tester.startGesture(tester.getCenter(find.byType(Slider)));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(events.where((e) => e.startsWith('changed')), isNotEmpty);
    expect(events.where((e) => e.startsWith('end')), hasLength(1));
  });

  testWidgets('step snaps both dragging and keyboard moves', (tester) async {
    double? value;
    await tester.pumpWidget(host(_slider(onChanged: (v) => value = v, step: 25)));
    final topLeft = tester.getTopLeft(find.byType(Slider));
    final height = tester.getSize(find.byType(Slider)).height;
    // x=100 alone would be 50 %, but it snaps to the nearest step of 25.
    final gesture = await tester.startGesture(topLeft + Offset(105, height / 2));
    await tester.pump();
    expect(value, closeTo(50, 0.01));
    await gesture.up();
  });

  testWidgets('disabled: faded, ignores drags', (tester) async {
    await tester.pumpWidget(host(_slider()));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
    final topLeft = tester.getTopLeft(find.byType(Slider));
    final height = tester.getSize(find.byType(Slider)).height;
    await tester.tapAt(topLeft + Offset(190, height / 2));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('G5: announced as a slider named by its label, value a percentage unless formatted', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(_slider(value: 40, onChanged: (_) {})));
    expect(tester.getSemantics(find.byType(Slider)), isSemantics(label: 'Volume', isSlider: true, value: '40 %'));

    await tester.pumpWidget(host(_slider(value: 40, onChanged: (_) {}, valueLabel: (v) => '${v.round()} dB')));
    expect(tester.getSemantics(find.byType(Slider)), isSemantics(value: '40 dB'));
    semantics.dispose();
  });

  testWidgets('the default range is 0 to 1, a step a twentieth of it, announced as a percentage, as on the web', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final focus = FocusNode();
    addTearDown(focus.dispose);
    var value = 0.5;
    await tester.pumpWidget(
      host(
        Center(
          child: SizedBox(
            width: 200,
            child: Slider(value: value, onChanged: (v) => value = v, label: 'Volume', focusNode: focus),
          ),
        ),
      ),
    );
    expect(tester.getSemantics(find.byType(Slider)), isSemantics(label: 'Volume', isSlider: true, value: '50 %'));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(value, closeTo(0.55, 1e-9));
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    expect(value, 1.0);
    semantics.dispose();
  });

  testWidgets('G6: arrows move by step, Page Up/Down by a tenth, Home/End to the ends', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    double value = 50;
    double? ended;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => _slider(
            value: value,
            onChanged: (v) => setState(() => value = v),
            onChangeEnd: (v) => ended = v,
            focusNode: focus,
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, 55, reason: 'a twentieth of a 0-100 range is 5');
    expect(ended, 55);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(value, 50);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();
    expect(value, 60, reason: 'a tenth of a 0-100 range is 10');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(value, 100);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(value, 0);
  });

  testWidgets('G6: Page Up/Down move by at least one step when the step is wider than a tenth', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    double value = 0.5;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => _slider(
            value: value,
            min: 0,
            max: 1,
            step: 0.25,
            onChanged: (v) => setState(() => value = v),
            focusNode: focus,
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();
    expect(value, 0.75);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();
    expect(value, 0.5);
  });

  testWidgets('G3: is target tall', (tester) async {
    await tester.pumpWidget(host(_slider(onChanged: (_) {})));
    expect(tester.getSize(find.byType(Slider)).height, TsuyaSize.target);
  });

  testWidgets('G14: fills from the end, and the arrow keys mirror, under right-to-left', (tester) async {
    await tester.pumpWidget(host(_slider(value: 25, onChanged: (_) {}), direction: TextDirection.rtl));
    final bars = tester.widgetList<Container>(find.byType(Container)).toList();
    final fill = tester.getTopRight(find.byWidget(bars[1]));
    final track = tester.getTopRight(find.byWidget(bars[0]));
    expect(fill.dx, closeTo(track.dx, 0.5), reason: 'the fill is anchored to the end (the right) under RTL');

    final focus = FocusNode();
    addTearDown(focus.dispose);
    double value = 50;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              _slider(value: value, onChanged: (v) => setState(() => value = v), focusNode: focus),
        ),
        direction: TextDirection.rtl,
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, 45, reason: 'right decreases under right-to-left');
  });
}
