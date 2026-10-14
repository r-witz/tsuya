// The film grain tile, compared to the PNG the build writes, and its fallbacks (DESIGN.md, The material:
// Grain).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/material/grain.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

void main() {
  testWidgets('the Dart tile equals the PNG scripts/grain.mjs writes', (tester) async {
    final expected = grainTexels(TsuyaGrain.size.toInt());
    await tester.runAsync(() async {
      final bytes = await File('../core/src/css/grain.png').readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      expect(image.width, TsuyaGrain.size.toInt());
      expect(image.height, TsuyaGrain.size.toInt());
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      final pixels = data!.buffer.asUint8List();
      // greyscale: R, G and B are equal, so comparing R to the generator's texel is enough
      for (var i = 0; i < expected.length; i++) {
        expect(pixels[i * 4], expected[i], reason: 'texel $i');
      }
    });
  });

  testWidgets('off under high contrast', (tester) async {
    await tester.pumpWidget(host(const Grain(), highContrast: true));
    expect(find.byType(CustomPaint), findsNothing);
  });

  testWidgets('drawn otherwise', (tester) async {
    await tester.pumpWidget(host(const Grain()));
    // the tile decodes on a real engine thread: poll until the FutureBuilder picks it up
    for (var i = 0; i < 20 && find.byType(CustomPaint).evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    expect(find.byType(CustomPaint), findsOneWidget);
  });

  testWidgets('drawn in a later test too: the tile is not tied to the test that asked for it first', (tester) async {
    // the tile decoded in the test above; a Future made inside that test's fake async zone would never deliver here
    await tester.pumpWidget(host(const Grain()));
    await tester.pump();
    expect(find.byType(CustomPaint), findsOneWidget);
  });
}
