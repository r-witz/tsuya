// TopBar (DESIGN.md, TopBar, ScreenBar).
// G5: semantics. G6: keyboard. G7: text scale. G13: spec values. G9, G14: smoke_test.dart.

import 'dart:ui' show Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

List<TopBarLink> _links({void Function(String)? onTap}) => [
  TopBarLink(label: 'Catalog', current: true, onPressed: () => onTap?.call('catalog')),
  TopBarLink(label: 'Orders', onPressed: () => onTap?.call('orders')),
  TopBarLink(label: 'Help', onPressed: () => onTap?.call('help')),
];

Finder _link(String label) => find.ancestor(of: find.text(label), matching: find.byType(Pressable));

List<TopBarLink> _menuLinks() => [
  TopBarLink(label: 'Home', current: true, onPressed: () {}),
  TopBarLink(label: 'Library', onPressed: () {}),
  TopBarLink(label: 'Settings', onPressed: () {}),
];

bool _hasRoleAbove(WidgetTester tester, Finder finder, SemanticsRole role) {
  SemanticsNode? node = tester.getSemantics(finder);
  while (node != null) {
    if (node.getSemanticsData().role == role) return true;
    node = node.parent;
  }
  return false;
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.byType(IconButton));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('glass, at least bar tall, margin 12 on the sides and the top', (tester) async {
    viewAt(tester, const Size(800, 800));
    await tester.pumpWidget(host(TopBar(links: _links()), size: const Size(800, 800)));
    expect(find.byType(Glass), findsOneWidget);
    expect(tester.getSize(find.byType(TopBar)).height, greaterThanOrEqualTo(TsuyaSize.bar));
    final bar = tester.getRect(find.byType(Glass));
    expect(bar.left, TsuyaSpace.s12);
    expect(800 - bar.right, TsuyaSpace.s12);
  });

  testWidgets('the current link stands out on fill-strong; a press calls onPressed', (tester) async {
    String? tapped;
    viewAt(tester, const Size(800, 800));
    await tester.pumpWidget(
      host(
        TopBar(links: _links(onTap: (v) => tapped = v)),
        size: const Size(800, 800),
      ),
    );
    // Pressable draws its own DecoratedBox (the hover/press highlight) around the link's; only one of the two
    // descendants should carry fill-strong.
    final boxes = tester.widgetList<DecoratedBox>(
      find.descendant(of: _link('Catalog'), matching: find.byType(DecoratedBox)),
    );
    expect(boxes.map((b) => (b.decoration as BoxDecoration).color), contains(TsuyaColors.light.fillStrong));
    expect(tester.widget<Text>(find.text('Catalog')).style!.color, TsuyaColors.light.text);
    expect(tester.widget<Text>(find.text('Help')).style!.color, TsuyaColors.light.textMuted);
    await tester.tap(_link('Help'));
    expect(tapped, 'help');
  });

  testWidgets('below the tablet width, the links move into a menu opened from a plain icon button', (tester) async {
    viewAt(tester, const Size(390, 800));
    await tester.pumpWidget(host(TopBar(links: _links()), size: const Size(390, 800)));
    expect(_link('Catalog'), findsNothing);
    final more = find.byType(IconButton);
    // the button's own node: the tooltip around it adds an empty one of its own
    final button = find.descendant(of: more, matching: find.byType(Pressable));
    expect(tester.getSemantics(button).label, 'More');
    await tester.tap(more);
    await tester.pump();
    await tester.pump();
    expect(find.text('Catalog'), findsOneWidget);
    expect(tester.getSemantics(button).flagsCollection.isExpanded, Tristate.isTrue);

    await tester.tap(_link('Help'));
    await tester.pumpAndSettle();
    expect(find.text('Catalog'), findsNothing, reason: 'a choice closes the menu');
  });

  testWidgets('the breakpoint is the bar\'s container, not the window (DESIGN.md, Layout)', (tester) async {
    Widget boxed(double width, Size window) {
      viewAt(tester, window);
      return host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: TopBar(links: _links()),
          ),
        ),
        size: window,
      );
    }

    await tester.pumpWidget(boxed(390, const Size(1440, 900)));
    expect(_link('Catalog'), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    await tester.pumpWidget(boxed(800, const Size(800, 900)));
    expect(_link('Catalog'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('at or above the tablet width, the links show inline and there is no menu button', (tester) async {
    viewAt(tester, const Size(800, 800));
    await tester.pumpWidget(host(TopBar(links: _links()), size: const Size(800, 800)));
    expect(_link('Catalog'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('start, center and end render; without links there is no menu button at any width', (tester) async {
    viewAt(tester, const Size(390, 800));
    await tester.pumpWidget(
      host(
        TopBar(start: const Text('Brand'), center: const Text('Search'), end: const Text('Settings')),
        size: const Size(390, 800),
      ),
    );
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('G7: wide, at text scale 2 and 3, the links overflow nothing', (tester) async {
    for (final scale in [2.0, 3.0]) {
      viewAt(tester, const Size(800, 800));
      await tester.pumpWidget(
        host(
          TopBar(links: _links()),
          size: const Size(800, 800),
          textScale: scale,
        ),
      );
      expect(tester.takeException(), isNull, reason: 'scale $scale');
    }
  });

  testWidgets('G7: at 320 wide and 300 %, a brand and a labelled button overflow nothing; the bar grows', (
    tester,
  ) async {
    await tester.runAsync(loadTsuyaFonts);
    viewAt(tester, const Size(320, 800));
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: TopBar(
              start: const Text('tsuya'),
              links: _links(),
              end: Button(label: 'Sign in', onPressed: () {}),
            ),
          ),
        ),
        size: const Size(320, 800),
        textScale: 3,
      ),
    );
    expect(tester.takeException(), isNull);
    final bar = tester.getRect(find.byType(Glass));
    expect(bar.height, greaterThan(TsuyaSize.bar));
    for (final finder in [find.text('tsuya'), find.text('Sign in'), find.byType(IconButton)]) {
      final rect = tester.getRect(finder);
      expect(rect.left, greaterThanOrEqualTo(bar.left));
      expect(rect.right, lessThanOrEqualTo(bar.right));
      expect(rect.bottom, lessThanOrEqualTo(bar.bottom));
    }
  });

  testWidgets('closing the narrow menu with Escape puts the focus back on the menu button', (tester) async {
    viewAt(tester, const Size(390, 800));
    await tester.pumpWidget(host(TopBar(links: _links()), size: const Size(390, 800)));
    final trigger = Focus.of(tester.element(find.byType(Glyph)));
    trigger.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump();
    expect(find.text(_links().first.label), findsOneWidget, reason: 'the menu is open');
    expect(trigger.hasFocus, isFalse, reason: 'the focus moved into the menu');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(_links().first.label), findsNothing, reason: 'the menu is closed');
    expect(trigger.hasFocus, isTrue);
  });

  testWidgets('choosing a link in the narrow menu puts the focus back on the menu button', (tester) async {
    viewAt(tester, const Size(390, 800));
    await tester.pumpWidget(host(TopBar(links: _links()), size: const Size(390, 800)));
    final trigger = Focus.of(tester.element(find.byType(Glyph)));
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    await tester.pump();
    await tester.tap(_link(_links().first.label));
    await tester.pumpAndSettle();
    expect(find.text(_links().first.label), findsNothing);
    expect(trigger.hasFocus, isTrue);
  });

  // TopBar's narrow menu and its landmarks (DESIGN.md, TopBar): a Popover, a navigation landmark, fitting.
  // G5: semantics. G6: keyboard. G7: text scale.
  testWidgets('the narrow menu is a Popover: a dialog named More, a navigation landmark inside', (tester) async {
    final handle = tester.ensureSemantics();
    viewAt(tester, const Size(390, 800));
    await tester.pumpWidget(host(TopBar(links: _menuLinks()), size: const Size(390, 800)));
    await _openMenu(tester);
    expect(find.byType(Popover), findsNothing, reason: 'the menu has no own button: its trigger is the icon button');
    expect(find.bySemanticsLabel('More'), findsWidgets);
    expect(_hasRoleAbove(tester, find.text('Library'), SemanticsRole.dialog), isTrue);
    expect(_hasRoleAbove(tester, find.text('Library'), SemanticsRole.navigation), isTrue);
    handle.dispose();
  });

  testWidgets('opened by a press the focus stays on the button; opened by a key it moves to the first link', (
    tester,
  ) async {
    viewAt(tester, const Size(390, 800));
    await tester.pumpWidget(host(TopBar(links: _menuLinks()), size: const Size(390, 800)));
    final trigger = Focus.of(tester.element(find.byType(Glyph)));
    await _openMenu(tester);
    expect(trigger.hasFocus, isTrue, reason: 'a press does not move focus into the menu');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    trigger.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump();
    expect(trigger.hasFocus, isFalse);
    final first = tester.element(find.text('Home'));
    expect(Focus.of(first).hasFocus, isTrue, reason: 'the first link has the focus');
  });

  testWidgets('the button stops saying expanded when it goes away with the menu open (narrow, wide, narrow)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    Widget app(double width) {
      viewAt(tester, Size(width, 800));
      return host(TopBar(links: _menuLinks()), size: Size(width, 800));
    }

    await tester.pumpWidget(app(500));
    await tester.tap(find.bySemanticsLabel('More'));
    await tester.pump();
    expect(find.text('Library'), findsOneWidget);
    await tester.pumpWidget(app(900));
    await tester.pumpWidget(app(500));
    await tester.pumpAndSettle();
    expect(find.text('Library'), findsNothing, reason: 'the menu closed with its button');
    final data = tester.getSemantics(find.bySemanticsLabel('More')).getSemanticsData();
    expect(data.flagsCollection.isExpanded, isNot(Tristate.isTrue));
    handle.dispose();
  });

  testWidgets('wide, the links are in a navigation landmark', (tester) async {
    final handle = tester.ensureSemantics();
    viewAt(tester, const Size(900, 800));
    await tester.pumpWidget(host(TopBar(links: _menuLinks()), size: const Size(900, 800)));
    expect(_hasRoleAbove(tester, find.text('Library'), SemanticsRole.navigation), isTrue);
    handle.dispose();
  });

  testWidgets('G7: 700 wide at text scale 2 with a brand, three links and an icon button overflows nothing', (
    tester,
  ) async {
    viewAt(tester, const Size(700, 800));
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 700,
            child: TopBar(
              start: const Text('Brand'),
              links: _menuLinks(),
              end: IconButton(icon: const Glyph(TsuyaGlyph.search), label: 'Search', onPressed: () {}),
            ),
          ),
        ),
        size: const Size(700, 800),
        textScale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
    // the links scroll sideways: the last one can be brought into view
    await tester.ensureVisible(find.text('Settings'));
    await tester.pump();
    expect(tester.getRect(find.text('Settings')).right, lessThanOrEqualTo(700));
  });

  testWidgets('a link\'s fill is as tall as its row: 32 with a mouse, 44 on touch', (tester) async {
    Finder fill() => find.descendant(
      of: find.byType(Pressable),
      matching: find.byWidgetPredicate(
        (w) => w is DecoratedBox && (w.decoration as BoxDecoration).color == TsuyaColors.light.fillStrong,
      ),
    );
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    viewAt(tester, const Size(900, 800));
    await tester.pumpWidget(host(TopBar(links: _menuLinks()), size: const Size(900, 800)));
    expect(tester.getSize(fill()).height, TsuyaSize.controlSm);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    viewAt(tester, const Size(901, 800));
    await tester.pumpWidget(host(TopBar(links: _menuLinks()), size: const Size(901, 800)));
    expect(tester.getSize(fill()).height, TsuyaSize.target);
    debugDefaultTargetPlatformOverride = null;
  });
}
