// The build: it checks before it writes, refuses to write anything when a check fails, and writes outputs
// that hold every token: tokens.css declares each one, every colour has its exact value in CSS and Dart, the other
// groups are spot-checked, and no output holds a missing value. CI reruns the build to check the outputs are fresh.
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { inflateSync } from 'node:zlib';
import { afterAll, describe, expect, test } from 'vitest';

import { checkStructure } from '../../scripts/checks.mjs';
import { buildDesign } from '../../scripts/design.mjs';
import { buildGrain, grainTexels } from '../../scripts/grain.mjs';
import { core, cssName, modes } from '../../scripts/tokens.mjs';

const ROOT = new URL('../../', import.meta.url).pathname;
const read = (path: string) => readFileSync(join(ROOT, path), 'utf8');
const camel = (name: string) => name.replace(/-(\w)/g, (_m, c: string) => c.toUpperCase());
type Token = (typeof core)[number];

describe('checks before writing', () => {
  test('the tokens pass', () => {
    expect(checkStructure()).toEqual([]);
  });

  test('light and dark must define the same tokens in the same order', () => {
    const errors = checkStructure(core, { light: modes.light, dark: modes.dark.slice(1) });
    expect(errors.join('\n')).toMatch(/same tokens/);
  });

  test('two tokens cannot share a CSS name, nor take one tokens.css uses', () => {
    const extra: Token[] = [
      { path: ['accent', 'light'], type: 'number', value: 1, description: undefined },
      { path: ['type', 'body-tracking'], type: 'number', value: 1, description: undefined },
    ];
    const errors = checkStructure([...core, ...extra], modes).join('\n');
    expect(errors).toMatch(/--t-accent-light/);
    expect(errors).toMatch(/--t-type-body-tracking/);
  });

  test('values must be well formed', () => {
    const bad: Token[] = [
      { path: ['color', 'x'], type: 'color', value: '#fff', description: undefined },
      { path: ['space', 'x'], type: 'dimension', value: { value: 1, unit: 'rem' }, description: undefined },
    ];
    const errors = checkStructure([...core, ...bad], modes).join('\n');
    expect(errors).toMatch(/color\.x/);
    expect(errors).toMatch(/space\.x/);
  });

  test('DESIGN.md may name only tokens that exist', () => {
    const text =
      'Use `--t-text-muted`, `--t-space-16`, `--t-type-body-tracking` and `--t-nope`; `--_t-private` is fine.\n<!-- tokens:start -->\n<!-- tokens:end -->\n';
    expect(buildDesign(text).unknown).toEqual(['--t-nope']);
    expect(() => buildDesign('no markers')).toThrow(/markers/);
  });
});

describe('a failing check writes nothing', () => {
  const work = mkdtempSync(join(tmpdir(), 'tsuya-build-'));
  afterAll(() => {
    rmSync(work, { recursive: true, force: true });
  });

  test('a too light secondary text stops the build before any output', () => {
    const copy = [
      'package.json',
      'DESIGN.md',
      'tokens',
      'scripts',
      'packages/core/package.json',
      'packages/core/src/engine',
    ];
    for (const path of copy) cpSync(join(ROOT, path), join(work, path), { recursive: true });
    const light = join(work, 'tokens/light.json');
    writeFileSync(light, readFileSync(light, 'utf8').replace('"#0A0A0CA3"', '"#0A0A0C80"'));
    const run = spawnSync(process.execPath, ['scripts/build.mjs'], { cwd: work, encoding: 'utf8' });
    expect(run.status).toBe(1);
    expect(run.stderr).toMatch(/light: textMuted on bg is \d\.\d\d:1, needs 4\.5:1/);
    for (const output of [
      'packages/core/src/css/tokens.css',
      'packages/core/src/tokens.ts',
      'packages/core/src/css/grain.png',
      'packages/flutter/lib/src/foundation/tokens.g.dart',
      'packages/core/DESIGN.md',
    ]) {
      expect(existsSync(join(work, output))).toBe(false);
    }
    expect(readFileSync(join(work, 'DESIGN.md'), 'utf8')).toBe(read('DESIGN.md'));
  });
});

describe('outputs', () => {
  const css = read('packages/core/src/css/tokens.css');
  const dart = read('packages/flutter/lib/src/foundation/tokens.g.dart');

  test('tokens.css declares the layers first, then every token with its value in each mode', () => {
    expect(css.split('\n')[1]).toBe('@layer tsuya.tokens, tsuya.base, tsuya.material, tsuya.components;');
    const [lightBlock, darkBlock] = [
      css.indexOf('[data-theme="light"] {'),
      css.lastIndexOf('[data-theme="dark"] {'),
    ].map((at) => css.slice(at, css.indexOf('}', at)));
    for (const [mode, block] of [
      ['light', lightBlock],
      ['dark', darkBlock],
    ] as const) {
      for (const t of modes[mode].filter((t: Token) => t.type === 'color' && t.path[1] !== 'accent')) {
        expect(block).toContain(`--t-${t.path.slice(1).join('-')}: ${String(t.value)};`);
      }
      // the accent is mixed from the pair; every other token of the mode is declared in its block
      for (const t of modes[mode].filter((t: Token) => t.path.join('.') !== 'color.accent')) {
        expect(block).toContain(`${cssName(t.path)}: `);
      }
      expect(block).toContain(
        '--t-accent: color-mix(in srgb, var(--t-accent-dark) calc(var(--t-mode-dark) * 100%), var(--t-accent-light));',
      );
    }
    for (const t of core) expect(css).toContain(`${cssName(t.path)}: `);
    expect(css).toContain('--t-accent-light: #0A0A0C;');
    expect(css).toContain('--t-accent-dark: #FFFFFF;');
    expect(css).toContain('--t-space-16: 16px;');
    expect(css).toContain('--t-container-gutter-phone: var(--t-space-16);');
    expect(css).toContain('--t-type-label: 700 12px/1.17 var(--t-font-sans);');
    expect(css).toContain('--t-easing-emphasized: cubic-bezier(0.22, 1, 0.36, 1);');
  });

  test('tokens.g.dart holds every colour of both modes and converts shadow blur to Flutter radii', () => {
    for (const mode of ['light', 'dark'] as const) {
      const block = dart.slice(dart.indexOf(`static const ${mode} = TsuyaColors(`));
      for (const t of modes[mode].filter((t: Token) => t.type === 'color')) {
        const hex = String(t.value).slice(1);
        const argb = hex.length === 8 ? `${hex.slice(6)}${hex.slice(0, 6)}` : `FF${hex}`;
        expect(block).toMatch(new RegExp(`\\b${camel(String(t.path[1]))}: Color\\(0x${argb}\\)`));
      }
    }
    // CSS blur 12 is σ 6; Flutter's σ is 0.57735 r + 0.5, so r = 9.53
    expect(dart).toContain('blurRadius: 9.53');
    expect(dart).toContain('static const s16 = 16.0;');
    expect(dart).toContain('static const gutterPhone = TsuyaSpace.s16;');
  });

  test('no output holds a missing value', () => {
    const design = read('DESIGN.md');
    const outputs = {
      'tokens.css': css,
      'tokens.ts': read('packages/core/src/tokens.ts'),
      'tokens.g.dart': dart,
      'DESIGN.md tokens': design.slice(design.indexOf('<!-- tokens:start -->'), design.indexOf('<!-- tokens:end -->')),
    };
    for (const [name, text] of Object.entries(outputs)) {
      expect(text, name).not.toMatch(/\bundefined\b|\bNaN\b|\[object Object\]/);
    }
  });

  test('the grain tile is a valid PNG of the shared generator, the same bytes every time', () => {
    const png = readFileSync(join(ROOT, 'packages/core/src/css/grain.png'));
    expect(buildGrain(64).equals(png)).toBe(true);
    const idat = png.indexOf('IDAT');
    const raw = inflateSync(png.subarray(idat + 4, idat + 4 + png.readUInt32BE(idat - 4)));
    const texels = grainTexels(64);
    for (let y = 0; y < 64; y++) {
      expect(raw[y * 65]).toBe(0);
      expect(raw.subarray(y * 65 + 1, (y + 1) * 65).equals(Buffer.from(texels.subarray(y * 64, (y + 1) * 64)))).toBe(
        true,
      );
    }
    const mean = texels.reduce((s, v) => s + v, 0) / texels.length;
    expect(mean).toBeGreaterThan(120);
    expect(mean).toBeLessThan(136);
  });
});
