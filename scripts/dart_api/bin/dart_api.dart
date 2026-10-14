// Writes apps/docs/src/lib/generated/dart-api/<Name>.json, one file per type of package:tsuya that a component page
// shows in its "Dart API" table (`<DartApi types={['Button', 'ButtonKind']} />`). It parses the sources (no type
// resolution) of what lib/tsuya.dart exports, honouring `show`, and lists for each public class its constructors'
// parameters (name, type, required, default, the first paragraph of the field's doc comment) and its public static
// methods; for each enum its values. Committed, so that the docs build needs no Dart; `--check` fails when the files
// are stale (CI, Flutter job).
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

final _root = File.fromUri(Platform.script).parent.parent.parent.parent.path;
final _lib = '$_root/packages/flutter/lib';
final _pages = Directory('$_root/apps/docs/src/routes/components');
final _out = Directory('$_root/apps/docs/src/lib/generated/dart-api');

void main(List<String> args) {
  final api = <String, Object>{};
  _exports(File('$_lib/tsuya.dart'), null, api);
  final shown = _shown();
  final unknown = shown.where((name) => !api.containsKey(name));
  if (unknown.isNotEmpty) {
    stderr.writeln('the docs show types that package:tsuya does not export: ${unknown.join(', ')}');
    exitCode = 1;
    return;
  }
  final files = {for (final name in shown) '$name.json': '${const JsonEncoder.withIndent('  ').convert(api[name])}\n'};
  if (args.contains('--check')) {
    final existing = _out.existsSync() ? _out.listSync().whereType<File>().toList() : <File>[];
    final stale =
        existing.length != files.length ||
        existing.any((file) => files[file.uri.pathSegments.last] != file.readAsStringSync());
    if (stale) {
      stderr.writeln('${_out.path} is stale: run `dart run bin/dart_api.dart` in scripts/dart_api');
      exitCode = 1;
    }
    return;
  }
  if (_out.existsSync()) _out.deleteSync(recursive: true);
  _out.createSync(recursive: true);
  for (final MapEntry(:key, :value) in files.entries) {
    File('${_out.path}/$key').writeAsStringSync(value);
  }
}

// The types the docs show: every name in a `<DartApi types={[…]}` of a component page.
Set<String> _shown() => {
  for (final file in _pages.listSync(recursive: true).whereType<File>())
    if (file.path.endsWith('.svelte'))
      for (final table in RegExp(r'<DartApi\s+types=\{\[([^\]]*)\]').allMatches(file.readAsStringSync()))
        for (final name in RegExp(r"'(\w+)'").allMatches(table[1]!)) name[1]!,
};

// What [file] declares and exports (a file can re-export another), kept to [only] when an export narrowed it.
void _exports(File file, Set<String>? only, Map<String, Object> api) {
  final unit = _parse(file.path);
  bool wanted(String name) => !name.startsWith('_') && (only == null || only.contains(name));
  for (final directive in unit.directives.whereType<ExportDirective>()) {
    final shown = {
      for (final combinator in directive.combinators.whereType<ShowCombinator>())
        for (final name in combinator.shownNames) name.name,
    };
    final narrowed = shown.isEmpty ? only : {...shown.where(wanted)};
    _exports(File.fromUri(file.uri.resolve(directive.uri.stringValue!)), narrowed, api);
  }
  for (final declaration in unit.declarations) {
    final (name, entry) = switch (declaration) {
      ClassDeclaration(:final namePart) => (namePart.typeName.lexeme, _class(declaration)),
      EnumDeclaration(:final namePart) => (namePart.typeName.lexeme, _enum(declaration)),
      _ => ('', null),
    };
    if (entry != null && wanted(name)) api[name] = entry;
  }
}

CompilationUnit _parse(String path) => parseFile(path: path, featureSet: FeatureSet.latestLanguageVersion()).unit;

// The first paragraph of a doc comment, its lines joined; `[Foo]` references kept as `Foo`.
String _doc(Comment? comment) {
  if (comment == null) return '';
  final lines = [for (final token in comment.tokens) token.lexeme.replaceFirst(RegExp(r'^///\s?'), '')];
  final end = lines.indexWhere((line) => line.trim().isEmpty);
  return (end < 0 ? lines : lines.sublist(0, end)).join(' ').replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) => m[1]!);
}

Map<String, Object>? _class(ClassDeclaration declaration) {
  final members = switch (declaration.body) {
    BlockClassBody(:final members) => members,
    _ => const <ClassMember>[],
  };
  final fields = <String, FieldDeclaration>{
    for (final field in members.whereType<FieldDeclaration>())
      for (final variable in field.fields.variables) variable.name.lexeme: field,
  };
  final constructors = [
    for (final constructor in members.whereType<ConstructorDeclaration>())
      if (!(constructor.name?.lexeme.startsWith('_') ?? false))
        {
          'name': constructor.name?.lexeme ?? '',
          'description': _doc(constructor.documentationComment),
          'params': [
            for (final parameter in constructor.parameters.parameters)
              if (_param(parameter, fields) case final param?) param,
          ],
        },
  ];
  final statics = [
    for (final method in members.whereType<MethodDeclaration>())
      if (method.isStatic && !method.name.lexeme.startsWith('_'))
        {
          'name': method.name.lexeme,
          'signature':
              '${method.returnType ?? 'void'} ${method.name.lexeme}'
              '${method.typeParameters ?? ''}${method.parameters}',
          'description': _doc(method.documentationComment),
        },
  ];
  return {
    'kind': 'class',
    'description': _doc(declaration.documentationComment),
    'constructors': constructors,
    'statics': statics,
  };
}

// A constructor parameter, typed by its field for `this.x`, documented by that field; null for `super.key`.
Map<String, Object>? _param(FormalParameter parameter, Map<String, FieldDeclaration> fields) {
  final name = parameter.name?.lexeme ?? '';
  if (parameter is SuperFormalParameter && name == 'key') return null;
  final field = fields[name];
  return {
    'name': name,
    'type': '${parameter.type ?? field?.fields.type ?? ''}',
    'required': parameter.isRequired,
    'named': parameter.isNamed,
    'default': '${parameter.defaultClause?.value ?? ''}',
    'description': _doc(field?.documentationComment),
  };
}

Map<String, Object> _enum(EnumDeclaration declaration) => {
  'kind': 'enum',
  'description': _doc(declaration.documentationComment),
  'values': [
    for (final constant in declaration.body.constants)
      {'name': constant.name.lexeme, 'description': _doc(constant.documentationComment)},
  ],
};
