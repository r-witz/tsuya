// Accordion (DESIGN.md, Accordion).
// G5: semantics. G6: keyboard. G13: spec values. G7, G9, G14: smoke_test.dart.
import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

List<AccordionItemData> _items({bool disabledWarranty = false}) => [
  const AccordionItemData(value: 'shipping', label: 'Shipping', content: Text('Ships in 2 days.')),
  const AccordionItemData(value: 'returns', label: 'Returns', content: Text('Start a return')),
  AccordionItemData(value: 'warranty', label: 'Warranty', content: const Text('One year.'), disabled: disabledWarranty),
];

Finder _header(String label) => find.ancestor(of: find.text(label), matching: find.byType(Pressable));

void main() {
  testWidgets('a header is a button in a heading, at least row tall, body-strong, a chevron in text-muted', (
    tester,
  ) async {
    await tester.pumpWidget(host(Accordion(items: _items(), value: const [], onChanged: (_) {})));
    expect(tester.getSize(_header('Shipping')).height, greaterThanOrEqualTo(TsuyaSize.row));
    final style = tester.widget<Text>(find.text('Shipping')).style!;
    expect(style.fontWeight, TsuyaType.bodyStrong.fontWeight);
    expect(style.color, TsuyaColors.light.text);
    final chevron = tester.widget<Glyph>(find.descendant(of: _header('Shipping'), matching: find.byType(Glyph)));
    expect(chevron.size, TsuyaSize.iconSm);
    expect(chevron.color, TsuyaColors.light.textMuted);
    // a hairline between rows, none before the first
    expect(find.byType(ColoredBox), findsNWidgets(2));
  });

  testWidgets('single: opening one closes the other; a press on the open one closes it', (tester) async {
    var value = <String>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              Accordion(items: _items(), value: value, onChanged: (v) => setState(() => value = v)),
        ),
      ),
    );
    await tester.tap(_header('Shipping'));
    await tester.pump();
    expect(value, ['shipping']);
    expect(find.text('Ships in 2 days.'), findsOneWidget);

    await tester.tap(_header('Returns'));
    await tester.pump();
    expect(value, ['returns']);

    await tester.tap(_header('Returns'));
    await tester.pump();
    expect(value, isEmpty);
  });

  testWidgets('multiple: several stay open; a disabled row does not toggle', (tester) async {
    var value = <String>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Accordion(
            items: _items(disabledWarranty: true),
            multiple: true,
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.tap(_header('Shipping'));
    await tester.pump();
    await tester.tap(_header('Returns'));
    await tester.pump();
    expect(value, ['shipping', 'returns']);
    await tester.tap(_header('Warranty'));
    await tester.pump();
    expect(value, ['shipping', 'returns'], reason: 'Warranty is disabled');
  });

  testWidgets('Enter and Space toggle a focused header', (tester) async {
    var value = <String>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              Accordion(items: _items(), multiple: true, value: value, onChanged: (v) => setState(() => value = v)),
        ),
      ),
    );
    Focus.of(tester.element(find.text('Shipping'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(value, ['shipping']);
    Focus.of(tester.element(find.text('Returns'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(value, ['shipping', 'returns']);
  });

  testWidgets(
    'the chevron turns over while open; the content is padded 16 and animates, at once under reduced motion',
    (tester) async {
      var value = <String>[];
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) =>
                Accordion(items: _items(), value: value, onChanged: (v) => setState(() => value = v)),
          ),
          animate: true,
        ),
      );
      await tester.tap(_header('Shipping'));
      await tester.pumpAndSettle();
      final chevron = tester.widget<AnimatedRotation>(
        find.descendant(of: _header('Shipping'), matching: find.byType(AnimatedRotation)),
      );
      expect(chevron.turns, 0.5);
      final padding = tester.widget<Padding>(
        find.ancestor(of: find.text('Ships in 2 days.'), matching: find.byType(Padding)).first,
      );
      expect(padding.padding, const EdgeInsets.all(TsuyaSpace.s16));
      final sizeTransition = tester.widget<SizeTransition>(find.byType(SizeTransition));
      expect(sizeTransition.sizeFactor.value, 1);

      await tester.tap(_header('Shipping'));
      await tester.pump();
      expect(find.byType(SizeTransition), findsOneWidget, reason: 'still mounted mid-exit');
      await tester.pumpAndSettle();
      expect(find.text('Ships in 2 days.'), findsNothing, reason: 'unmounted once closed');
    },
  );

  testWidgets('reduced motion: a press closes the row without an exit animation lingering', (tester) async {
    var value = ['shipping'];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              Accordion(items: _items(), value: value, onChanged: (v) => setState(() => value = v)),
        ),
      ),
    );
    await tester.tap(_header('Shipping'));
    await tester.pump();
    expect(find.text('Ships in 2 days.'), findsNothing);
  });

  testWidgets('G5: a header is read once, not by both its heading and its button', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Accordion(items: _items(), value: const [], onChanged: (_) {})));
    final heading = tester.getSemantics(
      find.ancestor(
        of: find.text('Shipping'),
        matching: find.byWidgetPredicate((w) => w is Semantics && w.properties.headingLevel == 3),
      ),
    );
    final labels = <String>[];
    void collect(SemanticsNode node) {
      if (node.label.isNotEmpty) labels.add(node.label);
      node.visitChildren((child) {
        collect(child);
        return true;
      });
    }

    collect(heading);
    expect(labels.where((l) => l.contains('Shipping')), hasLength(1), reason: 'labels: $labels');
    semantics.dispose();
  });

  testWidgets('G5: a header announces expanded; the open region is named by it', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Accordion(items: _items(), value: const ['shipping'], onChanged: (_) {})));
    final header = tester.getSemantics(_header('Shipping'));
    expect(header.flagsCollection.isExpanded, Tristate.isTrue);
    final heading = tester.getSemantics(
      find.ancestor(
        of: find.text('Shipping'),
        matching: find.byWidgetPredicate((w) => w is Semantics && w.properties.headingLevel == 3),
      ),
    );
    expect(heading.label, 'Shipping');
    final region = tester.getSemantics(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.role == SemanticsRole.region),
    );
    expect(region.label, 'Shipping');
    final collapsedHeader = tester.getSemantics(_header('Returns'));
    expect(collapsedHeader.flagsCollection.isExpanded, Tristate.isFalse);
    semantics.dispose();
  });

  testWidgets('G5: a disabled header is announced disabled, not removed', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Accordion(items: _items(disabledWarranty: true), value: const [], onChanged: (_) {})));
    expect(tester.getSemantics(_header('Warranty')).flagsCollection.isEnabled, Tristate.isFalse);
    semantics.dispose();
  });

  testWidgets('the pressed and hover highlight fills the whole row-tall header', (tester) async {
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: Accordion(
            value: const [],
            onChanged: (_) {},
            items: const [AccordionItemData(value: 'a', label: 'Shipping', content: Text('x'))],
          ),
        ),
      ),
    );
    final press = tester.getSize(find.byType(Pressable));
    final box = find.descendant(of: find.byType(Pressable), matching: find.byType(DecoratedBox)).first;
    expect(press.height, TsuyaSize.row);
    expect(tester.getSize(box).height, press.height);
  });

  testWidgets('a disabled header is not a tab stop, like a native disabled button', (tester) async {
    await tester.pumpWidget(
      host(
        Accordion(
          value: const [],
          onChanged: (_) {},
          items: const [
            AccordionItemData(value: 'a', label: 'Alpha', content: Text('x'), disabled: true),
            AccordionItemData(value: 'b', label: 'Beta', content: Text('y')),
          ],
        ),
      ),
    );
    final stops = [
      for (final n in FocusManager.instance.rootScope.traversalDescendants)
        if (n.debugLabel != 'View Scope') n,
    ];
    expect(stops, hasLength(1));
  });
}
