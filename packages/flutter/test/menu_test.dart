// Menu (DESIGN.md, Menu).
// G5: semantics. G6: keyboard, wrap, Home/End, type-ahead, Escape, Tab, disabled-but-focusable. G13: geometry.

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

// The panel's own chrome, the only DecoratedBox with a shadow (menuPanel's surface, not a button's ControlBody).
Finder get _panel => find.byWidgetPredicate(
  (w) => w is DecoratedBox && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).boxShadow != null,
);

Future<void> _open(WidgetTester tester, List<MenuItem> items) async {
  await tester.pumpWidget(
    host(
      Center(
        child: MenuButton(label: 'Actions', items: items),
      ),
    ),
  );
  await tester.tap(find.byType(MenuButton));
  await tester.pump();
  await tester.pump();
}

List<MenuItem> _sortMenu(void Function(String) onSelect, {String current = 'title'}) => [
  const MenuItem.label('Sort by'),
  for (final (value, label) in [('title', 'Title'), ('artist', 'Artist'), ('added', 'Date added')])
    MenuItem.radio(label: label, checked: current == value, onSelect: () => onSelect(value)),
];

void main() {
  testWidgets('MenuButton opens a menu below it, end-aligned, with the first item focused', (tester) async {
    // A declared size matching the real test surface: MediaQuery.sizeOf (what anchoredPosition clamps against)
    // only reflects what host() declares, not the surface tester.getRect's geometry is actually measured against.
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(
            label: 'Actions',
            items: [
              MenuItem(label: 'Rename', onSelect: () {}),
              MenuItem(label: 'Duplicate', onSelect: () {}),
            ],
          ),
        ),
        size: const Size(800, 600),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();

    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Duplicate'), findsOneWidget);
    expect(tester.binding.focusManager.primaryFocus?.debugLabel, contains('roving 0'));

    final button = tester.getRect(find.byType(MenuButton));
    final panel = tester.getRect(_panel);
    expect(panel.top, moreOrLessEquals(button.bottom + TsuyaSpace.s4));
    expect(panel.right, moreOrLessEquals(button.right));
    expect(panel.width, greaterThanOrEqualTo(220));
  });

  testWidgets('arrows wrap, Enter chooses, closes and returns focus to the opener', (tester) async {
    var chosen = '';
    final buttonFocus = FocusNode();
    addTearDown(buttonFocus.dispose);
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(
            label: 'Actions',
            focusNode: buttonFocus,
            items: [
              MenuItem(label: 'Rename', onSelect: () => chosen = 'Rename'),
              MenuItem(label: 'Duplicate', onSelect: () => chosen = 'Duplicate'),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus?.debugLabel, contains('roving 1'), reason: 'wraps to the last');

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(chosen, 'Duplicate');
    expect(find.text('Rename'), findsNothing, reason: 'the menu has closed');
    expect(buttonFocus.hasFocus, isTrue, reason: 'focus returns to the opener');
  });

  testWidgets('Escape closes it and returns focus to the opener', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(
            label: 'Actions',
            items: [MenuItem(label: 'Rename', onSelect: () {})],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rename'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsNothing);
  });

  testWidgets('focus leaving it (as Tab would, with the app shortcut host() does not provide) closes it', (
    tester,
  ) async {
    final elsewhere = FocusNode();
    addTearDown(elsewhere.dispose);
    await tester.pumpWidget(
      host(
        Column(
          children: [
            MenuButton(
              label: 'Actions',
              items: [MenuItem(label: 'Rename', onSelect: () {})],
            ),
            Focus(focusNode: elsewhere, child: const SizedBox(width: 20, height: 20)),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rename'), findsOneWidget);

    elsewhere.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsNothing);
  });

  testWidgets('type-ahead moves focus to the item starting with the typed letter', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(
            label: 'Actions',
            items: [
              MenuItem(label: 'Rename', onSelect: () {}),
              MenuItem(label: 'Duplicate', onSelect: () {}),
              MenuItem(label: 'Delete', onSelect: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus?.debugLabel, contains('roving 1'), reason: 'Duplicate');

    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus?.debugLabel, contains('roving 2'), reason: 'Delete, next D');
  });

  testWidgets('Menu.show names an invisible barrier behind the panel when given a barrierLabel', (tester) async {
    final semantics = tester.ensureSemantics();
    final anchorKey = GlobalKey();
    await tester.pumpWidget(host(Center(child: SizedBox(key: anchorKey, width: 10, height: 10))));

    unawaited(
      Menu.show(
        anchorKey.currentContext!,
        items: [MenuItem(label: 'Rename', onSelect: () {})],
        barrierLabel: 'Close menu',
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.bySemanticsLabel('Close menu'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a disabled item takes focus (Home/End reach it) but Enter does not choose it', (tester) async {
    var chosen = false;
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(
            label: 'Actions',
            items: [
              MenuItem(label: 'Rename', onSelect: () {}),
              MenuItem(label: 'Archive', disabled: true, onSelect: () => chosen = true),
              MenuItem(label: 'Duplicate', onSelect: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus?.debugLabel, contains('roving 1'), reason: 'the disabled item');

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(chosen, isFalse);
    expect(find.text('Rename'), findsOneWidget, reason: 'still open');
  });

  testWidgets('a checked item shows a tick and is announced as a checkbox item; destructive is in danger', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(
            label: 'Actions',
            items: [
              MenuItem(label: 'Bold', checked: true, onSelect: () {}),
              const MenuItem.separator(),
              MenuItem(label: 'Delete', destructive: true, onSelect: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Bold')),
      isSemantics(label: 'Bold', hasCheckedState: true, isChecked: true),
    );
    expect(tester.getSemantics(find.bySemanticsLabel('Bold')).role, SemanticsRole.menuItemCheckbox);

    final deleteText = tester.widget<Text>(find.text('Delete'));
    expect(deleteText.style!.color, TsuyaColors.light.danger);
    semantics.dispose();
  });

  testWidgets('pressing the button again closes the menu instead of reopening it', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(
            label: 'Actions',
            items: [MenuItem(label: 'Rename', onSelect: () {})],
          ),
        ),
        size: const Size(800, 600),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsOneWidget);

    await tester.tap(find.byType(MenuButton));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsNothing);
  });

  testWidgets('G5: the panel is a menu of menu items', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(
            label: 'Actions',
            items: [MenuItem(label: 'Rename', onSelect: () {})],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();

    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.role == SemanticsRole.menu), findsOneWidget);
    expect(tester.getSemantics(find.bySemanticsLabel('Rename')).role, SemanticsRole.menuItem);
    semantics.dispose();
  });

  // Menu radio and label items (DESIGN.md, Menu): the Flutter counterparts of Svelte's Menu.RadioItem and
  // Menu.Label. G5: semantics. G6: a label takes no focus.
  testWidgets('radio items are announced as radio menu items, one checked, ticked at the end', (tester) async {
    final semantics = tester.ensureSemantics();
    await _open(tester, _sortMenu((_) {}));

    final title = tester.getSemantics(find.bySemanticsLabel('Title'));
    expect(title.role, SemanticsRole.menuItemRadio);
    expect(title, isSemantics(label: 'Title', hasCheckedState: true, isChecked: true));
    final artist = tester.getSemantics(find.bySemanticsLabel('Artist'));
    expect(artist.role, SemanticsRole.menuItemRadio);
    expect(artist, isSemantics(label: 'Artist', hasCheckedState: true, isChecked: false));
    // one tick, at the end of the checked row
    final ticks = find.byWidgetPredicate((w) => w is Glyph && w.glyph == TsuyaGlyph.check);
    expect(ticks, findsOneWidget);
    expect(tester.getRect(ticks).center.dy, closeTo(tester.getRect(find.text('Title')).center.dy, 1));
    expect(tester.getRect(ticks).left, greaterThan(tester.getRect(find.text('Title')).right));
    semantics.dispose();
  });

  testWidgets('choosing a radio item calls onSelect and closes the menu', (tester) async {
    String? chosen;
    await _open(tester, _sortMenu((v) => chosen = v));
    await tester.tap(find.text('Artist'));
    await tester.pumpAndSettle();
    expect(chosen, 'artist');
    expect(find.text('Artist'), findsNothing);
  });

  testWidgets('a label is in the caption type and muted, and is not an item', (tester) async {
    final semantics = tester.ensureSemantics();
    await _open(tester, _sortMenu((_) {}));

    final label = tester.widget<Text>(find.text('Sort by'));
    expect(label.style!.fontSize, TsuyaType.caption.fontSize);
    expect(label.style!.color, TsuyaColors.light.textMuted);
    expect(tester.getSemantics(find.bySemanticsLabel('Sort by')).role, isNot(SemanticsRole.menuItem));
    semantics.dispose();
  });

  testWidgets('a label lines up with the items\' labels, at the start edge (G14: mirrored)', (tester) async {
    await _open(tester, _sortMenu((_) {}));
    expect(tester.getRect(find.text('Sort by')).left, tester.getRect(find.text('Date added')).left);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(label: 'Actions', items: _sortMenu((_) {})),
        ),
        direction: TextDirection.rtl,
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();
    expect(tester.getRect(find.text('Sort by')).right, tester.getRect(find.text('Date added')).right);
  });

  testWidgets('a label takes no focus, is not chosen and is not typed ahead', (tester) async {
    String? chosen;
    await _open(tester, _sortMenu((v) => chosen = v));

    expect(tester.binding.focusManager.primaryFocus?.debugLabel, contains('roving 0'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus?.debugLabel, contains('roving 2'), reason: 'wraps over the label');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus?.debugLabel, contains('roving 0'));

    await tester.tap(find.text('Sort by'));
    await tester.pump();
    expect(find.text('Sort by'), findsOneWidget, reason: 'still open');
    expect(chosen, isNull);
  });

  // Menu in a narrow view (DESIGN.md, Menu). G13: geometry.
  testWidgets('G13: in a view narrower than 252, the panel shrinks to the view less its margins, with no assert', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Center(
          child: MenuButton(
            label: 'Actions',
            items: [MenuItem(label: 'Rename', onSelect: () {})],
          ),
        ),
        size: const Size(200, 600),
      ),
    );
    await tester.tap(find.byType(MenuButton));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    final panel = tester.getRect(_panel);
    expect(panel.left, greaterThanOrEqualTo(TsuyaSpace.s16));
    expect(panel.right, lessThanOrEqualTo(200 - TsuyaSpace.s16));
  });
}
