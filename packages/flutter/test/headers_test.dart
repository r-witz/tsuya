// PageHeader and SectionHeader (DESIGN.md, PageHeader, SectionHeader).
// G5: semantics. G7: text scale. G9, G14: smoke_test.dart.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  group('PageHeader', () {
    testWidgets('the title, and the count line space-8 below, muted', (tester) async {
      await tester.pumpWidget(host(const PageHeader(title: 'Recently Added', subtitle: '412 albums · 3 208 tracks')));
      expect(tester.widget<Text>(find.text('Recently Added')).style!.color, TsuyaColors.light.text);
      final subtitle = tester.widget<Text>(find.text('412 albums · 3 208 tracks'));
      expect(subtitle.style!.color, TsuyaColors.light.textMuted);
      expect(subtitle.style!.fontSize, TsuyaType.small.fontSize);
      expect(tester.widgetList<SizedBox>(find.byType(SizedBox)).map((box) => box.height), contains(TsuyaSpace.s8));
    });

    testWidgets('display-s on phone, display-m from the desktop breakpoint', (tester) async {
      viewAt(tester, const Size(390, 800));
      await tester.pumpWidget(host(const PageHeader(title: 'Recently Added'), size: const Size(390, 800)));
      expect(tester.widget<Text>(find.text('Recently Added')).style!.fontSize, TsuyaType.displayS.fontSize);

      viewAt(tester, const Size(1024, 800));
      await tester.pumpWidget(host(const PageHeader(title: 'Recently Added'), size: const Size(1024, 800)));
      expect(tester.widget<Text>(find.text('Recently Added')).style!.fontSize, TsuyaType.displayM.fontSize);
    });

    testWidgets('the breakpoint is the header\'s container, not the window (DESIGN.md, Layout)', (tester) async {
      viewAt(tester, const Size(1440, 900));
      Widget boxed(double width) => host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: const PageHeader(title: 'Recently Added'),
          ),
        ),
        size: const Size(1440, 900),
      );
      await tester.pumpWidget(boxed(600));
      expect(tester.widget<Text>(find.text('Recently Added')).style!.fontSize, TsuyaType.displayS.fontSize);
      await tester.pumpWidget(boxed(1100));
      expect(tester.widget<Text>(find.text('Recently Added')).style!.fontSize, TsuyaType.displayM.fontSize);
    });

    testWidgets('large: display-l from the desktop breakpoint, still display-s on phone', (tester) async {
      viewAt(tester, const Size(390, 800));
      await tester.pumpWidget(host(const PageHeader(title: 'Recently Added', large: true), size: const Size(390, 800)));
      expect(tester.widget<Text>(find.text('Recently Added')).style!.fontSize, TsuyaType.displayS.fontSize);

      viewAt(tester, const Size(1024, 800));
      await tester.pumpWidget(
        host(const PageHeader(title: 'Recently Added', large: true), size: const Size(1024, 800)),
      );
      expect(tester.widget<Text>(find.text('Recently Added')).style!.fontSize, TsuyaType.displayL.fontSize);
    });

    testWidgets('actions sit beside the title when wide, wrap under it when narrow', (tester) async {
      // the real available width comes from the render tree, not from MediaQueryData.size (which only drives the
      // header's own display-s/m/l breakpoint): a real, wide test surface plus an explicit SizedBox constrain the
      // Wrap itself.
      tester.view.physicalSize = const Size(2000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Widget subject(double width) => SizedBox(
        width: width,
        child: PageHeader(
          title: 'Recently Added',
          actions: const SizedBox(key: Key('actions'), width: 250, height: 44),
        ),
      );
      await tester.pumpWidget(host(Center(child: subject(320))));
      final narrowHeadingBottom = tester.getBottomLeft(find.text('Recently Added')).dy;
      final narrowActionsTop = tester.getTopLeft(find.byKey(const Key('actions'))).dy;
      expect(narrowActionsTop, greaterThanOrEqualTo(narrowHeadingBottom));

      await tester.pumpWidget(host(Center(child: subject(900))));
      final wideHeadingBottom = tester.getBottomLeft(find.text('Recently Added')).dy;
      final wideActionsTop = tester.getTopLeft(find.byKey(const Key('actions'))).dy;
      expect(wideActionsTop, lessThan(wideHeadingBottom));
    });
  });

  group('SectionHeader', () {
    testWidgets('title-l title, a muted control count', (tester) async {
      await tester.pumpWidget(host(const SectionHeader(title: 'Albums', count: '24')));
      final title = tester.widget<Text>(find.text('Albums'));
      expect(title.style!.fontSize, TsuyaType.titleL.fontSize);
      expect(title.style!.color, TsuyaColors.light.text);
      final count = tester.widget<Text>(find.text('24'));
      expect(count.style!.fontSize, TsuyaType.control.fontSize);
      expect(count.style!.color, TsuyaColors.light.textMuted);
    });

    testWidgets('a ghost, sm action at the end', (tester) async {
      await tester.pumpWidget(host(const SectionHeader(title: 'Albums', actionLabel: 'See all')));
      final button = tester.widget<Button>(find.byType(Button));
      expect(button.kind, ButtonKind.ghost);
      expect(button.size, ButtonSize.sm);
    });

    testWidgets('margins: space-32 above, space-12 below', (tester) async {
      await tester.pumpWidget(host(const SectionHeader(title: 'Albums')));
      final padding = tester.widget<Padding>(
        find.ancestor(of: find.text('Albums'), matching: find.byType(Padding)).first,
      );
      expect(padding.padding.resolve(TextDirection.ltr).top, TsuyaSpace.s32);
      expect(padding.padding.resolve(TextDirection.ltr).bottom, TsuyaSpace.s12);
    });

    testWidgets('without a count or an action, neither shows', (tester) async {
      await tester.pumpWidget(host(const SectionHeader(title: 'Playlists')));
      expect(find.byType(Button), findsNothing);
      expect(tester.widgetList<Text>(find.byType(Text)), hasLength(1));
    });

    testWidgets('a press on the action calls onAction', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        host(SectionHeader(title: 'Albums', actionLabel: 'See all', onAction: () => pressed = true)),
      );
      await tester.tap(find.text('See all'));
      expect(pressed, isTrue);
    });

    testWidgets('the action sits at the end edge, whatever the title and count', (tester) async {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          host(
            const Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                child: SectionHeader(title: 'Albums', count: '24', actionLabel: 'See all'),
              ),
            ),
            direction: direction,
          ),
        );
        final action = tester.getRect(find.ancestor(of: find.text('See all'), matching: find.byType(Button)));
        expect(direction == TextDirection.ltr ? 600 - action.right : action.left, 0, reason: '$direction');
      }
    });

    testWidgets('G7: on a 320 screen at 300 %, a title, a count and an action stay whole, the action under', (
      tester,
    ) async {
      await tester.runAsync(loadTsuyaFonts);
      viewAt(tester, const Size(320, 800));
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topLeft,
            // 320 less the 16 px gutters
            child: SizedBox(
              width: 288,
              child: SectionHeader(title: 'Recently played', count: '12', actionLabel: 'See all'),
            ),
          ),
          size: const Size(320, 800),
          textScale: 3,
        ),
      );
      expect(tester.takeException(), isNull);
      for (final text in ['Recently played', '12', 'See all']) {
        final rect = tester.getRect(find.text(text));
        expect(rect.left, greaterThanOrEqualTo(0), reason: text);
        expect(rect.right, lessThanOrEqualTo(288), reason: text);
      }
      // the title keeps the width: a few lines (one word is wider than the screen at 300 %), not a column of letters
      expect(
        tester.getSize(find.text('Recently played')).height,
        lessThanOrEqualTo(4 * 3 * TsuyaType.titleL.fontSize! * 1.15),
      );
      // what does not fit beside it goes under it
      expect(
        tester.getRect(find.text('See all')).top,
        greaterThanOrEqualTo(tester.getRect(find.text('Recently played')).bottom),
      );
    });
  });

  testWidgets('the titles are headings: level 1 for a page, level 2 for a section', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const Column(
          children: [
            PageHeader(title: 'Albums'),
            SectionHeader(title: 'Recent'),
          ],
        ),
      ),
    );
    expect(tester.getSemantics(find.text('Albums')).getSemanticsData().headingLevel, 1);
    expect(tester.getSemantics(find.text('Recent')).getSemanticsData().headingLevel, 2);
    semantics.dispose();
  });
}
