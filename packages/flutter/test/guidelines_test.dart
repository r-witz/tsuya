// G3, G5: Flutter's own accessibility guidelines over every interactive component, in light and dark, on
// Android and on iOS: `iOSTapTargetGuideline` (44, which is `--t-size-target`), `labeledTapTargetGuideline` and
// `textContrastGuideline`. A switch with no label (named by its row, which the app provides) is left out.
//
// `androidTapTargetGuideline` asks 48 where the design's target is 44, so it fails on every 44-tall control (buttons,
// fields, segments, menu items...). The target stays 44 on every platform, Android included (G3): the
// Android guideline stays skipped below, with its reason.
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide RadioGroup, Banner;
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

// Away from the edges of the view, which the tap target guidelines skip (a node touching one may be scrolled off), and
// on the app's background, in the repaint boundary the guideline reads the rendered pixels from (the nearest one around
// the control): a fill with some transparency is measured against what it is drawn on, not against nothing.
Widget _column(Widget child) => Builder(
  builder: (context) => RepaintBoundary(
    child: ColoredBox(
      color: TsuyaTheme.of(context).colors.bg,
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  ),
);

const _options = [ListboxOption(value: 1, label: 'France'), ListboxOption(value: 2, label: 'Spain')];

final _cases = <String, Widget Function()>{
  'primary button': () => Button(label: 'Save', kind: ButtonKind.primary, onPressed: () {}),
  'secondary button': () => Button(label: 'Cancel', onPressed: () {}),
  'ghost button': () => Button(label: 'Skip', kind: ButtonKind.ghost, onPressed: () {}),
  'danger button': () => Button(label: 'Delete', kind: ButtonKind.danger, onPressed: () {}),
  'icon button': () => IconButton(icon: const SizedBox(width: 20, height: 20), label: 'More', onPressed: () {}),
  'chip': () => Chip(label: 'Rock', selected: false, onPressed: () {}),
  'selected chip': () => Chip(label: 'Rock', selected: true, onPressed: () {}),
  'switch with a label': () => Switch(value: false, onChanged: (_) {}, label: 'Wi-Fi'),
  'checkbox': () => Checkbox(value: false, onChanged: (_) {}, label: 'Remember me'),
  'slider': () => Slider(value: 0.5, onChanged: (_) {}, label: 'Volume'),
  'text field': () => const TextField(label: 'Email'),
  'search': () => const TextField.search(label: 'Search'),
  'select': () => Select<int>(label: 'Country', value: 1, onChanged: (_) {}, options: _options),
  'combobox': () => Combobox<int>(label: 'Country', options: _options, onSelected: (_) {}),
  'list item': () => ListItem(title: 'Albums', subtitle: 'Twelve', onPressed: () {}),
  'segmented control': () => SegmentedControl<int>(
    label: 'View',
    segments: const [
      Segment(value: 1, label: 'Grid'),
      Segment(value: 2, label: 'List'),
    ],
    selected: 1,
    onChanged: (_) {},
  ),
  'radio group': () => RadioGroup<int>(
    label: 'Plan',
    value: 1,
    onChanged: (_) {},
    options: const [
      RadioOption(value: 1, label: 'Free'),
      RadioOption(value: 2, label: 'Pro'),
    ],
  ),
  'tabs': () => Tabs<int>(
    label: 'Sections',
    selected: 1,
    onChanged: (_) {},
    tabs: const [
      TabItem(value: 1, label: 'Songs'),
      TabItem(value: 2, label: 'Albums'),
    ],
  ),
  'tab bar': () => TabBar<int>(
    label: 'Main',
    current: 1,
    onSelect: (_) {},
    items: const [
      TabBarItem(value: 1, label: 'Home', icon: Glyph(TsuyaGlyph.search)),
      TabBarItem(value: 2, label: 'Library', icon: Glyph(TsuyaGlyph.search)),
    ],
  ),
  'menu button': () => MenuButton(
    label: 'Actions',
    items: [MenuItem(label: 'Rename', onSelect: () {})],
  ),
  'popover': () => Popover(label: 'Info', builder: (c) => const Text('Hello')),
  'accordion': () => Accordion(
    value: const ['a'],
    onChanged: (_) {},
    items: const [AccordionItemData(value: 'a', label: 'Details', content: Text('More'))],
  ),
};

Future<void> _check(WidgetTester tester, Widget child, TsuyaMode mode, TargetPlatform platform) async {
  debugDefaultTargetPlatformOverride = platform;
  final handle = tester.ensureSemantics();
  await tester.pumpWidget(host(_column(child), mode: mode));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
  debugDefaultTargetPlatformOverride = null;
}

void main() {
  for (final mode in [TsuyaMode.light, TsuyaMode.dark]) {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      for (final entry in _cases.entries) {
        testWidgets('G3, G5: ${entry.key}, ${mode.name}, ${platform.name}', (tester) async {
          await _check(tester, entry.value(), mode, platform);
        });
      }

      testWidgets('G3, G5: the items of an open menu, ${mode.name}, ${platform.name}', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            _column(
              MenuButton(
                label: 'Actions',
                items: [
                  MenuItem(label: 'Rename', onSelect: () {}),
                  MenuItem(label: 'Archive', checked: true, onSelect: () {}),
                  MenuItem(label: 'Delete', destructive: true, onSelect: () {}),
                ],
              ),
            ),
            mode: mode,
          ),
        );
        await tester.tap(find.byType(MenuButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
        debugDefaultTargetPlatformOverride = null;
      });
    }
  }

  testWidgets('G3: androidTapTargetGuideline on a button', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(host(_column(Button(label: 'Save', onPressed: () {}))));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    debugDefaultTargetPlatformOverride = null;
  }, skip: true); // --t-size-target is 44 on every platform, Android included, though it asks 48 (G3)
}
