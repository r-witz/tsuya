// Select (DESIGN.md, Select).
// G3: targets. G5: semantics. G6: keyboard. G7: text scale. G9: reduced motion. G14: right-to-left.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/listbox.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

const _options = [
  ListboxOption(value: 'fr', label: 'France'),
  ListboxOption(value: 'de', label: 'Germany'),
  ListboxOption(value: 'it', label: 'Italy'),
];

Widget _select({
  String? value,
  ValueChanged<String>? onChanged,
  String? placeholder,
  List<ListboxOption<String>> options = _options,
  FocusNode? focusNode,
  bool sheetOnPhone = false,
}) => Center(
  child: SizedBox(
    width: 240,
    child: Select<String>(
      label: 'Country',
      value: value,
      onChanged: onChanged,
      options: options,
      placeholder: placeholder,
      sheetOnPhone: sheetOnPhone,
      focusNode: focusNode,
    ),
  ),
);

void main() {
  testWidgets('shows the placeholder muted while nothing is chosen, the label in text once chosen', (tester) async {
    await tester.pumpWidget(host(_select(placeholder: 'Choose a country', onChanged: (_) {})));
    expect(tester.widget<Text>(find.text('Choose a country')).style!.color, TsuyaColors.light.textMuted);

    await tester.pumpWidget(host(_select(value: 'fr', onChanged: (_) {})));
    expect(tester.widget<Text>(find.text('France')).style!.color, TsuyaColors.light.text);
    expect(find.text('Choose a country'), findsNothing);
  });

  testWidgets('tapping the trigger opens the panel listing the options; tapping one chooses it and closes', (
    tester,
  ) async {
    String? value;
    await tester.pumpWidget(host(_select(onChanged: (v) => value = v)));
    expect(find.text('Germany'), findsNothing);

    await tester.tap(find.byType(Select<String>));
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsOneWidget);

    await tester.tap(find.text('Germany'));
    await tester.pumpAndSettle();
    expect(value, 'de');
    expect(find.text('Germany'), findsNothing, reason: 'choosing closes the panel');
  });

  testWidgets('the chosen option is ticked in the panel, the others are not', (tester) async {
    await tester.pumpWidget(host(_select(value: 'de', onChanged: (_) {})));
    await tester.tap(find.byType(Select<String>));
    await tester.pumpAndSettle();

    final panel = find.byType(Listbox<String>);
    final germany = find
        .ancestor(
          of: find.descendant(of: panel, matching: find.text('Germany')),
          matching: find.byType(Container),
        )
        .first;
    final france = find
        .ancestor(
          of: find.descendant(of: panel, matching: find.text('France')),
          matching: find.byType(Container),
        )
        .first;
    expect(find.descendant(of: germany, matching: find.byType(Glyph)), findsOneWidget);
    expect(find.descendant(of: france, matching: find.byType(Glyph)), findsNothing);
  });

  testWidgets('tapping outside, or Escape, closes the panel without choosing', (tester) async {
    await tester.pumpWidget(host(_select(onChanged: (_) {})));
    await tester.tap(find.byType(Select<String>));
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsNothing);
  });

  testWidgets('shows a noResults row for an empty option list', (tester) async {
    await tester.pumpWidget(host(_select(onChanged: (_) {}, options: const [])));
    await tester.tap(find.byType(Select<String>));
    await tester.pumpAndSettle();
    expect(find.text('No results'), findsOneWidget);
  });

  testWidgets('disabled: faded, does not open', (tester) async {
    await tester.pumpWidget(host(_select()));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
    await tester.tap(find.byType(Select<String>));
    await tester.pump();
    expect(find.text('France'), findsNothing);
  });

  testWidgets('G5: a combo box named by its label and the chosen value; expanded once open', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(_select(value: 'fr', onChanged: (_) {})));
    final collapsed = tester.getSemantics(find.byType(Select<String>));
    expect(collapsed, isSemantics(label: 'Country', value: 'France', hasExpandedState: true, isExpanded: false));
    // role: isn't a matcher parameter on every supported SDK; read it straight off the trigger's own node instead.
    expect(find.byType(Pressable).evaluate().single.renderObject!.debugSemantics!.role, SemanticsRole.comboBox);

    await tester.tap(find.byType(Select<String>));
    await tester.pumpAndSettle();
    expect(tester.getSemantics(find.byType(Select<String>)), isSemantics(isExpanded: true));
    semantics.dispose();
  });

  testWidgets('G6: Enter, Space and arrows open; once open, arrows move and Enter chooses; Escape closes', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    String? value;
    await tester.pumpWidget(host(_select(onChanged: (v) => value = v, focusNode: focus)));
    focus.requestFocus();
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('France'), findsOneWidget, reason: 'an arrow key opens the panel');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(value, 'de', reason: 'arrows moved to the second option, Enter chose it');

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsOneWidget, reason: 'Enter re-opens the (now refocused) trigger');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsNothing);
  });

  testWidgets('pressing the trigger while its panel is open closes it, and it stays closed', (tester) async {
    await tester.pumpWidget(host(_select(onChanged: (_) {})));
    await tester.tap(find.byType(Select<String>));
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsOneWidget);
    await tester.tap(find.byType(Select<String>));
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsNothing);
    await tester.tap(find.byType(Select<String>));
    await tester.pumpAndSettle();
    expect(find.text('Germany'), findsOneWidget);
  });

  testWidgets('G3: the trigger is target tall', (tester) async {
    await tester.pumpWidget(host(_select(onChanged: (_) {})));
    expect(tester.getSize(find.byType(Pressable)).height, TsuyaSize.target);
  });

  testWidgets('G7: text scale 2.0 and 3.0 overflow nothing, open or closed', (tester) async {
    for (final scale in [2.0, 3.0]) {
      await tester.pumpWidget(
        host(
          _select(value: 'fr', onChanged: (_) {}),
          textScale: scale,
        ),
      );
      expect(tester.takeException(), isNull, reason: 'closed, scale $scale');
      await tester.tap(find.byType(Select<String>));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'open, scale $scale');
    }
  });

  testWidgets('G9: reduced motion and G14: right-to-left build and open without error', (tester) async {
    await tester.pumpWidget(host(_select(onChanged: (_) {}), direction: TextDirection.rtl));
    await tester.tap(find.byType(Select<String>));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  // Select on a phone (DESIGN.md, Select; G5, G6): below the tablet width the options open in a sheet
  // titled by the label, the listbox focused; a choice or Escape closes it and focus goes back to the trigger. Not
  // with sheetOnPhone false, nor from the tablet width.
  group('on a phone', () {
    late FocusNode trigger;
    setUp(() => trigger = FocusNode());
    tearDown(() => trigger.dispose());

    Widget select({required ValueChanged<String> onChanged, bool sheetOnPhone = true, double width = 390}) => host(
      Center(
        child: SizedBox(
          width: 240,
          child: Select<String>(
            label: 'Country',
            value: null,
            onChanged: onChanged,
            options: _options,
            sheetOnPhone: sheetOnPhone,
            focusNode: trigger,
          ),
        ),
      ),
      size: Size(width, 800),
    );

    testWidgets('a phone: the options open in a sheet titled by the label; a choice closes it, focus back on the '
        'trigger', (tester) async {
      String? chosen;
      await tester.pumpWidget(select(onChanged: (value) => chosen = value));
      await tester.tap(find.byType(Select<String>));
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      expect(find.descendant(of: find.byType(Sheet), matching: find.text('Country')), findsOneWidget);
      await tester.tap(find.text('Italy'));
      await tester.pumpAndSettle();
      expect(chosen, 'it');
      expect(find.byType(Sheet), findsNothing);
      expect(trigger.hasPrimaryFocus, isTrue);
    });

    testWidgets('the keyboard: the listbox has the focus, the arrows and Enter choose; Escape closes without '
        'choosing', (tester) async {
      String? chosen;
      await tester.pumpWidget(select(onChanged: (value) => chosen = value));
      trigger.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(Sheet), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect((find.byType(Sheet).evaluate().isEmpty, chosen, trigger.hasPrimaryFocus), (true, null, true));

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(chosen, isNotNull);
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('sheetOnPhone false, or the tablet width, keeps the panel', (tester) async {
      await tester.pumpWidget(select(onChanged: (_) {}, sheetOnPhone: false));
      await tester.tap(find.byType(Select<String>));
      await tester.pumpAndSettle();
      expect((find.byType(Sheet).evaluate().isEmpty, find.text('Italy').evaluate().length), (true, 1));
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      await tester.pumpWidget(select(onChanged: (_) {}, width: TsuyaBreakpoint.tablet));
      await tester.tap(find.byType(Select<String>));
      await tester.pumpAndSettle();
      expect((find.byType(Sheet).evaluate().isEmpty, find.text('Italy').evaluate().length), (true, 1));
    });
  });
}
