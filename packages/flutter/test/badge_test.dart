// Badge (DESIGN.md, Badge): the count pill, "99+" above 99, the dot, decorative, and pinned on the
// corner of an icon button and an avatar, whose own label carries its meaning.
// G5: semantics. G14: right-to-left.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/pressable.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

Widget _icon() => const SizedBox(width: 10, height: 10);

void main() {
  testWidgets('a count pill shows its number, "99+" above 99, 18 tall', (tester) async {
    for (final (count, text) in [(5, '5'), (99, '99'), (142, '99+')]) {
      await tester.pumpWidget(host(Center(child: Badge.count(count))));
      expect(find.text(text), findsOneWidget);
      expect(tester.getSize(find.byType(Badge)).height, 18);
    }
  });

  testWidgets('a dot is an 8 px circle', (tester) async {
    await tester.pumpWidget(host(const Center(child: Badge.dot())));
    expect(tester.getSize(find.byType(Badge)), const Size(8, 8));
    final decoration = tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
  });

  testWidgets('decorative: excluded from the semantics tree', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(const Column(children: [Badge.count(7), Badge.dot()])));
    // ignore: deprecated_member_use (rootPipelineOwner is a different, unattached pipeline in this test harness)
    final tree = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!.toStringDeep();
    expect(tree, isNot(contains('7')));
    semantics.dispose();
  });

  testWidgets('pinned on the corner of an icon button, whose own label carries its meaning', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Center(
          child: IconButton(
            icon: _icon(),
            label: 'Notifications, 3 unread',
            onPressed: () {},
            badge: const Badge.count(3),
          ),
        ),
      ),
    );
    expect(tester.getSemantics(find.byType(Pressable)).label, 'Notifications, 3 unread');
    final button = tester.getRect(find.byType(IconButton));
    final badge = tester.getRect(find.byType(Badge));
    expect(badge.right, greaterThan(button.right));
    expect(badge.top, lessThan(button.top));
    semantics.dispose();
  });

  testWidgets('pinned on the corner of an avatar, whose own label carries its meaning', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const Center(
          child: Avatar(initials: 'JD', label: 'Jamie Doe, online', badge: Badge.dot()),
        ),
      ),
    );
    expect(tester.getSemantics(find.byType(Avatar)).label, 'Jamie Doe, online');
    final avatar = tester.getRect(find.byType(Avatar));
    final badge = tester.getRect(find.byType(Badge));
    expect(badge.right, greaterThan(avatar.right));
    expect(badge.top, lessThan(avatar.top));
    semantics.dispose();
  });

  testWidgets('G14: right to left, the pin sits on the top-left corner', (tester) async {
    await tester.pumpWidget(
      host(
        Center(
          child: IconButton(icon: _icon(), label: 'Notifications', onPressed: () {}, badge: const Badge.count(3)),
        ),
        direction: TextDirection.rtl,
      ),
    );
    final button = tester.getRect(find.byType(IconButton));
    final badge = tester.getRect(find.byType(Badge));
    expect(badge.left, lessThan(button.left));
    expect(badge.top, lessThan(button.top));
  });

  testWidgets('without a badge, nothing pins', (tester) async {
    await tester.pumpWidget(host(IconButton(icon: _icon(), label: 'Share', onPressed: () {})));
    expect(find.byType(Badge), findsNothing);
  });
}
