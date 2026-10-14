// Every Dart snippet of the package's README is in lib/readme/, where the analyzer compiles it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// whitespace and trailing commas are the formatter's to move
String _squash(String code) => code.replaceAll(RegExp(r'\s+'), '').replaceAllMapped(RegExp(r',([)\]}])'), (m) => m[1]!);

void main() {
  test('the README\'s Dart snippets are compiled in lib/readme/', () {
    final readme = File('../README.md').readAsStringSync();
    final snippets = RegExp(r'```dart\n(.*?)```', dotAll: true).allMatches(readme).map((m) => m.group(1)!).toList();
    final compiled = Directory(
      'lib/readme',
    ).listSync().whereType<File>().map((file) => _squash(file.readAsStringSync())).join();
    expect(snippets, isNotEmpty);
    for (final snippet in snippets) {
      expect(compiled, contains(_squash(snippet)), reason: snippet);
    }
  });
}
