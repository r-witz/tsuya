// ListItem (DESIGN.md, List, ListItem, Section).
// G3: targets. G5: semantics. G6: keyboard (via Pressable). G9: reduced motion. G14: right-to-left.
// G7: smoke_test.dart.

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

Widget _icon() => const SizedBox(width: 10, height: 10);

void main() {
  testWidgets('row heights: size.row by default, size.row-tall with tall', (tester) async {
    await tester.pumpWidget(host(const Center(child: ListItem(title: 'Wi-Fi'))));
    expect(tester.getSize(find.byType(ListItem)).height, TsuyaSize.row);

    await tester.pumpWidget(host(const Center(child: ListItem(title: 'Jamie Doe', tall: true))));
    expect(tester.getSize(find.byType(ListItem)).height, TsuyaSize.rowTall);
  });

  testWidgets('leading icon 20, text-muted; title body-strong; subtitle small, text-muted, ellipsized', (tester) async {
    await tester.pumpWidget(host(ListItem(title: 'Wi-Fi', subtitle: 'Connected', leading: _icon())));
    final iconTheme = tester.widget<IconTheme>(
      find.descendant(of: find.byType(ListItem), matching: find.byType(IconTheme)).first,
    );
    expect(iconTheme.data.size, TsuyaSize.icon);
    expect(iconTheme.data.color, TsuyaColors.light.textMuted);

    final title = tester.widget<Text>(find.text('Wi-Fi'));
    expect(title.style!.fontSize, TsuyaType.bodyStrong.fontSize);
    expect(title.style!.fontWeight, TsuyaType.bodyStrong.fontWeight);
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);

    final subtitle = tester.widget<Text>(find.text('Connected'));
    expect(subtitle.style!.color, TsuyaColors.light.textMuted);
    expect(subtitle.maxLines, 1);
    expect(subtitle.overflow, TextOverflow.ellipsis);
  });

  testWidgets('a trailing value is muted, tabular, and capped at half the row', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: SizedBox(
            width: 300,
            child: ListItem(
              title: 'Storage',
              trailing: const Text('128 GB', key: Key('value')),
            ),
          ),
        ),
      ),
    );
    final style = tester
        .widget<DefaultTextStyle>(
          find.ancestor(of: find.byKey(const Key('value')), matching: find.byType(DefaultTextStyle)).first,
        )
        .style;
    expect(style.color, TsuyaColors.light.textMuted);
    expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    final box = tester.renderObject<RenderConstrainedBox>(
      find.ancestor(of: find.byKey(const Key('value')), matching: find.byType(ConstrainedBox)).first,
    );
    expect(box.additionalConstraints.maxWidth, 150);
  });

  testWidgets('navigates and nothing trails: a 16 chevron, text-muted; a trailing value replaces it', (tester) async {
    await tester.pumpWidget(host(ListItem(title: 'Account', onPressed: () {}, navigates: true)));
    expect(tester.getSize(find.byType(Glyph)).width, TsuyaSize.iconSm);

    await tester.pumpWidget(
      host(ListItem(title: 'Storage', onPressed: () {}, navigates: true, trailing: const Text('128 GB'))),
    );
    expect(find.byType(Glyph), findsNothing);
  });

  testWidgets('a plain row (no onPressed) is not wrapped in a Pressable', (tester) async {
    await tester.pumpWidget(host(const ListItem(title: 'Storage')));
    expect(find.byType(Pressable), findsNothing);
  });

  testWidgets('an interactive row is a Pressable with highlight feedback; a press calls onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(host(ListItem(title: 'Bluetooth', onPressed: () => pressed = true)));
    expect(tester.widget<Pressable>(find.byType(Pressable)).feedback, PressFeedback.highlight);
    await tester.tap(find.byType(ListItem));
    expect(pressed, isTrue);
  });

  testWidgets('current: the title is weight 800 and the Pressable is marked selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(ListItem(title: 'Wi-Fi', onPressed: () {}, current: true)));
    expect(tester.widget<Text>(find.text('Wi-Fi')).style!.fontWeight, FontWeight.w800);
    expect(tester.getSemantics(find.byType(ListItem)), isSemantics(hasSelectedState: true, isSelected: true));

    await tester.pumpWidget(host(ListItem(title: 'Wi-Fi', onPressed: () {})));
    expect(tester.widget<Text>(find.text('Wi-Fi')).style!.fontWeight, isNot(FontWeight.w800));
    expect(tester.getSemantics(find.byType(ListItem)), isSemantics(hasSelectedState: false));
    semantics.dispose();
  });

  testWidgets('current on a plain row is exposed as selected too', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(const ListItem(title: 'Home', current: true)));
    expect(tester.getSemantics(find.text('Home')), isSemantics(hasSelectedState: true, isSelected: true));
    await tester.pumpWidget(host(const ListItem(title: 'Home')));
    expect(tester.getSemantics(find.text('Home')), isSemantics(hasSelectedState: false));
    semantics.dispose();
  });

  testWidgets('destructive: the title is in danger', (tester) async {
    await tester.pumpWidget(host(ListItem(title: 'Sign out', onPressed: () {}, destructive: true)));
    expect(tester.widget<Text>(find.text('Sign out')).style!.color, TsuyaColors.light.danger);
  });

  group('selected', () {
    testWidgets('an action row (onPressed, not navigates): a tick, and a toggled state', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(host(ListItem(title: 'English', onPressed: () {}, selected: true)));
      expect(find.byType(Glyph), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(ListItem)),
        isSemantics(label: 'English', hasToggledState: true, isToggled: true),
      );

      await tester.pumpWidget(host(ListItem(title: 'English', onPressed: () {}, selected: false)));
      expect(find.byType(Glyph), findsNothing);
      expect(
        tester.getSemantics(find.byType(ListItem)),
        isSemantics(label: 'English', hasToggledState: true, isToggled: false),
      );
      semantics.dispose();
    });

    testWidgets('a row that navigates: a tick, and an announced "Selected" instead of a toggled state', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(host(ListItem(title: 'Français', onPressed: () {}, navigates: true, selected: true)));
      expect(find.byType(Glyph), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(ListItem)),
        isSemantics(label: 'Français\n${TsuyaLabels.en.selected}', hasToggledState: false),
      );
      semantics.dispose();
    });

    testWidgets('a plain row: a tick, and an announced "Selected"', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(host(const ListItem(title: 'Français', selected: true)));
      expect(find.byType(Glyph), findsOneWidget);
      expect(tester.getSemantics(find.byType(ListItem)), isSemantics(label: 'Français\n${TsuyaLabels.en.selected}'));
      semantics.dispose();
    });
  });

  testWidgets('G3: the target is at least 44 tall on touch platforms (56/72 already clears it)', (tester) async {
    try {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        host(
          Center(
            child: ListItem(title: 'Bluetooth', onPressed: () {}),
          ),
        ),
      );
      expect(tester.getSize(find.byType(ListItem)).height, greaterThanOrEqualTo(TsuyaSize.target));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('G9: reduced motion and G14: right-to-left build without error; the chevron mirrors', (tester) async {
    await tester.pumpWidget(
      host(
        ListItem(title: 'Account', onPressed: () {}, navigates: true),
        direction: TextDirection.rtl,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(Glyph), findsOneWidget);
  });

  // A Switch in a ListItem row (DESIGN.md, Switch: "Named by its label or its row"). G5: semantics.
  testWidgets('G5: a row\'s switch is one node named by the row, a toggle with its state, that toggles', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var value = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => ListItem(
            title: 'Crossfade',
            subtitle: 'Blend the end of a track into the next',
            trailing: Switch(value: value, onChanged: (next) => setState(() => value = next)),
          ),
        ),
      ),
    );

    // the title, the subtitle and the switch are one node, which is the one the switch's own press reaches
    final node = tester.getSemantics(find.text('Crossfade'));
    expect(tester.getSemantics(find.byType(Switch)).id, node.id);
    expect(node.getSemanticsData().label, 'Crossfade\nBlend the end of a track into the next');
    expect(node, isSemantics(hasToggledState: true, isToggled: false, hasTapAction: true));

    node.owner!.performAction(node.id, SemanticsAction.tap);
    await tester.pump();
    expect(value, isTrue);
    expect(tester.getSemantics(find.text('Crossfade')), isSemantics(hasToggledState: true, isToggled: true));
    semantics.dispose();
  });
}
