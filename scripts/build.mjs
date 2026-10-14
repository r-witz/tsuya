// Writes every generated file from tokens/: the token outputs, DESIGN.md and its copies, the grain tile and
// spec/cases.json. Nothing is written unless every check passes: well-formed tokens, the same
// tokens in both modes, one token per CSS name, the contrast guarantees (G1, G2) at their worst, and a DESIGN.md that
// names only existing tokens.
// Node 22.18+ with no dependencies, and the Dart SDK for `dart format`: `node scripts/build.mjs`.
import { spawnSync } from 'node:child_process';
import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

import { checkContrast, checkStructure, formatReport } from './checks.mjs';
import { buildCss } from './css.mjs';
import { buildDart } from './dart.mjs';
import { buildDesign } from './design.mjs';
import { buildGrain } from './grain.mjs';
import { buildTs } from './ts.mjs';
import { core, read, ROOT, valueOf } from './tokens.mjs';

const DART_OUT = 'packages/flutter/lib/src/foundation/tokens.g.dart';
const DESIGN_COPIES = ['packages/core/DESIGN.md', 'packages/svelte/DESIGN.md', 'packages/flutter/DESIGN.md'];
// the copies, which git ignores, ship DESIGN.md with each package; the three packages are released together, with
// one changelog
const CHANGELOG_COPIES = [
  'packages/core/CHANGELOG.md',
  'packages/svelte/CHANGELOG.md',
  'packages/flutter/CHANGELOG.md',
];

function fail(errors) {
  console.error(errors.map((e) => `✗ ${e}`).join('\n'));
  process.exit(1);
}

// formatted as `dart format` formats the package: its page width and the language version of its SDK constraint
function formatDart(source) {
  const width = /page_width:\s*(\d+)/.exec(read('packages/flutter/analysis_options.yaml'))?.[1];
  const language = /sdk:\s*\^(\d+\.\d+)/.exec(read('packages/flutter/pubspec.yaml'))?.[1];
  if (!width || !language) fail(['packages/flutter needs formatter.page_width and an `sdk: ^x.y` constraint.']);
  // --suppress-analytics: the notice of a first run would land in the output
  const args = [
    '--suppress-analytics',
    'format',
    '--output=show',
    `--page-width=${width}`,
    `--language-version=${language}`,
    `--stdin-name=${DART_OUT}`,
  ];
  const run = spawnSync('dart', args, { input: source, encoding: 'utf8' });
  if (run.status !== 0) fail([`dart format failed (is the Dart SDK on PATH?)\n${run.stderr ?? run.error}`]);
  return run.stdout;
}

const structure = checkStructure();
if (structure.length) fail(structure);

const contrast = checkContrast();
console.log(`Contrast, worst case of each check:\n${formatReport(contrast.report)}\n`);
const design = buildDesign(read('DESIGN.md'));
const errors = [...contrast.errors];
if (design.unknown.length) errors.push(`DESIGN.md names tokens that do not exist: ${design.unknown.join(', ')}`);
if (errors.length) fail(errors);

const grainSize = valueOf(core.find((t) => t.path.join('.') === 'grain.size')).value;
const outputs = [
  ['packages/core/src/css/tokens.css', buildCss()],
  ['packages/core/src/tokens.ts', buildTs()],
  ['packages/core/src/css/grain.png', buildGrain(grainSize)],
  [DART_OUT, formatDart(buildDart())],
  ['DESIGN.md', design.text],
  ...DESIGN_COPIES.map((path) => [path, design.text]),
  ...CHANGELOG_COPIES.map((path) => [path, read('CHANGELOG.md')]),
];
const write = (files) => {
  for (const [path, content] of files) writeFileSync(new URL(path, ROOT), content);
};
write(outputs);

// the engine reads src/tokens.ts, now written: it runs in its own process, where nothing has imported it yet
const cases = spawnSync(process.execPath, [fileURLToPath(new URL('scripts/cases.mjs', ROOT))], {
  encoding: 'utf8',
  maxBuffer: 64 * 1024 * 1024,
});
if (cases.status !== 0) fail([`scripts/cases.mjs failed\n${cases.stderr}`]);
const engineOutputs = [['spec/cases.json', cases.stdout]];
write(engineOutputs);
console.log([...outputs, ...engineOutputs].map(([path]) => `✓ ${path}`).join('\n'));
