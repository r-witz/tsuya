// What every overlay shares (DESIGN.md, Overlays and feedback): it outlives, or ends with, the widget that
// opened it, and a closing layer gives its keys back.
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide Banner;
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

// An opener that can be removed, next to a context that stays (to show something else from).
Widget _removable(ValueNotifier<bool> present, ValueSetter<BuildContext> other, Widget opener) => host(
  Column(
    children: [
      Builder(
        builder: (context) {
          other(context);
          return const SizedBox();
        },
      ),
      ValueListenableBuilder<bool>(
        valueListenable: present,
        builder: (_, there, _) => there ? opener : const SizedBox(),
      ),
    ],
  ),
  size: const Size(800, 600),
);

void main() {
  testWidgets('a dialog stays open, and the overlay keeps rebuilding, once its opener is gone', (tester) async {
    final present = ValueNotifier(true);
    addTearDown(present.dispose);
    late BuildContext other;
    await tester.pumpWidget(
      _removable(
        present,
        (c) => other = c,
        Builder(
          builder: (context) => Button(
            label: 'Open',
            onPressed: () => unawaited(Dialog.show<void>(context, builder: (_) => const Dialog(title: 'Title'))),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    present.value = false;
    await tester.pump();
    unawaited(Toast.show(other, message: 'Another'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Title'), findsOneWidget);
  });

  testWidgets('a popover closes with its opener, and the overlay rebuilds safely after', (tester) async {
    final present = ValueNotifier(true);
    addTearDown(present.dispose);
    late BuildContext other;
    await tester.pumpWidget(
      _removable(present, (c) => other = c, Popover(label: 'Filters', builder: (_) => const Text('Body'))),
    );
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Body'), findsOneWidget);
    present.value = false;
    await tester.pump();
    unawaited(Toast.show(other, message: 'Another'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Body'), findsNothing);
  });

  testWidgets('a menu closes with its opener, and the overlay rebuilds safely after', (tester) async {
    final present = ValueNotifier(true);
    addTearDown(present.dispose);
    late BuildContext other;
    await tester.pumpWidget(
      _removable(
        present,
        (c) => other = c,
        MenuButton(
          label: 'Actions',
          items: [MenuItem(label: 'Rename', onSelect: () {})],
        ),
      ),
    );
    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsOneWidget);
    present.value = false;
    await tester.pump();
    await tester.pump();
    unawaited(Toast.show(other, message: 'Another'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Rename'), findsNothing);
  });

  for (final kind in [PointerDeviceKind.mouse, PointerDeviceKind.touch]) {
    testWidgets('a modal overlay gives the focus back to the button pressed with a ${kind.name}', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => Button(
              label: 'Open',
              focusNode: node,
              onPressed: () => unawaited(
                Sheet.show<void>(
                  context,
                  builder: (sheet) => Sheet(
                    label: 'Edit',
                    child: Button(label: 'Done', onPressed: () => Sheet.close<void>(sheet)),
                  ),
                ),
              ),
            ),
          ),
          size: const Size(800, 600),
        ),
      );
      await tester.tap(find.text('Open'), kind: kind);
      await tester.pumpAndSettle();
      expect(node.hasPrimaryFocus, isFalse);
      await tester.tap(find.text('Done'), kind: kind);
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsNothing);
      expect(node.hasPrimaryFocus, isTrue);
    });
  }

  testWidgets('a dialog opened from a menu item gives the focus back to the menu button', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      host(
        Center(
          child: Builder(
            builder: (context) => MenuButton(
              label: 'Actions',
              focusNode: node,
              items: [
                MenuItem(
                  label: 'Delete',
                  onSelect: () => unawaited(
                    Dialog.show<void>(
                      context,
                      builder: (dialog) => Dialog(
                        title: 'Sure',
                        actions: [Button(label: 'Ok', onPressed: () => Dialog.close<void>(dialog))],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        size: const Size(800, 600),
      ),
    );
    await tester.tap(find.text('Actions'), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ok'), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();
    expect(find.text('Sure'), findsNothing);
    expect(node.hasPrimaryFocus, isTrue);
  });

  testWidgets('a layer that is closing gives Escape to the one under it, even mid-animation', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Button(
            label: 'Open',
            onPressed: () => unawaited(
              Dialog.show<void>(
                context,
                builder: (outer) => Dialog(
                  title: 'Outer',
                  actions: [
                    Button(
                      label: 'Inner',
                      onPressed: () =>
                          unawaited(Dialog.show<void>(outer, builder: (_) => const Dialog(title: 'Inner'))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        size: const Size(800, 600),
        animate: true,
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Button, 'Inner'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Inner'), findsWidgets, reason: 'the inner dialog is still fading out');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Outer'), findsNothing);
  });

  testWidgets('Escape closes a dialog that has nothing to focus', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Button(
            label: 'Open',
            onPressed: () => unawaited(Dialog.show<void>(context, builder: (_) => const Dialog(title: 'Title'))),
          ),
        ),
        size: const Size(800, 600),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Title'), findsNothing);
  });
}
