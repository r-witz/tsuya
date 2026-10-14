// Banner (DESIGN.md, Banner).
// G5: semantics. G7: text scale. G13: geometry and colours. G14: right-to-left.
import 'package:flutter/widgets.dart' hide Banner;
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

BoxDecoration _decoration(WidgetTester tester) {
  final box = find.descendant(of: find.byType(Banner), matching: find.byType(DecoratedBox)).first;
  return tester.widget<DecoratedBox>(box).decoration as BoxDecoration;
}

void main() {
  for (final (mode, colors) in [(TsuyaMode.light, TsuyaColors.light), (TsuyaMode.dark, TsuyaColors.dark)]) {
    testWidgets('each tone is its status colour at 13 % with a 1 px ring at 32 % and its icon (${mode.name})', (
      tester,
    ) async {
      final tones = {
        BannerTone.info: (colors.info, TsuyaGlyph.info),
        BannerTone.success: (colors.success, TsuyaGlyph.check),
        BannerTone.warning: (colors.warning, TsuyaGlyph.alert),
        BannerTone.danger: (colors.danger, TsuyaGlyph.alert),
      };
      for (final MapEntry(key: tone, value: (color, glyph)) in tones.entries) {
        await tester.pumpWidget(
          host(
            Banner(tone: tone, title: 'Offline'),
            mode: mode,
          ),
        );
        final decoration = _decoration(tester);
        expect(decoration.color, color.withValues(alpha: 0.13));
        expect(decoration.borderRadius, BorderRadius.circular(TsuyaRadius.md));
        final border = decoration.border! as Border;
        expect(border.isUniform, isTrue, reason: 'never a coloured side stripe');
        expect(border.top.width, 1);
        expect(border.top.color, color.withValues(alpha: 0.32));
        final icon = tester.widget<Glyph>(find.byType(Glyph));
        expect(icon.glyph, glyph);
        expect(icon.color, color);
        expect(icon.size, TsuyaSize.icon);
      }
    });
  }

  testWidgets('title is body-strong text, message small text-muted, padded 12 16', (tester) async {
    await tester.pumpWidget(host(const Banner(tone: BannerTone.info, title: 'Trial ending', message: 'Two days left')));
    final title = tester.widget<Text>(find.text('Trial ending')).style!;
    final message = tester.widget<Text>(find.text('Two days left')).style!;
    expect(title.color, TsuyaColors.light.text);
    expect(title.fontWeight, FontWeight.w600);
    expect(message.color, TsuyaColors.light.textMuted);
    expect(message.fontSize, lessThan(title.fontSize!));

    final banner = tester.getRect(find.byType(Banner));
    expect(tester.getRect(find.text('Trial ending')).top, moreOrLessEquals(banner.top + TsuyaSpace.s12));
    expect(tester.getRect(find.byType(Glyph)).left, moreOrLessEquals(banner.left + TsuyaSpace.s16));
  });

  testWidgets('wide: the actions sit at the end of the text row; narrow: under the text', (tester) async {
    Widget banner(double width) => host(
      Align(
        alignment: AlignmentDirectional.topStart,
        child: SizedBox(
          width: width,
          child: Banner(
            tone: BannerTone.warning,
            title: 'Sync failed',
            message: 'Retry later',
            actions: [Button(label: 'Retry', size: ButtonSize.sm, onPressed: () {})],
          ),
        ),
      ),
      size: const Size(800, 600),
    );

    await tester.pumpWidget(banner(700));
    var button = tester.getRect(find.byType(Button));
    var text = tester.getRect(find.text('Sync failed'));
    expect(button.left, greaterThan(text.right));
    expect(tester.getRect(find.byType(Banner)).right - button.right, moreOrLessEquals(TsuyaSpace.s16));

    await tester.pumpWidget(banner(300));
    button = tester.getRect(find.byType(Button));
    text = tester.getRect(find.text('Retry later'));
    expect(button.top, greaterThanOrEqualTo(text.bottom));
    expect(button.left, moreOrLessEquals(text.left));
  });

  testWidgets('wide but not wide enough for its content: the actions go under the text rather than overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Banner(
          tone: BannerTone.info,
          title: 'Offline',
          message: 'You are offline',
          onClose: () {},
          actions: [
            Button(label: 'Retry now please', onPressed: () {}),
            Button(label: 'Details here', onPressed: () {}),
          ],
        ),
        size: const Size(600, 800),
        textScale: 3,
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.getRect(find.text('You are offline'));
    expect(tester.getRect(find.text('Retry now please')).top, greaterThanOrEqualTo(text.bottom));
    expect(
      tester.getRect(find.byType(Banner)).right,
      greaterThanOrEqualTo(tester.getRect(find.byType(Button).last).right),
    );
  });

  testWidgets('G14: wide, in right-to-left the actions sit at the left end of the text row', (tester) async {
    await tester.pumpWidget(
      host(
        Banner(
          tone: BannerTone.info,
          title: 'Offline',
          message: 'You are offline',
          actions: [Button(label: 'Retry', onPressed: () {})],
        ),
        size: const Size(800, 600),
        direction: TextDirection.rtl,
      ),
    );
    final banner = tester.getRect(find.byType(Banner));
    expect(tester.getRect(find.byType(Button)).left, moreOrLessEquals(banner.left + TsuyaSpace.s16));
    expect(tester.getRect(find.text('Offline')).right, lessThan(banner.right));
    expect(tester.getRect(find.text('Offline')).left, greaterThan(tester.getRect(find.byType(Button)).right));
  });

  testWidgets('onClose adds a Close button; without it there is none', (tester) async {
    final handle = tester.ensureSemantics();
    var closed = 0;
    await tester.pumpWidget(host(const Banner(tone: BannerTone.info, title: 'Hello')));
    expect(find.byType(IconButton), findsNothing);

    await tester.pumpWidget(host(Banner(tone: BannerTone.info, title: 'Hello', onClose: () => closed++)));
    expect(
      tester.getSemantics(find.bySemanticsLabel(TsuyaLabels.en.close)),
      isSemantics(label: TsuyaLabels.en.close, isButton: true),
    );
    await tester.tap(find.byType(IconButton));
    expect(closed, 1);
    handle.dispose();
  });

  testWidgets('G14: in right-to-left the icon is at the right and the close button at the left', (tester) async {
    await tester.pumpWidget(
      host(
        Banner(tone: BannerTone.info, title: 'Hello', onClose: () {}),
        direction: TextDirection.rtl,
      ),
    );
    final banner = tester.getRect(find.byType(Banner));
    expect(tester.getRect(find.byType(Glyph).first).right, moreOrLessEquals(banner.right - TsuyaSpace.s16));
    expect(tester.getRect(find.byType(IconButton)).left, lessThan(banner.center.dx));
  });

  testWidgets('G7: at 300 % text scale it grows and does not overflow', (tester) async {
    await tester.pumpWidget(
      host(
        Banner(
          tone: BannerTone.danger,
          title: 'Something went wrong while syncing',
          message: 'Check your connection and try again in a moment',
          actions: [Button(label: 'Retry', onPressed: () {})],
          onClose: () {},
        ),
        textScale: 3,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(Banner)).height, greaterThan(100));
  });

  testWidgets('G5: it announces nothing by itself, and its icon is not read', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(const Banner(tone: BannerTone.danger, title: 'Offline', message: 'No connection')));
    expect(find.bySemanticsLabel('Offline'), findsOneWidget);
    expect(find.bySemanticsLabel('No connection'), findsOneWidget);
    final node = tester.getSemantics(find.text('Offline'));
    expect(node.flagsCollection.isLiveRegion, isFalse);
    handle.dispose();
  });
}
