// G6, roving focus: after a mouse click on a radio, tab, segment, tab bar item or chip, the arrow keys move
// from it, as on the web where a click focuses the native control. The click shows no focus ring (keyboard only); the
// arrow that follows does.
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide RadioGroup, Banner;
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/focus_ring.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

typedef _Build = Widget Function(String value, ValueChanged<String> set);

const _ids = ['a', 'b', 'c'];
const _labels = {'a': 'Free', 'b': 'Pro', 'c': 'Team'};

final _groups = <String, _Build>{
  'radio group': (v, set) => RadioGroup<String>(
    label: 'Plan',
    value: v,
    onChanged: set,
    options: [for (final id in _ids) RadioOption(value: id, label: _labels[id]!)],
  ),
  'tabs': (v, set) => Tabs<String>(
    label: 'Plan',
    selected: v,
    onChanged: set,
    manual: true,
    tabs: [for (final id in _ids) TabItem(value: id, label: _labels[id]!)],
  ),
  'segmented control': (v, set) => SegmentedControl<String>(
    label: 'Plan',
    selected: v,
    onChanged: set,
    segments: [for (final id in _ids) Segment(value: id, label: _labels[id]!)],
  ),
  'tab bar': (v, set) => TabBar<String>(
    label: 'Plan',
    current: v,
    onSelect: set,
    items: [for (final id in _ids) TabBarItem(value: id, label: _labels[id]!, icon: const Glyph(TsuyaGlyph.search))],
  ),
  'chip group': (v, set) => ChipGroup<String>(
    label: 'Plan',
    value: {v},
    onChanged: (x) => set(x.first),
    chips: [for (final id in _ids) ChipOption(value: id, label: _labels[id]!)],
  ),
};

bool _hasFocus(WidgetTester tester, String label) => Focus.of(tester.element(find.text(label))).hasPrimaryFocus;

bool _ringShown(WidgetTester tester) => tester.widgetList<FocusRing>(find.byType(FocusRing)).any((r) => r.focused);

void main() {
  for (final entry in _groups.entries) {
    testWidgets('G6: after a click in a ${entry.key}, the arrow keys move from it, with no ring until the arrow', (
      tester,
    ) async {
      viewAt(tester, const Size(500, 300));
      // a desktop: a key press switches to the keyboard highlight, a mobile platform never does
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      var value = 'a';
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.topLeft,
            child: StatefulBuilder(builder: (context, set) => entry.value(value, (v) => set(() => value = v))),
          ),
          size: const Size(500, 300),
        ),
      );
      await tester.tap(find.text('Pro'), kind: PointerDeviceKind.mouse);
      await tester.pump();
      expect(_hasFocus(tester, 'Pro'), isTrue, reason: 'the click focused it');
      expect(_ringShown(tester), isFalse, reason: 'a pointer press shows no keyboard ring');
      final forward = entry.key == 'radio group' ? LogicalKeyboardKey.arrowDown : LogicalKeyboardKey.arrowRight;
      await tester.sendKeyEvent(forward);
      await tester.pump();
      expect(_hasFocus(tester, 'Team'), isTrue);
      expect(_ringShown(tester), isTrue);
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
