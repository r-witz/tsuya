// Shared test helpers.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

/// Loads the bundled fonts under the family names the tokens use (`packages/tsuya/Inter`, `packages/tsuya/Geist
/// Mono`), so tests lay text out with them rather than with the test font. Inside `testWidgets`, call it through
/// `tester.runAsync`.
Future<void> loadTsuyaFonts() async {
  Future<ByteData> bytes(String path) async => ByteData.sublistView(await File(path).readAsBytes());
  final inter = FontLoader('packages/tsuya/Inter');
  for (final weight in [400, 500, 600, 700, 800]) {
    inter.addFont(bytes('fonts/Inter-$weight.ttf'));
  }
  final mono = FontLoader('packages/tsuya/Geist Mono')..addFont(bytes('fonts/GeistMono-400.ttf'));
  await Future.wait([inter.load(), mono.load()]);
}

/// [child] with the media, direction, theme and labels an app gives it; animations off unless [animate]. Wrapped
/// in the default shortcuts and actions of a `WidgetsApp` (Tab moves focus, as in an app) and in an [Overlay] so
/// overlay-based primitives can run. Tests that care about touch vs. pointer geometry must also set
/// `debugDefaultTargetPlatformOverride` themselves: this helper does not
/// guess a platform for you.
Widget host(
  Widget child, {
  Brightness platform = Brightness.light,
  TsuyaMode mode = TsuyaMode.light,
  bool highContrast = false,
  bool animate = false,
  double textScale = 1,
  Size size = const Size(400, 800),
  EdgeInsets viewInsets = EdgeInsets.zero,
  TextDirection direction = TextDirection.ltr,
  TsuyaLabels labels = TsuyaLabels.en,
}) => MediaQuery(
  data: MediaQueryData(
    size: size,
    viewInsets: viewInsets,
    platformBrightness: platform,
    highContrast: highContrast,
    disableAnimations: !animate,
    textScaler: TextScaler.linear(textScale),
  ),
  child: Directionality(
    textDirection: direction,
    child: TsuyaTheme(
      mode: mode,
      child: TsuyaLabelsScope(
        labels: labels,
        child: Shortcuts(
          shortcuts: WidgetsApp.defaultShortcuts,
          child: Actions(
            actions: WidgetsApp.defaultActions,
            child: Overlay.wrap(child: child),
          ),
        ),
      ),
    ),
  ),
);

/// Lays the test out on a view of [size] (at a device pixel ratio of 1), as [host]'s `size` only tells the
/// [MediaQuery]: for a widget that reads the width it is given, as a container breakpoint does (DESIGN.md, Layout).
void viewAt(WidgetTester tester, Size size) {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// The colour of the pixel at [point] of the [RepaintBoundary] with [key], as rendered, in straight (not
/// premultiplied) alpha.
Future<Color> pixelAt(WidgetTester tester, GlobalKey key, Offset point) async {
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    final width = image.width;
    image.dispose();
    return (data!.buffer.asUint8List(), width);
  }))!;
  final (Uint8List rgba, int width) = bytes;
  final i = (point.dy.toInt() * width + point.dx.toInt()) * 4;
  return Color.fromARGB(rgba[i + 3], rgba[i], rgba[i + 1], rgba[i + 2]);
}

/// A PNG of [width] × [height] pixels of one colour.
Future<Uint8List> solidPng(Color color, {int width = 48, int height = 48}) async {
  final argb = color.toARGB32();
  final pixels = Uint8List(width * height * 4);
  for (var i = 0; i < width * height; i++) {
    pixels.setAll(i * 4, [(argb >> 16) & 0xFF, (argb >> 8) & 0xFF, argb & 0xFF, (argb >> 24) & 0xFF]);
  }
  final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
  final descriptor = ui.ImageDescriptor.raw(buffer, width: width, height: height, pixelFormat: ui.PixelFormat.rgba8888);
  final frame = await (await descriptor.instantiateCodec()).getNextFrame();
  final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  return png!.buffer.asUint8List();
}
