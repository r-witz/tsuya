// Film grain, under the content (DESIGN.md, The material: Grain). The tile is generated at runtime from
// the same algorithm as `scripts/grain.mjs`, which writes `packages/core/src/css/grain.png`: both must draw the
// same texels (checked by a test that decodes the PNG).
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../foundation/tokens.g.dart';

/// The tile's greyscale texels, row by row, [size] × [size]: a linear congruential generator seeded with 64, each
/// texel the mean of two draws (the exact generator of `scripts/grain.mjs`). Not part of the public API: `Grain`
/// paints it; a test compares it to the build's PNG.
List<int> grainTexels(int size) {
  var state = 64;
  int draw() {
    // Dart's int is 64-bit on every target this package tests (no JS compilation): state * 1103515245 never
    // exceeds that range, so this already matches the build's Math.imul-based generator bit for bit.
    state = (state * 1103515245 + 12345) & 0x7fffffff;
    return (state >> 16) & 0xff;
  }

  return [for (var i = 0; i < size * size; i++) (draw() + draw()) >> 1];
}

Future<ui.Image> _drawTile(int size) {
  final texels = grainTexels(size);
  final pixels = Uint8List(size * size * 4);
  for (var i = 0; i < texels.length; i++) {
    pixels.setAll(i * 4, [texels[i], texels[i], texels[i], 255]);
  }
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(pixels, size, size, ui.PixelFormat.rgba8888, completer.complete);
  return completer.future;
}

/// The film grain tile, repeated one texel per physical pixel in overlay blend at [TsuyaGrain.opacity].
/// Off under high contrast.
class Grain extends StatelessWidget {
  /// The grain layer; size it with a parent (a [TsuyaSurface] sizes it to the region).
  const Grain({super.key});

  static final Future<ui.Image> _tile = _drawTile(TsuyaGrain.size.toInt()).then((tile) => _decoded = tile);

  // Once decoded the tile is kept as an image: a Future made inside one fake-async test zone never delivers to a
  // listener of another test, so a second test of the same process would draw no grain.
  static ui.Image? _decoded;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeHighContrastOf(context) ?? false) return const SizedBox.shrink();
    Widget paint(ui.Image tile) =>
        CustomPaint(painter: _GrainPainter(tile, MediaQuery.devicePixelRatioOf(context)), size: Size.infinite);
    final decoded = _decoded;
    if (decoded != null) return IgnorePointer(child: paint(decoded));
    return IgnorePointer(
      child: FutureBuilder<ui.Image>(
        future: _tile,
        builder: (context, tile) => tile.hasData ? paint(tile.data!) : const SizedBox.expand(),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.tile, this.pixelRatio);

  final ui.Image tile;
  final double pixelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    // one texel per physical pixel
    final scale = Matrix4.diagonal3Values(1 / pixelRatio, 1 / pixelRatio, 1).storage;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ImageShader(tile, TileMode.repeated, TileMode.repeated, scale)
        ..blendMode = BlendMode.overlay
        ..color = const Color(0xFFFFFFFF).withValues(alpha: TsuyaGrain.opacity),
    );
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.tile != tile || old.pixelRatio != pixelRatio;
}
