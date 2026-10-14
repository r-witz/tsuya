// The bundled fonts: the committed files are the ones the manifest records, and both packages declare
// exactly those files.
import { createHash } from 'node:crypto';
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, test } from 'vitest';

const ROOT = new URL('../../', import.meta.url).pathname;
const read = (path: string) => readFileSync(join(ROOT, path));
const manifest = JSON.parse(read('packages/core/fonts/manifest.json').toString()) as { files: Record<string, string> };

describe('fonts', () => {
  test('every font file matches its SHA-256 in the manifest, and the manifest lists every font file', () => {
    for (const [path, hash] of Object.entries(manifest.files)) {
      expect(createHash('sha256').update(read(path)).digest('hex'), path).toBe(hash);
    }
    const onDisk = ['packages/core/fonts', 'packages/flutter/fonts'].flatMap((dir) =>
      readdirSync(join(ROOT, dir))
        .filter((name) => /\.(woff2|ttf)$/.test(name))
        .map((name) => `${dir}/${name}`),
    );
    expect(Object.keys(manifest.files).sort()).toEqual(onDisk.sort());
  });

  test('fonts.css declares each woff2 once, with font-display: swap', () => {
    const css = read('packages/core/fonts/fonts.css').toString();
    const urls = [...css.matchAll(/url\('\.\/([\w-]+\.woff2)'\)/g)].map((m) => `packages/core/fonts/${m[1] ?? ''}`);
    expect(urls.sort()).toEqual(
      Object.keys(manifest.files)
        .filter((p) => p.endsWith('.woff2'))
        .sort(),
    );
    expect(css.match(/font-display: swap;/g)).toHaveLength(urls.length);
  });

  test('the Flutter package declares each TTF under Inter or Geist Mono', () => {
    const pubspec = read('packages/flutter/pubspec.yaml').toString();
    const assets = [...pubspec.matchAll(/asset: (fonts\/[\w-]+\.ttf)/g)].map((m) => `packages/flutter/${m[1] ?? ''}`);
    expect(assets.sort()).toEqual(
      Object.keys(manifest.files)
        .filter((p) => p.endsWith('.ttf'))
        .sort(),
    );
    expect(pubspec).toMatch(/- family: Inter\n/);
    expect(pubspec).toMatch(/- family: Geist Mono\n/);
  });
});
