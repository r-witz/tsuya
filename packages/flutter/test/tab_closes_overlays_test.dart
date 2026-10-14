// G6 (DESIGN.md, Menu: "Escape and Tab close"): under a real `TsuyaApp`, which maps Tab to the next focus, Tab in an
// open menu, popover or select closes it and focus goes on to the control after the opener; Shift+Tab goes to the opener
// first, the layer still open, and one more closes it and goes before it, as on the web where the layer sits right
// after its opener.
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide RadioGroup, Banner;
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/dismissable_layer.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

const _options = [ListboxOption(value: 1, label: 'France'), ListboxOption(value: 2, label: 'Spain')];

final _builders = <String, Widget Function(FocusNode)>{
  'menu': (f) => MenuButton(
    label: 'Actions',
    focusNode: f,
    items: [
      MenuItem(label: 'Rename', onSelect: () {}),
      MenuItem(label: 'Delete', onSelect: () {}),
    ],
  ),
  'popover': (f) => Popover(label: 'Info', focusNode: f, builder: (c) => const Text('Hello')),
  'select': (f) => Select<int>(
    label: 'Country',
    value: null,
    focusNode: f,
    onChanged: (_) {},
    options: _options,
    sheetOnPhone: false,
  ),
};

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  for (final entry in _builders.entries) {
    for (final forward in [true, false]) {
      testWidgets(
        "G6: ${forward ? 'Tab in an open ${entry.key} closes it and moves on' : 'Shift+Tab in an open ${entry.key} goes to its opener, then closes it and moves on'}",
        (tester) async {
          viewAt(tester, const Size(900, 700));
          final before = FocusNode(debugLabel: 'before');
          final opener = FocusNode(debugLabel: 'opener');
          final after = FocusNode(debugLabel: 'after');
          addTearDown(before.dispose);
          addTearDown(opener.dispose);
          addTearDown(after.dispose);
          await tester.pumpWidget(
            TsuyaApp(
              labels: TsuyaLabels.en,
              home: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Button(label: 'Before', onPressed: () {}, focusNode: before),
                    entry.value(opener),
                    Button(label: 'After', onPressed: () {}, focusNode: after),
                  ],
                ),
              ),
            ),
          );
          opener.requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await _settle(tester);
          expect(opener.hasFocus, isFalse, reason: 'focus moved into the layer');
          expect(find.byType(DismissableLayer), findsOneWidget);
          if (!forward) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          if (!forward) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await _settle(tester);
          if (forward) {
            expect(after.hasPrimaryFocus, isTrue);
            expect(find.byType(DismissableLayer), findsNothing);
            return;
          }
          // the layer sits right after its opener on the web: Shift+Tab from its first control lands on the opener, with
          // the layer still open, and one more goes before it and closes it
          expect(opener.hasPrimaryFocus, isTrue);
          expect(find.byType(DismissableLayer), findsOneWidget);
          await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await _settle(tester);
          expect(before.hasPrimaryFocus, isTrue);
          expect(find.byType(DismissableLayer), findsNothing);
        },
      );
    }
  }

  testWidgets("G6: Tab moves through a popover's controls, and closes it past the last", (tester) async {
    viewAt(tester, const Size(900, 700));
    final opener = FocusNode(debugLabel: 'opener');
    final first = FocusNode(debugLabel: 'first');
    final second = FocusNode(debugLabel: 'second');
    final after = FocusNode(debugLabel: 'after');
    for (final node in [opener, first, second, after]) {
      addTearDown(node.dispose);
    }
    await tester.pumpWidget(
      TsuyaApp(
        labels: TsuyaLabels.en,
        home: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Popover(
                label: 'Filters',
                focusNode: opener,
                builder: (c) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Button(label: 'One', onPressed: () {}, focusNode: first),
                    Button(label: 'Two', onPressed: () {}, focusNode: second),
                  ],
                ),
              ),
              Button(label: 'After', onPressed: () {}, focusNode: after),
            ],
          ),
        ),
      ),
    );
    opener.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await _settle(tester);
    expect(first.hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(second.hasPrimaryFocus, isTrue);
    expect(find.byType(DismissableLayer), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(after.hasPrimaryFocus, isTrue);
    expect(find.byType(DismissableLayer), findsNothing);
  });

  testWidgets('G6: after a mouse click on a popover, Tab on its opener goes into the panel', (tester) async {
    viewAt(tester, const Size(900, 700));
    final opener = FocusNode(debugLabel: 'opener');
    final inside = FocusNode(debugLabel: 'inside');
    final after = FocusNode(debugLabel: 'after');
    for (final node in [opener, inside, after]) {
      addTearDown(node.dispose);
    }
    await tester.pumpWidget(
      TsuyaApp(
        labels: TsuyaLabels.en,
        home: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Popover(
                label: 'Filters',
                focusNode: opener,
                builder: (c) => Button(label: 'One', onPressed: () {}, focusNode: inside),
              ),
              Button(label: 'After', onPressed: () {}, focusNode: after),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Popover), kind: PointerDeviceKind.mouse);
    await _settle(tester);
    expect(opener.hasPrimaryFocus, isTrue, reason: 'a click leaves focus on the opener, as on the web');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(inside.hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(after.hasPrimaryFocus, isTrue);
    expect(find.byType(DismissableLayer), findsNothing);
  });

  testWidgets('G6: in a dialog, Shift+Tab from an open menu goes to its opener, then to the control before it', (
    tester,
  ) async {
    viewAt(tester, const Size(900, 700));
    final first = FocusNode(debugLabel: 'first');
    final opener = FocusNode(debugLabel: 'opener');
    addTearDown(first.dispose);
    addTearDown(opener.dispose);
    late BuildContext context;
    await tester.pumpWidget(
      TsuyaApp(
        labels: TsuyaLabels.en,
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    unawaited(
      Dialog.show<void>(
        context,
        builder: (c) => Dialog(
          title: 'T',
          actions: const [],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(label: 'First', onPressed: () {}, focusNode: first),
              MenuButton(
                label: 'Actions',
                focusNode: opener,
                items: [MenuItem(label: 'Rename', onSelect: () {})],
              ),
            ],
          ),
        ),
      ),
    );
    await _settle(tester);
    opener.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await _settle(tester);
    for (final expected in [opener, first]) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await _settle(tester);
      expect(expected.hasPrimaryFocus, isTrue);
      expect(find.byType(DismissableLayer), expected == opener ? findsNWidgets(2) : findsOneWidget);
    }
  });

  testWidgets('G6: after a mouse click on a popover with nothing to focus, Tab on its opener closes it and moves on', (
    tester,
  ) async {
    viewAt(tester, const Size(900, 700));
    final opener = FocusNode(debugLabel: 'opener');
    final after = FocusNode(debugLabel: 'after');
    addTearDown(opener.dispose);
    addTearDown(after.dispose);
    await tester.pumpWidget(
      TsuyaApp(
        labels: TsuyaLabels.en,
        home: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Popover(label: 'Info', focusNode: opener, builder: (c) => const Text('Hi')),
              Button(label: 'After', onPressed: () {}, focusNode: after),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Popover), kind: PointerDeviceKind.mouse);
    await _settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(after.hasPrimaryFocus, isTrue, reason: 'no phantom stop on the empty panel');
    expect(find.byType(DismissableLayer), findsNothing);
  });
}
