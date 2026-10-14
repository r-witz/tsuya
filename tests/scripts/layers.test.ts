// The cascade layers: "declared first in every CSS file". A file may reach the page before tsuya.css does (a page
// links one component's file, or a bundler orders the CSS as it likes); if it opened `tsuya.components` first, that
// layer would be the weakest, and the base's `button { color: inherit }` would beat a primary button's own colour.
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { expect, test } from 'vitest';

const ROOT = new URL('../../', import.meta.url).pathname;
const ORDER = '@layer tsuya.tokens, tsuya.base, tsuya.material, tsuya.components;';

const files = (dir: string, ext: string): string[] =>
  readdirSync(join(ROOT, dir), { recursive: true, encoding: 'utf8' })
    .filter((name) => name.endsWith(ext))
    .map((name) => join(dir, name));

test('no Svelte component has a style of its own: their styles are in @tsuya/core', () => {
  const styled = files('packages/svelte/src/lib', '.svelte').filter((f) =>
    readFileSync(join(ROOT, f), 'utf8').includes('<style'),
  );
  expect(styled).toEqual([]);
});

test('every core CSS file declares the layer order before any rule', () => {
  for (const f of files('packages/core/src/css', '.css')) {
    const css = readFileSync(join(ROOT, f), 'utf8')
      .replace(/\/\*[\s\S]*?\*\//g, '')
      .trim();
    expect(css.startsWith(ORDER), f).toBe(true);
  }
});
