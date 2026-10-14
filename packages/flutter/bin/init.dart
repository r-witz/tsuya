// `dart run tsuya:init`: copies DESIGN.md, the contract this package ships, into the project and
// points its AI agents to it with a line in AGENTS.md and CLAUDE.md (made when missing). Run it again after an
// upgrade of the package to refresh the copy; the line is written once.
import 'dart:io';
import 'dart:isolate';

Future<void> main() async {
  final library = await Isolate.resolvePackageUri(Uri.parse('package:tsuya/tsuya.dart'));
  if (library == null) {
    stderr.writeln('package:tsuya is not a dependency here: run flutter pub add tsuya in this folder first.');
    exitCode = 1;
    return;
  }
  exitCode = init(Directory.current, File.fromUri(library.resolve('../DESIGN.md')));
}

const _line =
    'This project uses the tsuya design system. Before building or changing any user interface, read DESIGN.md (the '
    "rules, the material, every component's spec and the tokens) and follow it; use the widgets of package:tsuya. "
    '`dart run tsuya:init` refreshes DESIGN.md after an upgrade.';

/// Copies [design] into [project] and points its agents to it: 0 when done, 1 when [project] has a DESIGN.md of its
/// own, which it leaves alone.
int init(Directory project, File design, {StringSink? out, StringSink? error}) {
  out ??= stdout;
  error ??= stderr;
  final text = design.readAsStringSync();
  final target = File('${project.path}/DESIGN.md');
  // the front matter's first two lines name the design system
  final head = text.substring(0, text.indexOf('\n', text.indexOf('\n') + 1) + 1);
  final old = target.existsSync() ? target.readAsStringSync() : null;
  if (old != null && !old.startsWith(head)) {
    error.writeln('DESIGN.md already exists and is not the one of tsuya: move it, then run again.');
    return 1;
  }
  if (old != text) target.writeAsStringSync(text);
  out.writeln('DESIGN.md: ${old == null ? 'copied' : (old == text ? 'up to date' : 'updated')}');
  for (final name in ['AGENTS.md', 'CLAUDE.md']) {
    final file = File('${project.path}/$name');
    final before = file.existsSync() ? file.readAsStringSync() : '';
    if (before.contains(_line)) {
      out.writeln('$name: already points to DESIGN.md');
      continue;
    }
    final gap = before.isEmpty ? '' : (before.endsWith('\n') ? '\n' : '\n\n');
    file.writeAsStringSync('$before$gap$_line\n');
    out.writeln('$name: ${before.isEmpty ? 'created' : 'added the line'}');
  }
  return 0;
}
