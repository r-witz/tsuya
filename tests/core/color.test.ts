// The colour engine (G4): spec/cases.json, known values, refusals, and the invariants for any seed and any
// image. The Dart engine is tested against the same file (packages/flutter/test/engine_test.dart).
import { readFileSync } from 'node:fs';

import { describe, expect, test } from 'vitest';

import { lcg, randomColors } from '../../scripts/cases.mjs';
import { checkMode } from '../../packages/core/src/engine/check.ts';
import { accentFromColor, accentFromPixels, type ImageAccent } from '../../packages/core/src/engine/color.ts';
import {
  contrastOf,
  distance,
  gam,
  labOfHex,
  lin,
  over,
  parseColor,
  toHex,
  type Rgb,
} from '../../packages/core/src/engine/colorspace.ts';
import { accent, ambient, dark, glass, light } from '../../packages/core/src/tokens.ts';

interface Cases {
  colors: { seed: string; light: string; dark: string }[];
  images: ({ name: string; width: number; height: number; rgba: string } & ImageAccent)[];
  checks: { light: unknown[]; dark: unknown[] };
}

type ModeName = 'light' | 'dark';

const cases = JSON.parse(readFileSync(new URL('../../spec/cases.json', import.meta.url), 'utf8')) as Cases;
const MODES = { light, dark };
const STATUSES = ['danger', 'warning', 'success', 'info'] as const;

describe('spec/cases.json', () => {
  test('holds 20 chosen and 1000 random colours, the 12 images, and the contrast checks', () => {
    expect(cases.colors).toHaveLength(1020);
    expect(cases.images.map((c) => c.name)).toEqual([
      'teal-wrap',
      'checker',
      'confetti',
      'alpha',
      'small',
      'odd-size',
      'grey',
      'danger-red',
      'pastel',
      'near-black',
      'white',
      'black',
    ]);
    expect(cases.checks).toEqual({ light: checkMode(light, glass), dark: checkMode(dark, glass) });
  });

  test('the engine gives every colour case', () => {
    for (const c of cases.colors) expect(accentFromColor(c.seed)).toEqual(c);
  });

  test('the engine gives every image case', () => {
    for (const { name, width, height, rgba, ...result } of cases.images) {
      expect(accentFromPixels(Buffer.from(rgba, 'base64'), width, height), name).toEqual(result);
    }
  });
});

describe('accentFromColor', () => {
  test('known values', () => {
    // unchanged from tsuya 0.1 by the fourth status
    expect(accentFromColor('#2A9D8F')).toEqual({ seed: '#2A9D8F', light: '#03786C', dark: '#2FA193' });
    // a grey seed: its own lightness, clamped into each band
    const grey = accentFromColor('#808080');
    expect(labOfHex(grey.light).L).toBeCloseTo(light.accent.toneMax, 0);
    expect(labOfHex(grey.dark).L).toBeCloseTo(dark.accent.toneMin, 0);
  });

  test('a seed on a status colour is turned away from it, the fourth status included', () => {
    for (const status of STATUSES) {
      for (const mode of ['light', 'dark'] as const) {
        const pair = accentFromColor(MODES[mode].color[status]);
        const far = distance(labOfHex(pair[mode]), labOfHex(MODES[mode].color[status]));
        expect(far, `${mode} ${status}`).toBeGreaterThanOrEqual(accent.statusDistance);
      }
    }
  });

  test('normalises the seed (lower case, no hash, alpha dropped) and refuses anything else', () => {
    expect(accentFromColor('2a9d8f80')).toEqual(accentFromColor('#2A9D8F'));
    for (const bad of ['', 'teal', '#2A9D8', '#2A9D8F8']) expect(() => accentFromColor(bad)).toThrow(RangeError);
  });
});

describe('accentFromPixels', () => {
  test('refuses bytes that do not hold the image', () => {
    expect(() => accentFromPixels(new Uint8Array(10), 2, 2)).toThrow(RangeError);
    expect(() => accentFromPixels(new Uint8Array(16), 0, 4)).toThrow(RangeError);
    expect(() => accentFromPixels(new Uint8Array(16), 1.5, 2)).toThrow(RangeError);
  });

  test('takes a Uint8ClampedArray, as canvas getImageData gives it', () => {
    const [teal] = cases.images;
    if (!teal) throw new Error('no image case');
    const bytes = new Uint8ClampedArray(Buffer.from(teal.rgba, 'base64'));
    expect(accentFromPixels(bytes, teal.width, teal.height).seed).toBe(teal.seed);
  });
});

// G4: for any seed the pair stays in its band, reads on the grounds, keeps on-accent readable and stays away from
// every status colour; for any image the ambient opacity is the highest safe step
describe('invariants', () => {
  test('4000 random seeds', () => {
    const failures: string[] = [];
    for (const seed of randomColors(4000, 4000)) {
      const pair = accentFromColor(seed);
      for (const mode of ['light', 'dark'] as const) {
        const m = MODES[mode];
        const accentRgb = parseColor(pair[mode]);
        const at = `${seed} → ${mode} ${pair[mode]}`;
        const L = labOfHex(pair[mode]).L;
        // a hex rounds each channel to a byte, which moves L* by a few tenths at most
        if (L < m.accent.toneMin - 0.3 || L > m.accent.toneMax + 0.3) failures.push(`${at}: L* ${L.toFixed(2)}`);
        for (const status of STATUSES) {
          const d = distance(labOfHex(pair[mode]), labOfHex(m.color[status]));
          if (d < accent.statusDistance) failures.push(`${at}: ${d.toFixed(1)} from ${status}`);
        }
        const bg = parseColor(m.color.bg);
        const surface = over(parseColor(m.color.surface), bg);
        const cap = gam(m.ambient.cap);
        const grounds = { bg, surface, 'the ambient at its cap': { r: cap, g: cap, b: cap, a: 1 } };
        if (contrastOf(parseColor(m.color.onAccent), accentRgb) < 5.3) failures.push(`${at}: on-accent`);
        for (const [name, ground] of Object.entries(grounds)) {
          if (contrastOf(accentRgb, ground) < 3) failures.push(`${at}: on ${name}`);
        }
      }
    }
    expect(failures).toEqual([]);
  });

  // The ambient search halves the range on the premise that a colour within the cap at a step is within it at every
  // step below. Not so for every colour: luminance is convex in the opacity, so a colour can dip below the light cap and come back
  // (pure green over the light bg, at a cap of 0.714 and up to full opacity). In dark mode bg is within the cap, so the
  // steps within it run from 0; in light mode the tokens keep any dip above the cap. A grid of the RGB cube, which
  // holds every cell and its saturated variants to within 1/64.
  test('the premise of the ambient search holds for the tokens: within the cap at a step, within it below', () => {
    expect(premiseBreaks(parseColor(light.color.bg), 'light', 0.714, 100)).toContain('#00FF00');
    for (const mode of ['light', 'dark'] as const) {
      const { cap, maxOpacity } = MODES[mode].ambient;
      expect(premiseBreaks(parseColor(MODES[mode].color.bg), mode, cap, Math.round(maxOpacity * 100)), mode).toEqual(
        [],
      );
    }
  });

  test('40 random images: the ambient opacity is the highest step that keeps every cell within the cap', () => {
    const random = lcg(99);
    const next = () => random.next().value;
    for (let n = 0; n < 40; n++) {
      // stripes of random colours, sometimes translucent, at a size that is not a multiple of the grid
      const width = 20 + (next() % 140);
      const height = 20 + (next() % 140);
      const palette = Array.from({ length: 1 + (next() % 6) }, () => [next() & 255, next() & 255, next() & 255]);
      const pixels = new Uint8Array(width * height * 4);
      for (let i = 0; i < width * height; i++) {
        const [r = 0, g = 0, b = 0] = palette[Math.floor(((i % width) * palette.length) / width)] ?? [];
        pixels.set([r, g, b, n % 4 === 0 ? next() & 255 : 255], i * 4);
      }
      const result = accentFromPixels(pixels, width, height);
      for (const mode of ['light', 'dark'] as const) {
        const opacity = result.ambient[mode];
        const max = MODES[mode].ambient.maxOpacity;
        const steps = Math.round(opacity * 100);
        expect(steps / 100).toBe(opacity);
        expect(opacity).toBeLessThanOrEqual(max);
        expect(withinCap(pixels, width, height, mode, opacity), `${mode} at ${String(opacity)}`).toBe(true);
        if (opacity < max) {
          expect(withinCap(pixels, width, height, mode, (steps + 1) / 100), `${mode} one step above`).toBe(false);
        }
      }
    }
  });
});

// The colours of a 1/64 grid of the RGB cube that are within the cap at a step of 0.01 but not at a step below
function premiseBreaks(bg: Rgb, mode: ModeName, cap: number, steps: number): string[] {
  const n = 64;
  // the linear light of each channel value of the grid drawn over bg at each step, weighted
  const table = (weight: number, back: number) =>
    Array.from({ length: n + 1 }, (_, i) =>
      Array.from({ length: steps + 1 }, (_, step) => weight * lin(((i / n) * step) / 100 + back * (1 - step / 100))),
    );
  const [tr, tg, tb] = [table(0.2126, bg.r), table(0.7152, bg.g), table(0.0722, bg.b)];
  const broken: string[] = [];
  for (const [i, red] of tr.entries()) {
    for (const [j, green] of tg.entries()) {
      for (const [k, blue] of tb.entries()) {
        let failed = false;
        for (let step = 0; step <= steps; step++) {
          const y = (red[step] ?? 0) + (green[step] ?? 0) + (blue[step] ?? 0);
          if (mode === 'dark' ? y > cap : y < cap) failed = true;
          else if (failed) {
            broken.push(toHex({ r: i / n, g: j / n, b: k / n, a: 1 }));
            break;
          }
        }
      }
    }
  }
  return broken;
}

// The ambient search written again apart from the engine: the colour cells, each over bg, as is and saturated in sRGB
// and in linear light, drawn over bg at the opacity, keep their luminance within the mode's cap.
function withinCap(pixels: Uint8Array, width: number, height: number, mode: ModeName, opacity: number): boolean {
  const bg = parseColor(MODES[mode].color.bg);
  const cap = MODES[mode].ambient.cap;
  const s = ambient.saturate;
  const clamp = (v: number) => Math.min(1, Math.max(0, v));
  const saturate = ([r, g, b]: [number, number, number]): [number, number, number] => [
    clamp((0.213 + 0.787 * s) * r + (0.715 - 0.715 * s) * g + (0.072 - 0.072 * s) * b),
    clamp((0.213 - 0.213 * s) * r + (0.715 + 0.285 * s) * g + (0.072 - 0.072 * s) * b),
    clamp((0.213 - 0.213 * s) * r + (0.715 - 0.715 * s) * g + (0.072 + 0.928 * s) * b),
  ];
  const map = (c: [number, number, number], f: (v: number) => number): [number, number, number] => [
    f(c[0]),
    f(c[1]),
    f(c[2]),
  ];
  const n = accent.sample;
  for (let oy = 0; oy < n; oy++) {
    for (let ox = 0; ox < n; ox++) {
      const x0 = Math.floor((ox * width) / n);
      const y0 = Math.floor((oy * height) / n);
      const x1 = Math.max(Math.floor(((ox + 1) * width) / n), x0 + 1);
      const y1 = Math.max(Math.floor(((oy + 1) * height) / n), y0 + 1);
      const sum = [0, 0, 0, 0];
      for (let y = y0; y < y1; y++) {
        for (let x = x0; x < x1; x++) {
          const i = (y * width + x) * 4;
          const alpha = pixels[i + 3] ?? 0;
          for (let c = 0; c < 3; c++) sum[c] = (sum[c] ?? 0) + (pixels[i + c] ?? 0) * alpha;
          sum[3] = (sum[3] ?? 0) + alpha;
        }
      }
      const [sr = 0, sg = 0, sb = 0, sa = 0] = sum;
      const count = (x1 - x0) * (y1 - y0);
      const cell =
        sa === 0
          ? { r: 0, g: 0, b: 0, a: 0 }
          : { r: sr / sa / 255, g: sg / sa / 255, b: sb / sa / 255, a: sa / count / 255 };
      const seen = over(cell, bg);
      const px: [number, number, number] = [seen.r, seen.g, seen.b];
      for (const [r, g, b] of [px, saturate(px), map(saturate(map(px, lin)), gam)]) {
        const y =
          0.2126 * lin(r * opacity + bg.r * (1 - opacity)) +
          0.7152 * lin(g * opacity + bg.g * (1 - opacity)) +
          0.0722 * lin(b * opacity + bg.b * (1 - opacity));
        if (mode === 'dark' ? y > cap : y < cap) return false;
      }
    }
  }
  return true;
}

describe('timing', () => {
  test('a 256 × 256 image (printed, not a gate)', () => {
    const pixels = new Uint8Array(256 * 256 * 4);
    const random = lcg(1);
    for (let i = 0; i < pixels.length; i++) pixels[i] = i % 4 === 3 ? 255 : random.next().value & 255;
    accentFromPixels(pixels, 256, 256);
    const runs = 10;
    const start = performance.now();
    for (let i = 0; i < runs; i++) accentFromPixels(pixels, 256, 256);
    const ms = (performance.now() - start) / runs;
    console.log(`accentFromPixels, 256 × 256 noise: ${ms.toFixed(1)} ms per image (Node ${process.version})`);
    expect(ms).toBeGreaterThan(0);
  });
});
