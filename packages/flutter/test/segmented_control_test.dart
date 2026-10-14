// SegmentedControl (DESIGN.md, SegmentedControl).
// G3: targets. G5: semantics. G6: keyboard. G7: text scale. G9, G14: smoke_test.dart.
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

const _segments = [Segment(value: 'list', label: 'List'), Segment(value: 'grid', label: 'Grid')];

Container _track(WidgetTester tester) => tester.widgetList<Container>(find.byType(Container)).first;

AnimatedContainer _segment(WidgetTester tester, int index) =>
    tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).elementAt(index);

Finder _row(String label) => find.ancestor(of: find.text(label), matching: find.byType(Pressable));

void main() {
  testWidgets('the track is fill with a hairline; an unselected segment shows its label in text-muted', (tester) async {
    await tester.pumpWidget(
      host(SegmentedControl<String>(label: 'View', segments: _segments, selected: 'list', onChanged: (_) {})),
    );
    final track = _track(tester);
    expect((track.decoration! as BoxDecoration).color, TsuyaColors.light.fill);
    expect((track.foregroundDecoration! as BoxDecoration).border!.top.color, TsuyaColors.light.border);

    final unselected = _segment(tester, 1);
    expect((unselected.decoration! as BoxDecoration).color, isNull);
    expect((unselected.decoration! as BoxDecoration).boxShadow, isNull);
    expect(tester.widget<Text>(find.text('Grid')).style!.color, TsuyaColors.light.textMuted);
  });

  testWidgets('the selected segment is fill-selected with a shadow, in text', (tester) async {
    await tester.pumpWidget(
      host(SegmentedControl<String>(label: 'View', segments: _segments, selected: 'list', onChanged: (_) {})),
    );
    final selected = _segment(tester, 0);
    expect((selected.decoration! as BoxDecoration).color, TsuyaColors.light.fillSelected);
    expect((selected.decoration! as BoxDecoration).boxShadow, TsuyaShadows.light.sm);
    expect(tester.widget<Text>(find.text('List')).style!.color, TsuyaColors.light.text);
  });

  testWidgets('an icon-only segment shows only the icon, labelled for screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        SegmentedControl<String>(
          label: 'View',
          segments: [
            Segment(
              value: 'list',
              label: 'List',
              icon: const SizedBox(key: Key('icon'), width: 4, height: 4),
            ),
            const Segment(value: 'grid', label: 'Grid'),
          ],
          selected: 'list',
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.text('List'), findsNothing);
    expect(find.byKey(const Key('icon')), findsOneWidget);
    final iconSegment = find.ancestor(of: find.byKey(const Key('icon')), matching: find.byType(Pressable));
    expect(tester.getSemantics(iconSegment), isSemantics(label: 'List', isChecked: true));
    semantics.dispose();
  });

  testWidgets('expand shares the width between segments; otherwise each hugs its content', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: SegmentedControl<String>(
              label: 'View',
              segments: _segments,
              selected: 'list',
              onChanged: (_) {},
              expand: true,
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(SegmentedControl<String>)).width, 300);

    await tester.pumpWidget(
      host(
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: SegmentedControl<String>(label: 'View', segments: _segments, selected: 'list', onChanged: (_) {}),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(SegmentedControl<String>)).width, lessThan(300));
  });

  testWidgets('tapping a segment selects it', (tester) async {
    String value = 'list';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => SegmentedControl<String>(
            label: 'View',
            segments: _segments,
            selected: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Grid'));
    await tester.pump();
    expect(value, 'grid');
  });

  testWidgets('G6: arrow keys both move and select, as native radios do', (tester) async {
    String value = 'list';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => SegmentedControl<String>(
            label: 'View',
            segments: _segments,
            selected: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    Focus.of(tester.element(find.text('List'))).requestFocus();
    await tester.pump();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    await tester.pump();
    expect(value, 'grid');
  });

  testWidgets('G5: the group is a radio group named by its label; each segment is one radio of it', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(SegmentedControl<String>(label: 'View', segments: _segments, selected: 'list', onChanged: (_) {})),
    );
    expect(tester.getSemantics(find.byType(SegmentedControl<String>)), isSemantics(label: 'View'));
    expect(tester.getSemantics(find.byType(SegmentedControl<String>)).role, SemanticsRole.radioGroup);
    expect(
      tester.getSemantics(_row('List')),
      isSemantics(
        label: 'List',
        isButton: false,
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('G3: each segment grows under a touch target floor', (tester) async {
    try {
      for (final platform in [TargetPlatform.android, TargetPlatform.macOS]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          host(
            Center(
              child: SegmentedControl<String>(label: 'View', segments: _segments, selected: 'list', onChanged: (_) {}),
            ),
          ),
        );
        expect(tester.getSize(_row('List')).height, greaterThanOrEqualTo(24.0), reason: '$platform');
      }
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('G7: at 300 % and 280 px wide, four labels share the width and wrap, never overflow or clip', (
    tester,
  ) async {
    await tester.runAsync(loadTsuyaFonts);
    const labels = ['Day', 'Week', 'Month', 'Quarter'];
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 280,
            child: SegmentedControl<String>(
              label: 'Range',
              segments: [for (final l in labels) Segment(value: l, label: l)],
              selected: 'Day',
              onChanged: (_) {},
            ),
          ),
        ),
        size: const Size(280, 800),
        textScale: 3,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SegmentedControl<String>)).width, lessThanOrEqualTo(280));
    final track = tester.getRect(find.byType(SegmentedControl<String>));
    for (final label in labels) {
      // each label sits whole inside its segment, which is inside the track
      final text = tester.getRect(find.text(label));
      final segment = tester.getRect(_row(label));
      expect(segment.left, greaterThanOrEqualTo(track.left), reason: label);
      expect(segment.right, lessThanOrEqualTo(track.right), reason: label);
      expect(text.left, greaterThanOrEqualTo(segment.left), reason: label);
      expect(text.right, lessThanOrEqualTo(segment.right), reason: label);
      // wrapped labels grow their segment, and the others grow with it
      expect(segment.height, tester.getSize(_row('Quarter')).height, reason: label);
    }
  });

  testWidgets('expand keeps a word whole while another segment has room to spare', (tester) async {
    await tester.runAsync(loadTsuyaFonts);
    const labels = ['Day', 'Week', 'Month', 'Year', 'All'];
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 350,
            child: SegmentedControl<String>(
              label: 'Range',
              expand: true,
              segments: [for (final l in labels) Segment(value: l, label: l)],
              selected: 'Week',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SegmentedControl<String>)).width, 350);
    for (final label in labels) {
      // one line, neither broken nor ellipsized
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      expect(paragraph.didExceedMaxLines, isFalse, reason: label);
      expect(paragraph.size.height, tester.getSize(find.text('Day')).height, reason: label);
    }
  });
}
