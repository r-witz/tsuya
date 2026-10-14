// Runs before every test file: the real fonts, and a golden comparator that tolerates a hair of anti-aliasing.
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The share of pixels that may differ before a golden fails: 0.5 %. Flutter's own comparator is exact (it fails on
/// one pixel). The goldens are written on one machine and read on another, a contributor's Linux and CI's Ubuntu,
/// and a different FreeType or GPU-less Skia build moves the anti-aliased edge of a glyph by a pixel here and there.
/// 0.5 % of a 390 × 844 screen is about 1 600 pixels: more than that noise, far less than a moved element, a changed
/// colour or a missing icon, which each touch many times more.
const goldenTolerance = 0.005;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFonts();
  final previous = goldenFileComparator;
  if (previous is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(previous.basedir.resolve('flutter_test_config.dart'));
  }
  await testMain();
}

/// Loads the bundled fonts under the family names the tokens use (`packages/tsuya/Inter`, `packages/tsuya/Geist
/// Mono`), so goldens show Inter, not the test font. The tests run from `apps/gallery`; the fonts are the package's.
Future<void> _loadFonts() async {
  Future<ByteData> bytes(String path) async => ByteData.sublistView(await File(path).readAsBytes());
  const fonts = '../../packages/flutter/fonts';
  final inter = FontLoader('packages/tsuya/Inter');
  for (final weight in [400, 500, 600, 700, 800]) {
    inter.addFont(bytes('$fonts/Inter-$weight.ttf'));
  }
  final mono = FontLoader('packages/tsuya/Geist Mono')..addFont(bytes('$fonts/GeistMono-400.ttf'));
  await Future.wait([inter.load(), mono.load()]);
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (result.passed || result.diffPercent <= goldenTolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
