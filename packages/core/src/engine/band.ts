// "Any accent of the band": the accents the contrast checks take at their worst, at both ends of a mode's
// tone band. The 15° sample, the corners that tint glass the most, and the two colours that bound the
// luminance of any accent the engine gives. The Dart port, packages/flutter/lib/src/engine/band.dart, follows this
// file line by line.
import { fromLab, gam, inGamut, lin, toHex, toLab, type Rgb } from './colorspace.ts';

// cos of 0°, 15° … 90°, written out so every platform gets the same directions
const COS = [1, 0.9659258262890683, 0.8660254037844387, 0.7071067811865476, 0.5, 0.25881904510252074, 0];

// unit hue direction of k × 15°, k in 0..23
function direction(k: number): [number, number] {
  const j = k % 6;
  let a = COS[j] ?? 0;
  let b = COS[6 - j] ?? 0;
  for (let q = 0; q < Math.floor(k / 6); q++) [a, b] = [-b, a];
  return [a, b];
}

// the colour of tone L along a hue direction with the most chroma the engine can show
function mostSaturated(L: number, [ua, ub]: [number, number]): Rgb {
  const at = (c: number) => fromLab({ L, a: c * ua, b: c * ub });
  let low = 200;
  while (low > 0 && !inGamut(at(low))) low -= 0.5;
  let high = low + 0.5;
  for (let i = 0; i < 24; i++) {
    const mid = (low + high) / 2;
    if (inGamut(at(mid))) low = mid;
    else high = mid;
  }
  return at(low);
}

/**
 * "Any accent of the band": at both ends of the mode's tone band, the grey and the most saturated colour every 15°
 * of hue, as hex like the engine gives them (50 colours).
 */
export function bandAccents(toneMin: number, toneMax: number): string[] {
  return [toneMin, toneMax].flatMap((L) => [
    toHex(fromLab({ L, a: 0, b: 0 })),
    ...Array.from({ length: 24 }, (_, k) => toHex(mostSaturated(L, direction(k)))),
  ]);
}

const WEIGHTS = [0.2126, 0.7152, 0.0722] as const;

// the luminance of L* (the band is above L* 8, where L* is a cube root)
function toneLuminance(L: number): number {
  const f = (L + 16) / 116;
  return f * f * f;
}

/**
 * The accents of the band that tint glass the most. Glass mixes its tint in sRGB, not in linear light, so at a
 * given L* the worst tint is not on a 15° step but at a corner of the RGB cube's slice of that luminance: two
 * channels at 0 or 1, the third solved. At both ends of the band, and the cube's own corners inside it.
 */
export function bandCorners(toneMin: number, toneMax: number): string[] {
  const corners: string[] = [];
  for (const L of [toneMin, toneMax]) {
    const y = toneLuminance(L);
    for (const [k, i, j] of [
      [0, 1, 2],
      [1, 0, 2],
      [2, 0, 1],
    ] as const) {
      for (const p of [0, 1]) {
        for (const q of [0, 1]) {
          const free = (y - WEIGHTS[i] * p - WEIGHTS[j] * q) / WEIGHTS[k];
          if (free < 0 || free > 1) continue;
          const linear: [number, number, number] = [0, 0, 0];
          linear[i] = p;
          linear[j] = q;
          linear[k] = free;
          corners.push(toHex({ r: gam(linear[0]), g: gam(linear[1]), b: gam(linear[2]), a: 1 }));
        }
      }
    }
  }
  for (let n = 0; n < 8; n++) {
    const corner: Rgb = { r: n & 4 ? 1 : 0, g: n & 2 ? 1 : 0, b: n & 1 ? 1 : 0, a: 1 };
    const L = toLab(corner).L;
    if (L >= toneMin && L <= toneMax) corners.push(toHex(corner));
  }
  return corners;
}

/**
 * The lightest and the darkest colour the engine can give in the band. It gives an accent at a tone of the band,
 * then rounds each channel to a byte, which moves its luminance: by most where a channel is steep, and the 15° steps
 * do not find where. A byte h comes from any channel value in [h − ½, h + ½) / 255, out to the gamut's tolerance at
 * 0 and 1; luminance grows with each channel. So no accent is lighter than the colour of most luminance whose darkest
 * preimage is at most the top of the band, nor darker than the reverse. The slack covers the rounding of the Lab
 * matrices: their luminance rows differ by less than 1e-4. On an opaque ground, the contrast of an accent only
 * depends on its luminance: these two bound every check of an accent but glass.
 */
export function bandExtremes(toneMin: number, toneMax: number): [string, string] {
  const [wr, wg, wb] = WEIGHTS;
  const edge = (k: number) => lin(k === 0 ? -1e-4 : k === 256 ? 1 + 1e-4 : (k - 0.5) / 255);
  const at = Array.from({ length: 256 }, (_, h) => lin(h / 255));
  const below = Array.from({ length: 256 }, (_, h) => edge(h));
  const above = Array.from({ length: 256 }, (_, h) => edge(h + 1));
  const top = toneLuminance(toneMax) + 1e-4;
  const bottom = toneLuminance(toneMin) - 1e-4;
  let lightest = '';
  let darkest = '';
  let most = -Infinity;
  let least = Infinity;
  for (let r = 0; r < 256; r++) {
    for (let g = 0; g < 256; g++) {
      const lr = wr * (at[r] ?? 0) + wg * (at[g] ?? 0);
      // the highest blue byte whose darkest preimage is not above the top
      const room = top - wr * (below[r] ?? 0) - wg * (below[g] ?? 0);
      if (wb * (below[0] ?? 0) <= room) {
        let lo = 0;
        let hi = 255;
        while (lo < hi) {
          const mid = (lo + hi + 1) >> 1;
          if (wb * (below[mid] ?? 0) <= room) lo = mid;
          else hi = mid - 1;
        }
        const y = lr + wb * (at[lo] ?? 0);
        if (y > most) {
          most = y;
          lightest = toHex({ r: r / 255, g: g / 255, b: lo / 255, a: 1 });
        }
      }
      // the lowest blue byte whose lightest preimage is not below the bottom
      const need = bottom - wr * (above[r] ?? 0) - wg * (above[g] ?? 0);
      if (wb * (above[255] ?? 0) >= need) {
        let lo = 0;
        let hi = 255;
        while (lo < hi) {
          const mid = (lo + hi) >> 1;
          if (wb * (above[mid] ?? 0) >= need) hi = mid;
          else lo = mid + 1;
        }
        const y = lr + wb * (at[lo] ?? 0);
        if (y < least) {
          least = y;
          darkest = toHex({ r: r / 255, g: g / 255, b: lo / 255, a: 1 });
        }
      }
    }
  }
  return [lightest, darkest];
}
