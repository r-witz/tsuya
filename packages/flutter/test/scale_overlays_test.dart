// G7 (anchored position, "shift to stay space-16 inside"): at a text scale of 2 or 3 on a 320 px phone, a
// floating panel stays at most the view minus 2 × space-16 wide, so its anchored position keeps it space-16 inside.
// A menu item's label that does not fit ellipsizes on one line, and stays the semantics label whole.
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/listbox.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

const _long = 'A rather long label that has to wrap or ellipsize at three hundred percent';
const _phone = Size(320, 568);
const _options = [ListboxOption(value: 1, label: _long), ListboxOption(value: 2, label: 'Spain')];

// the panel's own rect: what a space-16 margin is measured on
void _insideBy16(WidgetTester tester, Finder panelContent) {
  final r = tester.getRect(panelContent);
  expect(r.left, greaterThanOrEqualTo(TsuyaSpace.s16 - 0.01), reason: '$r');
  expect(r.right, lessThanOrEqualTo(_phone.width - TsuyaSpace.s16 + 0.01), reason: '$r');
}

void main() {
  for (final scale in [2.0, 3.0]) {
    testWidgets('G7: a menu at text scale $scale stays inside, its long label on one line', (tester) async {
      final semantics = tester.ensureSemantics();
      viewAt(tester, _phone);
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.topRight,
            child: MenuButton(
              label: 'Actions',
              items: [
                MenuItem(label: _long, onSelect: () {}, shortcut: 'Ctrl+K'),
                MenuItem(label: 'Duplicate', onSelect: () {}),
              ],
            ),
          ),
          size: _phone,
          textScale: scale,
        ),
      );
      await tester.tap(find.byType(MenuButton));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      _insideBy16(tester, find.byType(IntrinsicWidth));
      final label = tester.renderObject<RenderParagraph>(find.text(_long));
      expect(label.didExceedMaxLines, isTrue);
      expect(tester.getSize(find.text(_long)).height, lessThan(label.text.style!.fontSize! * scale * 2));
      expect(find.bySemanticsLabel(_long), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('G7: a popover at text scale $scale stays inside', (tester) async {
      viewAt(tester, _phone);
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.topLeft,
            child: Popover(label: 'Info', builder: (c) => const Text(_long)),
          ),
          size: _phone,
          textScale: scale,
        ),
      );
      await tester.tap(find.byType(Popover));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      _insideBy16(tester, find.text(_long));
      expect(tester.getRect(find.text(_long)).bottom, lessThanOrEqualTo(_phone.height));
    });

    testWidgets('G7: a select panel at text scale $scale stays inside', (tester) async {
      viewAt(tester, _phone);
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.topLeft,
            child: Select<int>(
              label: 'Country',
              value: null,
              onChanged: (_) {},
              options: _options,
              sheetOnPhone: false,
            ),
          ),
          size: _phone,
          textScale: scale,
        ),
      );
      await tester.tap(find.byType(Select<int>));
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      _insideBy16(tester, find.byType(Listbox<int>));
    });

    testWidgets('G7: a combobox panel at text scale $scale stays inside', (tester) async {
      viewAt(tester, _phone);
      await tester.pumpWidget(
        host(
          Align(
            alignment: Alignment.topLeft,
            child: Combobox<int>(label: 'Country', options: _options, onSelected: (_) {}),
          ),
          size: _phone,
          textScale: scale,
        ),
      );
      await tester.tap(find.byType(Combobox<int>));
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      _insideBy16(tester, find.text(_long));
    });
  }
}
