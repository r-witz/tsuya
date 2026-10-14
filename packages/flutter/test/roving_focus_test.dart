// One tab stop for a group of controls (DESIGN.md, Foundations: States).
// G6: keyboard. G14: right-to-left mirrors the arrow keys.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/roving_focus.dart';

import 'support.dart';

void main() {
  late List<FocusNode> nodes;

  Widget harness({
    int count = 3,
    Axis axis = Axis.horizontal,
    bool wrap = true,
    TextDirection direction = TextDirection.ltr,
    String Function(int)? labelOf,
    bool Function(int)? disabledOf,
    bool disabledFocusable = false,
  }) => host(
    RovingFocus(
      count: count,
      axis: axis,
      wrap: wrap,
      labelOf: labelOf,
      disabledOf: disabledOf,
      disabledFocusable: disabledFocusable,
      builder: (context, built, active) {
        nodes = built;
        return Row(
          children: [for (final node in built) Focus(focusNode: node, child: const SizedBox(width: 20))],
        );
      },
    ),
    direction: direction,
  );

  testWidgets('only the active item is a tab stop', (tester) async {
    await tester.pumpWidget(harness());
    expect(nodes[0].skipTraversal, isFalse);
    expect(nodes[1].skipTraversal, isTrue);
    expect(nodes[2].skipTraversal, isTrue);
  });

  testWidgets('arrow keys move focus, wrapping past either end by default', (tester) async {
    await tester.pumpWidget(harness());
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[1].hasFocus, isTrue);
    expect(nodes[0].skipTraversal, isTrue);
    expect(nodes[1].skipTraversal, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue, reason: 'wraps past the last item');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue, reason: 'wraps past the first item going backward');
  });

  testWidgets('wrap: false stops at either end', (tester) async {
    await tester.pumpWidget(harness(wrap: false));
    nodes[2].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue, reason: 'stays on the last item');
  });

  testWidgets('Home and End jump to the first and last item', (tester) async {
    await tester.pumpWidget(harness());
    nodes[1].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue);
  });

  testWidgets('a vertical group moves with up and down, not left and right', (tester) async {
    await tester.pumpWidget(harness(axis: Axis.vertical));
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue, reason: 'left and right do nothing on a vertical axis');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(nodes[1].hasFocus, isTrue);
  });

  testWidgets('G14: a horizontal group under right-to-left mirrors the arrow keys', (tester) async {
    await tester.pumpWidget(harness(direction: TextDirection.rtl));
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(nodes[1].hasFocus, isTrue, reason: 'left moves forward under right-to-left');
  });

  testWidgets('typing a label jumps to the next item starting with it', (tester) async {
    const labels = ['Apple', 'Banana', 'Cherry'];
    await tester.pumpWidget(harness(labelOf: (i) => labels[i]));
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
  });

  testWidgets('the initial tab stop skips a disabled item at initialIndex', (tester) async {
    await tester.pumpWidget(harness(count: 3, disabledOf: (i) => i == 0));
    expect(nodes[0].skipTraversal, isTrue, reason: 'item 0 is disabled: not the tab stop');
    expect(nodes[1].skipTraversal, isFalse, reason: 'the first reachable item becomes the tab stop instead');
  });

  testWidgets('arrow keys and Home/End skip disabled items, wrapping past them too', (tester) async {
    await tester.pumpWidget(harness(count: 4, disabledOf: (i) => i == 1));
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue, reason: 'item 1 is disabled: item 2 is next');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue, reason: 'back the same way, skipping the disabled item again');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(nodes[3].hasFocus, isTrue, reason: 'wraps past the first item');

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(nodes[3].hasFocus, isTrue);
  });

  testWidgets('disabledFocusable: a disabled item still takes focus, like a disabled menu item', (tester) async {
    await tester.pumpWidget(harness(count: 4, wrap: false, disabledOf: (i) => i == 1, disabledFocusable: true));
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[1].hasFocus, isTrue, reason: 'disabledFocusable lets the disabled item take focus');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
  });

  testWidgets('Ctrl+<letter> does not start a type-ahead search', (tester) async {
    const labels = ['Apple', 'Banana', 'Cherry'];
    await tester.pumpWidget(harness(labelOf: (i) => labels[i]));
    nodes[1].requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(nodes[1].hasFocus, isTrue, reason: 'Ctrl+A is not type-ahead, unlike a plain "a"');
  });

  testWidgets('focus moving by other means (a tap) keeps the active index in sync', (tester) async {
    await tester.pumpWidget(harness());
    nodes[2].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[0].hasFocus, isTrue, reason: 'now wraps relative to item 2, not the stale initial index');
  });

  testWidgets('the tab stop follows initialIndex when count changes in the same update', (tester) async {
    late int active;
    Widget build(int count, int initialIndex) => host(
      RovingFocus(
        count: count,
        initialIndex: initialIndex,
        builder: (context, built, a) {
          nodes = built;
          active = a;
          return const SizedBox();
        },
      ),
    );
    await tester.pumpWidget(build(3, 0));
    await tester.pumpWidget(build(4, 3));
    expect(active, 3);
    expect([for (final n in nodes) n.skipTraversal], [true, true, true, false]);
  });

  testWidgets('a focused item keeps its focus when the group grows or shrinks', (tester) async {
    Widget build(int count) => host(
      RovingFocus(
        count: count,
        builder: (context, built, active) {
          nodes = built;
          return Row(
            children: [
              for (var i = 0; i < count; i++) Focus(focusNode: built[i], child: const SizedBox(width: 20, height: 20)),
            ],
          );
        },
      ),
    );
    await tester.pumpWidget(build(3));
    nodes[1].requestFocus();
    await tester.pump();
    final focused = nodes[1];
    await tester.pumpWidget(build(4));
    await tester.pump();
    expect(identical(nodes[1], focused), isTrue, reason: 'the existing nodes are kept');
    expect(focused.hasPrimaryFocus, isTrue, reason: 'growing');
    await tester.pumpWidget(build(2));
    await tester.pump();
    expect(focused.hasPrimaryFocus, isTrue, reason: 'shrinking past other items');
    expect(nodes, hasLength(2));
  });
}
