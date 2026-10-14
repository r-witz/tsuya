// The web budgets, measured on the built packages (run `npm run build --workspaces` first): @tsuya/core's
// JavaScript (engine and helpers) at most 10 KB gzip, its CSS at most 20 KB gzip, each font subset at most 40 KB, and
// each Svelte component tree-shaken (an app importing only Button gets Button, not the library). Prints each figure
// and exits non-zero when one is over. A release gate; CI runs it with `--skip-fonts`, the fonts being
// over until https://github.com/r-witz/tsuya/issues/7 is settled.
import { readdirSync, statSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { gzipSync } from 'node:zlib';

import { svelte } from '@sveltejs/vite-plugin-svelte';
import { bundle as bundleCss } from 'lightningcss';
import { build } from 'vite';

const ROOT = fileURLToPath(new URL('../', import.meta.url));
const KB = 1024;
const rows = [];

function check(name, bytes, budget) {
  rows.push({ name, size: `${(bytes / KB).toFixed(1)} KB`, budget: `${budget / KB} KB`, ok: bytes <= budget });
}

const gzip = (text) => gzipSync(text, { level: 9 }).length;

// An app's production bundle of `code`, minified: the JavaScript and the CSS it ends up with, gzipped.
async function appBundle(code) {
  const entry = '\0budget-entry.js';
  const output = await build({
    root: ROOT,
    configFile: false,
    logLevel: 'silent',
    plugins: [
      svelte({ compilerOptions: { css: 'external' } }),
      {
        name: 'budget-entry',
        resolveId: (id) => (id === 'budget-entry' ? entry : undefined),
        load: (id) => (id === entry ? code : undefined),
      },
    ],
    build: { write: false, minify: true, cssMinify: true, rollupOptions: { input: 'budget-entry' } },
  });
  const files = (Array.isArray(output) ? output : [output]).flatMap((o) => o.output);
  // the bytes each module of @tsuya/svelte's components left in the bundle, before minifying
  const rendered = files
    .filter((f) => f.type === 'chunk')
    .flatMap((f) => Object.entries(f.modules))
    .filter(([id, m]) => m.renderedLength > 0 && id.includes('packages/svelte/dist/components/'))
    .map(([id, m]) => ({ dir: id.split('/components/')[1].split('/')[0], bytes: m.renderedLength }));
  const sum = (ext) =>
    gzip(
      files
        .filter((f) => f.fileName.endsWith(ext))
        .map((f) => (f.type === 'chunk' ? f.code : String(f.source)))
        .join('\n'),
    );
  return { js: sum('.js'), css: sum('.css'), rendered };
}

// @tsuya/core: everything its main entry exports, kept alive by the app
const core = await appBundle("import * as core from '@tsuya/core'; globalThis.core = core;");
check('@tsuya/core JavaScript (engine and helpers)', core.js, 10 * KB);

// the CSS an app imports: tokens, base, material and the components' styles, its @imports resolved
const { code: css } = bundleCss({ filename: `${ROOT}packages/core/src/css/tsuya.css`, minify: true });
check('@tsuya/core CSS (tsuya.css)', gzip(css), 20 * KB);

const fonts = `${ROOT}packages/core/fonts/`;
for (const file of process.argv.includes('--skip-fonts')
  ? []
  : readdirSync(fonts).filter((f) => f.endsWith('.woff2'))) {
  check(`font ${file}`, statSync(fonts + file).size, 40 * KB);
}

// tree-shaking: an app importing only Button gets Button and the Spinner it shows while loading; what other
// components leave (a line that registers their events) stays under 1 KB
const button = await appBundle("import { Button } from '@tsuya/svelte'; globalThis.Button = Button;");
const others = button.rendered.filter((m) => !['button', 'spinner'].includes(m.dir));
const left = others.reduce((total, m) => total + m.bytes, 0);
check(
  `Svelte: other components' code in a Button-only app (${[...new Set(others.map((m) => m.dir))].join(', ')})`,
  left,
  KB,
);

const width = Math.max(...rows.map((r) => r.name.length));
for (const r of rows) console.log(`${r.ok ? '✓' : '✗'} ${r.name.padEnd(width)}  ${r.size.padStart(20)}  ≤ ${r.budget}`);
if (rows.some((r) => !r.ok)) process.exitCode = 1;
