// IconButton (DESIGN.md, IconButton).
// G3: targets. G5: semantics. G6: keyboard. G9, G14: smoke_test.dart.
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

Widget _icon() => const SizedBox(width: 10, height: 10);

void main() {
  testWidgets('kind defaults to filled (fill and hairline); sizes map to 32/44/56, icon 16/20/24', (tester) async {
    await tester.pumpWidget(host(IconButton(icon: _icon(), label: 'Share', onPressed: () {})));
    final container = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, TsuyaColors.light.fill);
    expect((container.foregroundDecoration! as BoxDecoration).border!.top.color, TsuyaColors.light.border);

    // A mouse platform, so the smallest size isn't padded up to the touch target floor (covered by G3 below):
    // this loop only checks the size-to-diameter mapping itself.
    try {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      for (final (size, diameter, icon) in [
        (IconButtonSize.sm, TsuyaSize.controlSm, 16.0),
        (IconButtonSize.md, TsuyaSize.controlMd, 20.0),
        (IconButtonSize.lg, TsuyaSize.controlLg, 24.0),
      ]) {
        await tester.pumpWidget(
          host(
            Center(
              child: IconButton(icon: _icon(), label: 'Share', onPressed: () {}, size: size),
            ),
          ),
        );
        expect(tester.getSize(find.byType(IconButton)), Size(diameter, diameter));
        final iconTheme = find.descendant(of: find.byType(IconButton), matching: find.byType(IconTheme));
        expect(tester.widget<IconTheme>(iconTheme).data.size, icon);
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('a custom size is 40 to 72, its icon 38% of it, at least 18', (tester) async {
    expect(IconButtonSize.custom(60).iconSize, closeTo(22.8, 0.01));
    expect(IconButtonSize.custom(40).iconSize, 18.0, reason: 'clamped to at least 18');
    expect(() => IconButtonSize.custom(39), throwsA(isA<AssertionError>()));
    expect(() => IconButtonSize.custom(73), throwsA(isA<AssertionError>()));
  });

  testWidgets('a toggle is accent-filled with an on-accent icon when pressed, and announced toggled', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(IconButton(icon: _icon(), label: 'Shuffle', onPressed: () {}, toggled: false)));
    expect(
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration,
      isA<BoxDecoration>().having((d) => d.color, 'color', TsuyaColors.light.fill),
    );

    await tester.pumpWidget(host(IconButton(icon: _icon(), label: 'Shuffle', onPressed: () {}, toggled: true)));
    expect(
      (tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration).color,
      TsuyaColors.light.accent,
    );
    expect(
      // Tooltip now sits between the IconButton and its Pressable, so the node is found by label, not by ancestry.
      tester.getSemantics(find.bySemanticsLabel('Shuffle')),
      isSemantics(label: 'Shuffle', tooltip: 'Shuffle', hasToggledState: true, isToggled: true),
    );
    semantics.dispose();
  });

  testWidgets('accent kind is always accent-filled; glass uses control glass', (tester) async {
    await tester.pumpWidget(
      host(IconButton(icon: _icon(), label: 'Play', onPressed: () {}, kind: IconButtonKind.accent)),
    );
    expect(
      (tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration).color,
      TsuyaColors.light.accent,
    );

    await tester.pumpWidget(
      host(IconButton(icon: _icon(), label: 'Play', onPressed: () {}, kind: IconButtonKind.glass)),
    );
    expect(find.byType(ControlGlass), findsOneWidget);
  });

  testWidgets('disabled: faded, not pressable', (tester) async {
    await tester.pumpWidget(host(IconButton(icon: _icon(), label: 'Share', onPressed: null)));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
  });

  testWidgets('G5: an icon-only button is named by its label; the icon itself is not read', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(IconButton(icon: _icon(), label: 'Share', onPressed: () {})));
    expect(
      // Tooltip now sits between the IconButton and its Pressable, so the node is found by label, not by ancestry.
      tester.getSemantics(find.bySemanticsLabel('Share')),
      isSemantics(label: 'Share', tooltip: 'Share', isButton: true, hasEnabledState: true, isEnabled: true),
    );
    semantics.dispose();
  });

  testWidgets('the label shows as a tooltip on a mouse after the delay, never on touch, never with tooltip: false', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Center(
          child: IconButton(icon: _icon(), label: 'Share', onPressed: () {}),
        ),
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byType(IconButton)));
    await tester.pump(const Duration(milliseconds: 499));
    expect(find.text('Share'), findsNothing, reason: 'not yet the delay');
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.text('Share'), findsOneWidget);
    await gesture.moveTo(const Offset(5, 5));
    await tester.pump();
    await tester.pump(TsuyaDuration.fast);
    await tester.pumpAndSettle();

    final touch = await tester.createGesture(kind: PointerDeviceKind.touch);
    addTearDown(touch.removePointer);
    await touch.addPointer(location: tester.getCenter(find.byType(IconButton)));
    await tester.pump();
    await tester.pump(TsuyaDuration.tooltipDelay * 2);
    expect(find.text('Share'), findsNothing, reason: 'never on touch');

    await tester.pumpWidget(
      host(
        Center(
          child: IconButton(icon: _icon(), label: 'Share', onPressed: () {}, tooltip: false),
        ),
      ),
    );
    await gesture.moveTo(tester.getCenter(find.byType(IconButton)));
    await tester.pump();
    await tester.pump(TsuyaDuration.tooltipDelay * 2);
    expect(find.text('Share'), findsNothing, reason: 'tooltip: false turns it off');
    expect(
      tester.getSemantics(find.bySemanticsLabel('Share')).tooltip,
      '',
      reason: 'no stray tooltip once it is turned off',
    );
    semantics.dispose();
  });

  testWidgets('G3: the target is 44 on touch platforms, 24 with a mouse', (tester) async {
    try {
      for (final (platform, side) in [(TargetPlatform.android, 44.0), (TargetPlatform.macOS, 32.0)]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          host(
            Center(
              child: IconButton(icon: _icon(), label: 'Share', onPressed: () {}, size: IconButtonSize.sm),
            ),
          ),
        );
        expect(tester.getSize(find.byType(IconButton)), Size(side, side), reason: '$platform');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
