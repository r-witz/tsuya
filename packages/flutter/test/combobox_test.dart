// Combobox (DESIGN.md, Combobox).
// G3: targets. G5: semantics. G6: keyboard. G7: text scale. G9: reduced motion. G14: right-to-left.

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

const _options = [
  ListboxOption(value: 'fr', label: 'France'),
  ListboxOption(value: 'de', label: 'Germany'),
  ListboxOption(value: 'it', label: 'Italy'),
];

Widget _combobox({
  List<ListboxOption<String>> options = _options,
  ValueChanged<String>? onSelected,
  bool loading = false,
  bool freeText = false,
  FocusNode? focusNode,
  bool enabled = true,
}) => Center(
  child: SizedBox(
    width: 240,
    child: Combobox<String>(
      label: 'Country',
      options: options,
      onSelected: onSelected,
      loading: loading,
      freeText: freeText,
      focusNode: focusNode,
      enabled: enabled,
    ),
  ),
);

Finder _roleFinder = find.byWidgetPredicate((w) => w is Semantics && w.properties.role == SemanticsRole.comboBox);

const _countries = [
  ListboxOption(value: 'fr', label: 'France'),
  ListboxOption(value: 'de', label: 'Germany'),
  ListboxOption(value: 'it', label: 'Italy'),
];

void main() {
  testWidgets('typing filters the options, case-insensitively, and opens the panel', (tester) async {
    await tester.pumpWidget(host(_combobox()));
    expect(find.text('Germany'), findsNothing);
    await tester.enterText(find.byType(EditableText), 'RM');
    await tester.pump();
    expect(find.text('Germany'), findsOneWidget);
    expect(find.text('France'), findsNothing);
    expect(find.text('Italy'), findsNothing);
  });

  testWidgets('tapping a row chooses it: fills the field, calls onSelected, closes the panel', (tester) async {
    String? chosen;
    await tester.pumpWidget(host(_combobox(onSelected: (v) => chosen = v)));
    await tester.enterText(find.byType(EditableText), 'an'); // matches France and Germany
    await tester.pump();
    expect(find.text('France'), findsOneWidget);

    await tester.tap(find.text('Germany'));
    await tester.pump();
    expect(chosen, 'de');
    expect(find.text('France'), findsNothing, reason: 'choosing closes the panel');
    expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, 'Germany');
  });

  testWidgets('Enter chooses the active option', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    String? chosen;
    await tester.pumpWidget(host(_combobox(onSelected: (v) => chosen = v, focusNode: focus)));
    focus.requestFocus();
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'it');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(chosen, 'it');
  });

  testWidgets('loading shows a spinner row instead of the filtered options', (tester) async {
    await tester.pumpWidget(host(_combobox(loading: true)));
    await tester.enterText(find.byType(EditableText), 'fr');
    await tester.pump();
    expect(find.text('Loading'), findsOneWidget);
    expect(find.text('France'), findsNothing);
  });

  testWidgets('shows a noResults row when nothing matches', (tester) async {
    await tester.pumpWidget(host(_combobox()));
    await tester.enterText(find.byType(EditableText), 'xyz');
    await tester.pump();
    expect(find.text('No results'), findsOneWidget);
  });

  testWidgets('strict by default: unmatched text reverts on blur; freeText keeps it', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(host(_combobox(focusNode: focus)));
    focus.requestFocus();
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'xyz');
    await tester.pump();
    focus.unfocus();
    await tester.pump();
    expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, '');

    await tester.pumpWidget(host(_combobox(focusNode: focus, freeText: true)));
    focus.requestFocus();
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'xyz');
    await tester.pump();
    focus.unfocus();
    await tester.pump();
    expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, 'xyz');
  });

  testWidgets('disabled: faded, read-only', (tester) async {
    await tester.pumpWidget(host(_combobox(enabled: false)));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
    expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
  });

  testWidgets('G5: a combo box named by its label; expanded once the panel opens', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(_combobox()));
    expect(tester.getSemantics(find.byType(Combobox<String>)), isSemantics(label: 'Country'));
    expect(tester.widget<Semantics>(_roleFinder).properties.expanded, false);

    await tester.enterText(find.byType(EditableText), 'fr');
    await tester.pump();
    expect(tester.widget<Semantics>(_roleFinder).properties.expanded, true);
    semantics.dispose();
  });

  testWidgets('G6: arrows move the active option with no wrap; Escape closes, then clears', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    String? chosen;
    await tester.pumpWidget(host(_combobox(onSelected: (v) => chosen = v, focusNode: focus)));
    focus.requestFocus();
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'an'); // matches France (0) and Germany (1)
    await tester.pump();

    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
    }
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(chosen, 'de', reason: 'the third arrow stayed on the last option instead of wrapping to the first');

    await tester.enterText(find.byType(EditableText), 'an');
    await tester.pump();
    expect(find.text('France'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('France'), findsNothing, reason: 'the first Escape only closes the panel');
    expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, 'an');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, '', reason: 'the second clears');
  });

  testWidgets('G3: the field is at least control-md tall', (tester) async {
    await tester.pumpWidget(host(_combobox()));
    expect(tester.getSize(find.byType(Combobox<String>)).height, greaterThanOrEqualTo(TsuyaSize.controlMd));
  });

  testWidgets('G7: text scale 2.0 and 3.0 overflow nothing, open or closed', (tester) async {
    for (final scale in [2.0, 3.0]) {
      await tester.pumpWidget(host(_combobox(), textScale: scale));
      expect(tester.takeException(), isNull, reason: 'closed, scale $scale');
      await tester.enterText(find.byType(EditableText), 'fr');
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'open, scale $scale');
    }
  });

  testWidgets('G9: reduced motion and G14: right-to-left build and filter without error', (tester) async {
    await tester.pumpWidget(host(_combobox(), direction: TextDirection.rtl));
    await tester.enterText(find.byType(EditableText), 'fr');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  // Combobox: the model it shares with the web (DESIGN.md, Combobox; G6, G13; as in
  // tests/svelte/combobox.test.ts): no option active until an arrow moves, a press or an arrow that opens every option,
  // Enter that keeps the text when no option is active, a text that names an option chooses it, Escape that passes on
  // once there is nothing to close or clear, and the results announced again when the options change.
  group('the model it shares with the web', () {
    late FocusNode focus;
    String? chosen;

    setUp(() {
      focus = FocusNode();
      chosen = null;
    });
    tearDown(() => focus.dispose());

    Widget combobox({List<ListboxOption<String>> options = _countries, bool loading = false}) => host(
      Center(
        child: SizedBox(
          width: 240,
          child: Combobox<String>(
            label: 'Country',
            options: options,
            loading: loading,
            onSelected: (value) => chosen = value,
            focusNode: focus,
          ),
        ),
      ),
    );

    String text(WidgetTester tester) => tester.widget<EditableText>(find.byType(EditableText)).controller.text;
    Future<void> key(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }

    Future<void> enter(WidgetTester tester) async {
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    }

    Future<void> type(WidgetTester tester, String value) async {
      await tester.enterText(find.byType(EditableText), value);
      await tester.pump();
    }

    testWidgets(
      'typing makes no option active: Enter keeps the text; down goes to the first, up from none to the last',
      (tester) async {
        await tester.pumpWidget(combobox());
        focus.requestFocus();
        await tester.pump();
        await type(tester, 'an'); // France and Germany
        await enter(tester);
        expect(chosen, isNull, reason: 'no option was active');
        expect(text(tester), '', reason: 'strict: a text that names no option goes back');
        expect(find.text('France'), findsNothing, reason: 'Enter closes the panel');

        await type(tester, 'an');
        await key(tester, LogicalKeyboardKey.arrowUp);
        await enter(tester);
        expect(chosen, 'de');

        await type(tester, 'an');
        await key(tester, LogicalKeyboardKey.arrowDown);
        await enter(tester);
        expect(chosen, 'fr');
      },
    );

    testWidgets('a text that names an option, in any case, chooses it on Enter and when focus leaves', (tester) async {
      await tester.pumpWidget(combobox());
      focus.requestFocus();
      await tester.pump();
      await type(tester, 'italy');
      await enter(tester);
      expect((chosen, text(tester)), ('it', 'Italy'));

      await type(tester, ' GERMANY ');
      focus.unfocus();
      await tester.pump();
      expect((chosen, text(tester)), ('de', 'Germany'));
    });

    testWidgets('a press on the field opens every option; an arrow too, on the chosen one', (tester) async {
      await tester.pumpWidget(combobox());
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      for (final label in ['France', 'Germany', 'Italy']) {
        expect(find.text(label), findsOneWidget);
      }
      await tester.tap(find.text('Germany'));
      await tester.pump();
      expect(chosen, 'de');
      expect(find.text('France'), findsNothing);

      await key(tester, LogicalKeyboardKey.arrowDown);
      expect(find.text('France'), findsOneWidget, reason: 'every option, not those matching the label');
      await key(tester, LogicalKeyboardKey.arrowDown);
      await enter(tester);
      expect(chosen, 'it', reason: 'the arrow opened on Germany, the next one is Italy');
    });

    testWidgets('options that change under the active one leave none active: down goes to the first again', (
      tester,
    ) async {
      const apples = [
        ListboxOption(value: 'a1', label: 'Apple one'),
        ListboxOption(value: 'a2', label: 'Apple two'),
        ListboxOption(value: 'a3', label: 'Apple three'),
      ];
      await tester.pumpWidget(combobox(options: apples));
      focus.requestFocus();
      await tester.pump();
      await type(tester, 'apple');
      for (var i = 0; i < 3; i++) {
        await key(tester, LogicalKeyboardKey.arrowDown);
      }
      // results from a server: one is left
      await tester.pumpWidget(combobox(options: apples.sublist(0, 1)));
      await key(tester, LogicalKeyboardKey.arrowDown);
      await enter(tester);
      expect(chosen, 'a1');
    });

    testWidgets('Escape closes, then clears, then passes on to what is around it', (tester) async {
      var dismissed = 0;
      await tester.pumpWidget(
        Actions(
          actions: {DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => dismissed++)},
          child: Shortcuts(
            shortcuts: const {SingleActivator(LogicalKeyboardKey.escape): DismissIntent()},
            child: combobox(),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await type(tester, 'an');
      await key(tester, LogicalKeyboardKey.escape);
      expect((find.text('France').evaluate().isEmpty, text(tester), dismissed), (true, 'an', 0));
      await key(tester, LogicalKeyboardKey.escape);
      expect((text(tester), dismissed), ('', 0));
      await key(tester, LogicalKeyboardKey.escape);
      expect(dismissed, 1, reason: 'nothing to close or clear: a dialog around it closes');
    });

    testWidgets('G5: the results are announced again once options that were loading arrive', (tester) async {
      final announced = <String>[];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (
        message,
      ) async {
        final data = (message as Map<Object?, Object?>)['data'] as Map<Object?, Object?>?;
        if (data?['message'] case final String text) announced.add(text);
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
      );
      await tester.pumpWidget(combobox(loading: true));
      focus.requestFocus();
      await tester.pump();
      await type(tester, 'an');
      await tester.pump(const Duration(milliseconds: 600));
      expect(announced, ['Loading']);
      await tester.pumpWidget(combobox());
      await tester.pump(const Duration(milliseconds: 600));
      expect(announced, ['Loading', '2 results']);
    });
  });
}
