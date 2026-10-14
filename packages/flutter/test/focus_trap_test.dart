// Trapping and restoring focus for a modal region (DESIGN.md, Foundations: Accessibility).
// G6: keyboard.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/focus_trap.dart';

import 'support.dart';

Widget _harness({
  required ValueNotifier<bool> open,
  required FocusNode opener,
  required FocusNode first,
  required FocusNode second,
  FocusNode? initialFocus,
}) => host(
  ValueListenableBuilder<bool>(
    valueListenable: open,
    builder: (context, isOpen, _) => Column(
      children: [
        Focus(focusNode: opener, child: const SizedBox(width: 20, height: 20)),
        if (isOpen)
          FocusTrap(
            initialFocus: initialFocus,
            child: Column(
              children: [
                Focus(focusNode: first, child: const SizedBox(width: 20, height: 20)),
                Focus(focusNode: second, child: const SizedBox(width: 20, height: 20)),
              ],
            ),
          ),
      ],
    ),
  ),
);

void main() {
  testWidgets('without initialFocus, the first focusable descendant is focused on mount', (tester) async {
    final opener = FocusNode(), first = FocusNode(), second = FocusNode();
    final open = ValueNotifier(false);
    addTearDown(() {
      opener.dispose();
      first.dispose();
      second.dispose();
      open.dispose();
    });
    await tester.pumpWidget(_harness(open: open, opener: opener, first: first, second: second));
    open.value = true;
    await tester.pump();
    expect(first.hasFocus, isTrue);
  });

  testWidgets('with initialFocus, that node is focused on mount instead', (tester) async {
    final opener = FocusNode(), first = FocusNode(), second = FocusNode();
    final open = ValueNotifier(false);
    addTearDown(() {
      opener.dispose();
      first.dispose();
      second.dispose();
      open.dispose();
    });
    await tester.pumpWidget(_harness(open: open, opener: opener, first: first, second: second, initialFocus: second));
    open.value = true;
    await tester.pump();
    expect(second.hasFocus, isTrue);
  });

  testWidgets('Tab on the last item cycles to the first, Shift+Tab on the first cycles to the last', (tester) async {
    final opener = FocusNode(), first = FocusNode(), second = FocusNode();
    final open = ValueNotifier(false);
    addTearDown(() {
      opener.dispose();
      first.dispose();
      second.dispose();
      open.dispose();
    });
    await tester.pumpWidget(_harness(open: open, opener: opener, first: first, second: second));
    open.value = true;
    await tester.pump();

    second.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(first.hasFocus, isTrue, reason: 'Tab past the last item cycles to the first');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(second.hasFocus, isTrue, reason: 'Shift+Tab before the first item cycles to the last');
  });

  testWidgets('removing the trap restores focus to its own opener, not whatever is focused by then', (tester) async {
    // Flutter's own focus history already falls back to the previous node when the current one is simply removed,
    // which would make a bare "opener still has focus after" test pass on its own, without FocusTrap's explicit
    // restoration doing anything. Something else (a toast, a live announcement…) taking focus while the trap is
    // open — which FocusTrap does not and should not prevent, it only traps Tab — is realistic, and is enough for
    // that automatic fallback to land on it instead of the opener: only the explicit restoration still gets this
    // right.
    final opener = FocusNode(), decoy = FocusNode(), first = FocusNode(), second = FocusNode();
    final open = ValueNotifier(false);
    addTearDown(() {
      opener.dispose();
      decoy.dispose();
      first.dispose();
      second.dispose();
      open.dispose();
    });
    await tester.pumpWidget(
      host(
        ValueListenableBuilder<bool>(
          valueListenable: open,
          builder: (context, isOpen, _) => Column(
            children: [
              Focus(focusNode: opener, child: const SizedBox(width: 20, height: 20)),
              Focus(focusNode: decoy, child: const SizedBox(width: 20, height: 20)),
              if (isOpen)
                FocusTrap(
                  child: Column(
                    children: [
                      Focus(focusNode: first, child: const SizedBox(width: 20, height: 20)),
                      Focus(focusNode: second, child: const SizedBox(width: 20, height: 20)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    opener.requestFocus();
    await tester.pump();
    expect(opener.hasFocus, isTrue);

    open.value = true;
    await tester.pump();
    expect(first.hasFocus, isTrue);

    decoy.requestFocus();
    await tester.pump();
    expect(decoy.hasFocus, isTrue);

    open.value = false;
    await tester.pump();
    expect(opener.hasFocus, isTrue, reason: "the trap's own opener, not the decoy focused while it was open");
  });
}
