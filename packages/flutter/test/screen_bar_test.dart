// ScreenBar (DESIGN.md, TopBar, ScreenBar).
// G3: targets. G5: semantics. G13: spec values. G14: right-to-left. G7, G9: smoke_test.dart.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  testWidgets('at least bar tall; a round back button that calls onBack', (tester) async {
    var backs = 0;
    await tester.pumpWidget(
      host(
        ScreenBar(title: 'Order 1042', onBack: () => backs++, backLabel: 'Back'),
        size: const Size(400, 200),
      ),
    );
    expect(tester.getSize(find.byType(ScreenBar)).height, greaterThanOrEqualTo(TsuyaSize.bar));
    final back = find.ancestor(of: find.byType(Glyph), matching: find.byType(Pressable));
    expect(tester.getSize(back).width, TsuyaSize.controlMd);
    final radius = tester.widget<Pressable>(back).borderRadius;
    expect(radius.topLeft.x, TsuyaSize.controlMd / 2, reason: 'a corner radius of half its side draws a circle');
    await tester.tap(back);
    expect(backs, 1);
  });

  testWidgets('the title is centred, title-m at weight 700; the caption is text-muted', (tester) async {
    await tester.pumpWidget(
      host(
        ScreenBar(title: 'Order 1042', subtitle: 'Shipped', onBack: () {}, backLabel: 'Back'),
        size: const Size(400, 200),
      ),
    );
    final title = tester.widget<Text>(find.text('Order 1042'));
    expect(title.style!.fontSize, 22);
    expect(title.style!.fontWeight, FontWeight.w700);
    final bar = tester.getRect(find.byType(ScreenBar));
    final titleRect = tester.getRect(find.text('Order 1042'));
    expect(titleRect.center.dx, closeTo(bar.center.dx, 1));
    final caption = tester.widget<Text>(find.text('Shipped'));
    expect(caption.style!.fontSize, 12);
    expect(caption.style!.color, TsuyaColors.light.textMuted);
  });

  testWidgets('a long title stays on one line and ends with an ellipsis, leaving the action its room', (tester) async {
    await tester.pumpWidget(
      host(
        ScreenBar(
          title: 'The order of a customer who bought far too many things at once',
          action: const SizedBox(width: 24, height: 24),
        ),
        size: const Size(320, 200),
      ),
    );
    final title = tester.widget<Text>(find.text('The order of a customer who bought far too many things at once'));
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without onBack there is no back button', (tester) async {
    await tester.pumpWidget(host(const ScreenBar(title: 'Order 1042'), size: const Size(400, 200)));
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('backLabel is required together with onBack', (tester) async {
    expect(() => ScreenBar(title: 'x', onBack: () {}), throwsAssertionError);
    expect(() => ScreenBar(title: 'x', backLabel: 'Back'), throwsAssertionError);
  });

  testWidgets('right to left, the back button sits at the end (the right)', (tester) async {
    await tester.pumpWidget(
      host(
        ScreenBar(title: 'Order 1042', onBack: () {}, backLabel: 'Back'),
        direction: TextDirection.rtl,
        size: const Size(400, 200),
      ),
    );
    final bar = tester.getRect(find.byType(ScreenBar));
    final back = find.ancestor(of: find.byType(Glyph), matching: find.byType(Pressable));
    expect(tester.getRect(back).right, closeTo(bar.right, 1));
  });

  testWidgets('G5: the back button is named by backLabel; the title is a heading named by it', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        ScreenBar(title: 'Order 1042', onBack: () {}, backLabel: 'Back to orders'),
        size: const Size(400, 200),
      ),
    );
    final back = find.ancestor(of: find.byType(Glyph), matching: find.byType(Pressable));
    expect(tester.getSemantics(back).label, 'Back to orders');
    final heading = tester.getSemantics(
      find.byWidgetPredicate((w) => w is Semantics && w.properties.headingLevel == 1),
    );
    expect(heading.label, 'Order 1042');
    semantics.dispose();
  });

  Widget narrow(Widget bar) => host(
    Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 400, child: bar),
    ),
  );

  testWidgets('a text action keeps its natural width, the title stays centred', (tester) async {
    Button save() => Button(label: 'Save', onPressed: () {});
    await tester.pumpWidget(host(Align(alignment: Alignment.topLeft, child: save())));
    final natural = tester.getSize(find.byType(Button)).width;
    expect(natural, greaterThan(TsuyaSize.controlMd));
    await tester.pumpWidget(narrow(ScreenBar(title: 'Order', onBack: () {}, backLabel: 'Back', action: save())));
    expect(tester.getSize(find.byType(Button)).width, natural);
    final bar = tester.getRect(find.byType(ScreenBar));
    expect(tester.getRect(find.text('Order')).center.dx, closeTo(bar.center.dx, 1));
    expect(tester.getRect(find.byType(Button)).right, closeTo(bar.right, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long title with a text action ends in an ellipsis without overflow', (tester) async {
    await tester.pumpWidget(
      narrow(
        ScreenBar(
          title: 'The order of a customer who bought far too many things at once',
          onBack: () {},
          backLabel: 'Back',
          action: Button(label: 'Save', onPressed: () {}),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final bar = tester.getRect(find.byType(ScreenBar));
    final title = tester.getRect(find.textContaining('The order'));
    expect(title.center.dx, closeTo(bar.center.dx, 1));
    expect(title.width, lessThanOrEqualTo(bar.width - 2 * TsuyaSize.controlMd - 2 * TsuyaSpace.s8));
  });
}
