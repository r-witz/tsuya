// Dialog (DESIGN.md, Dialog).
// G5: semantics, modal. G6: focus trap, initial focus, Escape. G7: text scale. G9: motion. G10: keyboard.
// G13: geometry. G14: right-to-left.
import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'dialog_host.dart';
import 'support.dart';

DecoratedBox _box(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.descendant(of: find.byType(Dialog), matching: find.byType(DecoratedBox)).first);

void main() {
  testWidgets('a box 420 wide (lg: 560), centred, radius-lg, padding 24, surface, hairline, shadow, over the scrim', (
    tester,
  ) async {
    await tester.pumpWidget(dialogApp());
    await openDialog(tester);

    final dialog = tester.getRect(find.byType(Dialog));
    expect(dialog.width, 420);
    expect(dialog.center.dx, moreOrLessEquals(400));
    expect(dialog.center.dy, moreOrLessEquals(300));
    final decoration = _box(tester).decoration as BoxDecoration;
    expect(decoration.color, TsuyaColors.light.surface);
    expect(decoration.borderRadius, BorderRadius.circular(TsuyaRadius.lg));
    expect((decoration.border! as Border).top.color, TsuyaColors.light.border);
    expect(decoration.boxShadow, isNotNull);
    expect(tester.getRect(find.text('Delete photo?')).left, moreOrLessEquals(dialog.left + TsuyaSpace.s24));
    expect(tester.getRect(find.text('Delete photo?')).top, moreOrLessEquals(dialog.top + TsuyaSpace.s24));
    final scrim = find.byWidgetPredicate((w) => w is ColoredBox && w.color == TsuyaColors.light.scrim);
    expect(scrim, findsOneWidget);
    expect(tester.getRect(scrim), const Rect.fromLTWH(0, 0, 800, 600));

    await tester.pumpWidget(dialogApp(size: DialogSize.lg));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await openDialog(tester);
    expect(tester.getRect(find.byType(Dialog)).width, 560);
  });

  testWidgets('on a phone it stays 16 from the screen edges', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(dialogApp(viewport: const Size(360, 640)));
    await openDialog(tester);
    final dialog = tester.getRect(find.byType(Dialog));
    expect(dialog.left, TsuyaSpace.s16);
    expect(dialog.right, 360 - TsuyaSpace.s16);
  });

  testWidgets('on a tall phone it is centred both ways, as the web\'s margin: auto', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(dialogApp(viewport: const Size(390, 844)));
    await openDialog(tester);
    final dialog = tester.getRect(find.byType(Dialog));
    expect(dialog.center.dx, moreOrLessEquals(195));
    expect(dialog.center.dy, moreOrLessEquals(422));
  });

  testWidgets('title is title-m, body text-muted; the dark theme uses its own surface', (tester) async {
    await tester.pumpWidget(dialogApp(mode: TsuyaMode.dark));
    await openDialog(tester);
    expect(tester.widget<Text>(find.text('Delete photo?')).style!.color, TsuyaColors.dark.text);
    expect(tester.widget<Text>(find.text('This cannot be undone.')).style!.color, TsuyaColors.dark.textMuted);
    expect((_box(tester).decoration as BoxDecoration).color, TsuyaColors.dark.surface);
  });

  testWidgets('actions sit at the end, the main one last; RTL mirrors them', (tester) async {
    await tester.pumpWidget(dialogApp());
    await openDialog(tester);
    var dialog = tester.getRect(find.byType(Dialog));
    var cancel = tester.getRect(find.byType(Button).at(1));
    var remove = tester.getRect(find.byType(Button).at(2));
    expect(remove.right, moreOrLessEquals(dialog.right - TsuyaSpace.s24));
    expect(cancel.right, lessThan(remove.left));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(dialogApp(direction: TextDirection.rtl));
    await openDialog(tester);
    dialog = tester.getRect(find.byType(Dialog));
    cancel = tester.getRect(find.byType(Button).at(1));
    remove = tester.getRect(find.byType(Button).at(2));
    expect(remove.left, moreOrLessEquals(dialog.left + TsuyaSpace.s24));
    expect(cancel.left, greaterThan(remove.right));
  });

  testWidgets('initial focus is on the first action (Cancel), Tab is trapped, and focus returns to the opener', (
    tester,
  ) async {
    await tester.pumpWidget(dialogApp());
    final opener = FocusManager.instance;
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final cancel = tester.getRect(find.text('Cancel'));
    final remove = tester.getRect(find.text('Delete'));
    bool on(Rect r) => opener.primaryFocus!.rect.contains(r.center);

    expect(on(cancel), isTrue);
    // moving between two controls is the app's own Tab traversal; the trap only wraps at the edges
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(on(remove), isTrue, reason: 'Shift+Tab on the first control wraps to the last');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(on(cancel), isTrue, reason: 'Tab on the last control wraps to the first');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(opener.primaryFocus!.rect.contains(tester.getRect(find.text('Open')).center), isTrue);
  });

  testWidgets('an initialFocus node wins over the first action', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Button(
            label: 'Open',
            onPressed: () => unawaited(
              Dialog.show<void>(
                context,
                builder: (_) => Dialog(
                  title: 'Rename',
                  initialFocus: node,
                  content: Focus(focusNode: node, child: const SizedBox(width: 50, height: 20)),
                  actions: [Button(label: 'Save', onPressed: () {})],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(node.hasPrimaryFocus, isTrue);
  });

  testWidgets('Escape and a press on the scrim dismiss it with null; an action closes it with its result', (
    tester,
  ) async {
    await tester.pumpWidget(dialogApp());
    await openDialog(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(dialogResult, isNull);

    await openDialog(tester);
    await tester.tapAt(const Offset(700, 550));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);

    await openDialog(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(dialogResult, isTrue);
  });

  testWidgets('dismissible: false ignores Escape and the scrim but not an action', (tester) async {
    await tester.pumpWidget(dialogApp(dismissible: false, barrierLabel: 'Close dialog'));
    await openDialog(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.tapAt(const Offset(700, 550));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(dialogResult, isFalse);
  });

  testWidgets('G5: a dialog named by its title, an alert dialog when it interrupts, the page under it blocked', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(dialogApp(barrierLabel: 'Close dialog'));
    expect(find.bySemanticsLabel('Open'), findsOneWidget);
    await openDialog(tester);

    final dialog = tester.getSemantics(find.text('Delete photo?'));
    var node = dialog;
    while (node.role != SemanticsRole.dialog) {
      node = node.parent!;
    }
    expect(node.label, 'Delete photo?');
    final reachable = tester.semantics.simulatedAccessibilityTraversal().map((n) => n.label);
    expect(reachable, isNot(contains('Open')), reason: 'what is under a modal is hidden');
    expect(reachable, contains('Cancel'));
    expect(find.bySemanticsLabel('Close dialog'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(dialogApp(alert: true));
    await openDialog(tester);
    node = tester.getSemantics(find.text('Delete photo?'));
    while (node.role != SemanticsRole.alertDialog) {
      node = node.parent!;
    }
    expect(node.role, SemanticsRole.alertDialog);
    handle.dispose();
  });

  testWidgets('G9: it fades and grows from 0.98 over base; under reduced motion it is there at once', (tester) async {
    await tester.pumpWidget(dialogApp(animate: true));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(TsuyaDuration.base ~/ 4);
    final fade = tester.widget<FadeTransition>(
      find.ancestor(of: find.byType(Dialog), matching: find.byType(FadeTransition)).first,
    );
    expect(fade.opacity.value, inExclusiveRange(0, 1));
    final scale = tester.widget<ScaleTransition>(
      find.ancestor(of: find.byType(Dialog), matching: find.byType(ScaleTransition)),
    );
    expect(scale.scale.value, inExclusiveRange(0.98, 1));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ScaleTransition>(find.ancestor(of: find.byType(Dialog), matching: find.byType(ScaleTransition)))
          .scale
          .value,
      1,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(dialogApp());
    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(
      tester
          .widget<ScaleTransition>(find.ancestor(of: find.byType(Dialog), matching: find.byType(ScaleTransition)))
          .scale
          .value,
      1,
    );
  });

  testWidgets('G10: the dialog stays above the keyboard', (tester) async {
    await tester.pumpWidget(dialogApp(viewInsets: const EdgeInsets.only(bottom: 300)));
    await openDialog(tester);
    expect(tester.getRect(find.byType(Dialog)).bottom, lessThanOrEqualTo(600 - 300 - TsuyaSpace.s16));
  });

  testWidgets('G7: at 300 % text scale the content scrolls rather than overflowing', (tester) async {
    await tester.pumpWidget(
      dialogApp(textScale: 3, body: List.filled(30, 'A long sentence of explanation.').join(' ')),
    );
    await openDialog(tester);
    expect(tester.takeException(), isNull);
    final dialog = tester.getRect(find.byType(Dialog));
    expect(dialog.height, lessThanOrEqualTo(600 - 2 * TsuyaSpace.s16));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
