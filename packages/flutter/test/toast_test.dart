// Toast (DESIGN.md, Toast).
// G5: semantics, live region. G6: Escape, F6. G7: text scale. G8: above dialogs. G9: dwell under reduced motion.
// G13: geometry. G14: right-to-left.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/dock_inset.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

int _actions = 0;
IconThemeData? _seen;

Widget _app({
  String message = 'Saved',
  bool icon = false,
  bool action = false,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  bool animate = false,
  bool autofocus = false,
  double dock = 0,
  Widget? extra,
}) => host(
  DockInset(
    height: dock,
    child: Column(
      children: [
        Builder(
          builder: (context) => Button(
            label: 'Show',
            autofocus: autofocus,
            onPressed: () => unawaited(
              Toast.show(
                context,
                message: message,
                icon: icon
                    ? Builder(
                        builder: (context) {
                          _seen = IconTheme.of(context);
                          return SizedBox.square(dimension: IconTheme.of(context).size);
                        },
                      )
                    : null,
                actionLabel: action ? 'Undo' : null,
                onAction: action ? () => _actions++ : null,
              ),
            ),
          ),
        ),
        ?extra,
      ],
    ),
  ),
  size: const Size(800, 600),
  direction: direction,
  textScale: textScale,
  animate: animate,
);

Future<void> _show(WidgetTester tester) async {
  _actions = 0;
  await tester.tap(find.text('Show'));
  await tester.pump();
  await tester.pump();
}

// A button opening a dialog; with [toastInside], the dialog has a button that shows a toast with an action.
Widget _dialogButton({bool toastInside = false}) => Builder(
  builder: (context) => Button(
    label: 'Dialog',
    onPressed: () => unawaited(
      Dialog.show<void>(
        context,
        builder: (_) => Dialog(
          title: 'Delete?',
          actions: [
            if (toastInside)
              Button(
                label: 'Toast',
                onPressed: () =>
                    unawaited(Toast.show(context, message: 'Saved', actionLabel: 'Undo', onAction: () => _actions++)),
              ),
          ],
        ),
      ),
    ),
  ),
);

final _iconBox = find.byWidgetPredicate(
  (w) => w is SizedBox && w.width == TsuyaSize.icon && w.height == TsuyaSize.icon,
);

Rect _pill(WidgetTester tester) => tester.getRect(find.byType(Glass));

// A dialog with a button that shows a toast above it.
Widget _dialogWithToast({String? actionLabel = 'Undo'}) => host(
  Builder(
    builder: (context) => Button(
      label: 'Open',
      onPressed: () => unawaited(
        Dialog.show<void>(
          context,
          builder: (dialog) => Dialog(
            title: 'Title',
            actions: [
              Button(
                label: 'Toast',
                onPressed: () =>
                    unawaited(Toast.show(dialog, message: 'Hi', actionLabel: actionLabel, onAction: () {})),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
  size: const Size(800, 600),
);

void main() {
  testWidgets('bottom centre, 16 above the bottom, at least 48 tall, fully round, icon 20 in the accent', (
    tester,
  ) async {
    await tester.pumpWidget(_app(icon: true));
    await _show(tester);

    final pill = _pill(tester);
    expect(pill.center.dx, moreOrLessEquals(400));
    expect(pill.bottom, 600 - TsuyaSpace.s16);
    expect(pill.height, greaterThanOrEqualTo(TsuyaSpace.s48));
    expect(tester.widget<Glass>(find.byType(Glass)).borderRadius, BorderRadius.circular(TsuyaRadius.full));
    expect(_seen!.size, TsuyaSize.icon);
    expect(_seen!.color, TsuyaColors.light.accent);
    expect(tester.getRect(_iconBox).left, moreOrLessEquals(pill.left + 14));
    expect(pill.right - tester.getRect(find.text('Saved')).right, moreOrLessEquals(TsuyaSpace.s20));
    final style = tester.widget<Text>(find.text('Saved')).style!;
    expect(style.color, TsuyaColors.light.text);
    expect(style.fontWeight, FontWeight.w600);
  });

  testWidgets('it clears a dock, and the safe area', (tester) async {
    await tester.pumpWidget(_app(dock: TsuyaSize.dock + TsuyaSpace.s12));
    await _show(tester);
    expect(_pill(tester).bottom, 600 - TsuyaSpace.s16 - TsuyaSize.dock - TsuyaSpace.s12);
  });

  testWidgets('G14: in right-to-left the icon is on the right', (tester) async {
    await tester.pumpWidget(_app(icon: true, direction: TextDirection.rtl));
    await _show(tester);
    final pill = _pill(tester);
    expect(tester.getRect(_iconBox).right, moreOrLessEquals(pill.right - 14));
  });

  testWidgets('without an action it leaves after 4 s, even under reduced motion; hover and focus pause it', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await _show(tester);
    await tester.pump(const Duration(milliseconds: 3900));
    expect(find.text('Saved'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Saved'), findsNothing);

    await _show(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await tester.pump(const Duration(seconds: 2));
    await mouse.moveTo(_pill(tester).center);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Saved'), findsOneWidget, reason: 'paused while hovered');
    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.text('Saved'), findsOneWidget, reason: 'two seconds were left');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved'), findsNothing);

    await _show(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f6);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Saved'), findsOneWidget, reason: 'paused while focused');
  });

  testWidgets('with an action it stays: the action runs and dismisses, the dismiss button only dismisses', (
    tester,
  ) async {
    await tester.pumpWidget(_app(action: true));
    await _show(tester);
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pump();
    await tester.pump();
    expect(_actions, 1);
    expect(find.text('Saved'), findsNothing);

    await _show(tester);
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    await tester.pump();
    expect(_actions, 0);
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('one at a time: a new toast replaces the current one, which completes', (tester) async {
    await tester.pumpWidget(
      _app(
        extra: Builder(
          builder: (context) => Button(
            label: 'Second',
            onPressed: () => unawaited(Toast.show(context, message: 'Deleted')),
          ),
        ),
      ),
    );
    await _show(tester);
    await tester.tap(find.text('Second'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Saved'), findsNothing);
    expect(find.text('Deleted'), findsOneWidget);
  });

  testWidgets('F6 moves focus to it, Escape dismisses it, and focus goes back to where it was', (tester) async {
    await tester.pumpWidget(_app(action: true, autofocus: true));
    await tester.pump();
    final focus = FocusManager.instance;
    final before = focus.primaryFocus;
    await _show(tester);
    expect(focus.primaryFocus, before, reason: 'showing a toast takes no focus');

    await tester.sendKeyEvent(LogicalKeyboardKey.f6);
    await tester.pump();
    expect(focus.primaryFocus!.debugLabel, 'Toast');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump();
    expect(find.text('Saved'), findsNothing);
    expect(focus.primaryFocus, before);
  });

  testWidgets('G8: a toast shown while a dialog is open is above it and takes the press', (tester) async {
    await tester.pumpWidget(_app(extra: _dialogButton(toastInside: true)));
    await tester.tap(find.text('Dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toast'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(_actions, 1);
  });

  testWidgets('G8: a dialog opened while a toast shows stays below it', (tester) async {
    await tester.pumpWidget(_app(action: true, extra: _dialogButton()));
    await _show(tester);
    expect(find.text('Saved'), findsOneWidget);
    await tester.tap(find.text('Dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Delete?'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(_actions, 1);
  });

  testWidgets('G5: the message is a polite status; the action and dismiss buttons are their own nodes', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(action: true));
    await _show(tester);

    final status = tester.getSemantics(find.text('Saved'));
    expect(status.role, SemanticsRole.status);
    expect(status.label, 'Saved');
    expect(find.bySemanticsLabel('Undo'), findsOneWidget);
    expect(find.bySemanticsLabel(TsuyaLabels.en.dismiss), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a swipe down on touch dismisses it; a mouse drag does not', (tester) async {
    await tester.pumpWidget(_app(action: true));
    await _show(tester);
    final center = _pill(tester).center;

    final mouse = await tester.startGesture(center, kind: PointerDeviceKind.mouse);
    await mouse.moveBy(const Offset(0, 80));
    await mouse.up();
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);

    final touch = await tester.startGesture(center, kind: PointerDeviceKind.touch);
    await touch.moveBy(const Offset(0, 40));
    await touch.moveBy(const Offset(0, 40));
    await touch.up();
    await tester.pump();
    await tester.pump();
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('G9: it fades and rises in over base; G7: at 300 % it wraps and does not overflow', (tester) async {
    await tester.pumpWidget(_app(animate: true));
    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(TsuyaDuration.base ~/ 4);
    final opacity = tester.widget<Opacity>(find.ancestor(of: find.byType(Glass), matching: find.byType(Opacity)).first);
    expect(opacity.opacity, inExclusiveRange(0, 1));
    await tester.pump(TsuyaDuration.base);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(TsuyaDuration.base);
    await tester.pumpWidget(_app(textScale: 3, message: 'A rather long message about what just happened'));
    await _show(tester);
    expect(tester.takeException(), isNull);
    expect(_pill(tester).width, lessThanOrEqualTo(800 - 2 * TsuyaSpace.s16));
  });

  // A toast among the other layers (DESIGN.md, Toast): above a dialog or a sheet without being part of
  // it, Escape for it only when nothing above it takes the key, and clear of the keyboard.
  testWidgets('a press on a toast shown above a dialog does not dismiss the dialog', (tester) async {
    await tester.pumpWidget(_dialogWithToast());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toast'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hi'));
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsNothing);
    expect(find.text('Title'), findsOneWidget);
  });

  testWidgets('a press outside both still dismisses the dialog under a toast', (tester) async {
    await tester.pumpWidget(_dialogWithToast());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toast'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Title'), findsNothing);
    expect(find.text('Hi'), findsOneWidget);
  });

  testWidgets('a toast keeps clear of the keyboard, and follows it as it comes and goes', (tester) async {
    Widget app(double keyboard) => host(
      Builder(
        builder: (context) => Button(
          label: 'Show',
          onPressed: () => unawaited(Toast.show(context, message: 'Hi')),
        ),
      ),
      size: const Size(400, 800),
      viewInsets: EdgeInsets.only(bottom: keyboard),
    );
    await tester.pumpWidget(app(0));
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    final resting = tester.getRect(find.text('Hi')).bottom;
    await tester.pumpWidget(app(300));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Hi')).bottom, lessThanOrEqualTo(800 - 300));
    await tester.pumpWidget(app(0));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Hi')).bottom, resting);
  });

  testWidgets('Escape dismisses a toast that does not have the focus', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Button(
            label: 'Show',
            onPressed: () => unawaited(Toast.show(context, message: 'Hi', actionLabel: 'Undo', onAction: () {})),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsNothing);
  });

  testWidgets('Escape over a dialog dismisses the toast first, the dialog on the next one', (tester) async {
    await tester.pumpWidget(_dialogWithToast());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toast'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Hi'), findsNothing);
    expect(find.text('Title'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Title'), findsNothing);
  });

  testWidgets('a toast shown before a dialog leaves the next Escape to the dialog', (tester) async {
    late BuildContext page;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            page = context;
            return const SizedBox();
          },
        ),
        size: const Size(800, 600),
      ),
    );
    unawaited(Toast.show(page, message: 'Hi', actionLabel: 'Undo', onAction: () {}));
    await tester.pumpAndSettle();
    unawaited(Dialog.show<void>(page, builder: (_) => const Dialog(title: 'Title')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Title'), findsNothing);
    expect(find.text('Hi'), findsOneWidget);
  });

  for (final inPanel in [true, false]) {
    testWidgets(
      'a toast shown after a popover takes Escape first, focus ${inPanel ? 'in the panel' : 'on the button'}',
      (tester) async {
        final key = GlobalKey();
        await tester.pumpWidget(
          host(
            Center(
              key: key,
              child: Popover(
                label: 'Filters',
                builder: (_) => Button(label: 'Inside', onPressed: () {}),
              ),
            ),
            size: const Size(800, 600),
          ),
        );
        if (inPanel) {
          Focus.of(tester.element(find.text('Filters'))).requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        } else {
          await tester.tap(find.text('Filters'));
        }
        await tester.pumpAndSettle();
        expect(find.text('Inside'), findsOneWidget);
        unawaited(Toast.show(key.currentContext!, message: 'Hi', actionLabel: 'Undo', onAction: () {}));
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Hi'), findsNothing, reason: 'the toast, shown last, goes first, as on the web');
        expect(find.text('Inside'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Inside'), findsNothing);
      },
    );
  }
}
