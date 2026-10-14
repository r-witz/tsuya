// Chip and ChipGroup (DESIGN.md, Chip).
// G3: targets. G5: semantics. G6: keyboard. G7, G9, G14: smoke_test.dart.
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

BoxDecoration _fill(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration! as BoxDecoration;

BoxDecoration? _border(WidgetTester tester) {
  final decoration = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).foregroundDecoration;
  return decoration == null ? null : decoration as BoxDecoration;
}

const _chips = [
  ChipOption(value: 'recent', label: 'Recent'),
  ChipOption(value: 'popular', label: 'Popular'),
  ChipOption(value: 'top', label: 'Top'),
];

void main() {
  testWidgets('unselected: fill with a hairline, text label, text-muted icon', (tester) async {
    await tester.pumpWidget(
      host(
        Chip(
          label: 'Recent',
          selected: false,
          onPressed: () {},
          icon: const SizedBox(key: Key('icon'), width: 4, height: 4),
        ),
      ),
    );
    expect(_fill(tester).color, TsuyaColors.light.fill);
    expect(_border(tester)!.border!.top.color, TsuyaColors.light.border);
    expect(tester.widget<Text>(find.text('Recent')).style!.color, TsuyaColors.light.text);
    expect(
      tester.widget<IconTheme>(find.descendant(of: find.byType(Chip), matching: find.byType(IconTheme))).data.color,
      TsuyaColors.light.textMuted,
    );
  });

  testWidgets('selected: accent fill, on-accent content, no hairline', (tester) async {
    await tester.pumpWidget(host(Chip(label: 'Recent', selected: true, onPressed: () {})));
    expect(_fill(tester).color, TsuyaColors.light.accent);
    expect(_border(tester), isNull);
    expect(tester.widget<Text>(find.text('Recent')).style!.color, TsuyaColors.light.onAccent);
  });

  testWidgets('glass: control glass instead of the fill and hairline', (tester) async {
    await tester.pumpWidget(host(Chip(label: 'Recent', selected: false, onPressed: () {}, glass: true)));
    expect(find.byType(ControlGlass), findsOneWidget);
  });

  testWidgets('disabled: faded, not pressable', (tester) async {
    await tester.pumpWidget(host(const Chip(label: 'Recent', selected: false, onPressed: null)));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
  });

  testWidgets('G5: a standalone chip is announced as a toggle, not a plain button', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Chip(label: 'Recent', selected: false, onPressed: () {})));
    expect(
      tester.getSemantics(find.byType(Chip)),
      isSemantics(label: 'Recent', isButton: false, hasToggledState: true, isToggled: false),
    );

    await tester.pumpWidget(host(Chip(label: 'Recent', selected: true, onPressed: () {})));
    expect(
      tester.getSemantics(find.byType(Chip)),
      isSemantics(label: 'Recent', isButton: false, hasToggledState: true, isToggled: true),
    );
    semantics.dispose();
  });

  testWidgets('G3: the target is 44 on touch platforms, control-sm with a mouse', (tester) async {
    try {
      for (final (platform, side) in [(TargetPlatform.android, 44.0), (TargetPlatform.macOS, TsuyaSize.controlSm)]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          host(
            Center(
              child: Chip(label: 'Recent', selected: false, onPressed: () {}),
            ),
          ),
        );
        expect(tester.getSize(find.byType(Chip)).height, greaterThanOrEqualTo(side), reason: '$platform');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  group('ChipGroup', () {
    testWidgets('scrolls sideways; single-select replaces the value with the chosen chip', (tester) async {
      var value = <String>{'recent'};
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => ChipGroup<String>(
              label: 'Sort by',
              value: value,
              onChanged: (v) => setState(() => value = v),
              chips: _chips,
            ),
          ),
        ),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView)).scrollDirection, Axis.horizontal);

      await tester.tap(find.text('Popular'));
      await tester.pump();
      expect(value, {'popular'});
    });

    testWidgets('multiple: toggles membership, allowing more than one chosen at once', (tester) async {
      var value = <String>{'recent'};
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => ChipGroup<String>(
              label: 'Filters',
              value: value,
              onChanged: (v) => setState(() => value = v),
              chips: _chips,
              multiple: true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Popular'));
      await tester.pump();
      expect(value, {'recent', 'popular'});

      await tester.tap(find.text('Recent'));
      await tester.pump();
      expect(value, {'popular'}, reason: 'tapping a chosen chip again removes it');
    });

    testWidgets('G6: arrow keys move the roving focus; Enter chooses the focused chip', (tester) async {
      var value = <String>{'recent'};
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => ChipGroup<String>(
              label: 'Sort by',
              value: value,
              onChanged: (v) => setState(() => value = v),
              chips: _chips,
            ),
          ),
        ),
      );
      Focus.of(tester.element(find.text('Recent'))).requestFocus();
      await tester.pump();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, {'popular'});
    });

    testWidgets('G5: single-select reads each chip as one radio of a mutually exclusive group', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(ChipGroup<String>(label: 'Sort by', value: const {'recent'}, onChanged: (_) {}, chips: _chips)),
      );
      expect(tester.getSemantics(find.byType(ChipGroup<String>)), isSemantics(label: 'Sort by'));
      expect(tester.getSemantics(find.byType(ChipGroup<String>)).role, SemanticsRole.radioGroup);
      expect(
        tester.getSemantics(find.widgetWithText(Chip, 'Recent')),
        isSemantics(
          label: 'Recent',
          isButton: false,
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      semantics.dispose();
    });
  });
}
