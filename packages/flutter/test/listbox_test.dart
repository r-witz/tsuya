// Options, an active descendant, selection, type-ahead, groups and an empty state (DESIGN.md, Foundations:
// Accessibility). G5: semantics. G6: keyboard.
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/listbox.dart';

import 'support.dart';

const _options = [
  ListboxOption(value: 'a', label: 'Apple', disabled: true),
  ListboxOption(value: 'b', label: 'Banana'),
  ListboxOption(value: 'c', label: 'Cherry'),
];

Widget _itemBuilder(
  BuildContext context,
  ListboxOption<String> option, {
  required bool active,
  required bool selected,
}) => SizedBox(height: 20, child: Text(option.label));

Widget _harness({
  List<ListboxOption<String>> options = _options,
  Set<String> selected = const {},
  required ValueChanged<String> onSelected,
  bool multiple = false,
}) => host(
  Listbox<String>(
    options: options,
    selected: selected,
    onSelected: onSelected,
    multiple: multiple,
    itemBuilder: _itemBuilder,
    empty: const Text('Nothing here'),
    autofocus: true,
  ),
);

Semantics _semanticsOf(WidgetTester tester, String label) =>
    tester.widget<Semantics>(find.ancestor(of: find.text(label), matching: find.byType(Semantics)).first);

Semantics _listSemantics(WidgetTester tester) =>
    tester.widgetList<Semantics>(find.byType(Semantics)).firstWhere((s) => s.properties.role == SemanticsRole.list);

void main() {
  testWidgets('shows empty instead of the list when there are no options', (tester) async {
    await tester.pumpWidget(_harness(options: const [], onSelected: (_) {}));
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('G5: renders the options, each a listItem, under one list', (tester) async {
    await tester.pumpWidget(_harness(onSelected: (_) {}));
    expect(_listSemantics(tester).properties.role, SemanticsRole.list);
    expect(_listSemantics(tester).explicitChildNodes, isTrue);
    expect(_semanticsOf(tester, 'Banana').properties.role, SemanticsRole.listItem);
    expect(_semanticsOf(tester, 'Cherry').properties.role, SemanticsRole.listItem);
  });

  testWidgets('G5: the first enabled option is active (the active descendant); a disabled one never is', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(onSelected: (_) {}));
    expect(_semanticsOf(tester, 'Apple').properties.focused, isFalse);
    expect(_semanticsOf(tester, 'Apple').properties.enabled, isFalse);
    expect(_semanticsOf(tester, 'Banana').properties.focused, isTrue);
  });

  testWidgets('G6: ArrowDown/ArrowUp move the active option, skipping disabled ones, and stop at the ends', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(onSelected: (_) {}));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_semanticsOf(tester, 'Cherry').properties.focused, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_semanticsOf(tester, 'Cherry').properties.focused, isTrue, reason: 'it stops at the last');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(_semanticsOf(tester, 'Banana').properties.focused, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(_semanticsOf(tester, 'Banana').properties.focused, isTrue, reason: 'it stops at the first, Apple disabled');
  });

  testWidgets('G6: Home and End jump to the first and last enabled option', (tester) async {
    await tester.pumpWidget(_harness(onSelected: (_) {}));
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(_semanticsOf(tester, 'Cherry').properties.focused, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(_semanticsOf(tester, 'Banana').properties.focused, isTrue, reason: 'the disabled Apple is skipped');
  });

  testWidgets('G6: Enter and Space select the active option', (tester) async {
    final values = <String>[];
    await tester.pumpWidget(_harness(onSelected: values.add));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(values, ['b']);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(values, ['b', 'c']);
  });

  testWidgets('G6: typing a label jumps to the next option starting with it', (tester) async {
    await tester.pumpWidget(_harness(onSelected: (_) {}));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.pump();
    expect(_semanticsOf(tester, 'Cherry').properties.focused, isTrue);
  });

  testWidgets('G6: Ctrl+<letter> does not start a type-ahead search', (tester) async {
    await tester.pumpWidget(_harness(onSelected: (_) {}));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_semanticsOf(tester, 'Cherry').properties.focused, isTrue);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(_semanticsOf(tester, 'Cherry').properties.focused, isTrue, reason: 'Ctrl+B must not move the active option');
  });

  testWidgets('tapping an option makes it active and selects it', (tester) async {
    final values = <String>[];
    await tester.pumpWidget(_harness(onSelected: values.add));
    await tester.tap(find.text('Cherry'));
    await tester.pump();
    expect(values, ['c']);
    expect(_semanticsOf(tester, 'Cherry').properties.focused, isTrue);
  });

  testWidgets('single selection marks the option selected; multiple marks it checked instead', (tester) async {
    await tester.pumpWidget(_harness(selected: const {'b'}, onSelected: (_) {}));
    expect(_semanticsOf(tester, 'Banana').properties.selected, isTrue);
    expect(_semanticsOf(tester, 'Banana').properties.checked, isNull);

    await tester.pumpWidget(_harness(selected: const {'b'}, onSelected: (_) {}, multiple: true));
    expect(_semanticsOf(tester, 'Banana').properties.checked, isTrue);
    expect(_semanticsOf(tester, 'Banana').properties.selected, isNull);
  });

  testWidgets('a group heading is built once per group, in order', (tester) async {
    final headings = <String>[];
    await tester.pumpWidget(
      host(
        Listbox<String>(
          options: const [
            ListboxOption(value: 'a', label: 'Apple', group: 'Fruit'),
            ListboxOption(value: 'b', label: 'Banana', group: 'Fruit'),
            ListboxOption(value: 'c', label: 'Carrot', group: 'Vegetable'),
          ],
          selected: const {},
          onSelected: (_) {},
          itemBuilder: _itemBuilder,
          groupBuilder: (context, group) {
            headings.add(group);
            return SizedBox(height: 16, child: Text(group));
          },
        ),
      ),
    );
    expect(headings, ['Fruit', 'Vegetable']);
  });
}
