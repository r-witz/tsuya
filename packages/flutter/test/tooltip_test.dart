// Tooltip (DESIGN.md, Tooltip).
// G5: semantics. G6: keyboard, Escape. G9: forced colours (high contrast) edge. G13: spec values, both modes.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

final _boxKey = GlobalKey();

Widget _box({FocusNode? focusNode}) {
  final child = SizedBox(key: _boxKey, width: 100, height: 40);
  return focusNode == null ? child : Focus(focusNode: focusNode, child: child);
}

Finder get _bubble => find.ancestor(of: find.text('Copy the link'), matching: find.byType(DecoratedBox));

Widget _tip({AnchorSide side = AnchorSide.top, bool enabled = true, TextDirection direction = TextDirection.ltr}) =>
    host(
      Center(
        child: Tooltip(
          message: 'Copy the link',
          side: side,
          enabled: enabled,
          child: SizedBox(key: _boxKey, width: 100, height: 40),
        ),
      ),
      direction: direction,
      size: const Size(800, 600),
    );

Future<TestGesture> _mouse(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: Offset.zero);
  return mouse;
}

Future<void> _hover(WidgetTester tester, TestGesture mouse) async {
  await mouse.moveTo(Offset.zero);
  await mouse.moveTo(tester.getCenter(find.byKey(_boxKey)));
  await tester.pump(TsuyaDuration.tooltipDelay);
  await tester.pump();
}

const _message = 'Copy the link to this photo album so that you can paste it into a message and share it with anyone';

Future<Rect> _shown(WidgetTester tester, Alignment at, {double scale = 1, AnchorSide side = AnchorSide.bottom}) async {
  viewAt(tester, const Size(320, 568));
  await tester.pumpWidget(
    host(
      Align(
        alignment: at,
        child: Tooltip(
          message: _message,
          side: side,
          child: const SizedBox(key: Key('t'), width: 44, height: 44),
        ),
      ),
      size: const Size(320, 568),
      textScale: scale,
    ),
  );
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: Offset.zero);
  await tester.pump();
  await mouse.moveTo(tester.getCenter(find.byKey(const Key('t'))));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump();
  expect(tester.takeException(), isNull);
  return tester.getRect(find.ancestor(of: find.text(_message), matching: find.byType(DecoratedBox)).first);
}

void main() {
  testWidgets('on a mouse it shows after the delay, above the trigger, centred, inverted, sized as DESIGN.md says', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Center(
          child: Tooltip(message: 'Copy the link', child: _box()),
        ),
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byKey(_boxKey)));
    await tester.pump(const Duration(milliseconds: 499));
    expect(find.text('Copy the link'), findsNothing, reason: 'not yet the delay');

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.text('Copy the link'), findsOneWidget);

    final box = tester.getRect(find.byKey(_boxKey));
    final bubble = tester.getRect(_bubble);
    expect(bubble.bottom, moreOrLessEquals(box.top - TsuyaSpace.s4));
    expect(bubble.center.dx, moreOrLessEquals(box.center.dx));

    final decoration = tester.widget<DecoratedBox>(_bubble).decoration as BoxDecoration;
    expect(decoration.color, TsuyaColors.light.text);
    expect((decoration.borderRadius! as BorderRadius).topLeft, const Radius.circular(TsuyaRadius.xs));
    expect(decoration.border, isNull, reason: 'no forced-colours edge by default');

    final padding = tester.widget<Padding>(
      find.ancestor(of: find.text('Copy the link'), matching: find.byType(Padding)).first,
    );
    expect(padding.padding, const EdgeInsets.symmetric(horizontal: TsuyaSpace.s8, vertical: TsuyaSpace.s4));

    final constraints = tester.widget<ConstrainedBox>(
      find.ancestor(of: find.text('Copy the link'), matching: find.byType(ConstrainedBox)).first,
    );
    expect(constraints.constraints.maxWidth, 240);

    final style = tester.widget<Text>(find.text('Copy the link')).style!;
    expect(style.fontSize, 12);
    expect(style.color, TsuyaColors.light.bg);
  });

  testWidgets('G13: inverted the other way round in dark mode', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: Tooltip(message: 'Copy the link', child: _box()),
        ),
        mode: TsuyaMode.dark,
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.byKey(_boxKey)));
    await tester.pump(TsuyaDuration.tooltipDelay);
    await tester.pump();
    final decoration = tester.widget<DecoratedBox>(_bubble).decoration as BoxDecoration;
    expect(decoration.color, TsuyaColors.dark.text);
    expect(tester.widget<Text>(find.text('Copy the link')).style!.color, TsuyaColors.dark.bg);
  });

  testWidgets('a high-contrast setting draws an edge around it', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: Tooltip(message: 'Copy the link', child: _box()),
        ),
        highContrast: true,
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.byKey(_boxKey)));
    await tester.pump(TsuyaDuration.tooltipDelay);
    await tester.pump();
    final decoration = tester.widget<DecoratedBox>(_bubble).decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
  });

  testWidgets('it stays while the pointer is over it, and hides on the grace after leaving both', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: Tooltip(message: 'Copy the link', child: _box()),
        ),
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byKey(_boxKey)));
    await tester.pump(TsuyaDuration.tooltipDelay);
    await tester.pump();
    expect(find.text('Copy the link'), findsOneWidget);

    await gesture.moveTo(tester.getCenter(_bubble));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Copy the link'), findsOneWidget, reason: 'the grace does not fire while over the bubble');

    await gesture.moveTo(const Offset(5, 5));
    await tester.pump();
    await tester.pump(TsuyaDuration.fast);
    await tester.pumpAndSettle();
    expect(find.text('Copy the link'), findsNothing);
  });

  testWidgets('never on touch', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: Tooltip(message: 'Copy the link', child: _box()),
        ),
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.touch);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: tester.getCenter(find.byKey(_boxKey)));
    await tester.pump();
    await tester.pump(TsuyaDuration.tooltipDelay * 2);
    expect(find.text('Copy the link'), findsNothing);
  });

  testWidgets('G6: keyboard focus shows it at once; blur and Escape hide it', (tester) async {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
    final focus = FocusNode();
    addTearDown(focus.dispose);
    final elsewhere = FocusNode();
    addTearDown(elsewhere.dispose);
    await tester.pumpWidget(
      host(
        Column(
          children: [
            Tooltip(
              message: 'Copy the link',
              child: _box(focusNode: focus),
            ),
            Focus(focusNode: elsewhere, child: const SizedBox(width: 20, height: 20)),
          ],
        ),
      ),
    );

    focus.requestFocus();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Copy the link'), findsOneWidget, reason: 'no delay on keyboard focus');

    elsewhere.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Copy the link'), findsNothing, reason: 'blur hides it');

    focus.requestFocus();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Copy the link'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Copy the link'), findsNothing);
  });

  testWidgets('a press on the trigger hides it at once', (tester) async {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      host(
        Center(
          child: Tooltip(
            message: 'Copy the link',
            child: _box(focusNode: focus),
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Copy the link'), findsOneWidget);

    await tester.tap(find.byKey(_boxKey), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Copy the link'), findsNothing);
  });

  testWidgets('G5: the message reaches the trigger as its tooltip semantics; describe: false adds none', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Center(
          child: Tooltip(message: 'Share this page', child: _box()),
        ),
      ),
    );
    expect(tester.getSemantics(find.byKey(_boxKey)).tooltip, 'Share this page');

    await tester.pumpWidget(
      host(
        Center(
          child: Tooltip(message: 'Share this page', describe: false, child: _box()),
        ),
      ),
    );
    expect(tester.getSemantics(find.byKey(_boxKey)).tooltip, '');
    semantics.dispose();
  });

  // Tooltip's sides, its enabled switch and its place in the tab order (DESIGN.md, Tooltip).
  // G6: keyboard. G13: geometry. G14: right-to-left.
  testWidgets('G13: end is on the right and start on the left, 4 off, centred; the other way in right-to-left', (
    tester,
  ) async {
    final mouse = await _mouse(tester);
    for (final (side, direction, right) in [
      (AnchorSide.end, TextDirection.ltr, true),
      (AnchorSide.start, TextDirection.ltr, false),
      (AnchorSide.end, TextDirection.rtl, false),
      (AnchorSide.start, TextDirection.rtl, true),
    ]) {
      await tester.pumpWidget(_tip(side: side, direction: direction));
      await _hover(tester, mouse);
      final box = tester.getRect(find.byKey(_boxKey));
      final bubble = tester.getRect(_bubble);
      final reason = '$side $direction';
      if (right) {
        expect(bubble.left, moreOrLessEquals(box.right + TsuyaSpace.s4), reason: reason);
      } else {
        expect(bubble.right, moreOrLessEquals(box.left - TsuyaSpace.s4), reason: reason);
      }
      expect(bubble.center.dy, moreOrLessEquals(box.center.dy), reason: reason);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('not enabled, it never shows, and goes if it was showing', (tester) async {
    final mouse = await _mouse(tester);
    await tester.pumpWidget(_tip(enabled: false));
    await _hover(tester, mouse);
    expect(find.text('Copy the link'), findsNothing);
    await tester.pumpWidget(_tip());
    await _hover(tester, mouse);
    expect(find.text('Copy the link'), findsOneWidget);
    await tester.pumpWidget(_tip(enabled: false));
    await tester.pumpAndSettle();
    expect(find.text('Copy the link'), findsNothing);
  });

  testWidgets('G6: Tab moves on from a control with a tooltip to the next one', (tester) async {
    await tester.pumpWidget(
      host(
        Column(
          children: [
            IconButton(icon: const SizedBox(), label: 'First', onPressed: () {}),
            IconButton(icon: const SizedBox(), label: 'Second', onPressed: () {}),
          ],
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    final nodes = [
      for (final button in find.byType(IconButton).evaluate())
        Focus.of(
          find.descendant(of: find.byWidget(button.widget), matching: find.byType(DecoratedBox)).evaluate().first,
        ),
    ];
    nodes.first.requestFocus();
    await tester.pump();
    nodes.first.nextFocus();
    await tester.pump();
    expect(nodes.last.hasPrimaryFocus, isTrue);
  });

  // G7, G8 (anchored position): a long tooltip near the edge of the view shifts to space-16 inside
  // it instead of hanging off, as the web's does, and its width is capped at the view minus 2 × space-16.
  testWidgets('G8: a long tooltip on a trigger at the start edge shifts to space-16 inside', (tester) async {
    final r = await _shown(tester, Alignment.topLeft);
    expect(r.left, TsuyaSpace.s16);
    expect(r.right, lessThanOrEqualTo(320 - TsuyaSpace.s16));
  });

  testWidgets('G8: a long tooltip on a trigger at the end edge shifts to space-16 inside', (tester) async {
    final r = await _shown(tester, Alignment.topRight);
    expect(r.right, 320 - TsuyaSpace.s16);
    expect(r.left, greaterThanOrEqualTo(TsuyaSpace.s16));
  });

  testWidgets('G7: at text scale 3 it is still at most the view minus 2 × space-16 wide', (tester) async {
    final r = await _shown(tester, Alignment.topCenter, scale: 3);
    expect(r.left, greaterThanOrEqualTo(TsuyaSpace.s16));
    expect(r.right, lessThanOrEqualTo(320 - TsuyaSpace.s16));
  });

  for (final side in [AnchorSide.top, AnchorSide.bottom]) {
    testWidgets('G7: at text scale 2 on a centred trigger, a long tooltip ($side) stays in the view, off the trigger', (
      tester,
    ) async {
      final r = await _shown(tester, Alignment.center, scale: 2, side: side);
      final trigger = tester.getRect(find.byKey(const Key('t')));
      expect(r.top, greaterThanOrEqualTo(TsuyaSpace.s16));
      expect(r.bottom, lessThanOrEqualTo(568 - TsuyaSpace.s16));
      expect(r.overlaps(trigger), isFalse);
    });
  }

  for (final side in [AnchorSide.start, AnchorSide.end]) {
    testWidgets('G8: a long tooltip on the $side of a centred trigger stays inside the view, off the trigger', (
      tester,
    ) async {
      final r = await _shown(tester, Alignment.center, side: side);
      final trigger = tester.getRect(find.byKey(const Key('t')));
      expect(r.left, greaterThanOrEqualTo(TsuyaSpace.s16));
      expect(r.right, lessThanOrEqualTo(320 - TsuyaSpace.s16));
      expect(r.overlaps(trigger), isFalse);
    });
  }

  testWidgets('a short tooltip stays centred on its trigger', (tester) async {
    viewAt(tester, const Size(320, 568));
    await tester.pumpWidget(
      host(
        const Center(
          child: Tooltip(
            message: 'Copy',
            child: SizedBox(key: Key('t'), width: 44, height: 44),
          ),
        ),
        size: const Size(320, 568),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await tester.pump();
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('t'))));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    final r = tester.getRect(find.ancestor(of: find.text('Copy'), matching: find.byType(DecoratedBox)).first);
    expect(r.center.dx, closeTo(160, 0.01));
  });

  testWidgets('the bubble follows its trigger when the page scrolls under a pointer that stays', (tester) async {
    viewAt(tester, const Size(320, 568));
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        SingleChildScrollView(
          controller: controller,
          child: const Column(
            children: [
              SizedBox(height: 200),
              Tooltip(
                message: 'Copy',
                child: SizedBox(key: Key('t'), width: 44, height: 44),
              ),
              SizedBox(height: 1000),
            ],
          ),
        ),
        size: const Size(320, 568),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await tester.pump();
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('t'))));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    final bubble = find.ancestor(of: find.text('Copy'), matching: find.byType(DecoratedBox)).first;
    final before = tester.getRect(bubble).top;
    controller.jumpTo(50);
    await tester.pump();
    await tester.pump();
    expect(tester.getRect(bubble).top, closeTo(before - 50, 0.01));
  });

  // Tooltip and the dialog around it (DESIGN.md, Tooltip): Escape on the focused trigger stops at
  // the tooltip, one the pointer shows lets it through.
  testWidgets('Escape on the focused trigger hides the tooltip only; the next one closes the dialog around it', (
    tester,
  ) async {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Button(
            label: 'Open',
            onPressed: () => unawaited(
              Dialog.show<void>(
                context,
                builder: (dialog) => Dialog(
                  title: 'Title',
                  actions: [
                    Tooltip(
                      message: 'Copy the link',
                      describe: false,
                      child: Button(label: 'Ok', onPressed: () => Dialog.close<void>(dialog)),
                    ),
                  ],
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
    expect(find.text('Copy the link'), findsOneWidget, reason: 'the focused action shows its tooltip');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Copy the link'), findsNothing);
    expect(find.text('Title'), findsOneWidget, reason: 'the first Escape stops at the tooltip');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Title'), findsNothing);
  });

  testWidgets('Escape hides a tooltip the pointer shows and goes on to the dialog around it', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Button(
            label: 'Open',
            onPressed: () => unawaited(
              Dialog.show<void>(
                context,
                builder: (dialog) => Dialog(
                  title: 'Title',
                  actions: [
                    Button(label: 'Cancel', onPressed: () => Dialog.close<void>(dialog)),
                    Tooltip(
                      message: 'Copy the link',
                      describe: false,
                      child: Button(label: 'Ok', onPressed: () => Dialog.close<void>(dialog)),
                    ),
                  ],
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
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.text('Ok')));
    await tester.pump(TsuyaDuration.tooltipDelay);
    await tester.pump();
    expect(find.text('Copy the link'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Copy the link'), findsNothing);
    expect(find.text('Title'), findsNothing);
  });
}
