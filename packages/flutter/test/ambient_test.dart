// The ambient background and the neutral glow (DESIGN.md, The material: Ambient background, Glow). G1:
// text keeps 4.5:1 over the ambient background of a few reference images.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

// a 1 × 1 transparent PNG, enough to exercise Ambient's structure without real image data
final _kTransparentImage = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

double _opacityOf(WidgetTester tester) =>
    tester.widget<Opacity>(find.descendant(of: find.byType(Ambient), matching: find.byType(Opacity)).first).opacity;

Future<Uint8List> _pngFromCase(Map<String, dynamic> entry) async {
  final rgba = base64Decode(entry['rgba'] as String);
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    rgba,
    entry['width'] as int,
    entry['height'] as int,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  final image = await completer.future;
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return png!.buffer.asUint8List();
}

void main() {
  group('Ambient', () {
    testWidgets('without an image, nothing is drawn', (tester) async {
      await tester.pumpWidget(host(const Ambient(image: null)));
      await tester.pump();
      expect(find.descendant(of: find.byType(Ambient), matching: find.byType(ShaderMask)), findsNothing);
    });

    testWidgets('with an image, it is drawn unless transparency is reduced', (tester) async {
      await tester.pumpWidget(host(Ambient(image: MemoryImage(_kTransparentImage))));
      await tester.pump();
      expect(find.descendant(of: find.byType(Ambient), matching: find.byType(ShaderMask)), findsOneWidget);

      await tester.pumpWidget(host(GlassScope(reduce: true, child: Ambient(image: MemoryImage(_kTransparentImage)))));
      await tester.pump();
      expect(find.descendant(of: find.byType(Ambient), matching: find.byType(ShaderMask)), findsNothing);
    });

    testWidgets('opacity is the safe opacity outside any accent region', (tester) async {
      await tester.pumpWidget(host(Ambient(image: MemoryImage(_kTransparentImage))));
      await tester.pump();
      expect(_opacityOf(tester), TsuyaAmbient.safeOpacity);
    });

    testWidgets('opacity comes from the nearest pair, for the current mode', (tester) async {
      final pair = AccentPair(
        light: const Color(0xFF2C9C8B),
        dark: const Color(0xFF6BBBAE),
        ambientLight: 0.33,
        ambientDark: 0.4,
      );
      await tester.pumpWidget(
        host(
          Accent(
            pair: pair,
            child: Ambient(image: MemoryImage(_kTransparentImage)),
          ),
        ),
      );
      await tester.pump();
      expect(_opacityOf(tester), 0.33);

      await tester.pumpWidget(
        host(
          Accent(
            pair: pair,
            child: Ambient(image: MemoryImage(_kTransparentImage)),
          ),
          mode: TsuyaMode.dark,
        ),
      );
      await tester.pump();
      expect(_opacityOf(tester), 0.4);
    });
  });

  group('Glow', () {
    testWidgets('hidden under reduced transparency', (tester) async {
      await tester.pumpWidget(host(GlassScope(reduce: true, child: const Glow())));
      expect(find.descendant(of: find.byType(Glow), matching: find.byType(CustomPaint)), findsNothing);
    });

    testWidgets('drawn otherwise', (tester) async {
      await tester.pumpWidget(host(const Glow()));
      expect(find.descendant(of: find.byType(Glow), matching: find.byType(CustomPaint)), findsOneWidget);
    });
  });

  group('G1: text reaches 4.5:1 over the ambient background of reference images', () {
    final cases =
        (jsonDecode(File('../../spec/cases.json').readAsStringSync()) as Map<String, dynamic>)['images']
            as List<dynamic>;
    final chosen = ['teal-wrap', 'danger-red', 'white'];
    for (final name in chosen) {
      final entry = cases.cast<Map<String, dynamic>>().firstWhere((c) => c['name'] == name);
      for (final mode in [TsuyaMode.light, TsuyaMode.dark]) {
        testWidgets('$name, $mode', (tester) async {
          final key = GlobalKey();
          final rgba = base64Decode(entry['rgba'] as String);
          final pngBytes = await tester.runAsync(() => _pngFromCase(entry));
          final image = MemoryImage(pngBytes!);
          final pair = accentFromPixels(rgba, entry['width'] as int, entry['height'] as int);
          final colors = mode == TsuyaMode.dark ? TsuyaColors.dark : TsuyaColors.light;
          await tester.pumpWidget(
            host(
              RepaintBoundary(
                key: key,
                child: TsuyaTheme(
                  mode: mode,
                  child: Accent(
                    pair: pair,
                    child: ColoredBox(
                      color: colors.bg,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Ambient(image: image),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.runAsync(
            () => precacheImage(ResizeImage(image, width: 128), tester.element(find.byType(Ambient))),
          );
          await tester.pump();
          final lit = await pixelAt(tester, key, const Offset(200, 40));
          expect(contrast(colors.text, lit), greaterThanOrEqualTo(4.5));
          expect(contrast(colors.textMuted, lit), greaterThanOrEqualTo(4.5));
        });
      }
    }
  });
}
