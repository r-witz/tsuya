// Sheet (DESIGN.md, Sheet).
// G5: semantics, modal. G6: Escape, focus. G7: text scale. G9: motion. G10: keyboard. G13: geometry.
// G14: right-to-left.
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

String? _result;

Widget _app({
  SheetSide side = SheetSide.bottom,
  bool glass = false,
  String? barrierLabel,
  TsuyaMode mode = TsuyaMode.light,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  bool animate = false,
  EdgeInsets viewInsets = EdgeInsets.zero,
  int lines = 2,
}) => host(
  Align(
    alignment: Alignment.topLeft,
    child: Builder(
      builder: (context) => Button(
        label: 'Open',
        onPressed: () => unawaited(
          Sheet.show<String>(
            context,
            side: side,
            barrierLabel: barrierLabel,
            builder: (context) => Sheet(
              label: 'Share',
              glass: glass,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < lines; i++) Text('Line $i'),
                  Button(label: 'Copy link', onPressed: () => Sheet.close(context, 'copied')),
                ],
              ),
            ),
          ).then((value) => _result = value),
        ),
      ),
    ),
  ),
  size: const Size(800, 600),
  mode: mode,
  direction: direction,
  textScale: textScale,
  animate: animate,
  viewInsets: viewInsets,
);

Future<void> _open(WidgetTester tester) async {
  _result = null;
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

DecoratedBox _box(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.descendant(of: find.byType(Sheet), matching: find.byType(DecoratedBox)).first);

void main() {
  testWidgets('bottom: at most tablet wide, flush with the bottom, top corners radius-lg, on the surface', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await _open(tester);

    final sheet = tester.getRect(find.byType(Sheet));
    expect(sheet.width, TsuyaBreakpoint.tablet);
    expect(sheet.center.dx, moreOrLessEquals(400));
    expect(sheet.bottom, 600);
    final decoration = _box(tester).decoration as BoxDecoration;
    expect(decoration.color, TsuyaColors.light.surface);
    expect(decoration.borderRadius, const BorderRadius.vertical(top: Radius.circular(TsuyaRadius.lg)));
    expect(decoration.boxShadow, isNotNull);
    expect((decoration.border! as Border).top.color, TsuyaColors.light.border);
    expect(find.byWidgetPredicate((w) => w is ColoredBox && w.color == TsuyaColors.light.scrim), findsOneWidget);
  });

  testWidgets('handle: 32 × 4 in border-strong, 12 below the top; content padded 24 and 32 above the bottom', (
    tester,
  ) async {
    await tester.pumpWidget(_app(mode: TsuyaMode.dark));
    await _open(tester);

    final sheet = tester.getRect(find.byType(Sheet));
    final handle = find.byWidgetPredicate(
      (w) => w is DecoratedBox && (w.decoration as BoxDecoration).color == TsuyaColors.dark.borderStrong,
    );
    expect(tester.getSize(handle), const Size(TsuyaSpace.s32, TsuyaSpace.s4));
    expect(tester.getRect(handle).top, moreOrLessEquals(sheet.top + TsuyaSpace.s12));
    expect(tester.getRect(handle).center.dx, moreOrLessEquals(sheet.center.dx));
    expect((_box(tester).decoration as BoxDecoration).color, TsuyaColors.dark.surface);
    expect(tester.getRect(find.text('Line 0')).left, moreOrLessEquals(sheet.left + TsuyaSpace.s24));
    expect(sheet.bottom - tester.getRect(find.text('Copy link')).bottom, greaterThanOrEqualTo(TsuyaSpace.s32));
  });

  testWidgets('on a phone it spans the width; it never grows past the viewport minus space-48', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(lines: 80));
    await _open(tester);

    final sheet = tester.getRect(find.byType(Sheet));
    expect(sheet.width, 360);
    expect(sheet.height, lessThanOrEqualTo(640 - TsuyaSpace.s48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('glass: on glass instead of the surface', (tester) async {
    await tester.pumpWidget(_app(glass: true));
    await _open(tester);
    expect(find.descendant(of: find.byType(Sheet), matching: find.byType(Glass)), findsOneWidget);
  });

  testWidgets('side: 400 wide and full height from the end edge; the start edge in right-to-left', (tester) async {
    await tester.pumpWidget(_app(side: SheetSide.end));
    await _open(tester);
    var sheet = tester.getRect(find.byType(Sheet));
    expect(sheet, const Rect.fromLTWH(400, 0, 400, 600));
    expect((_box(tester).decoration as BoxDecoration).borderRadius, BorderRadius.zero);
    expect(tester.getRect(find.text('Line 0')).left, moreOrLessEquals(sheet.left + TsuyaSpace.s24));
    expect(
      find.byWidgetPredicate((w) => w is SizedBox && w.width == TsuyaSpace.s32),
      findsNothing,
      reason: 'no handle',
    );

    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app(side: SheetSide.end, direction: TextDirection.rtl));
    await _open(tester);
    sheet = tester.getRect(find.byType(Sheet));
    expect(sheet, const Rect.fromLTWH(0, 0, 400, 600));
  });

  testWidgets('G9: it slides over the sheet duration; under reduced motion it is in place at once', (tester) async {
    await tester.pumpWidget(_app(animate: true));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(TsuyaDuration.sheet ~/ 4);
    expect(tester.getRect(find.byType(Sheet)).top, greaterThan(300), reason: 'still on its way up');
    await tester.pump(TsuyaDuration.sheet);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(Sheet)).bottom, 600);

    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(tester.getRect(find.byType(Sheet)).bottom, 600);
  });

  testWidgets('Escape, a press on the scrim and an action all close it; focus is trapped and restored', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final focus = FocusManager.instance;
    expect(focus.primaryFocus!.rect.contains(tester.getRect(find.text('Copy link')).center), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focus.primaryFocus!.rect.contains(tester.getRect(find.text('Copy link')).center), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(Sheet), findsNothing);
    expect(focus.primaryFocus!.rect.contains(tester.getRect(find.text('Open')).center), isTrue);

    await _open(tester);
    await tester.tapAt(const Offset(700, 100));
    await tester.pumpAndSettle();
    expect(find.byType(Sheet), findsNothing);
    expect(_result, isNull);

    await _open(tester);
    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(_result, 'copied');
  });

  testWidgets('dragging the handle down on touch: past a third closes, less snaps back, a mouse does nothing', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await _open(tester);
    final handle = Offset(400, tester.getRect(find.byType(Sheet)).top + TsuyaSpace.s12 + 2);
    final height = tester.getSize(find.byType(Sheet)).height;

    final mouse = await tester.startGesture(handle, kind: PointerDeviceKind.mouse);
    await mouse.moveBy(Offset(0, height));
    await mouse.up();
    await tester.pumpAndSettle();
    expect(find.byType(Sheet), findsOneWidget, reason: 'a mouse does not drag');

    final touch = await tester.startGesture(handle, kind: PointerDeviceKind.touch);
    await touch.moveBy(Offset(0, height / 4));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getRect(find.byWidget(_box(tester))).bottom, moreOrLessEquals(600 + height / 4), reason: 'follows');
    await touch.up();
    await tester.pumpAndSettle();
    expect(find.byType(Sheet), findsOneWidget);
    expect(tester.getRect(find.byWidget(_box(tester))).bottom, 600, reason: 'snapped back');

    final far = await tester.startGesture(handle, kind: PointerDeviceKind.touch);
    await far.moveBy(Offset(0, height / 2));
    await tester.pump(const Duration(milliseconds: 300));
    await far.up();
    await tester.pumpAndSettle();
    expect(find.byType(Sheet), findsNothing);
  });

  testWidgets('a quick short flick down closes it', (tester) async {
    await tester.pumpWidget(_app());
    await _open(tester);
    final handle = Offset(400, tester.getRect(find.byType(Sheet)).top + TsuyaSpace.s12 + 2);
    final flick = await tester.startGesture(handle, kind: PointerDeviceKind.touch);
    await flick.moveBy(const Offset(0, 20), timeStamp: const Duration(milliseconds: 30));
    await tester.pump(const Duration(milliseconds: 30));
    await flick.moveBy(const Offset(0, 20), timeStamp: const Duration(milliseconds: 60));
    await tester.pump(const Duration(milliseconds: 30));
    await flick.up();
    await tester.pumpAndSettle();
    expect(find.byType(Sheet), findsNothing);
  });

  testWidgets('G5: a dialog named by its label, hiding the page under it; the handle is not read', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(barrierLabel: 'Close sheet'));
    await _open(tester);

    var node = tester.getSemantics(find.text('Line 0'));
    while (node.role != SemanticsRole.dialog) {
      node = node.parent!;
    }
    expect(node.label, 'Share');
    final reachable = tester.semantics.simulatedAccessibilityTraversal().map((n) => n.label).toList();
    expect(reachable, isNot(contains('Open')));
    expect(reachable, contains('Close sheet'));
    handle.dispose();
  });

  testWidgets('G10: the sheet rises above the keyboard', (tester) async {
    await tester.pumpWidget(_app(viewInsets: const EdgeInsets.only(bottom: 300)));
    await _open(tester);
    expect(tester.getRect(find.byType(Sheet)).bottom, lessThanOrEqualTo(600 - 300));
  });

  testWidgets('G7: at 300 % text scale it does not overflow', (tester) async {
    await tester.pumpWidget(_app(textScale: 3, lines: 20));
    await _open(tester);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(Sheet)).height, lessThanOrEqualTo(600 - TsuyaSpace.s48));
  });
}
