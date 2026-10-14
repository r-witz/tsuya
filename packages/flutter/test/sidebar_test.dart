// Sidebar (DESIGN.md, Sidebar).
// G3: targets. G5: semantics. G13: spec values. G14: right-to-left. G7, G9: smoke_test.dart.

import 'dart:ui' show Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

const _star = SizedBox(width: 20, height: 20);

Finder _item(String label) => find.ancestor(of: find.text(label), matching: find.byType(Pressable));

// Aligned so the test's own (wider) viewport gives it a loose, not a tight, incoming width: a real app places a
// Sidebar next to other content in a Row, which loosens it the same way.
Widget _sidebar({bool collapsed = false, VoidCallback? onNew}) => Align(
  alignment: Alignment.topLeft,
  child: Sidebar(
    collapsed: collapsed,
    label: 'Library',
    children: [
      // Not const: a platform-override G3 test pumps this twice in a row, and a canonicalized const subtree would
      // otherwise be reused as-is rather than rebuilt against the new platform.
      SidebarItem(icon: _star, label: 'Home', current: true),
      SidebarGroup(
        label: 'Collection',
        children: [
          SidebarItem(icon: _star, label: 'Albums', count: 12),
          SidebarItem(icon: _star, label: 'Artists'),
        ],
      ),
      SidebarGroup(
        label: 'Playlists',
        children: [SidebarItem(icon: _star, label: 'New playlist', onPressed: onNew)],
      ),
    ],
  ),
);

Widget _itemSidebar({bool collapsed = false, String artists = 'Artists', Alignment at = Alignment.topLeft}) => Align(
  alignment: at,
  child: Sidebar(
    collapsed: collapsed,
    children: [
      SidebarItem(icon: _star, label: 'Albums', current: true, onPressed: () {}),
      SidebarItem(icon: _star, label: artists, onPressed: () {}),
    ],
  ),
);

// the inverted bubble of a Tooltip
Finder get _bubble =>
    find.byWidgetPredicate((w) => w is DecoratedBox && (w.decoration as BoxDecoration).color == TsuyaColors.light.text);

// Tab, as WidgetsApp would wire it: the host has no app shortcuts, so the focus moves by hand, in keyboard mode.
Future<void> _tab(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
  final current = FocusManager.instance.primaryFocus;
  if (current == null) {
    Focus.of(
      tester.element(find.descendant(of: find.byType(Pressable).first, matching: find.byType(DecoratedBox)).first),
    ).requestFocus();
  } else {
    current.nextFocus();
  }
  await tester.pump();
}

Future<TestGesture> _hover(WidgetTester tester, Finder item) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(mouse.removePointer);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(item));
  return mouse;
}

Finder _fill(Color color) => find.descendant(
  of: find.byType(SidebarItem),
  matching: find.byWidgetPredicate((w) => w is DecoratedBox && (w.decoration as BoxDecoration).color == color),
);

void main() {
  testWidgets('240 wide, padded 12; an item, the current one on fill-strong, a count', (tester) async {
    await tester.pumpWidget(host(_sidebar(), size: const Size(800, 600)));
    expect(tester.getSize(find.byType(Sidebar)).width, 240);
    final sidebar = tester.getRect(find.byType(Sidebar));
    final home = tester.getRect(_item('Home'));
    expect(home.top - sidebar.top, TsuyaSpace.s12);

    expect(tester.getSize(_item('Albums')).height, greaterThanOrEqualTo(TsuyaSize.controlSm));
    expect(tester.widget<Pressable>(_item('Albums')).borderRadius, BorderRadius.circular(TsuyaRadius.sm));
    final homeBoxes = tester.widgetList<DecoratedBox>(
      find.descendant(of: _item('Home'), matching: find.byType(DecoratedBox)),
    );
    expect(homeBoxes.map((b) => (b.decoration as BoxDecoration).color), contains(TsuyaColors.light.fillStrong));
    expect(tester.widget<Text>(find.text('Home')).style!.color, TsuyaColors.light.text);
    expect(tester.widget<Text>(find.text('Albums')).style!.color, TsuyaColors.light.textMuted);
    expect(tester.widget<Text>(find.text('Albums')).style!.fontSize, 13);
    final icon = tester.widget<IconTheme>(find.descendant(of: _item('Albums'), matching: find.byType(IconTheme)));
    expect(icon.data.size, TsuyaSize.icon);
    expect(find.text('12'), findsOneWidget);
    expect(tester.widget<Text>(find.text('12')).style!.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  testWidgets('collapsed: 72 wide, icons only, every item and group still named', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(_sidebar(collapsed: true), size: const Size(800, 600)));
    expect(tester.getSize(find.byType(Sidebar)).width, 72);
    expect(find.text('Albums'), findsNothing, reason: 'collapsed: the label is not drawn');
    expect(find.text('12'), findsNothing, reason: 'collapsed: the count is not drawn either');
    final albums = find.bySemanticsLabel('Albums');
    expect(albums, findsOneWidget);
    expect(tester.getSize(albums).width, 72 - TsuyaSpace.s12 * 2);
    final group = find.byWidgetPredicate((w) => w is SidebarGroup && w.label == 'Collection');
    expect(tester.getRect(group).top, tester.getRect(albums).top, reason: "a collapsed group's label takes no room");
    semantics.dispose();
  });

  testWidgets('a bare item (no href on Svelte) still presses', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(host(_sidebar(onNew: () => pressed++)));
    await tester.tap(_item('New playlist'));
    expect(pressed, 1);
  });

  testWidgets('G3: an item is control-sm tall, growing to a touch target on a touch platform', (tester) async {
    try {
      for (final (platform, height) in [
        (TargetPlatform.macOS, TsuyaSize.controlSm),
        (TargetPlatform.android, TsuyaSize.target),
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(host(_sidebar()));
        expect(tester.getSize(_item('Albums')).height, height, reason: '$platform');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('G5: a named navigation; the current item is selected; a count follows the label; a group is named', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(_sidebar()));
    final nav = tester.getSemantics(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.role == SemanticsRole.navigation),
    );
    expect(nav.label, 'Library');
    expect(tester.getSemantics(_item('Home')).flagsCollection.isSelected, Tristate.isTrue);
    expect(tester.getSemantics(_item('Albums')).flagsCollection.isSelected, Tristate.isFalse);
    expect(tester.getSemantics(_item('Albums')).label, 'Albums 12');
    expect(find.bySemanticsLabel('Collection'), findsOneWidget);
    semantics.dispose();
  });

  // SidebarItem's drawing and its collapsed tooltip (DESIGN.md, Sidebar; tests/svelte/sidebar.test.ts).
  // G3: targets. G13: spec values.
  testWidgets('G3: the current fill and the hover fill cover the whole item: 32 with a mouse, 44 on touch', (
    tester,
  ) async {
    try {
      for (final (platform, height) in [
        (TargetPlatform.linux, TsuyaSize.controlSm),
        (TargetPlatform.android, TsuyaSize.target),
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(host(_itemSidebar()));
        expect(tester.getSize(_fill(TsuyaColors.light.fillStrong)).height, height, reason: '$platform, current');
        if (platform == TargetPlatform.linux) {
          final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
          await mouse.addPointer(location: tester.getCenter(find.text('Artists')));
          await tester.pump();
          expect(tester.getSize(_fill(TsuyaColors.light.fill)).height, height, reason: 'hover');
          await mouse.removePointer();
        }
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('collapsed, an item shows its label as a tooltip at its end on a mouse, after the delay', (tester) async {
    await tester.pumpWidget(host(_itemSidebar(collapsed: true), size: const Size(800, 600)));
    final item = find.byType(Pressable).last;
    await _hover(tester, item);
    await tester.pump(const Duration(milliseconds: 499));
    expect(_bubble, findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(find.text('Artists'), findsOneWidget, reason: 'the bubble is the only place the label is drawn');
    final bubble = tester.getRect(_bubble);
    final box = tester.getRect(item);
    expect(bubble.left, moreOrLessEquals(box.right + TsuyaSpace.s4));
    expect(bubble.center.dy, moreOrLessEquals(box.center.dy));
  });

  testWidgets('collapsed, right-to-left: the tooltip is at the item\'s left', (tester) async {
    await tester.pumpWidget(
      host(
        _itemSidebar(collapsed: true, at: Alignment.topRight),
        direction: TextDirection.rtl,
        size: const Size(800, 600),
      ),
    );
    final item = find.byType(Pressable).last;
    await _hover(tester, item);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(tester.getRect(_bubble).right, moreOrLessEquals(tester.getRect(item).left - TsuyaSpace.s4));
  });

  testWidgets('collapsed, keyboard focus shows it at once; it describes nothing twice', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(_itemSidebar(collapsed: true), size: const Size(800, 600)));
    expect(_bubble, findsNothing);
    await _tab(tester);
    await _tab(tester);
    expect(find.text('Artists'), findsOneWidget);
    expect(tester.getSemantics(find.byType(Pressable).last).tooltip, isEmpty, reason: 'it repeats the item\'s name');
    semantics.dispose();
  });

  testWidgets('expanded, the labels show and there is no tooltip', (tester) async {
    await tester.pumpWidget(host(_itemSidebar(), size: const Size(800, 600)));
    await _hover(tester, find.byType(Pressable).last);
    await tester.pump(const Duration(milliseconds: 800));
    await _tab(tester);
    expect(_bubble, findsNothing);
    expect(find.text('Artists'), findsOneWidget);
  });

  testWidgets('a tooltip goes when its sidebar expands, and follows its label', (tester) async {
    await tester.pumpWidget(host(_itemSidebar(collapsed: true), size: const Size(800, 600)));
    await _tab(tester);
    await _tab(tester);
    expect(_bubble, findsOneWidget);
    await tester.pumpWidget(host(_itemSidebar(collapsed: true, artists: 'Records'), size: const Size(800, 600)));
    await tester.pump();
    expect(find.text('Records'), findsOneWidget);
    expect(find.text('Artists'), findsNothing);
    await tester.pumpWidget(host(_itemSidebar(artists: 'Records'), size: const Size(800, 600)));
    await tester.pumpAndSettle();
    expect(_bubble, findsNothing);
    expect(find.text('Records'), findsOneWidget, reason: 'the label only');
  });
}
