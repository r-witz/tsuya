import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya_example/main.dart';

void main() {
  testWidgets('the example shows a list, a toast, a tab and a dialog', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.runAsync(() async => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(find.text('Apple picked'), findsOneWidget);

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete everything'));
    await tester.pumpAndSettle();
    expect(find.text('Delete everything?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete everything?'), findsNothing);
  });
}
