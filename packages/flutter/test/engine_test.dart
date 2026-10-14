// The colour engine against spec/cases.json, which the TS reference writes, and its guarantees for any seed and any
// image (G4).
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/src/engine/check.dart';
import 'package:tsuya/src/engine/colorspace.dart';
import 'package:tsuya/tsuya.dart';

// lcg of scripts/cases.mjs: the low 31 bits, as with Math.imul
Iterable<int> _lcg(int seed) sync* {
  for (;;) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    yield seed;
  }
}

List<String> _randomColors(int count, int seed) => [
  for (final n in _lcg(seed).take(count)) '#${(n & 0xffffff).toRadixString(16).padLeft(6, '0').toUpperCase()}',
];

void main() {
  final cases = jsonDecode(File('../../spec/cases.json').readAsStringSync()) as Map<String, dynamic>;
  final images = (cases['images'] as List<dynamic>).cast<Map<String, dynamic>>();
  const modes = [
    (Brightness.light, TsuyaColors.light, TsuyaMaterial.light),
    (Brightness.dark, TsuyaColors.dark, TsuyaMaterial.dark),
  ];

  test('every colour case gives the pair of the TS reference, to the hex digit', () {
    final colors = (cases['colors'] as List<dynamic>).cast<Map<String, dynamic>>();
    expect(colors, hasLength(1020));
    for (final c in colors) {
      final pair = accentFromColor(c['seed'] as String);
      expect([pair.seed, hexOf(pair.light), hexOf(pair.dark)], [c['seed'], c['light'], c['dark']]);
    }
  });

  test('every image case gives the pair and the ambient opacities of the TS reference', () {
    expect(images, hasLength(12));
    for (final c in images) {
      final pair = accentFromPixels(base64Decode(c['rgba'] as String), c['width'] as int, c['height'] as int);
      final ambient = c['ambient'] as Map<String, dynamic>;
      expect(
        [pair.seed, hexOf(pair.light), hexOf(pair.dark), pair.ambientLight, pair.ambientDark],
        [c['seed'], c['light'], c['dark'], ambient['light'], ambient['dark']],
        reason: c['name'] as String,
      );
    }
  });

  test('the contrast checks of the tokens give the results of the TS reference, to the last bit', () {
    final checks = cases['checks'] as Map<String, dynamic>;
    for (final (mode, colors, material) in modes) {
      final expected = [
        for (final r in (checks[mode.name] as List<dynamic>).cast<Map<String, dynamic>>())
          (r['check'], r['ratio'], (r['min'] as num).toDouble(), r['worst']),
      ];
      final actual = [for (final r in checkMode(colors, material)) (r.check, r.ratio, r.min, r.worst)];
      expect(actual, expected, reason: mode.name);
      expect(looksLike(colors, mode), isTrue);
    }
  });

  test('4000 random seeds: in the band, away from the four statuses, readable on the grounds and under on-accent', () {
    final failures = <String>[];
    for (final seed in _randomColors(4000, 4000)) {
      final pair = accentFromColor(seed);
      for (final (mode, colors, material) in modes) {
        final accent = pair.of(mode);
        final at = '$seed → ${mode.name} ${hexOf(accent)}';
        final lab = toLab(rgbOf(accent));
        if (lab.l < material.accentToneMin - 0.3 || lab.l > material.accentToneMax + 0.3) failures.add('$at: L*');
        for (final status in [colors.danger, colors.warning, colors.success, colors.info]) {
          if (distance(lab, toLab(rgbOf(status))) < TsuyaAccent.statusDistance) failures.add('$at: near $status');
        }
        final cap = gam(material.ambientCap);
        final grounds = [rgbOf(colors.bg), over(rgbOf(colors.surface), rgbOf(colors.bg)), Rgb(cap, cap, cap)];
        if (contrastOf(rgbOf(colors.onAccent), rgbOf(accent)) < 5.3) failures.add('$at: on-accent');
        for (final ground in grounds) {
          if (contrastOf(rgbOf(accent), ground) < 3) failures.add('$at: on a ground');
        }
      }
    }
    expect(failures, isEmpty);
  });

  test('random images: the ambient opacity is a step of 0.01, at most the maximum', () {
    final random = _lcg(99).iterator;
    int next() => (random..moveNext()).current;
    for (var n = 0; n < 40; n++) {
      final width = 20 + next() % 140;
      final height = 20 + next() % 140;
      final palette = [
        for (var i = 0; i < 1 + next() % 6; i++) [next() & 255, next() & 255, next() & 255],
      ];
      final pixels = Uint8List(width * height * 4);
      for (var i = 0; i < width * height; i++) {
        pixels.setAll(i * 4, [...palette[(i % width) * palette.length ~/ width], n % 4 == 0 ? next() & 255 : 255]);
      }
      final pair = accentFromPixels(pixels, width, height);
      for (final (mode, _, material) in modes) {
        final opacity = pair.ambientOf(mode);
        expect(opacity, lessThanOrEqualTo(material.ambientMaxOpacity));
        expect((opacity * 100).round() / 100, opacity);
      }
    }
  });

  test('a malformed seed and bytes that do not hold the image are refused', () {
    expect(accentFromColor('2a9d8f80'), accentFromColor('#2A9D8F'));
    for (final bad in ['', 'teal', '#2A9D8', '#2A9D8F8']) {
      expect(() => accentFromColor(bad), throwsFormatException, reason: bad);
    }
    expect(() => accentFromPixels(Uint8List(10), 2, 2), throwsRangeError);
    expect(() => accentFromPixels(Uint8List(16), 0, 4), throwsRangeError);
  });

  testWidgets('an image decoded from a PNG gives the accent of its pixels', (tester) async {
    final teal = images.firstWhere((c) => c['name'] == 'teal-wrap');
    final pixels = base64Decode(teal['rgba'] as String);
    final width = teal['width'] as int;
    final height = teal['height'] as int;
    // real decoding does not advance inside the fake async zone of testWidgets
    final pair = await tester.runAsync(() async {
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(pixels, width, height, ui.PixelFormat.rgba8888, completer.complete);
      final image = await completer.future;
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return accentFromImage(MemoryImage(png!.buffer.asUint8List()));
    });
    expect(pair, accentFromPixels(pixels, width, height));
  });

  test('timing: a 256 × 256 image (printed, not a gate)', () {
    final random = _lcg(1).iterator;
    final pixels = Uint8List(256 * 256 * 4);
    for (var i = 0; i < pixels.length; i++) {
      pixels[i] = i % 4 == 3 ? 255 : (random..moveNext()).current & 255;
    }
    accentFromPixels(pixels, 256, 256);
    const runs = 10;
    final watch = Stopwatch()..start();
    for (var i = 0; i < runs; i++) {
      accentFromPixels(pixels, 256, 256);
    }
    // ignore: avoid_print
    print('accentFromPixels, 256 × 256 noise: ${(watch.elapsedMicroseconds / runs / 1000).toStringAsFixed(1)} ms');
  });
}
