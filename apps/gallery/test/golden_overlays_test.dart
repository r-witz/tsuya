// What opens from a component screen, open: the menu, popover, dialog, sheet, command palette, toast and select, light
// and dark, at phone width. Written with `flutter test --update-goldens`; see README.md.
@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';
import 'package:tsuya_gallery/src/app/host.dart';
import 'package:tsuya_gallery/src/app/registry.dart';
import 'package:tsuya_gallery/src/app/settings.dart';

import 'support.dart';

// the screen, and the text of the control that opens what it shows
const _opened = [
  ('menu', 'Track options'),
  ('popover', 'Filters'),
  ('dialog', 'Delete album'),
  ('sheet', 'Add to playlist'),
  ('command-palette', 'Search commands'),
  ('toast', 'Remove track'),
  ('select', 'Choose a language'),
];

void main() {
  for (final (id, opener) in _opened) {
    final entry = allEntries.firstWhere((e) => e.id == id);
    for (final mode in [TsuyaMode.light, TsuyaMode.dark]) {
      testWidgets('${entry.title}, open, ${mode.name}', (tester) async {
        await withShadows(() async {
          await pumpEntry(tester, entry, settings: GallerySettings(mode: mode, reduceMotion: true));
          await tester.ensureVisible(find.text(opener).last);
          await tester.tap(find.text(opener).last);
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          await settle(tester);
          await expectLater(find.byType(GalleryHost), matchesGoldenFile('goldens/overlays/$id-open-${mode.name}.png'));
        });
      });
    }
  }
}
