// The tsuya colour engine: the accent pair of a colour or an image, and the opacity of its ambient background
// (DESIGN.md, The engine). This file is the reference: packages/flutter/lib/src/engine/color.dart follows it line
// by line and both are tested against spec/cases.json, which the build writes from this file. No dependencies; it
// runs in browsers, workers and Node. The maths that gives the same bits everywhere is in colorspace.ts.
import {
  atan2,
  chroma,
  COS1,
  DEGREES,
  distance,
  fromLab,
  gam,
  inGamut,
  labOfHex,
  lin,
  over,
  parseColor,
  roundHalfUp,
  SIN1,
  toHex,
  toLab,
  type Lab,
  type Rgb,
} from './colorspace.ts';
import { accent as A, ambient as AMB, dark, light, type Mode } from '../tokens.ts';

/** The accent of a content for both modes. `seed` is the colour it comes from, or null for the neutral pair. */
export interface AccentPair {
  seed: string | null;
  light: string;
  dark: string;
}

/** An accent pair and the opacity of its ambient background in each mode. */
export interface ImageAccent extends AccentPair {
  ambient: { light: number; dark: number };
}

type ModeName = 'light' | 'dark';
const MODES: Record<ModeName, Mode> = { light, dark };
const STATUS = ['danger', 'warning', 'success', 'info'] as const;

/** The accent when no content leads and the product has no brand colour: the text colour of each mode. */
export const neutralPair: AccentPair = { seed: null, light: light.color.accent, dark: dark.color.accent };

// ---------------------------------------------------------------- accent of a colour

// The colour of tone L along the unit hue direction (ua, ub) with the largest chroma ≤ c that sRGB can show
function fit(L: number, c: number, ua: number, ub: number): string {
  for (let k = 0; k <= 100; k++) {
    const ck = c * (1 - k / 100);
    const rgb = fromLab({ L, a: ck * ua, b: ck * ub });
    if (inGamut(rgb)) return toHex(rgb);
  }
  return toHex(fromLab({ L, a: 0, b: 0 }));
}

function accentFor(seed: string, mode: ModeName): string {
  const m = MODES[mode];
  const lab = labOfHex(seed);
  const L = Math.min(m.accent.toneMax, Math.max(m.accent.toneMin, lab.L));
  const c = chroma(lab.a, lab.b);
  let ua = c > 0 ? lab.a / c : 1;
  let ub = c > 0 ? lab.b / c : 0;
  const status = STATUS.map((name) => labOfHex(m.color[name]));
  const farEnough = (hex: string) => {
    const p = labOfHex(hex);
    return status.every((s) => distance(p, s) >= A.statusDistance);
  };

  const first = fit(L, c, ua, ub);
  if (farEnough(first)) return first;

  // turn away from the nearest status colour: the sign of the cross product says on which side it is
  const firstLab = labOfHex(first);
  let near = status[0] as Lab;
  for (const s of status) if (distance(firstLab, s) < distance(firstLab, near)) near = s;
  const sin1 = ua * near.b - ub * near.a <= 0 ? SIN1 : -SIN1;
  for (let step = 1; step <= 180; step++) {
    const ra = ua * COS1 - ub * sin1;
    ub = ua * sin1 + ub * COS1;
    ua = ra;
    const out = fit(L, c, ua, ub);
    if (farEnough(out)) return out;
  }
  return fit(L, 0, 1, 0);
}

/** The accent pair of a colour: a brand colour, or a seed stored with a content. Throws on a malformed colour. */
export function accentFromColor(seed: string): AccentPair {
  const hex = toHex(parseColor(seed));
  return { seed: hex, light: accentFor(hex, 'light'), dark: accentFor(hex, 'dark') };
}

// ---------------------------------------------------------------- accent of an image

/** Straight (not premultiplied) RGBA bytes, as canvas `getImageData` gives them. */
export type Pixels = ArrayLike<number>;

// Box-averages straight RGBA bytes into n × n cells, channels 0..1, colour weighted by alpha
function sample(rgba: Pixels, width: number, height: number): Rgb[] {
  const n = A.sample;
  const cells: Rgb[] = [];
  const at = (i: number) => rgba[i] ?? 0;
  for (let oy = 0; oy < n; oy++) {
    const y0 = Math.floor((oy * height) / n);
    const y1 = Math.max(Math.floor(((oy + 1) * height) / n), y0 + 1);
    for (let ox = 0; ox < n; ox++) {
      const x0 = Math.floor((ox * width) / n);
      const x1 = Math.max(Math.floor(((ox + 1) * width) / n), x0 + 1);
      let sr = 0;
      let sg = 0;
      let sb = 0;
      let sa = 0;
      for (let y = y0; y < y1; y++) {
        for (let x = x0; x < x1; x++) {
          const i = (y * width + x) * 4;
          const alpha = at(i + 3);
          sr += at(i) * alpha;
          sg += at(i + 1) * alpha;
          sb += at(i + 2) * alpha;
          sa += alpha;
        }
      }
      const count = (y1 - y0) * (x1 - x0);
      cells.push(
        sa === 0
          ? { r: 0, g: 0, b: 0, a: 0 }
          : { r: sr / sa / 255, g: sg / sa / 255, b: sb / sa / 255, a: sa / count / 255 },
      );
    }
  }
  return cells;
}

// The chroma-weighted mean colour of the best window of three neighbouring hue bins, or null
function seedOf(cells: Rgb[]): string | null {
  const bins = A.bins;
  const width = 360 / bins;
  const weight = new Array<number>(bins).fill(0);
  const kept: { bin: number; c: number; lab: Lab }[] = [];
  for (const cell of cells) {
    if (cell.a < 0.5) continue;
    const lab = toLab(cell);
    const c = chroma(lab.a, lab.b);
    if (c < A.minChroma || lab.L < A.minTone || lab.L > A.maxTone) continue;
    let degrees = atan2(lab.b, lab.a) * DEGREES;
    if (degrees < 0) degrees += 360;
    const bin = Math.floor(degrees / width) % bins;
    weight[bin] = (weight[bin] ?? 0) + c;
    kept.push({ bin, c, lab });
  }
  if (kept.length === 0) return null;

  // a window of three bins, so a colour split by a bin boundary still counts whole
  const w = (i: number) => weight[(i + bins) % bins] ?? 0;
  let best = 0;
  let bestScore = -1;
  for (let i = 0; i < bins; i++) {
    const score = w(i - 1) + w(i) + w(i + 1);
    if (score > bestScore || (score === bestScore && w(i) > w(best))) {
      best = i;
      bestScore = score;
    }
  }
  let sw = 0;
  let sL = 0;
  let sa = 0;
  let sb = 0;
  for (const { bin, c, lab } of kept) {
    if (bin !== best && bin !== (best + 1) % bins && bin !== (best + bins - 1) % bins) continue;
    sw += c;
    sL += lab.L * c;
    sa += lab.a * c;
    sb += lab.b * c;
  }
  return toHex(fromLab({ L: sL / sw, a: sa / sw, b: sb / sw }));
}

// ---------------------------------------------------------------- ambient opacity

// The saturate matrix of CSS and SVG filters
function saturate({ r, g, b }: Rgb): Rgb {
  const s = AMB.saturate;
  const clamp = (v: number) => Math.min(1, Math.max(0, v));
  return {
    r: clamp((0.213 + 0.787 * s) * r + (0.715 - 0.715 * s) * g + (0.072 - 0.072 * s) * b),
    g: clamp((0.213 - 0.213 * s) * r + (0.715 + 0.285 * s) * g + (0.072 - 0.072 * s) * b),
    b: clamp((0.213 - 0.213 * s) * r + (0.715 - 0.715 * s) * g + (0.072 + 0.928 * s) * b),
    a: 1,
  };
}

const mapRgb = ({ r, g, b }: Rgb, f: (v: number) => number): Rgb => ({ r: f(r), g: f(g), b: f(b), a: 1 });

// A cell as it is and saturated, in sRGB and in linear light: platforms saturate in either space
const variantsOf = (px: Rgb): Rgb[] => [px, saturate(px), mapRgb(saturate(mapRgb(px, lin)), gam)];

// The highest opacity, in steps of 0.01 and at most the mode's maximum, at which every cell over bg stays within
// the luminance cap. The range is halved, and the cells within the cap at a failing opacity are dropped from the next
// steps: a cell within the cap at some opacity is taken to be within it below too. Luminance is convex in the
// opacity, so that holds for any cell in dark mode, where bg is within the cap; in light mode a cell could dip below
// the cap and come back, which the tokens rule out (tests/core/color.test.ts).
function ambientOpacity(cells: Rgb[], opaqueVariants: (Rgb[] | null)[], mode: ModeName): number {
  const base = parseColor(MODES[mode].color.bg);
  const { cap, maxOpacity: max } = MODES[mode].ambient;
  const within = (px: Rgb, opacity: number) => {
    const k = 1 - opacity;
    const y =
      0.2126 * lin(px.r * opacity + base.r * k) +
      0.7152 * lin(px.g * opacity + base.g * k) +
      0.0722 * lin(px.b * opacity + base.b * k);
    return mode === 'dark' ? y <= cap : y >= cap;
  };
  let low = 0;
  let high = roundHalfUp(max * 100);
  let risky: Rgb[] = [];
  cells.forEach((cell, i) => {
    for (const variant of opaqueVariants[i] ?? variantsOf(over(cell, base))) {
      if (!within(variant, high / 100)) risky.push(variant);
    }
  });
  if (risky.length === 0) return high / 100;
  while (high - low > 1) {
    const mid = Math.floor((low + high) / 2);
    const failing = risky.filter((px) => !within(px, mid / 100));
    if (failing.length === 0) {
      low = mid;
    } else {
      high = mid;
      risky = failing;
    }
  }
  return low / 100;
}

/**
 * The accent pair and ambient opacities of an image, from its straight RGBA bytes (a thumbnail is enough). With no
 * colourful cell, `seed` is null and the pair is the neutral one. Throws a RangeError if the bytes do not hold the
 * image.
 */
export function accentFromPixels(rgba: Pixels, width: number, height: number): ImageAccent {
  if (!Number.isInteger(width) || !Number.isInteger(height) || width < 1 || height < 1) {
    throw new RangeError(`accentFromPixels: ${String(width)} × ${String(height)} is not an image size`);
  }
  if (rgba.length < width * height * 4) {
    throw new RangeError(
      `accentFromPixels: ${String(rgba.length)} bytes do not hold a ${String(width)} × ${String(height)} RGBA image`,
    );
  }
  const cells = sample(rgba, width, height);
  const seed = seedOf(cells);
  const pair = seed ? accentFromColor(seed) : neutralPair;
  // an opaque cell looks the same over either background: its variants are computed once for both modes
  const opaqueVariants = cells.map((cell) => (cell.a === 1 ? variantsOf(cell) : null));
  return {
    ...pair,
    ambient: {
      light: ambientOpacity(cells, opaqueVariants, 'light'),
      dark: ambientOpacity(cells, opaqueVariants, 'dark'),
    },
  };
}
