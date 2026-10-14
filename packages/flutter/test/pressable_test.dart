// The shared control behaviour (DESIGN.md, Foundations: States).
// G3: targets. G5: semantics. G6: keyboard.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

Widget box([double side = 20]) => SizedBox.square(
  dimension: side,
  child: const ColoredBox(color: Color(0xFF808080)),
);

void main() {
  testWidgets('a press calls onPressed and shrinks while held', (tester) async {
    var presses = 0;
    await tester.pumpWidget(
      host(
        Center(
          child: Pressable(onPressed: () => presses++, child: box(100)),
        ),
      ),
    );
    final gesture = await tester.startGesture(tester.getCenter(find.byType(Pressable)));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1, reason: 'still when animations are off');
    await gesture.up();
    expect(presses, 1);

    await tester.pumpWidget(
      host(
        Center(
          child: Pressable(onPressed: () => presses++, child: box(100)),
        ),
        animate: true,
      ),
    );
    final held = await tester.startGesture(tester.getCenter(find.byType(Pressable)));
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, TsuyaState.pressedScale);
    await held.up();
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    expect(presses, 2);
  });

  testWidgets('disabled: faded, not pressable, not focusable', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      host(
        Center(
          child: Pressable(onPressed: null, focusNode: focus, child: box(100)),
        ),
      ),
    );
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
    await tester.tap(find.byType(Pressable));
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isFalse);
  });

  testWidgets('G6: Enter and Space activate it, and the focus ring shows with its gap', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    final key = GlobalKey();
    var presses = 0;
    await tester.pumpWidget(
      host(
        TsuyaTheme(
          mode: TsuyaMode.dark,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: ColoredBox(
                color: const Color(0xFF808080),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Pressable(onPressed: () => presses++, focusNode: focus, child: box(40)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(presses, 2);
    await tester.pump();

    // the box spans 10..50; the gap 8..10, the ring 6..8 (left edge, middle row)
    const offset = TsuyaState.focusOffset, width = TsuyaState.focusWidth;
    expect(await pixelAt(tester, key, const Offset(10 - offset / 2, 30)), TsuyaColors.dark.bg);
    expect(await pixelAt(tester, key, const Offset(10 - offset - width / 2, 30)), TsuyaColors.dark.accent);
    expect(await pixelAt(tester, key, const Offset(2, 30)), const Color(0xFF808080));

    focus.unfocus();
    await tester.pump();
    await tester.pump();
    expect(await pixelAt(tester, key, const Offset(10 - offset - width / 2, 30)), const Color(0xFF808080));
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('G3: the target is 44 on touch platforms, 24 with a mouse, never shrinking a bigger child', (
    tester,
  ) async {
    for (final (platform, side) in [
      (TargetPlatform.android, 44.0),
      (TargetPlatform.iOS, 44.0),
      (TargetPlatform.macOS, 24.0),
      (TargetPlatform.linux, 24.0),
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      await tester.pumpWidget(
        host(
          Center(
            child: Pressable(onPressed: () {}, child: box()),
          ),
        ),
      );
      expect(tester.getSize(find.byType(Pressable)), Size(side, side), reason: '$platform');
      expect(tester.getSize(find.byType(ColoredBox)), const Size(20, 20));
    }

    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    await tester.pumpWidget(
      host(
        Center(
          child: Pressable(onPressed: () {}, child: box(30)),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Pressable)), const Size(30, 30), reason: 'a bigger child is never shrunk');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('G3: the whole target is tappable, not just the visible child; just outside it is not', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android; // touch: a 44×44 target around a 20×20 child
    var presses = 0;
    await tester.pumpWidget(
      host(
        Center(
          child: Pressable(onPressed: () => presses++, child: box()),
        ),
      ),
    );
    final topLeft = tester.getTopLeft(find.byType(Pressable));

    // 1 px inside the target's edge, well outside the 20×20 visible box centred 12 px in
    await tester.tapAt(topLeft + const Offset(1, 1));
    await tester.pump();
    expect(presses, 1, reason: 'the whole 44×44 target is tappable, not just the visible child');

    // 1 px outside the target altogether
    await tester.tapAt(topLeft + const Offset(-1, -1));
    await tester.pump();
    expect(presses, 1, reason: 'just outside the target, nothing happens');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('G5: screen readers get a button or a toggle with its label and state', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Column(
          children: [
            Pressable(onPressed: () {}, label: 'Play', child: box()),
            Pressable(onPressed: null, label: 'Next', child: box()),
            Pressable(onPressed: () {}, toggled: true, label: 'Shuffle', child: box()),
            Pressable(onPressed: () {}, selected: true, child: const Text('Albums')),
          ],
        ),
      ),
    );
    final pressables = find.byType(Pressable);
    expect(
      tester.getSemantics(pressables.at(0)),
      isSemantics(
        label: 'Play',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    expect(tester.getSemantics(pressables.at(1)), isSemantics(label: 'Next', isButton: true, hasEnabledState: true));
    expect(
      tester.getSemantics(pressables.at(2)),
      isSemantics(label: 'Shuffle', isButton: false, hasToggledState: true, isToggled: true, isEnabled: true),
    );
    expect(
      tester.getSemantics(pressables.at(3)),
      isSemantics(label: 'Albums', isSelected: true, isButton: true, hasSelectedState: true),
    );
    semantics.dispose();
  });
}
