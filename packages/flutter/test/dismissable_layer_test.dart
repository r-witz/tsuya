// Escape, an outside press, or focus leaving dismiss an overlay (DESIGN.md, Foundations: Accessibility).
// G6: keyboard.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/dismissable_layer.dart';

import 'support.dart';

void main() {
  testWidgets('Escape dismisses it', (tester) async {
    var dismissed = 0;
    await tester.pumpWidget(
      host(
        DismissableLayer(
          onDismiss: () => dismissed++,
          child: const Focus(autofocus: true, child: SizedBox(width: 20, height: 20)),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(dismissed, 1);
  });

  testWidgets('a custom shortcut mapped to DismissIntent above it also dismisses it', (tester) async {
    var dismissed = 0;
    await tester.pumpWidget(
      host(
        Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{SingleActivator(LogicalKeyboardKey.keyK): DismissIntent()},
          child: DismissableLayer(
            onDismiss: () => dismissed++,
            child: const Focus(autofocus: true, child: SizedBox(width: 20, height: 20)),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.pump();
    expect(dismissed, 1);
  });

  testWidgets('a pointer press outside its child dismisses it; inside does not', (tester) async {
    var dismissed = 0;
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: DismissableLayer(onDismiss: () => dismissed++, child: const SizedBox(width: 100, height: 100)),
        ),
      ),
    );
    await tester.tapAt(const Offset(50, 50));
    await tester.pump();
    expect(dismissed, 0);
    await tester.tapAt(const Offset(700, 500));
    await tester.pump();
    expect(dismissed, 1);
  });

  Widget focusLeavingHarness(FocusNode inside, FocusNode outside, VoidCallback onDismiss, {required bool modal}) =>
      host(
        Column(
          children: [
            Focus(focusNode: outside, child: const SizedBox(width: 20, height: 20)),
            DismissableLayer(
              onDismiss: onDismiss,
              modal: modal,
              child: Focus(focusNode: inside, child: const SizedBox(width: 20, height: 20)),
            ),
          ],
        ),
      );

  testWidgets('non-modal: focus leaving it dismisses it', (tester) async {
    var dismissed = 0;
    final inside = FocusNode(debugLabel: 'inside');
    final outside = FocusNode(debugLabel: 'outside');
    addTearDown(() {
      inside.dispose();
      outside.dispose();
    });
    await tester.pumpWidget(focusLeavingHarness(inside, outside, () => dismissed++, modal: false));
    inside.requestFocus();
    await tester.pump();
    expect(dismissed, 0);
    outside.requestFocus();
    await tester.pump();
    expect(dismissed, 1);
  });

  testWidgets('modal: focus leaving it does not dismiss it', (tester) async {
    var dismissed = 0;
    final inside = FocusNode(debugLabel: 'inside');
    final outside = FocusNode(debugLabel: 'outside');
    addTearDown(() {
      inside.dispose();
      outside.dispose();
    });
    await tester.pumpWidget(focusLeavingHarness(inside, outside, () => dismissed++, modal: true));
    inside.requestFocus();
    await tester.pump();
    expect(dismissed, 0);
    outside.requestFocus();
    await tester.pump();
    expect(dismissed, 0);
  });

  testWidgets('only the topmost of several open layers reacts to Escape; the next waits its turn', (tester) async {
    var dismissedA = 0, dismissedB = 0;
    await tester.pumpWidget(
      host(
        Stack(
          children: [
            DismissableLayer(
              onDismiss: () => dismissedA++,
              child: const Focus(autofocus: true, child: SizedBox(width: 20, height: 20)),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    await tester.pumpWidget(
      host(
        Stack(
          children: [
            DismissableLayer(
              onDismiss: () => dismissedA++,
              child: const Focus(child: SizedBox(width: 20, height: 20)),
            ),
            DismissableLayer(
              onDismiss: () => dismissedB++,
              child: const Focus(autofocus: true, child: SizedBox(width: 20, height: 20)),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(dismissedB, 1);
    expect(dismissedA, 0);

    // B closes: only A remains, and it now reacts
    await tester.pumpWidget(
      host(
        Stack(
          children: [
            DismissableLayer(
              onDismiss: () => dismissedA++,
              child: const Focus(autofocus: true, child: SizedBox(width: 20, height: 20)),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(dismissedA, 1);
  });

  testWidgets('G8: nested layers: Escape reaching the outer one does not dismiss it while the inner one is open', (
    tester,
  ) async {
    // B nested inside A's child (as a submenu would be), with focus on a node of A's that is not inside B: the key
    // event still reaches A (A is an ancestor of the focused node), so this exercises the topmost guard itself,
    // not just whether the event arrives.
    var dismissedA = 0, dismissedB = 0;
    final aFocus = FocusNode(debugLabel: 'aFocus');
    final bFocus = FocusNode(debugLabel: 'bFocus');
    addTearDown(() {
      aFocus.dispose();
      bFocus.dispose();
    });
    await tester.pumpWidget(
      host(
        DismissableLayer(
          onDismiss: () => dismissedA++,
          child: Column(
            children: [
              Focus(focusNode: aFocus, child: const SizedBox(width: 20, height: 20)),
              DismissableLayer(
                onDismiss: () => dismissedB++,
                child: Focus(focusNode: bFocus, child: const SizedBox(width: 20, height: 20)),
              ),
            ],
          ),
        ),
      ),
    );
    aFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(dismissedA, 0, reason: 'B is still open and topmost: A must not react, even with focus on A, not B');
    expect(dismissedB, 0);

    bFocus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(dismissedB, 1, reason: 'with focus actually inside B, Escape reaches and dismisses it');
    expect(dismissedA, 0);
  });

  testWidgets('G8: a press outside two stacked layers dismisses only the topmost one', (tester) async {
    var dismissedA = 0, dismissedB = 0;
    await tester.pumpWidget(
      host(
        Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: DismissableLayer(onDismiss: () => dismissedA++, child: const SizedBox(width: 100, height: 100)),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: DismissableLayer(onDismiss: () => dismissedB++, child: const SizedBox(width: 100, height: 100)),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.tapAt(const Offset(200, 400)); // outside both 100×100 boxes
    await tester.pump();
    expect(dismissedB, 1, reason: 'B opened last: only it reacts to the outside press');
    expect(dismissedA, 0);
  });
}
