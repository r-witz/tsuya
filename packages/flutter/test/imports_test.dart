// The package stays on the widgets layer: no file under lib/ imports or exports Material or Cupertino.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// an import or export directive, up to its semicolon: it may span lines and name conditional URIs
final _directive = RegExp(r'^\s*(?:import|export)\b[^;]*;', multiLine: true);
final _uri = RegExp(r'''['"]([^'"]*)['"]''');
final _material = RegExp(r'^package:flutter/(?:src/)?(?:material|cupertino)(?:\.dart|/)');

/// The material and cupertino URIs that the directives of [source] import or export.
List<String> _forbiddenUris(String source) => [
  for (final directive in _directive.allMatches(source))
    for (final uri in _uri.allMatches(directive[0]!))
      if (_material.hasMatch(uri[1]!)) uri[1]!,
];

void main() {
  test('the check catches material and cupertino in any import or export, conditional ones too', () {
    bool flagged(String source) => _forbiddenUris(source).isNotEmpty;
    expect(flagged("import 'package:flutter/material.dart';"), isTrue);
    expect(flagged('export "package:flutter/cupertino.dart" show CupertinoIcons;'), isTrue);
    expect(flagged("import 'package:flutter/src/material/colors.dart';"), isTrue);
    expect(
      flagged("import 'package:flutter/widgets.dart' if (dart.library.io) 'package:flutter/material.dart';"),
      isTrue,
    );
    expect(flagged("import 'stub.dart'\n    if (dart.library.io) 'package:flutter/cupertino.dart';"), isTrue);
    expect(flagged("import 'package:flutter/widgets.dart';"), isFalse);
    expect(flagged("// import 'package:flutter/material.dart';"), isFalse);
    expect(flagged("const uri = 'package:flutter/material.dart';"), isFalse);
  });

  test('no file under lib/ imports or exports material or cupertino', () {
    final offending = [
      for (final file in Directory('lib').listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.dart'))
          for (final uri in _forbiddenUris(file.readAsStringSync())) '${file.path}: $uri',
    ];
    expect(offending, isEmpty);
  });
}
