// TextField, TextField.search (DESIGN.md, TextField, Textarea, Search).
// G3: targets. G5: semantics. G6: keyboard. G7, G14: smoke_test.dart.
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

// The field's own box: the first DecoratedBox under it (trailing actions, such as the clear button, are Pressables
// with a DecoratedBox of their own, further down the tree).
BoxDecoration _boxDecoration(WidgetTester tester) =>
    tester
            .widgetList<DecoratedBox>(find.descendant(of: find.byType(TextField), matching: find.byType(DecoratedBox)))
            .first
            .decoration
        as BoxDecoration;

void main() {
  testWidgets('control-md tall, radius-sm, filled, border-strong boundary, the label above, the placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(host(const TextField(label: 'Email', placeholder: 'you@example.com')));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('you@example.com'), findsOneWidget);
    final decoration = _boxDecoration(tester);
    expect(decoration.color, TsuyaColors.light.fill);
    expect(decoration.borderRadius, BorderRadius.circular(TsuyaRadius.sm));
    expect(decoration.border!.top.color, TsuyaColors.light.borderStrong);
    expect(decoration.border!.top.width, 1);
    expect(tester.getSize(find.byType(TextField)).height, greaterThanOrEqualTo(TsuyaSize.controlMd));
  });

  testWidgets('typing updates the controller and calls onChanged; the placeholder then hides', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <String>[];
    await tester.pumpWidget(
      host(TextField(label: 'Name', controller: controller, placeholder: 'Jane', onChanged: changes.add)),
    );
    await tester.enterText(find.byType(EditableText), 'Ada');
    expect(controller.text, 'Ada');
    expect(changes, ['Ada']);
    await tester.pump();
    expect(find.text('Jane'), findsNothing);
  });

  testWidgets('focus turns the boundary to the accent at focus-width; an error turns it to danger', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(host(TextField(label: 'Email', focusNode: focus)));
    focus.requestFocus();
    await tester.pump();
    await tester.pump();
    var decoration = _boxDecoration(tester);
    expect(decoration.border!.top.color, TsuyaColors.light.accent);
    expect(decoration.border!.top.width, TsuyaState.focusWidth);

    await tester.pumpWidget(host(TextField(label: 'Email', focusNode: focus, error: 'Enter a valid email')));
    decoration = _boxDecoration(tester);
    expect(decoration.border!.top.color, TsuyaColors.light.danger);
    expect(decoration.border!.top.width, TsuyaState.focusWidth);
  });

  testWidgets('clearable shows a clear button only while it holds text, and it clears', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <String>[];
    await tester.pumpWidget(
      host(TextField(label: 'Search term', controller: controller, clearable: true, onChanged: changes.add)),
    );
    expect(find.bySemanticsLabel(TsuyaLabels.en.clear), findsNothing);
    controller.text = 'jazz';
    await tester.pump();
    expect(find.bySemanticsLabel(TsuyaLabels.en.clear), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(TsuyaLabels.en.clear));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(changes.last, '');
  });

  testWidgets('obscureText hides the text behind a revealable show/hide button named from the labels', (tester) async {
    await tester.pumpWidget(host(const TextField(label: 'Password', obscureText: true)));
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText, isTrue);
    expect(find.bySemanticsLabel(TsuyaLabels.en.showPassword), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(TsuyaLabels.en.showPassword));
    await tester.pump();
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText, isFalse);
    expect(find.bySemanticsLabel(TsuyaLabels.en.hidePassword), findsOneWidget);
  });

  testWidgets('revealable: false never shows the button', (tester) async {
    await tester.pumpWidget(host(const TextField(label: 'Password', obscureText: true, revealable: false)));
    expect(find.bySemanticsLabel(TsuyaLabels.en.showPassword), findsNothing);
  });

  group('TextField.search', () {
    testWidgets('is a pill with a leading search glyph, a clear button by default, and no visible label', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'jazz');
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(TextField.search(label: 'Search', controller: controller)));
      expect(find.text('Search'), findsNothing);
      final glyphs = tester.widgetList<Glyph>(find.byType(Glyph));
      expect(glyphs.map((g) => g.glyph), contains(TsuyaGlyph.search));
      expect(find.bySemanticsLabel(TsuyaLabels.en.clear), findsOneWidget);
      final decoration = _boxDecoration(tester);
      expect(decoration.borderRadius, BorderRadius.circular(TsuyaSize.controlMd / 2));
    });

    testWidgets('the default size is md, as the web\'s; sm is control-sm', (tester) async {
      await tester.pumpWidget(host(const TextField.search(label: 'Search')));
      expect(_boxDecoration(tester).borderRadius, BorderRadius.circular(TsuyaSize.controlMd / 2));
      await tester.pumpWidget(host(const TextField.search(label: 'Search', size: TextFieldSize.sm)));
      expect(_boxDecoration(tester).borderRadius, BorderRadius.circular(TsuyaSize.controlSm / 2));
    });

    testWidgets('glass uses control glass', (tester) async {
      await tester.pumpWidget(host(const TextField.search(label: 'Search', glass: true)));
      expect(find.byType(ControlGlass), findsOneWidget);
    });

    testWidgets('G5: the label is still read by a screen reader', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(host(const TextField.search(label: 'Search albums')));
      expect(tester.getSemantics(find.byType(TextField)), isSemantics(label: 'Search albums', isTextField: true));
      semantics.dispose();
    });
  });

  testWidgets('G5: label, hint and value are read together; required and invalid are in semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController(text: 'ok');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(TextField(label: 'Email', hint: 'Your work email', controller: controller, required: true)),
    );
    expect(
      tester.getSemantics(find.byType(TextField)),
      isSemantics(isTextField: true, isRequired: true, validationResult: SemanticsValidationResult.none),
    );

    await tester.pumpWidget(
      host(TextField(label: 'Email', error: 'Enter a valid email', controller: controller, required: true)),
    );
    expect(
      tester.getSemantics(find.byType(TextField)),
      isSemantics(isTextField: true, isRequired: true, validationResult: SemanticsValidationResult.invalid),
    );
    semantics.dispose();
  });

  testWidgets('disabled: faded, read-only, not focusable', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(host(TextField(label: 'Email', focusNode: focus, enabled: false)));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, TsuyaState.disabledOpacity);
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isFalse);
  });

  testWidgets('G3: the clear button answers on 44 on touch platforms, 24 with a mouse', (tester) async {
    try {
      for (final (platform, side) in [(TargetPlatform.android, 44.0), (TargetPlatform.macOS, 24.0)]) {
        debugDefaultTargetPlatformOverride = platform;
        // not const: a cached const instance would skip rebuilding when only the ambient platform changes.
        await tester.pumpWidget(host(TextField(label: 'Search', clearable: true, placeholder: 'x')));
        await tester.enterText(find.byType(EditableText), 'jazz');
        await tester.pump();
        expect(tester.getSize(find.bySemanticsLabel(TsuyaLabels.en.clear)), Size(side, side), reason: '$platform');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('the context menu shows Select all once there is text, Copy and Cut once selected', (tester) async {
    final controller = TextEditingController(text: 'hello world');
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(TextField(label: 'Note', controller: controller)));
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    final element = tester.element(find.byType(EditableText));
    final state = tester.state<EditableTextState>(find.byType(EditableText));

    // Built eagerly, while the field's element is still active: the returned tree holds no live BuildContext.
    Widget menu(Element element, EditableTextState state) =>
        tester.widget<EditableText>(find.byType(EditableText)).contextMenuBuilder!(element, state);
    final collapsed = menu(element, state);
    await tester.pumpWidget(host(collapsed));
    expect(find.text(TsuyaLabels.en.selectAll), findsOneWidget);
    expect(find.text(TsuyaLabels.en.copy), findsNothing);

    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
    await tester.pumpWidget(host(TextField(label: 'Note', controller: controller)));
    final selected = menu(
      tester.element(find.byType(EditableText)),
      tester.state<EditableTextState>(find.byType(EditableText)),
    );
    await tester.pumpWidget(host(selected));
    expect(find.text(TsuyaLabels.en.copy), findsOneWidget);
    expect(find.text(TsuyaLabels.en.cut), findsOneWidget);
  });
}
