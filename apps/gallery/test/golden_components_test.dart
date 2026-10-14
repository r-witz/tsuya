// One golden per component screen and mode, at phone width and as tall as the page. Written with
// `flutter test --update-goldens`; see README.md.
@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';
import 'package:tsuya_gallery/src/app/host.dart';
import 'package:tsuya_gallery/src/app/registry.dart';
import 'package:tsuya_gallery/src/app/settings.dart';

import 'support.dart';

void main() {
  for (final entry in allEntries.where((e) => !e.isBlock)) {
    for (final mode in [TsuyaMode.light, TsuyaMode.dark]) {
      testWidgets('${entry.title}, ${mode.name}', (tester) async {
        await withShadows(() async {
          await pumpEntry(tester, entry, settings: GallerySettings(mode: mode, reduceMotion: true), whole: true);
          await expectLater(
            find.byType(GalleryHost),
            matchesGoldenFile('goldens/components/${entry.id}-${mode.name}.png'),
          );
        });
      });
    }
  }
}
