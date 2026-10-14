// The portable maths and colour conversions of the engine. Exact cross-platform parity is checked against
// spec/cases.json; these tests pin the behaviour the build's contrast checks rely on.
import { describe, expect, test } from 'vitest';

import {
  atan2,
  contrast,
  fromLab,
  gam,
  inGamut,
  lin,
  luminance,
  parseColor,
  roundHalfUp,
  toHex,
  toLab,
} from '../../packages/core/src/engine/colorspace.ts';

describe('colorspace', () => {
  test('WCAG contrast of black on white is 21, of a colour on itself 1', () => {
    expect(contrast('#000000', '#FFFFFF')).toBeCloseTo(21, 10);
    expect(contrast('#FFFFFF', '#000000')).toBeCloseTo(21, 10);
    expect(contrast('#2A9D8F', '#2A9D8F')).toBe(1);
  });

  test('a translucent foreground is seen over its background', () => {
    // black at alpha 128/255 over white is the grey 1 − 128/255
    const grey = lin(1 - 128 / 255);
    expect(contrast('#00000080', '#FFFFFF')).toBeCloseTo(1.05 / (grey + 0.05), 12);
  });

  test('parses #RRGGBB and #RRGGBBAA, refuses anything else', () => {
    expect(parseColor('#FF8000')).toEqual({ r: 1, g: 128 / 255, b: 0, a: 1 });
    expect(parseColor('#ff800080').a).toBe(128 / 255);
    for (const bad of ['#FFF', 'red', '#GG0000', '', '#FF80001']) expect(() => parseColor(bad)).toThrow(RangeError);
  });

  test('rounds halves up, negative ones included (JS and Dart round differ there)', () => {
    expect([-1.5, -0.5, 0.5, 1.5, 2.4999].map(roundHalfUp)).toEqual([-1, 0, 1, 2, 2]);
  });

  test('the written-out atan2 matches the platform one to 1e-12', () => {
    for (let i = 0; i < 2000; i++) {
      const y = Math.sin(i * 12.9898) * 50;
      const x = Math.cos(i * 78.233) * 50;
      expect(Math.abs(atan2(y, x) - Math.atan2(y, x))).toBeLessThan(1e-12);
    }
    expect(atan2(0, 0)).toBe(0);
  });

  test('linearisation and its inverse round-trip, and luminance follows WCAG', () => {
    for (let v = 0; v <= 1; v += 1 / 255) expect(gam(lin(v))).toBeCloseTo(v, 12);
    expect(luminance(parseColor('#FFFFFF'))).toBeCloseTo(1, 12);
    expect(luminance(parseColor('#808080'))).toBeCloseTo(0.2158605, 6);
  });

  test('CIE L*a*b* of white and black, and the round trip of in-gamut colours', () => {
    expect(toLab(parseColor('#FFFFFF')).L).toBeCloseTo(100, 3);
    expect(toLab(parseColor('#000000')).L).toBeCloseTo(0, 10);
    for (const hex of ['#2A9D8F', '#C62828', '#1F5FBF', '#F5B942', '#0A0A0C']) {
      const back = fromLab(toLab(parseColor(hex)));
      expect(inGamut(back)).toBe(true);
      expect(toHex(back)).toBe(hex);
    }
  });
});
