// The shared test helpers read what is rendered faithfully.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  testWidgets('pixelAt reads a translucent colour as it is, not premultiplied', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      Center(
        child: RepaintBoundary(
          key: key,
          child: const SizedBox.square(dimension: 8, child: ColoredBox(color: Color(0x80FF8000))),
        ),
      ),
    );
    final color = await pixelAt(tester, key, const Offset(4, 4));
    expect(color.toARGB32() >> 24, 0x80);
    expect((color.r * 255).round(), 0xFF);
    expect((color.g * 255).round(), closeTo(0x80, 1));
  });
}
