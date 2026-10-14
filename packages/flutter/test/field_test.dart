// Field (DESIGN.md, Field).
// G5: semantics. G7, G14: smoke_test.dart.
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  testWidgets('the label sits above the control, the hint under it', (tester) async {
    const controlKey = Key('control');
    await tester.pumpWidget(
      host(
        const Field(
          label: 'Email',
          hint: 'Your work email',
          child: SizedBox(key: controlKey, height: 44, width: 200),
        ),
      ),
    );
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Your work email'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Email')).dy, lessThan(tester.getTopLeft(find.byKey(controlKey)).dy));
  });

  testWidgets('an error replaces the hint and shows the alert glyph, in danger', (tester) async {
    await tester.pumpWidget(
      host(
        const Field(label: 'Email', hint: 'Your work email', error: 'Enter a valid email', child: SizedBox(height: 44)),
      ),
    );
    expect(find.text('Your work email'), findsNothing);
    expect(find.text('Enter a valid email'), findsOneWidget);
    final glyph = tester.widget<Glyph>(find.byType(Glyph));
    expect(glyph.glyph, TsuyaGlyph.alert);
    expect(glyph.color, TsuyaColors.light.danger);
  });

  testWidgets('optional appends its marker after one space, at normal weight, in one run of text', (tester) async {
    await tester.pumpWidget(host(const Field(label: 'Nickname', optional: true, child: SizedBox(height: 44))));
    final label = tester.widget<Text>(find.descendant(of: find.byType(FieldLabel), matching: find.byType(Text)));
    expect(label.textSpan!.toPlainText(), 'Nickname Optional');
    final optionalSpan = (label.textSpan! as TextSpan).children!.single as TextSpan;
    expect(optionalSpan.text, ' Optional');
    expect(optionalSpan.style!.fontWeight, FontWeight.w400);
  });

  testWidgets('G5: isRequired and validationResult are wired, read with the control', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const Field(
          label: 'Email',
          required: true,
          child: SizedBox(height: 44, child: Text('value')),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(Field)),
      isSemantics(label: 'Email\nvalue', isRequired: true, validationResult: SemanticsValidationResult.none),
    );

    await tester.pumpWidget(
      host(
        const Field(
          label: 'Email',
          error: 'Required',
          child: SizedBox(height: 44, child: Text('value')),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(Field)),
      isSemantics(label: 'Email\nvalue\nRequired', validationResult: SemanticsValidationResult.invalid),
    );
    semantics.dispose();
  });
}
