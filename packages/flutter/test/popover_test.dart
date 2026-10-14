// Popover (DESIGN.md, Popover).
// G5: semantics. G6: keyboard focus in, Escape, focus return, outside press. G13: geometry.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/dismissable_layer.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

final _panel = find.byWidgetPredicate(
  (w) => w is DecoratedBox && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).boxShadow != null,
);

Widget _popover({FocusNode? focusNode, TextDirection direction = TextDirection.ltr}) => host(
  Align(
    alignment: const Alignment(-0.5, -0.5),
    child: Popover(
      label: 'Filters',
      focusNode: focusNode,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status'),
          Button(label: 'Apply', onPressed: () {}),
        ],
      ),
    ),
  ),
  size: const Size(800, 600),
  direction: direction,
);

void main() {
  testWidgets('opens under its button at the start edge, padded space-16, on the surface', (tester) async {
    await tester.pumpWidget(_popover());
    await tester.tap(find.byType(Popover));
    await tester.pump();
    await tester.pump();

    final button = tester.getRect(find.byType(Popover));
    final panel = tester.getRect(_panel);
    expect(panel.top, moreOrLessEquals(button.bottom + TsuyaSpace.s4));
    expect(panel.left, moreOrLessEquals(button.left));
    final decoration = tester.widget<DecoratedBox>(_panel).decoration as BoxDecoration;
    expect(decoration.color, TsuyaColors.light.surface);
    expect(tester.getRect(find.text('Status')).left, moreOrLessEquals(panel.left + TsuyaSpace.s16));
  });

  testWidgets('aligns to the button right edge in RTL', (tester) async {
    await tester.pumpWidget(_popover(direction: TextDirection.rtl));
    await tester.tap(find.byType(Popover));
    await tester.pump();
    await tester.pump();

    expect(tester.getRect(_panel).right, moreOrLessEquals(tester.getRect(find.byType(Popover)).right));
  });

  testWidgets('a keyboard opening moves focus to the first control; a pointer one leaves it on the button', (
    tester,
  ) async {
    final buttonFocus = FocusNode();
    addTearDown(buttonFocus.dispose);
    await tester.pumpWidget(_popover(focusNode: buttonFocus));
    buttonFocus.requestFocus();
    await tester.pump();

    await tester.tap(find.byType(Popover));
    await tester.pump();
    await tester.pump();
    expect(buttonFocus.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump();
    final focus = tester.binding.focusManager.primaryFocus;
    expect(buttonFocus.hasFocus, isFalse);
    expect(focus, isNotNull);
    final apply = tester.getRect(find.text('Apply'));
    expect(focus!.rect.contains(apply.center), isTrue);
  });

  testWidgets('Escape closes it and focus returns to the button', (tester) async {
    final buttonFocus = FocusNode();
    addTearDown(buttonFocus.dispose);
    await tester.pumpWidget(_popover(focusNode: buttonFocus));
    buttonFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsNothing);
    expect(buttonFocus.hasFocus, isTrue);
  });

  testWidgets('an outside press closes it, and pressing the button again toggles it shut', (tester) async {
    await tester.pumpWidget(_popover());
    await tester.tap(find.byType(Popover));
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);

    await tester.tapAt(const Offset(700, 500));
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsNothing);

    await tester.tap(find.byType(Popover));
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);
    await tester.tap(find.byType(Popover));
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsNothing);
  });

  testWidgets('focus leaving it closes it', (tester) async {
    final other = FocusNode();
    addTearDown(other.dispose);
    await tester.pumpWidget(
      host(
        Column(
          children: [
            Focus(focusNode: other, child: const SizedBox(width: 10, height: 10)),
            Popover(
              label: 'Filters',
              autofocus: true,
              builder: (_) => Button(label: 'Apply', onPressed: () {}),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);
    other.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsNothing);
  });

  testWidgets('G5: the button is expanded while open, the panel is a dialog named by its opener', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_popover());
    await tester.tap(find.byType(Popover));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byType(Pressable).first),
      isSemantics(label: 'Filters', hasExpandedState: true, isExpanded: true),
    );
    SemanticsNode? node = tester.getSemantics(find.text('Status'));
    while (node != null && node.role != SemanticsRole.dialog) {
      node = node.parent;
    }
    expect(node, isNotNull);
    expect(node!.label, 'Filters');
    handle.dispose();
  });

  testWidgets('once closed, Escape on its button goes on to the dialog around it', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Button(
            label: 'Open',
            onPressed: () => unawaited(
              Dialog.show<void>(
                context,
                builder: (_) => Dialog(
                  title: 'Settings',
                  content: Popover(label: 'More', builder: (_) => const Text('Inside')),
                  actions: const [],
                ),
              ),
            ),
          ),
        ),
        size: const Size(800, 600),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Inside'), findsNothing);
    expect(find.text('Settings'), findsOneWidget, reason: 'the first Escape closes the popover only');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNothing);
  });

  // G6, G13: a popover opened with a click keeps focus on its opener; when focus then leaves the opener, and not into
  // the panel, the popover closes, as the web's closes on focus outside.
  testWidgets('G6: after a mouse click on a popover, Shift+Tab on its opener closes it and goes before', (
    tester,
  ) async {
    viewAt(tester, const Size(900, 700));
    final before = FocusNode(debugLabel: 'before');
    final opener = FocusNode(debugLabel: 'opener');
    addTearDown(before.dispose);
    addTearDown(opener.dispose);
    await tester.pumpWidget(
      TsuyaApp(
        labels: TsuyaLabels.en,
        home: Align(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(label: 'Before', onPressed: () {}, focusNode: before),
              Popover(
                label: 'Filters',
                focusNode: opener,
                builder: (c) => Button(label: 'One', onPressed: () {}),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Popover), kind: PointerDeviceKind.mouse);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(opener.hasPrimaryFocus, isTrue);
    expect(find.byType(DismissableLayer), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(before.hasPrimaryFocus, isTrue);
    expect(find.byType(DismissableLayer), findsNothing);
  });
}
