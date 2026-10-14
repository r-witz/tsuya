// TabBar (DESIGN.md, TabBar, Screen).
// G3: targets. G5: semantics. G6: keyboard. G13: spec values. G14: right-to-left. G7, G9: smoke_test.dart.
import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

List<TabBarItem<String>> _items({bool crowded = false}) => [
  const TabBarItem(value: 'home', label: 'Home', icon: Glyph(TsuyaGlyph.search)),
  TabBarItem(value: 'library', label: crowded ? 'Your music library' : 'Library', icon: const Glyph(TsuyaGlyph.search)),
  const TabBarItem(
    value: 'inbox',
    label: 'Inbox',
    icon: Glyph(TsuyaGlyph.search),
    badge: TabBarBadge(count: 3, label: '3 new'),
  ),
  const TabBarItem(value: 'settings', label: 'Settings', icon: Glyph(TsuyaGlyph.search)),
];

Finder _tab(String label) => find.ancestor(of: find.text(label), matching: find.byType(Pressable));

void main() {
  testWidgets('glass, at least dock tall, radius-lg, items sharing the width', (tester) async {
    await tester.pumpWidget(
      host(
        TabBar<String>(items: _items(), current: 'home', onSelect: (_) {}),
        size: const Size(390, 200),
      ),
    );
    expect(find.byType(Glass), findsOneWidget);
    expect(tester.getSize(find.byType(TabBar<String>)).height, greaterThanOrEqualTo(TsuyaSize.dock));
    expect(tester.widget<Glass>(find.byType(Glass)).borderRadius, BorderRadius.circular(TsuyaRadius.lg));
    final widths = ['Home', 'Library', 'Inbox', 'Settings'].map((l) => tester.getSize(_tab(l)).width).toSet();
    expect(widths.length, 1, reason: 'every item shares the same width');
  });

  testWidgets('an item: icon 24 over a micro label in text-muted; the current one in a fill-strong capsule, accent '
      'icon, label at 700', (tester) async {
    await tester.pumpWidget(
      host(
        TabBar<String>(items: _items(), current: 'home', onSelect: (_) {}),
        size: const Size(390, 200),
      ),
    );
    final homeIcon = tester.widget<IconTheme>(find.descendant(of: _tab('Home'), matching: find.byType(IconTheme)));
    expect(homeIcon.data.size, TsuyaSize.iconLg);
    expect(homeIcon.data.color, TsuyaColors.light.accent);
    final libraryIcon = tester.widget<IconTheme>(
      find.descendant(of: _tab('Library'), matching: find.byType(IconTheme)),
    );
    expect(libraryIcon.data.color, TsuyaColors.light.textMuted);

    final homeLabel = tester.widget<Text>(find.text('Home')).style!;
    expect(homeLabel.fontSize, 11);
    expect(homeLabel.color, TsuyaColors.light.text);
    expect(homeLabel.fontWeight, FontWeight.w700);
    final libraryLabel = tester.widget<Text>(find.text('Library')).style!;
    expect(libraryLabel.color, TsuyaColors.light.textMuted);
    expect(libraryLabel.fontWeight, isNot(FontWeight.w700));

    final homeBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(of: _tab('Home'), matching: find.byType(DecoratedBox)),
    );
    expect(homeBoxes.map((b) => (b.decoration as BoxDecoration).color), contains(TsuyaColors.light.fillStrong));
    final libraryBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(of: _tab('Library'), matching: find.byType(DecoratedBox)),
    );
    expect(
      libraryBoxes.map((b) => (b.decoration as BoxDecoration).color),
      isNot(contains(TsuyaColors.light.fillStrong)),
    );
  });

  testWidgets('the first tab counts as current while there is no value', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(TabBar<String>(items: _items(), onSelect: (_) {})));
    expect(tester.getSemantics(_tab('Home')).flagsCollection.isSelected, Tristate.isTrue);
    expect(tester.getSemantics(_tab('Library')).flagsCollection.isSelected, Tristate.isFalse);
    semantics.dispose();
  });

  testWidgets('one tab stop: arrows move focus only; Enter and a press choose', (tester) async {
    String? value;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              TabBar<String>(items: _items(), current: 'home', onSelect: (v) => setState(() => value = v)),
        ),
      ),
    );
    Focus.of(tester.element(find.text('Home'))).requestFocus();
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Library'))).hasFocus, isTrue);
    expect(value, isNull, reason: 'moving focus does not choose a tab');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(value, 'library');

    await tester.tap(_tab('Settings'));
    await tester.pump();
    expect(value, 'settings');
  });

  testWidgets('a press on the already-current tab scrolls the nearest primary scrollable to the top', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      host(
        PrimaryScrollController(
          controller: controller,
          child: Column(
            children: [
              Expanded(
                child: ListView(children: [for (var i = 0; i < 40; i++) SizedBox(height: 50, child: Text('Row $i'))]),
              ),
              TabBar<String>(items: _items(), current: 'home', onSelect: (_) {}),
            ],
          ),
        ),
        size: const Size(390, 700),
      ),
    );
    controller.jumpTo(300);
    await tester.pump();
    expect(controller.offset, 300);
    await tester.tap(_tab('Home'));
    await tester.pump();
    expect(controller.offset, 0, reason: 'reduced motion: an animateTo of a zero duration jumps instantly');
  });

  testWidgets('animated, the same press eases the scroll back to the top', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      host(
        PrimaryScrollController(
          controller: controller,
          child: Column(
            children: [
              Expanded(
                child: ListView(children: [for (var i = 0; i < 40; i++) SizedBox(height: 50, child: Text('Row $i'))]),
              ),
              TabBar<String>(items: _items(), current: 'home', onSelect: (_) {}),
            ],
          ),
        ),
        size: const Size(390, 700),
        animate: true,
      ),
    );
    controller.jumpTo(300);
    await tester.pump();
    await tester.tap(_tab('Home'));
    await tester.pump();
    expect(controller.offset, isNot(0), reason: 'mid-flight, still easing');
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });

  testWidgets('a badge is pinned to the icon, mirrored right to left; what it means is read after the label', (
    tester,
  ) async {
    await tester.pumpWidget(host(TabBar<String>(items: _items(), current: 'home', onSelect: (_) {})));
    final icon = tester.getRect(find.descendant(of: _tab('Inbox'), matching: find.byType(Glyph)));
    final badge = tester.getRect(find.descendant(of: _tab('Inbox'), matching: find.text('3')));
    expect(badge.right, greaterThan(icon.right));
    expect(badge.top, lessThan(icon.top));

    await tester.pumpWidget(
      host(
        TabBar<String>(items: _items(), current: 'home', onSelect: (_) {}),
        direction: TextDirection.rtl,
      ),
    );
    final iconRtl = tester.getRect(find.descendant(of: _tab('Inbox'), matching: find.byType(Glyph)));
    final badgeRtl = tester.getRect(find.descendant(of: _tab('Inbox'), matching: find.text('3')));
    expect(badgeRtl.left, lessThan(iconRtl.left));
    expect(badgeRtl.top, lessThan(iconRtl.top));
  });

  testWidgets('G3: an item grows under a touch target floor', (tester) async {
    await tester.pumpWidget(host(TabBar<String>(items: _items(), current: 'home', onSelect: (_) {})));
    final size = tester.getSize(_tab('Home'));
    expect(size.width, greaterThanOrEqualTo(TsuyaSize.target));
    expect(size.height, greaterThanOrEqualTo(TsuyaSize.target));
  });

  testWidgets('G5: tab bar and tab roles; selected; a badge\'s meaning follows the label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(TabBar<String>(items: _items(), current: 'home', onSelect: (_) {}, label: 'Sections')),
    );
    final bar = tester.getSemantics(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.role == SemanticsRole.tabBar),
    );
    expect(bar.label, 'Sections');
    final home = tester.getSemantics(_tab('Home'));
    expect(home.role, SemanticsRole.tab);
    expect(home.flagsCollection.isSelected, Tristate.isTrue);
    final library = tester.getSemantics(_tab('Library'));
    expect(library.flagsCollection.isSelected, Tristate.isFalse);
    final inbox = tester.getSemantics(_tab('Inbox'));
    expect(inbox.label, 'Inbox, 3 new');
    semantics.dispose();
  });

  testWidgets('right to left, the first tab is on the right and the arrows follow', (tester) async {
    await tester.pumpWidget(
      host(
        TabBar<String>(items: _items(), current: 'home', onSelect: (_) {}),
        direction: TextDirection.rtl,
      ),
    );
    expect(tester.getTopLeft(_tab('Home')).dx, greaterThan(tester.getTopLeft(_tab('Library')).dx));
    Focus.of(tester.element(find.text('Home'))).requestFocus();
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Library'))).hasFocus, isTrue);
  });

  testWidgets('G13, G14: a badge is the Badge, pinned past the top-end corner of the icon, mirrored right to left', (
    tester,
  ) async {
    List<TabBarItem<String>> items(TabBarBadge badge) => [
      const TabBarItem(value: 'home', label: 'Home', icon: Glyph(TsuyaGlyph.search)),
      TabBarItem(value: 'inbox', label: 'Inbox', icon: const Glyph(TsuyaGlyph.search), badge: badge),
    ];
    for (final direction in TextDirection.values) {
      await tester.pumpWidget(
        host(
          TabBar<String>(
            items: items(const TabBarBadge(count: 120, label: 'new')),
            onSelect: (_) {},
          ),
          size: const Size(390, 200),
          direction: direction,
        ),
      );
      expect(find.text('99+'), findsOneWidget);
      final icon = tester.getRect(find.descendant(of: _tab('Inbox'), matching: find.byType(IconTheme)).first);
      final badge = tester.getRect(find.byType(Badge));
      final rtl = direction == TextDirection.rtl;
      expect(badge.top, lessThan(icon.top), reason: 'above the top edge');
      expect(rtl ? badge.left < icon.left : badge.right > icon.right, isTrue, reason: 'past the end edge');
    }
    await tester.pumpWidget(
      host(
        TabBar<String>(
          items: items(const TabBarBadge(dot: true, label: 'new')),
          onSelect: (_) {},
        ),
        size: const Size(390, 200),
      ),
    );
    expect(tester.widget<Badge>(find.byType(Badge)).count, isNull, reason: 'a dot');
    await tester.pumpWidget(
      host(
        TabBar<String>(
          items: items(const TabBarBadge(label: 'nothing')),
          onSelect: (_) {},
        ),
        size: const Size(390, 200),
      ),
    );
    expect(find.byType(Badge), findsNothing, reason: 'neither a count nor a dot');
  });
}
