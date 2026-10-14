// Mount, animate in, animate out, then unmount (DESIGN.md, Foundations: Motion).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/foundation/presence.dart';

import 'support.dart';

void main() {
  testWidgets('visible from the start: mounted and animated fully in', (tester) async {
    await tester.pumpWidget(
      host(Presence(visible: true, builder: (context, animation) => const SizedBox(key: Key('x'))), animate: true),
    );
    expect(find.byKey(const Key('x')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('not visible from the start: never built', (tester) async {
    await tester.pumpWidget(
      host(Presence(visible: false, builder: (context, animation) => const SizedBox(key: Key('x')))),
    );
    expect(find.byKey(const Key('x')), findsNothing);
  });

  testWidgets('turning visible off keeps it mounted while it animates out, then unmounts it', (tester) async {
    late Animation<double> animation;
    var visible = true;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => host(
          Presence(
            visible: visible,
            builder: (context, a) {
              animation = a;
              return const SizedBox(key: Key('x'));
            },
          ),
          animate: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(animation.value, 1);

    visible = false;
    (tester.element(find.byType(StatefulBuilder)) as StatefulElement).markNeedsBuild();
    await tester.pump();
    expect(find.byKey(const Key('x')), findsOneWidget, reason: 'still mounted mid-exit');
    expect(animation.status, AnimationStatus.reverse);

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('x')), findsNothing, reason: 'unmounted once the exit finishes');
  });

  testWidgets('reduced motion: the first appearance is instant, not animated', (tester) async {
    late Animation<double> animation;
    await tester.pumpWidget(
      host(
        Presence(
          visible: true,
          builder: (context, a) {
            animation = a;
            return const SizedBox(key: Key('x'));
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));
    expect(animation.value, 1);
  });
}
