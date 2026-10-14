// The generated tokens as Flutter sees them: their types and units, and type styles that resolve to the bundled
// fonts. That every token of tokens/ is in tokens.g.dart with its value is checked by the build's tests.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

double _width(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

void main() {
  test('tokens keep their units: lengths in logical pixels, durations, curves, colours with alpha', () {
    expect(TsuyaSpace.s16, 16.0);
    expect(TsuyaContainer.gutterPhone, TsuyaSpace.s16);
    expect(TsuyaDuration.sheet, const Duration(milliseconds: 450));
    expect(TsuyaEasing.emphasized, const Cubic(0.22, 1, 0.36, 1));
    expect(TsuyaColors.light.textMuted, const Color(0xA30A0A0C));
    expect(TsuyaColors.dark.bg, const Color(0xFF0A0A0C));
    expect(TsuyaMaterial.dark.ambientCap, 0.055);
    expect(TsuyaShadows.light.lg.single.offset, const Offset(0, 24));
  });

  test('type styles point to the fonts bundled with the package', () {
    expect(TsuyaType.body.fontFamily, 'packages/tsuya/Inter');
    expect(TsuyaType.mono.fontFamily, 'packages/tsuya/Geist Mono');
    expect(TsuyaType.label.letterSpacing, 1.68);
    expect(TsuyaType.displayXl.fontWeight, FontWeight.w800);
  });

  testWidgets('the bundled fonts load and lay text out, not the square test font', (tester) async {
    // real file and engine I/O does not advance inside the fake async zone of testWidgets
    await tester.runAsync(loadTsuyaFonts);
    // the test font draws every glyph as a square as wide as the font size: 4 × 20 for "iiii"
    final square = _width('iiii', const TextStyle(fontSize: 20));
    for (final style in [TsuyaType.small, TsuyaType.body, TsuyaType.bodyStrong, TsuyaType.button, TsuyaType.displayS]) {
      expect(_width('iiii', style.copyWith(fontSize: 20)), lessThan(square / 2), reason: '${style.fontWeight}');
    }
    // Geist Mono: every glyph has the same advance, narrower than a square
    final mono = TsuyaType.mono.copyWith(fontSize: 20);
    expect(_width('iiii', mono), closeTo(_width('MMMM', mono), 0.01));
    expect(_width('iiii', mono), lessThan(square));
  });
}
