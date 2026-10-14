// CommandPalette (DESIGN.md, CommandPalette).
// G5: semantics, modal. G6: keyboard, focus. G7: text scale. G10: keyboard inset. G13: geometry. G14: RTL.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

final _chosen = <String>[];

Widget _app({
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  EdgeInsets viewInsets = EdgeInsets.zero,
  String? barrierLabel,
}) => host(
  Align(
    alignment: Alignment.bottomLeft,
    child: Builder(
      builder: (context) => Button(
        label: 'Open',
        autofocus: true,
        onPressed: () => unawaited(
          CommandPalette.show<String>(
            context,
            barrierLabel: barrierLabel,
            onSelected: _chosen.add,
            groups: const [
              CommandGroup(
                label: 'Recent',
                commands: [Command(value: 'open', label: 'Open file')],
              ),
              CommandGroup(
                label: 'Actions',
                commands: [
                  Command(value: 'rename', label: 'Rename'),
                  Command(value: 'archive', label: 'Archive', disabled: true),
                  Command(value: 'delete', label: 'Delete'),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
  size: const Size(800, 600),
  direction: direction,
  textScale: textScale,
  viewInsets: viewInsets,
);

Future<void> _open(WidgetTester tester) async {
  _chosen.clear();
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(EditableText), text);
  await tester.pump();
}

Finder get _panel => find.byWidgetPredicate(
  (w) => w is DecoratedBox && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).boxShadow != null,
);

bool _active(WidgetTester tester, String label) =>
    tester
        .widget<Semantics>(find.ancestor(of: find.text(label), matching: find.byType(Semantics)).first)
        .properties
        .focused ??
    false;

final _target = FocusNode(debugLabel: 'target');
bool? _paletteShownWhenRun;

Widget _appWithTarget({required void Function(String) onSelected, bool animate = false}) => host(
  Align(
    alignment: Alignment.bottomLeft,
    child: Builder(
      builder: (context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Button(
            label: 'Open',
            autofocus: true,
            onPressed: () => unawaited(
              CommandPalette.show<String>(
                context,
                onSelected: (value) {
                  _paletteShownWhenRun = find.byType(EditableText).evaluate().isNotEmpty;
                  onSelected(value);
                },
                groups: const [
                  CommandGroup(
                    label: 'Actions',
                    commands: [
                      Command(value: 'open', label: 'Open file'),
                      Command(value: 'archive', label: 'Archive', disabled: true),
                      Command(value: 'focus', label: 'Focus the note'),
                    ],
                  ),
                  CommandGroup(
                    label: 'Settings',
                    commands: [Command(value: 'theme', label: 'Change theme')],
                  ),
                ],
              ),
            ),
          ),
          Focus(focusNode: _target, child: const SizedBox(width: 50, height: 20)),
        ],
      ),
    ),
  ),
  size: const Size(800, 600),
  animate: animate,
);

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
}

void main() {
  testWidgets('a dialog at most 560 wide near the top, groups in order, the search field focused', (tester) async {
    await tester.pumpWidget(_app());
    await _open(tester);

    final panel = tester.getRect(_panel);
    expect(panel.width, 560);
    expect(panel.center.dx, moreOrLessEquals(400));
    expect(panel.top, TsuyaSpace.s64);
    final decoration = tester.widget<DecoratedBox>(_panel).decoration as BoxDecoration;
    expect(decoration.color, TsuyaColors.light.surface);
    expect(decoration.borderRadius, BorderRadius.circular(TsuyaRadius.lg));
    expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);

    final order = ['Recent', 'Open file', 'Actions', 'Rename', 'Archive', 'Delete'];
    final tops = [for (final text in order) tester.getRect(find.text(text)).top];
    expect([...tops]..sort(), tops);
  });

  testWidgets('typing filters, hides emptied groups and activates the first match', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app());
    await _open(tester);
    expect(_active(tester, 'Open file'), isTrue);

    await _type(tester, 'ren');
    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);
    expect(find.text('Recent'), findsNothing, reason: 'its group has no match left');
    expect(find.text('Actions'), findsOneWidget);
    expect(_active(tester, 'Rename'), isTrue);

    await _type(tester, ' ren ');
    expect(find.text('Rename'), findsOneWidget, reason: 'spaces around the query do not count, as on the web');

    await _type(tester, 'zzz');
    expect(find.text(TsuyaLabels.en.noResults), findsOneWidget);
    handle.dispose();
  });

  testWidgets('arrows move past a disabled command; Enter runs it once the palette has closed', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app());
    await _open(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_active(tester, 'Rename'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_active(tester, 'Delete'), isTrue, reason: 'Archive is disabled');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_active(tester, 'Delete'), isTrue, reason: 'it stops at the last');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_chosen, ['delete']);
    expect(find.byType(EditableText), findsNothing);
    handle.dispose();
  });

  testWidgets('a press runs a command, a disabled one does nothing; hover makes a row active', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app());
    await _open(tester);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Delete')));
    await tester.pump();
    expect(_active(tester, 'Delete'), isTrue);

    await tester.tap(find.text('Archive'));
    await tester.pump();
    expect(_chosen, isEmpty);
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    expect(_chosen, ['rename']);
    handle.dispose();
  });

  testWidgets('Escape and the scrim close it without running anything; focus returns to the opener', (tester) async {
    await tester.pumpWidget(_app(barrierLabel: 'Close palette'));
    await tester.pump();
    final opener = FocusManager.instance.primaryFocus;
    await _open(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsNothing);
    expect(FocusManager.instance.primaryFocus, opener);

    await _open(tester);
    await tester.tapAt(const Offset(700, 500));
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsNothing);
    expect(_chosen, isEmpty);
  });

  testWidgets('G5: a dialog named by its search, hiding the page; a list of list items', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(barrierLabel: 'Close palette'));
    await _open(tester);

    var node = tester.getSemantics(find.text('Rename'));
    expect(node.role, SemanticsRole.listItem);
    while (node.role != SemanticsRole.dialog) {
      node = node.parent!;
    }
    expect(node.label, TsuyaLabels.en.search);
    final reachable = tester.semantics.simulatedAccessibilityTraversal().map((n) => n.label);
    expect(reachable, isNot(contains('Open')));
    expect(reachable, contains('Close palette'));
    handle.dispose();
  });

  testWidgets('G14: in right-to-left a command\'s label is at the start side', (tester) async {
    await tester.pumpWidget(_app(direction: TextDirection.rtl));
    await _open(tester);
    final panel = tester.getRect(_panel);
    // the row starts at the right: its padding is on that side, the label running leftwards from it
    expect(
      tester.getRect(find.text('Open file')).right,
      moreOrLessEquals(panel.right - TsuyaSpace.s8 - TsuyaSpace.s12),
    );
  });

  testWidgets('G10: it stays clear of the keyboard; G7: at 300 % it scrolls rather than overflowing', (tester) async {
    await tester.pumpWidget(_app(viewInsets: const EdgeInsets.only(bottom: 400), textScale: 3));
    await _open(tester);
    expect(tester.takeException(), isNull);
    expect(tester.getRect(_panel).bottom, lessThanOrEqualTo(600 - 400));
  });

  // CommandPalette's arrows and its running order (DESIGN.md, CommandPalette;
  // tests/svelte/command-palette.test.ts). G6: keyboard, focus.
  group('arrows and running order', () {
    setUp(() => _paletteShownWhenRun = null);

    testWidgets('G6: the arrows stop at the ends, past a disabled command, without wrapping', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_appWithTarget(onSelected: (_) {}));
      await _open(tester);

      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(_active(tester, 'Open file'), isTrue, reason: 'the first stays active going up');
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_active(tester, 'Focus the note'), isTrue, reason: 'Archive is disabled');
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_active(tester, 'Change theme'), isTrue);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_active(tester, 'Change theme'), isTrue, reason: 'the last stays active going down');
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(_active(tester, 'Focus the note'), isTrue);
      handle.dispose();
    });

    for (final animate in [false, true]) {
      testWidgets(
        'running closes the palette, then calls onSelected, so a command can move the focus (animated: $animate)',
        (tester) async {
          final chosen = <String>[];
          await tester.pumpWidget(
            _appWithTarget(
              animate: animate,
              onSelected: (value) {
                chosen.add(value);
                _target.requestFocus();
              },
            ),
          );
          await _open(tester);
          await tester.enterText(find.byType(EditableText), 'note');
          await tester.pump();
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          expect(chosen, ['focus']);
          expect(_paletteShownWhenRun, isFalse, reason: 'the palette had gone when the command ran');
          expect(find.byType(EditableText), findsNothing);
          expect(_target.hasPrimaryFocus, isTrue, reason: 'the focus the command set was not taken back by the opener');
        },
      );
    }

    testWidgets('without moving the focus, a command leaves it on the opener', (tester) async {
      await tester.pumpWidget(_appWithTarget(onSelected: (_) {}));
      final opener = FocusManager.instance.primaryFocus;
      await _open(tester);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, opener);
    });
  });
}
