// Compiles every Flutter snippet of the docs (apps/docs/src/routes/components/*/flutter.ts): each one goes into a
// scratch app that depends on packages/flutter, and `flutter analyze` must find no error or warning in it.
// A snippet is an expression (a widget) or statements (`await Dialog.show…`); the state it reads (`volume`,
// `setState`…) is declared by the harness below, and so are the icon widgets the snippets say are the app's own.
import { execFileSync } from 'node:child_process';
import { mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const components = join(root, 'apps/docs/src/routes/components');

const HARNESS = `// ignore_for_file: unused_import, unused_local_variable, unused_element, unused_field
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';
import 'package:tsuya/tsuya.dart' as t;

// The app's own icons: tsuya ships no icon set.
${['Bell', 'Check', 'Filter', 'Home', 'Inbox', 'Library', 'More', 'Play', 'Plus', 'Search', 'Share', 'Shuffle']
  .map(
    (name) =>
      `class ${name}Icon extends StatelessWidget {\n  const ${name}Icon({super.key});\n  @override\n  Widget build(BuildContext context) => const SizedBox();\n}`,
  )
  .join('\n')}

class Snippets extends State<StatefulWidget> {
  List<String> open = [];
  bool showTip = true, remember = false, downloaded = false, shuffle = false, showHidden = false;
  bool wifiEnabled = true;
  String sort = 'recent', sortBy = 'title', size = 'm', view = 'list', country = 'fr', current = 'home';
  String selected = 'overview';
  Set<String> genres = {};
  double volume = 50;
  void play() {}
  List<TabBarItem<String>> items = const [];
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) => const SizedBox();
`;

const snippets = [];
for (const dir of readdirSync(components, { withFileTypes: true })) {
  if (!dir.isDirectory()) continue;
  let source;
  try {
    source = readFileSync(join(components, dir.name, 'flutter.ts'), 'utf8');
  } catch {
    continue;
  }
  for (const [, name, body] of source.matchAll(/export const (\w+) = `([\s\S]*?)`\.trim\(\);/g)) {
    // a template literal's escapes: \${ is a literal ${
    const code = body.replace(/\\\$/g, '$').trim();
    for (const [index, chunk] of code.split(/\n\s*\n/).entries()) {
      // what is not code: the imports and the comments that lead a chunk
      const lines = chunk.split('\n');
      while (lines.length && /^\s*(import |\/\/)/.test(lines[0])) lines.shift();
      if (lines.length) snippets.push({ id: `${dir.name}/${name}#${index}`, code: lines.join('\n') });
    }
  }
}

const methods = snippets.map(({ id, code }, n) => {
  const statements = /^(final|var|await)\b/.test(code) || /;\s*$/.test(code);
  const body = statements ? `Future<void> s${n}() async {\n${code}\n}` : `Widget s${n}() => ${code};`;
  return `  // ${id}\n${body.replace(/^/gm, (m, offset) => (offset === 0 ? '' : '  '))}`;
});

const dir = mkdtempSync(join(tmpdir(), 'tsuya-snippets-'));
try {
  mkdirSync(join(dir, 'lib'));
  writeFileSync(
    join(dir, 'pubspec.yaml'),
    `name: snippets\nenvironment:\n  sdk: ^3.12.0\ndependencies:\n  flutter:\n    sdk: flutter\n  tsuya:\n    path: ${join(root, 'packages/flutter')}\n`,
  );
  writeFileSync(join(dir, 'analysis_options.yaml'), 'analyzer:\n  language:\n    strict-casts: true\n');
  writeFileSync(join(dir, 'lib/snippets.dart'), `${HARNESS}\n${methods.join('\n')}\n}\n`);
  execFileSync('flutter', ['pub', 'get', '--offline'], { cwd: dir, stdio: 'pipe' });
  let output = '';
  try {
    output = execFileSync('flutter', ['analyze', '--no-fatal-infos'], { cwd: dir, encoding: 'utf8', stdio: 'pipe' });
  } catch (error) {
    output = `${error.stdout ?? ''}${error.stderr ?? ''}`;
  }
  const generated = readFileSync(join(dir, 'lib/snippets.dart'), 'utf8').split('\n');
  const problems = output.split('\n').filter((line) => /^\s*(error|warning) •/.test(line));
  for (const problem of problems) {
    const at = /lib\/snippets\.dart:(\d+):/.exec(problem);
    let origin = '';
    for (let i = Number(at?.[1] ?? 0) - 1; i >= 0; i--) {
      const marker = /^ {2}\/\/ (\S+#\d+)$/.exec(generated[i]);
      if (marker) {
        origin = marker[1];
        break;
      }
    }
    console.error(`${origin}: ${problem.trim()}`);
  }
  if (problems.length) {
    console.error(`\n${problems.length} problem(s) in the docs' Flutter snippets`);
    process.exitCode = 1;
  } else {
    console.log(`✓ ${snippets.length} Flutter snippets compile`);
  }
} finally {
  rmSync(dir, { recursive: true, force: true });
}
