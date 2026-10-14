// Section (DESIGN.md, List, ListItem, Section).
// G5: semantics (the label groups its rows, announced to assistive technology).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  testWidgets('hairlines separate a row from the one before it, not from the label', (tester) async {
    await tester.pumpWidget(
      host(
        const Section(
          label: 'Network',
          children: [
            ListItem(title: 'Wi-Fi'),
            ListItem(title: 'Bluetooth'),
            ListItem(title: 'Hotspot'),
          ],
        ),
      ),
    );
    // three rows: two hairlines between them, none above the first or below the last
    expect(find.byType(ColoredBox), findsNWidgets(2));
    for (final hairline in tester.widgetList<ColoredBox>(find.byType(ColoredBox))) {
      expect(hairline.color, TsuyaColors.light.border);
    }
  });

  testWidgets('a single row needs no hairline', (tester) async {
    await tester.pumpWidget(
      host(
        const Section(
          label: 'Network',
          children: [ListItem(title: 'Wi-Fi')],
        ),
      ),
    );
    expect(find.byType(ColoredBox), findsNothing);
  });

  testWidgets('the label: uppercase, label style, text-muted, space-24 above and space-8 below', (tester) async {
    await tester.pumpWidget(
      host(
        const Section(
          label: 'Network',
          children: [ListItem(title: 'Wi-Fi')],
        ),
      ),
    );
    final text = tester.widget<Text>(find.text('NETWORK'));
    expect(text.style!.fontSize, TsuyaType.label.fontSize);
    expect(text.style!.color, TsuyaColors.light.textMuted);
    final padding = tester.widget<Padding>(
      find.ancestor(of: find.text('NETWORK'), matching: find.byType(Padding)).first,
    );
    expect(padding.padding.resolve(TextDirection.ltr).top, TsuyaSpace.s24);
    expect(padding.padding.resolve(TextDirection.ltr).bottom, TsuyaSpace.s8);
  });

  testWidgets('G5: the label is announced, each row keeping its own node', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Section(
          label: 'Network',
          children: const [
            ListItem(key: Key('wifi'), title: 'Wi-Fi'),
            ListItem(key: Key('bt'), title: 'Bluetooth'),
          ],
        ),
      ),
    );
    expect(tester.getSemantics(find.byType(Section)), isSemantics(label: 'Network'));
    expect(tester.getSemantics(find.byKey(const Key('wifi'))), isSemantics(label: 'Wi-Fi'));
    expect(tester.getSemantics(find.byKey(const Key('bt'))), isSemantics(label: 'Bluetooth'));
    semantics.dispose();
  });
}
