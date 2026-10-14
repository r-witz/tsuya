// Tabs (DESIGN.md, Tabs).
// G3: targets. G5: semantics. G6: keyboard. G9: reduced motion. G13: spec values. G14: right-to-left.
// G7: smoke_test.dart.

import 'dart:ui' show Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

const _tabs = [
  TabItem(value: 'overview', label: 'Overview'),
  TabItem(value: 'reviews', label: 'Reviews'),
  TabItem(value: 'details', label: 'Details'),
];

Finder _tab(String label) => find.ancestor(of: find.text(label), matching: find.byType(Pressable));

Rect _barRect(WidgetTester tester) {
  final positioned = tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned));
  return Rect.fromLTWH(positioned.left!, positioned.top!, positioned.width!, positioned.height!);
}

void main() {
  testWidgets('the first tab is selected while there is no value; text-muted, text, same weight', (tester) async {
    await tester.pumpWidget(host(Tabs<String>(label: 'Product', tabs: _tabs, selected: null, onChanged: (_) {})));
    expect(tester.getSize(_tab('Overview')).height, TsuyaSize.controlMd);
    final overview = tester.widget<Text>(find.text('Overview')).style!;
    final reviews = tester.widget<Text>(find.text('Reviews')).style!;
    expect(overview.fontWeight, reviews.fontWeight, reason: 'only the colour marks the selected tab, not the weight');
    expect(overview.color, TsuyaColors.light.text);
    expect(reviews.color, TsuyaColors.light.textMuted);
  });

  testWidgets('a 2 px accent bar slides under the selected tab', (tester) async {
    var selected = 'overview';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Tabs<String>(
            label: 'Product',
            tabs: _tabs,
            selected: selected,
            onChanged: (v) => setState(() => selected = v),
          ),
        ),
        animate: true,
      ),
    );
    await tester.pump();
    expect(find.byType(AnimatedPositioned), findsOneWidget);
    expect(_barRect(tester).height, 2);
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(of: find.byType(AnimatedPositioned), matching: find.byType(DecoratedBox)),
                )
                .decoration
            as BoxDecoration;
    expect(decoration.color, TsuyaColors.light.accent);
    final overviewWidth = tester.getSize(_tab('Overview')).width;
    expect(_barRect(tester).width, overviewWidth);

    await tester.tap(_tab('Reviews'));
    await tester.pump();
    // mid-flight: not yet at the Reviews tab's width
    final reviewsWidth = tester.getSize(_tab('Reviews')).width;
    expect(_barRect(tester).width, isNot(reviewsWidth));
    await tester.pumpAndSettle();
    expect(_barRect(tester).width, reviewsWidth);
  });

  testWidgets('reduced motion: the bar reaches the new tab without running the sliding animation', (tester) async {
    var selected = 'overview';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Tabs<String>(
            label: 'Product',
            tabs: _tabs,
            selected: selected,
            onChanged: (v) => setState(() => selected = v),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(_tab('Details'));
    // one frame rebuilds with the new selection and schedules the measurement; a second applies it: with
    // TsuyaDuration.fast reduced to zero, that is already the final frame (no animation keeps it mid-flight).
    await tester.pump();
    await tester.pump();
    expect(_barRect(tester).width, tester.getSize(_tab('Details')).width);
  });

  testWidgets('one tab stop; arrows select and wrap; Home and End; a disabled tab is skipped', (tester) async {
    String value = 'overview';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Tabs<String>(
            label: 'Product',
            tabs: const [
              TabItem(value: 'overview', label: 'Overview'),
              TabItem(value: 'reviews', label: 'Reviews', disabled: true),
              TabItem(value: 'details', label: 'Details'),
            ],
            selected: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    Focus.of(tester.element(find.text('Overview'))).requestFocus();
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Details'))).hasFocus, isTrue, reason: 'Reviews is disabled: skipped');
    expect(value, 'details');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Overview'))).hasFocus, isTrue, reason: 'wraps, skipping Reviews again');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Details'))).hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Overview'))).hasFocus, isTrue);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Focus && (w.focusNode?.debugLabel ?? '').startsWith('roving') && w.focusNode?.skipTraversal == false,
      ),
      findsOneWidget,
    );
  });

  testWidgets('manual: arrows move focus only, Enter selects; a press selects', (tester) async {
    String? value;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Tabs<String>(
            label: 'Product',
            tabs: _tabs,
            selected: value,
            onChanged: (v) => setState(() => value = v),
            manual: true,
          ),
        ),
      ),
    );
    Focus.of(tester.element(find.text('Overview'))).requestFocus();
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Reviews'))).hasFocus, isTrue);
    expect(value, isNull, reason: 'manual: moving focus does not select');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(value, 'reviews');

    await tester.tap(_tab('Details'));
    await tester.pump();
    expect(value, 'details');
  });

  testWidgets('right to left, the arrows follow the visual order', (tester) async {
    String? value;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) =>
              Tabs<String>(label: 'Product', tabs: _tabs, selected: value, onChanged: (v) => setState(() => value = v)),
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(tester.getTopLeft(_tab('Overview')).dx, greaterThan(tester.getTopLeft(_tab('Reviews')).dx));
    Focus.of(tester.element(find.text('Overview'))).requestFocus();
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    await tester.pump();
    expect(Focus.of(tester.element(find.text('Reviews'))).hasFocus, isTrue);
  });

  testWidgets('G5: a tab list named by its label; each tab announces selected; the panel is named and role tabPanel', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Column(
          children: [
            Tabs<String>(label: 'Product', tabs: _tabs, selected: 'overview', onChanged: (_) {}),
            const TabView<String>(
              value: 'overview',
              selected: 'overview',
              label: 'Overview',
              child: Text('The overview of the product.'),
            ),
          ],
        ),
      ),
    );
    final list = tester.getSemantics(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.role == SemanticsRole.tabBar),
    );
    expect(list.label, 'Product');
    expect(list.role, SemanticsRole.tabBar);
    final overview = tester.getSemantics(_tab('Overview'));
    expect(overview.role, SemanticsRole.tab);
    expect(overview.flagsCollection.isSelected, Tristate.isTrue);
    final reviews = tester.getSemantics(_tab('Reviews'));
    expect(reviews.flagsCollection.isSelected, Tristate.isFalse);
    final panel = tester.getSemantics(find.byType(TabView<String>));
    expect(panel.role, SemanticsRole.tabPanel);
    expect(panel.label, 'Overview');
    semantics.dispose();
  });

  testWidgets('a disabled tab is not pressable and excluded from the tab order', (tester) async {
    await tester.pumpWidget(
      host(
        Tabs<String>(
          label: 'Product',
          tabs: const [
            TabItem(value: 'overview', label: 'Overview'),
            TabItem(value: 'reviews', label: 'Reviews', disabled: true),
          ],
          selected: 'overview',
          onChanged: (_) {},
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    expect(tester.getSemantics(_tab('Reviews')).flagsCollection.isEnabled, Tristate.isFalse);
    semantics.dispose();
  });

  testWidgets('a hidden TabView builds nothing', (tester) async {
    await tester.pumpWidget(
      host(const TabView<String>(value: 'reviews', selected: 'overview', label: 'Reviews', child: Text('Hidden'))),
    );
    expect(find.text('Hidden'), findsNothing);
  });

  testWidgets('G3: each tab grows under a touch target floor', (tester) async {
    try {
      for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          host(Tabs<String>(label: 'Product', tabs: _tabs, selected: 'overview', onChanged: (_) {})),
        );
        expect(tester.getSize(_tab('Overview')).height, greaterThanOrEqualTo(24.0), reason: '$platform');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  // Tabs (DESIGN.md, Tabs): the selection the app owns (scroll, tab stop, onChanged).
  // G6: keyboard. G9: reduced motion.
  testWidgets('a rebuild with the same selection does not scroll the row back to the selected tab', (tester) async {
    final many = [for (var i = 0; i < 12; i++) TabItem(value: 'tab$i', label: 'Tab number $i')];
    Widget row() => host(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 300,
          child: Tabs<String>(label: 'Many', tabs: many, selected: 'tab0', onChanged: (_) {}),
        ),
      ),
    );
    await tester.pumpWidget(row());
    await tester.pump();
    final position = tester.state<ScrollableState>(find.byType(Scrollable)).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();
    expect(position.pixels, greaterThan(0));
    final scrolled = position.pixels;
    await tester.pumpWidget(row());
    await tester.pump();
    await tester.pump();
    expect(position.pixels, scrolled);
  });

  testWidgets('when the app changes the selection, the tab stop follows it', (tester) async {
    Widget row(String selected) =>
        host(Tabs<String>(label: 'Product', tabs: _tabs, selected: selected, onChanged: (_) {}));
    await tester.pumpWidget(row('overview'));
    await tester.pumpWidget(row('details'));
    await tester.pump();
    final stops = tester
        .widgetList<Focus>(find.byType(Focus))
        .map((w) => w.focusNode)
        .where((n) => (n?.debugLabel ?? '').startsWith('roving') && n?.skipTraversal == false);
    expect(stops.map((n) => n!.debugLabel), ['roving 2']);
  });

  testWidgets('a selection the app makes itself does not call onChanged back', (tester) async {
    var calls = 0;
    Widget row(String selected) =>
        host(Tabs<String>(label: 'Product', tabs: _tabs, selected: selected, onChanged: (_) => calls++));
    await tester.pumpWidget(row('overview'));
    await tester.pumpWidget(row('details'));
    await tester.pump();
    await tester.pump();
    expect(calls, 0);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
    testWidgets('a press on another tab calls onChanged once ($platform)', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        var selected = 'overview';
        final calls = <String>[];
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, setState) => Tabs<String>(
                label: 'Product',
                tabs: _tabs,
                selected: selected,
                onChanged: (v) => setState(() {
                  calls.add(v);
                  selected = v;
                }),
              ),
            ),
          ),
        );
        await tester.tap(_tab('Reviews'));
        await tester.pump();
        await tester.pump();
        await tester.pump();
        expect(calls, ['reviews']);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  List<String?> stops() => [
    for (final n in FocusManager.instance.rootScope.traversalDescendants)
      if (n.debugLabel != 'View Scope') n.debugLabel,
  ];

  testWidgets('a tab appended and selected at once becomes the tab stop', (tester) async {
    var tabs = _tabs;
    var selected = 'overview';
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return Tabs<String>(label: 'T', tabs: tabs, selected: selected, onChanged: (v) {});
          },
        ),
      ),
    );
    set(() {
      tabs = [...tabs, const TabItem(value: 'extra', label: 'Extra')];
      selected = 'extra';
    });
    await tester.pump();
    await tester.pump();
    expect(stops(), ['roving 3']);
  });

  testWidgets('a focused tab keeps its focus when a tab is appended', (tester) async {
    var tabs = _tabs;
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return Tabs<String>(label: 'T', tabs: tabs, selected: 'overview', onChanged: (v) {});
          },
        ),
      ),
    );
    Focus.of(tester.element(find.text('Overview'))).requestFocus();
    await tester.pump();
    set(() => tabs = [...tabs, const TabItem(value: 'extra', label: 'Extra')]);
    await tester.pump();
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'roving 0');
  });
}
