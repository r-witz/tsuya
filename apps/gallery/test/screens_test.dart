// Every screen builds without an exception, overflow errors included, at the narrowest width and at the largest text
// (G7: up to 300 % nothing overflows; 320 px is the web's reflow width), and in right-to-left.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';
import 'package:tsuya_gallery/src/app/registry.dart';
import 'package:tsuya_gallery/src/app/settings.dart';
import 'package:tsuya_gallery/src/app/shell.dart';

import 'support.dart';

void main() {
  test('every id is unique: the goldens are named after it', () {
    final ids = allEntries.map((e) => e.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('the gallery has the 33 components, the 4 parts of the material and the 11 blocks of DESIGN.md', () {
    expect(allEntries.where((e) => e.kind.name == 'material'), hasLength(4));
    expect(allEntries.where((e) => e.isBlock), hasLength(11));
    // 33 numbered components, TopBar with ScreenBar and TabBar with Screen counted once each, and the glyphs
    expect(allEntries.where((e) => e.kind.name == 'component'), hasLength(34));
  });

  for (final entry in allEntries) {
    testWidgets('${entry.title} at 320 wide and text scale 3', (tester) async {
      await pumpEntry(
        tester,
        entry,
        size: const Size(320, 640),
        settings: const GallerySettings(mode: TsuyaMode.dark, textScale: 3, reduceMotion: true),
        whole: true,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('${entry.title} right to left, on a phone and on a desktop', (tester) async {
      for (final size in [phone, desktop]) {
        await pumpEntry(
          tester,
          entry,
          size: size,
          settings: const GallerySettings(rtl: true, textScale: 1.3, reduceMotion: true),
          whole: true,
        );
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('the shell at 320 wide and text scale 3, on every tab and on a desktop', (tester) async {
    setScreen(tester, const Size(320, 640));
    await pumpHome(tester, const GalleryShell(), settings: const GallerySettings(textScale: 3, reduceMotion: true));
    for (final tab in ['Blocks', 'Controls', 'Components']) {
      await tester.tap(find.text(tab));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
    }
    setScreen(tester, desktop);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
