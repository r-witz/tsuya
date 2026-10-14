// Avatar (DESIGN.md, Avatar).
// G1: the gradient's contrast check. G5: semantics. G9, G14: smoke_test.dart.
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

// a 1 × 1 transparent PNG: enough to exercise Avatar's structure, no real decode needed for these assertions
final _picture = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

DecoratedBox _decoration(WidgetTester tester) =>
    tester.widget<DecoratedBox>(find.descendant(of: find.byType(Avatar), matching: find.byType(DecoratedBox)).first);

void main() {
  testWidgets('a photo: round, 40 by default, named by the label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        Center(
          child: Avatar(image: MemoryImage(_picture), label: 'Jamie Doe'),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Avatar)), const Size(40, 40));
    expect(find.byType(ClipOval), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(tester.getSemantics(find.byType(Avatar)), isSemantics(label: 'Jamie Doe', isImage: true));
    semantics.dispose();
  });

  testWidgets('initials on fill, in text-muted, weight 600', (tester) async {
    await tester.pumpWidget(host(const Avatar(initials: 'JD', label: 'Jamie Doe')));
    expect(_decoration(tester).decoration, BoxDecoration(color: TsuyaColors.light.fill));
    final text = tester.widget<Text>(find.text('JD'));
    expect(text.style!.color, TsuyaColors.light.textMuted);
    expect(text.style!.fontWeight, FontWeight.w600);
  });

  testWidgets('initials in the bundled Inter, or in the theme typeface', (tester) async {
    await tester.pumpWidget(host(const Avatar(initials: 'JD')));
    expect(tester.widget<Text>(find.text('JD')).style!.fontFamily, TsuyaType.body.fontFamily);
    await tester.pumpWidget(
      host(
        const TsuyaTheme(
          typeface: 'Lora',
          child: Avatar(initials: 'JD'),
        ),
      ),
    );
    expect(tester.widget<Text>(find.text('JD')).style!.fontFamily, 'Lora');
  });

  testWidgets('a gradient that passes 4.5:1 on its darker colour (whichever position) shows white', (tester) async {
    const light = Color(0xFFEEEEEE);
    const dark = Color(0xFF000000);
    await tester.pumpWidget(host(const Avatar(initials: 'AL', colors: (light, dark), label: 'Alex Lee')));
    final decoration = _decoration(tester).decoration as BoxDecoration;
    expect(decoration.gradient, isNotNull);
    expect(tester.widget<Text>(find.text('AL')).style!.color, const Color(0xFFFFFFFF));
  });

  testWidgets('a gradient whose darker colour would not keep 4.5:1 falls back to fill', (tester) async {
    const a = Color(0xFFCCCCCC);
    const b = Color(0xFFDDDDDD);
    await tester.pumpWidget(host(const Avatar(initials: 'RK', colors: (a, b), label: 'Robin Kim')));
    final decoration = _decoration(tester).decoration as BoxDecoration;
    expect(decoration.gradient, isNull);
    expect(decoration.color, TsuyaColors.light.fill);
    expect(tester.widget<Text>(find.text('RK')).style!.color, TsuyaColors.light.textMuted);
  });

  testWidgets('a photo is decoded at physical pixels, keeping its aspect', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(devicePixelRatio: 3),
            child: Avatar(image: MemoryImage(_picture), size: 40),
          ),
        ),
      ),
    );
    final resized = tester.widget<Image>(find.byType(Image)).image as ResizeImage;
    expect(resized.height, 120);
    expect(resized.width, isNull);
    expect(resized.policy, ResizeImagePolicy.fit);
  });

  testWidgets('the initials stay inside the circle at text scale 3', (tester) async {
    await tester.pumpWidget(host(const Avatar(initials: 'MB'), textScale: 3));
    final size = tester.getSize(find.text('MB'));
    expect(size.width, lessThanOrEqualTo(40));
    expect(size.height, lessThanOrEqualTo(40));
  });

  testWidgets('a photo that fails to load falls back to the initials', (tester) async {
    await tester.pumpWidget(host(Avatar(image: MemoryImage(_picture), initials: 'BR', label: 'Bo Reyes')));
    final image = tester.widget<Image>(find.byType(Image));
    final fallback = image.errorBuilder!(tester.element(find.byType(Image)), Object(), null);
    expect(fallback, isA<SizedBox>());
    expect((fallback as SizedBox).width, 0);
  });

  testWidgets('without a label it is decorative: excluded from the semantics tree', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(const Avatar(initials: 'NL')));
    // ignore: deprecated_member_use (rootPipelineOwner is a different, unattached pipeline in this test harness)
    final tree = tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!.toStringDeep();
    expect(tree, isNot(contains('NL')));
    semantics.dispose();
  });

  testWidgets('a custom size scales the initials to 36 % of it', (tester) async {
    await tester.pumpWidget(
      host(
        const Center(
          child: Avatar(size: 64, initials: 'SZ', label: 'Size test'),
        ),
      ),
    );
    expect(tester.getSize(find.byType(Avatar)), const Size(64, 64));
    expect(tester.widget<Text>(find.text('SZ')).style!.fontSize, closeTo(64 * 0.36, 0.01));
  });
}
