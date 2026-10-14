// The contrast checks (G1, G2): the band of accents they test, and that they catch a token too weak to pass.
import { describe, expect, test } from 'vitest';

import { bandAccents, bandCorners, bandExtremes } from '../../packages/core/src/engine/band.ts';
import {
  checkMode,
  checkTheme,
  looksLike,
  type GlassTheme,
  type ModeTheme,
} from '../../packages/core/src/engine/check.ts';
import { accentFromColor } from '../../packages/core/src/engine/color.ts';
import {
  contrastOf,
  fromLab,
  gam,
  inGamut,
  labOfHex,
  lin,
  luminance,
  parseColor,
  toHex,
} from '../../packages/core/src/engine/colorspace.ts';
import { lcg } from '../../scripts/cases.mjs';
import { dark, glass, light } from '../../packages/core/src/tokens.ts';

const GLASS: GlassTheme = { opacity: glass.opacity, tint: glass.tint };
const failures = (theme: ModeTheme, glassTheme = GLASS) =>
  checkMode(theme, glassTheme)
    .filter((r) => r.ratio < r.min)
    .map((r) => r.check);

describe('bandAccents', () => {
  test('50 colours: at each end of the band, a grey and the most saturated colour every 15°', () => {
    const colours = bandAccents(light.accent.toneMin, light.accent.toneMax);
    expect(colours).toHaveLength(50);
    for (const [i, hex] of colours.entries()) {
      const lab = labOfHex(hex);
      const tone = i < 25 ? light.accent.toneMin : light.accent.toneMax;
      expect(Math.abs(lab.L - tone)).toBeLessThan(0.5);
      const chroma = Math.hypot(lab.a, lab.b);
      if (i % 25 === 0) expect(chroma).toBeLessThan(1);
      else expect(chroma).toBeGreaterThan(20);
    }
  });
});

describe('bandCorners', () => {
  test('the corners of the RGB slices at both ends of the band, and the cube corners inside it', () => {
    const corners = (theme: ModeTheme) => bandCorners(theme.accent.toneMin, theme.accent.toneMax);
    expect(corners(light)).toHaveLength(8);
    expect(corners(dark)).toHaveLength(10);
    for (const theme of [light, dark]) {
      for (const hex of corners(theme)) {
        const L = labOfHex(hex).L;
        expect(L).toBeGreaterThan(theme.accent.toneMin - 0.5);
        expect(L).toBeLessThan(theme.accent.toneMax + 0.5);
        // a corner: at least two channels at 0 or 255
        const { r, g, b } = parseColor(hex);
        expect([r, g, b].filter((v) => v === 0 || v === 1).length, hex).toBeGreaterThanOrEqual(2);
      }
    }
    expect(corners(light)).toContain('#0000FF');
    expect(corners(dark)).toContain('#FF00FF');
  });

  // the 15° steps of the band missed the worst glass tint, a pure blue at the dark end
  test('the glass checks find the worst tint between the 15° steps', () => {
    const glassResult = (theme: ModeTheme) => checkMode(theme, GLASS).find((r) => r.check === 'textMuted on any glass');
    expect(glassResult(light)?.worst).toBe('tinted by #0000FD (L* 32.0), over black');
    // one alpha step lighter, text-muted passes at every 15° step but not on that blue
    const lighter = { ...light, color: { ...light.color, textMuted: '#0A0A0CA2' } };
    const result = glassResult(lighter);
    expect(result?.ratio).toBeLessThan(4.5);
    expect(result?.worst).toBe('tinted by #0000FD (L* 32.0), over black');
  });
});

describe('bandExtremes', () => {
  test('no colour of the band, rounded to bytes, is lighter or darker', () => {
    const random = lcg(5);
    const next = () => random.next().value / 0x7fffffff;
    for (const theme of [light, dark]) {
      const { toneMin, toneMax } = theme.accent;
      const [lightest, darkest] = bandExtremes(toneMin, toneMax);
      // just past the ends of the band: rounding moves L* by a few tenths at most
      expect(labOfHex(lightest).L).toBeGreaterThan(toneMax);
      expect(labOfHex(lightest).L).toBeLessThan(toneMax + 0.5);
      expect(labOfHex(darkest).L).toBeLessThan(toneMin);
      expect(labOfHex(darkest).L).toBeGreaterThan(toneMin - 0.5);
      const [most, least] = [luminance(parseColor(lightest)), luminance(parseColor(darkest))];
      for (let n = 0; n < 20000; n++) {
        const L = n % 4 === 0 ? toneMax : n % 4 === 1 ? toneMin : toneMin + next() * (toneMax - toneMin);
        const rgb = fromLab({ L, a: (next() - 0.5) * 260, b: (next() - 0.5) * 260 });
        if (!inGamut(rgb)) continue;
        const y = luminance(parseColor(toHex(rgb)));
        expect(y).toBeLessThanOrEqual(most);
        expect(y).toBeGreaterThanOrEqual(least);
      }
    }
  });
});

describe('checkMode', () => {
  // the engine rounds its accents to bytes, which moves their luminance; the 15° steps missed
  // the lightest and the darkest it can give
  test('the accent checks bound every accent the engine gives', () => {
    // the most chroma in every direction, every 1/255 of the hue hexagon, at five lightnesses
    const seeds: string[] = [];
    for (let edge = 0; edge < 6; edge++) {
      for (let k = 0; k < 255; k++) {
        const t = k / 255;
        const rgb = [
          [1, t, 0],
          [1 - t, 1, 0],
          [0, 1, t],
          [0, 1 - t, 1],
          [t, 0, 1],
          [1, 0, 1 - t],
        ][edge] as [number, number, number];
        for (const [scale, white] of [
          [1, 0],
          [0.7, 0],
          [0.45, 0],
          [1, 0.3],
          [1, 0.6],
        ] as const) {
          const [r, g, b] = rgb.map((v) => gam(lin(v) * scale) * (1 - white) + white);
          seeds.push(toHex({ r: r ?? 0, g: g ?? 0, b: b ?? 0, a: 1 }));
        }
      }
    }
    for (const [mode, theme] of [
      ['light', light],
      ['dark', dark],
    ] as const) {
      const reported = new Map(checkMode(theme, GLASS).map((r) => [r.check, r.ratio]));
      const lowest = new Map<string, number>();
      const see = (check: string, ratio: number) => lowest.set(check, Math.min(ratio, lowest.get(check) ?? Infinity));
      const onAccent = parseColor(theme.color.onAccent);
      const cap = gam(theme.ambient.cap);
      for (const seed of seeds) {
        const accent = parseColor(accentFromColor(seed)[mode]);
        see('on-accent on any accent', contrastOf(onAccent, accent));
        see('any accent on bg', contrastOf(accent, parseColor(theme.color.bg)));
        see('any accent on the ambient at its cap', contrastOf(accent, { r: cap, g: cap, b: cap, a: 1 }));
      }
      for (const [check, ratio] of lowest)
        expect(ratio, `${mode}: ${check}`).toBeGreaterThanOrEqual(reported.get(check) ?? 0);
    }
  });

  test('the tokens pass every check in both modes', () => {
    expect(failures(light)).toEqual([]);
    expect(failures(dark)).toEqual([]);
    expect(looksLike(light, 'light')).toBe(true);
    expect(looksLike(dark, 'dark')).toBe(true);
    expect(looksLike(dark, 'light')).toBe(false);
  });

  test('covers every pair the guarantees name', () => {
    const checks = new Set(checkMode(light, GLASS).map((r) => r.check));
    for (const fg of ['text', 'textMuted']) {
      for (const on of ['bg', 'surface', 'fill', 'fill-selected over fill', 'any glass', 'the ambient at its cap']) {
        expect(checks).toContain(`${fg} on ${on}`);
      }
    }
    for (const status of ['danger', 'warning', 'success', 'info']) {
      expect(checks).toContain(`${status} on bg`);
      expect(checks).toContain(`${status} on surface`);
      expect(checks).toContain(`on-status on ${status}`);
    }
    for (const check of [
      'on-accent on any accent',
      'border-strong on bg',
      'border-strong on surface',
      'border-strong over fill',
      'any accent on bg',
      'any accent on surface',
      'any accent on the ambient at its cap',
      'thumb on border-strong',
      'on-accent thumb on any accent',
      'text (icons) on control glass over the ambient at its cap',
    ]) {
      expect(checks).toContain(check);
    }
  });

  test('a lighter secondary text fails on glass and on the ambient first', () => {
    const weak = { ...light, color: { ...light.color, textMuted: '#0A0A0C90' } };
    expect(failures(weak)).toEqual(
      expect.arrayContaining(['textMuted on any glass', 'textMuted on the ambient at its cap']),
    );
  });

  test('a thinner glass fails for text over white or black content', () => {
    expect(failures(dark, { ...GLASS, opacity: 0.7 })).toContain('textMuted on any glass');
  });

  test('a band reaching too light fails the accent checks', () => {
    const wide = { ...light, accent: { toneMin: 32, toneMax: 60 } };
    expect(failures(wide)).toEqual(
      expect.arrayContaining(['on-accent on any accent', 'any accent on the ambient at its cap']),
    );
  });

  test('a status too light fails on bg and under its own text', () => {
    const pale = { ...light, color: { ...light.color, danger: '#E57373' } };
    expect(failures(pale)).toEqual(expect.arrayContaining(['danger on bg', 'on-status on danger']));
  });
});

describe('checkTheme', () => {
  test('the tokens pass', () => {
    expect(checkTheme({ light, dark, glass })).toEqual([]);
  });

  test('returns each failing check with its mode and worst case', () => {
    const weak = { ...dark, color: { ...dark.color, textMuted: '#FFFFFF66' } };
    const failures = checkTheme({ light, dark: weak, glass });
    expect(failures.length).toBeGreaterThan(0);
    for (const failure of failures) {
      expect(failure.mode).toBe('dark');
      expect(failure.ratio).toBeLessThan(failure.min);
    }
    expect(failures.map((f) => f.check)).toContain('textMuted on bg');
  });
});
