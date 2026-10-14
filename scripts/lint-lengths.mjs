// Refuses raw lengths and durations in component styles (packages/core/src/css/components, and the style attributes
// of the Svelte components): every value is a token, or its line says why it is not with a comment, which covers every
// value on that line: `width: 240px; /* raw: a sidebar is 240 wide */`. Allowed anywhere: zero, 1px hairlines and 100%.
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { join, relative } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const DIRS = ['../packages/svelte/src/lib/', '../packages/core/src/css/components/'].map((dir) =>
  fileURLToPath(new URL(dir, import.meta.url)),
);
const UNITS = 'px|rem|em|ex|ch|vw|vh|vmin|vmax|dvh|dvw|svh|svw|lvh|lvw|cqw|cqh|cqi|cqb|cqmin|cqmax|ms|s|%';
// a number with a unit, not inside a name or a hex colour (.icon-24px, #1e3); negative values count too
const VALUE = new RegExp(`(?<![\\w.#-])(-?\\d*\\.?\\d+)(${UNITS})(?![\\w-])`, 'g');
const ALWAYS = new Set(['1px', '100%']);
// a comment that gives a reason: /* raw: <reason> */
const RAW = /\/\*\s*raw:\s*[^*\s][^*]*\*\//;

/**
 * The raw lengths and durations of a style sheet, except those always allowed and those on a line that says why.
 * @returns {{ value: string, line: number }[]}
 */
export function rawLengths(css) {
  const lines = css.split('\n');
  const found = [];
  // comments may hold any number; keep the line count by blanking them
  const code = css.replace(/\/\*[\s\S]*?\*\//g, (c) => c.replace(/[^\n]/g, ' '));
  code.split('\n').forEach((text, i) => {
    if (RAW.test(lines[i] ?? '')) return;
    for (const [value, number] of text.matchAll(VALUE)) {
      if (Number(number) !== 0 && !ALWAYS.has(value)) found.push({ value, line: i + 1 });
    }
  });
  return found;
}

// the styles of a Svelte file: its <style> blocks and its style attributes and directives; everything else is blanked
// so that line numbers stay the file's
function styles(source, file) {
  if (file.endsWith('.css')) return source;
  const keep = [
    ...[...source.matchAll(/<style[^>]*>([\s\S]*?)<\/style>/dg)].map((m) => m.indices[1]),
    ...[...source.matchAll(/\sstyle(?::[\w-]+)?="([^"]*)"/dg)].map((m) => m.indices[1]),
  ];
  const inside = (i) => keep.some(([start, end]) => i >= start && i < end);
  // split('') walks UTF-16 units, as the match indices count them
  return source
    .split('')
    .map((c, i) => (c === '\n' || inside(i) ? c : ' '))
    .join('');
}

function files(dir) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) return files(path);
    return /\.(svelte|css)$/.test(entry.name) ? [path] : [];
  });
}

/**
 * Every raw value of the component styles that does not say why, as "file: raw value v (line n); …".
 * @param {string | string[]} [dirs]
 * @returns {string[]}
 */
export function checkLengths(dirs = DIRS) {
  return [dirs].flat().flatMap((dir) =>
    files(dir).flatMap((path) => {
      const file = relative(dir, path);
      return rawLengths(styles(readFileSync(path, 'utf8'), file)).map(
        ({ value, line }) =>
          `${file}: raw value ${value} (line ${line}); use a token, or say why: /* raw: <reason> */.`,
      );
    }),
  );
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  const errors = checkLengths();
  if (errors.length) {
    console.error(errors.map((e) => `✗ ${e}`).join('\n'));
    process.exit(1);
  }
  console.log('✓ no raw lengths in component styles');
}
