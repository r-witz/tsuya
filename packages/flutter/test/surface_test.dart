// The screen shell's back-to-front order and grain modes (DESIGN.md, The material: Surface).
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

final _kTransparentImage = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  testWidgets('shows Glow without an ambient image', (tester) async {
    await tester.pumpWidget(host(const TsuyaSurface(child: SizedBox())));
    expect(find.byType(Glow), findsOneWidget);
    expect(find.byType(Ambient), findsNothing);
  });

  testWidgets('shows Ambient with one', (tester) async {
    await tester.pumpWidget(host(TsuyaSurface(ambient: MemoryImage(_kTransparentImage), child: const SizedBox())));
    expect(find.byType(Ambient), findsOneWidget);
    expect(find.byType(Glow), findsNothing);
  });

  testWidgets('grain mode bg (the default) draws one grain layer', (tester) async {
    await tester.pumpWidget(host(const TsuyaSurface(child: SizedBox())));
    expect(find.byType(Grain), findsOneWidget);
  });

  testWidgets('grain mode off draws no grain layer', (tester) async {
    await tester.pumpWidget(host(const TsuyaSurface(grain: GrainMode.off, child: SizedBox())));
    expect(find.byType(Grain), findsNothing);
  });

  testWidgets('grain mode all adds a second grain layer over the content, which lets touches through', (tester) async {
    await tester.pumpWidget(host(const TsuyaSurface(grain: GrainMode.all, child: SizedBox())));
    expect(find.byType(Grain), findsNWidgets(2));
    expect(find.ancestor(of: find.byType(Grain).last, matching: find.byType(IgnorePointer)), findsWidgets);
  });

  testWidgets('the content is interactive: a tap reaches it through the surface', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      host(
        TsuyaSurface(
          grain: GrainMode.all,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => tapped = true,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(GestureDetector));
    expect(tapped, isTrue);
  });
}
