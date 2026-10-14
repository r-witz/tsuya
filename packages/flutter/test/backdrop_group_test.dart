// G11: each glass surface reads its own backdrop under Impeller. Under Impeller, widgets sharing a `BackdropGroup`
// reuse the first one's backdrop sample, so a later glass would not see what scrolled under it (DESIGN.md, The
// material: Glass). No file under lib/ may use it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no file under lib/ references BackdropGroup, backdropGroupKey or BackdropFilter.grouped(', () {
    const needles = ['BackdropGroup', 'backdropGroupKey', 'BackdropFilter.grouped('];
    final offending = [
      for (final file in Directory('lib').listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.dart'))
          for (final needle in needles)
            if (file.readAsStringSync().contains(needle)) '${file.path}: $needle',
    ];
    expect(offending, isEmpty);
  });
}
