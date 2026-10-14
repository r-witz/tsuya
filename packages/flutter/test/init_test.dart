// `dart run tsuya:init`: DESIGN.md copied into the project and a line in AGENTS.md and CLAUDE.md
// that points its agents to it, written once; another project's own DESIGN.md is left alone.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../bin/init.dart';

void main() {
  late Directory project;
  final design = File('../../DESIGN.md');
  final out = StringBuffer();

  setUp(() {
    project = Directory.systemTemp.createTempSync('tsuya-init-');
    out.clear();
  });
  tearDown(() => project.deleteSync(recursive: true));

  String read(String name) => File('${project.path}/$name').readAsStringSync();

  test('copies DESIGN.md and writes AGENTS.md and CLAUDE.md, each one line that points to it', () {
    expect(init(project, design, out: out), 0);
    expect(read('DESIGN.md'), design.readAsStringSync());
    for (final name in ['AGENTS.md', 'CLAUDE.md']) {
      expect(read(name).split('\n'), hasLength(2));
      expect(read(name), contains('read DESIGN.md'));
    }
    expect(out.toString(), contains('AGENTS.md: created'));
  });

  test('a second run changes nothing', () {
    init(project, design, out: out);
    final before = read('AGENTS.md');
    out.clear();
    expect(init(project, design, out: out), 0);
    expect(read('AGENTS.md'), before);
    expect(out.toString(), contains('DESIGN.md: up to date'));
    expect(out.toString(), contains('AGENTS.md: already points to DESIGN.md'));
  });

  test('refreshes an older copy of DESIGN.md', () {
    final head = design.readAsLinesSync().take(2).join('\n');
    File('${project.path}/DESIGN.md').writeAsStringSync('$head\nan older version\n');
    expect(init(project, design, out: out), 0);
    expect(read('DESIGN.md'), design.readAsStringSync());
    expect(out.toString(), contains('DESIGN.md: updated'));
  });

  test("keeps a file's own text, the line after a blank one", () {
    File('${project.path}/AGENTS.md').writeAsStringSync('# Agents\n\nUse fvm.');
    init(project, design, out: out);
    expect(read('AGENTS.md'), startsWith('# Agents\n\nUse fvm.\n\nThis project uses'));
    expect(read('AGENTS.md'), endsWith('\n'));
  });

  test("leaves the project's own DESIGN.md alone and writes nothing", () {
    File('${project.path}/DESIGN.md').writeAsStringSync('# Our design\n');
    expect(init(project, design, out: out, error: out), 1);
    expect(read('DESIGN.md'), '# Our design\n');
    expect(File('${project.path}/AGENTS.md').existsSync(), isFalse);
    expect(out.toString(), contains('DESIGN.md already exists'));
  });
}
