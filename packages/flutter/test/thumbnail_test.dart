// Thumbnail (DESIGN.md, Thumbnail).
// G5: semantics. G9, G14: smoke_test.dart.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

// a 1 × 1 transparent PNG: enough to exercise Thumbnail's structure, no real decode needed for these assertions
final _picture = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

// 100 × 50: black, with a white 50 × 50 centre
Future<Uint8List> _widePng() async {
  const w = 100, h = 50;
  final pixels = Uint8List(w * h * 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      pixels[i] = pixels[i + 1] = pixels[i + 2] = x >= 25 && x < 75 ? 255 : 0;
      pixels[i + 3] = 255;
    }
  }
  final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
  final descriptor = ui.ImageDescriptor.raw(buffer, width: w, height: h, pixelFormat: ui.PixelFormat.rgba8888);
  final frame = await (await descriptor.instantiateCodec()).getNextFrame();
  return (await frame.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

void main() {
  testWidgets('a loaded picture: named by label, decoded at the display size', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Thumbnail(image: MemoryImage(_picture), label: 'Album cover')));
    final image = tester.widget<Image>(find.byType(Image));
    final resized = image.image as ResizeImage;
    expect(resized.height, 48, reason: 'the covering dimension of a square, at 1x');
    expect(resized.width, isNull, reason: 'the other follows the picture, so its aspect is kept');
    expect(resized.policy, ResizeImagePolicy.fit);
    expect(tester.getSemantics(find.byType(Thumbnail)), isSemantics(label: 'Album cover', isImage: true));
    semantics.dispose();
  });

  testWidgets('the picture is decoded at physical pixels: 3x screen, 48 box', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(devicePixelRatio: 3),
            child: Thumbnail(image: MemoryImage(_picture), size: 48),
          ),
        ),
      ),
    );
    final resized = tester.widget<Image>(find.byType(Image)).image as ResizeImage;
    expect(resized.height, 144);
  });

  testWidgets('a wide picture is cropped by cover, not squashed into a square', (tester) async {
    final key = GlobalKey();
    final bytes = (await tester.runAsync(_widePng))!;
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: key,
            child: Thumbnail(image: MemoryImage(bytes), size: 48),
          ),
        ),
      ),
    );
    final provider = tester.widget<Image>(find.byType(Image)).image;
    await tester.runAsync(() => precacheImage(provider, tester.element(find.byType(Thumbnail))));
    await tester.pump();
    await tester.pump();
    // the centre of a 2:1 picture is white, its sides black: cover shows only the white centre
    final edge = await pixelAt(tester, key, const Offset(3, 24));
    expect(edge.r, greaterThan(0.9), reason: 'edge pixel $edge: the black sides were squashed in');
  });

  testWidgets('without label it is decorative: excluded from the semantics tree', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(Thumbnail(image: MemoryImage(_picture))));
    // Image always builds its own Semantics(image: true) widget (unless excludeFromSemantics), which merges into
    // the nearest ancestor boundary when not blocked: a finder at Thumbnail's own (non-boundary) position cannot
    // see this, so the real tree is dumped instead.
    // rootPipelineOwner (the suggested replacement) is a different, unattached pipeline in this test harness
    // ignore: deprecated_member_use
    final tree = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!.toStringDeep();
    expect(tree, isNot(contains('isImage')));
    semantics.dispose();
  });

  testWidgets('without an image, the fill placeholder shows its icon', (tester) async {
    await tester.pumpWidget(host(const Thumbnail(placeholder: SizedBox(key: Key('icon'), width: 20, height: 20))));
    expect(find.byType(Image), findsNothing);
    expect(find.byKey(const Key('icon')), findsOneWidget);
  });

  testWidgets('a picture that fails to load falls back to the placeholder', (tester) async {
    await tester.pumpWidget(
      host(
        Thumbnail(
          image: MemoryImage(_picture),
          placeholder: const SizedBox(key: Key('icon'), width: 20, height: 20),
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    final fallback = image.errorBuilder!(tester.element(find.byType(Image)), Object(), null);
    expect(fallback, isA<SizedBox>());
    expect((fallback as SizedBox).width, 0);
    expect(fallback.height, 0);
    expect(fallback.child, isNull);
  });

  testWidgets('a 1 px border hairline over the picture', (tester) async {
    await tester.pumpWidget(host(const Thumbnail()));
    final container = tester.widget<Container>(find.byType(Container));
    final border = (container.foregroundDecoration! as BoxDecoration).border!.top;
    expect(border.width, 1);
    expect(border.color, TsuyaColors.light.border);
    expect(border.strokeAlign, BorderSide.strokeAlignInside);
  });

  testWidgets('square by default, portrait 2:3, wide 16:9', (tester) async {
    await tester.pumpWidget(host(const Center(child: Thumbnail(size: 48))));
    expect(tester.getSize(find.byType(Thumbnail)), const Size(48, 48));

    await tester.pumpWidget(host(const Center(child: Thumbnail(size: 48, ratio: ThumbnailRatio.portrait))));
    expect(tester.getSize(find.byType(Thumbnail)), const Size(48, 72));

    await tester.pumpWidget(host(const Center(child: Thumbnail(size: 48, ratio: ThumbnailRatio.wide))));
    expect(tester.getSize(find.byType(Thumbnail)).height, closeTo(27, 0.5));
  });

  testWidgets('radius grows with the width: xs up to 40, sm up to 64, md up to 160, lg above', (tester) async {
    for (final (size, radius) in [
      (40.0, TsuyaRadius.xs),
      (64.0, TsuyaRadius.sm),
      (160.0, TsuyaRadius.md),
      (200.0, TsuyaRadius.lg),
    ]) {
      await tester.pumpWidget(host(Thumbnail(size: size)));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.foregroundDecoration! as BoxDecoration;
      expect((decoration.borderRadius! as BorderRadius).topLeft.x, radius, reason: 'size $size');
    }
  });
}
