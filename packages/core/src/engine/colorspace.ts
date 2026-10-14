// Portable maths, sRGB, CIE L*a*b* and WCAG contrast for the colour engine. Channels are 0..1.
//
// For the same result on every platform to the last bit, the maths uses only +, −, ×, ÷ and sqrt, which IEEE 754
// rounds the same way everywhere: ln, exp, pow and atan2 are written out here. The Dart port follows this file line
// by line.

export interface Rgb {
  r: number;
  g: number;
  b: number;
  a: number;
}

export interface Lab {
  L: number;
  a: number;
  b: number;
}

// ---------------------------------------------------------------- portable maths

export const PI = 3.141592653589793;
const LN2 = 0.6931471805599453;
const SQRT2 = 1.4142135623730951;
const SQRT1_2 = 0.7071067811865476;
// 1 / n, computed once: IEEE division gives the same bits everywhere, and a product is cheaper than a quotient
const INVERSE = Array.from({ length: 26 }, (_, n) => 1 / n);
export const DEGREES = 57.29577951308232; // 180 / π
export const COS1 = 0.9998476951563913; // cos 1°
export const SIN1 = 0.01745240643728351; // sin 1°

const inverse = (n: number): number => INVERSE[n] ?? 1 / n;

// ln x for x > 0: x = m · 2^k with m in [√½, √2), then ln m = 2 atanh z with |z| = |m − 1| / (m + 1) < 0.172
function ln(x: number): number {
  let k = 0;
  while (x >= SQRT2) {
    x *= 0.5;
    k++;
  }
  while (x < SQRT1_2) {
    x *= 2;
    k--;
  }
  const z = (x - 1) / (x + 1);
  const z2 = z * z;
  let term = z;
  let sum = 0;
  for (let n = 1; n <= 25; n += 2) {
    sum += term * inverse(n);
    term *= z2;
  }
  return 2 * sum + k * LN2;
}

// e^x: x = k ln 2 + r with |r| ≤ ln 2 / 2, then e^r by its series and 2^k by halving or doubling
function exp(x: number): number {
  const k = Math.floor(x / LN2 + 0.5);
  const r = x - k * LN2;
  let term = 1;
  let sum = 1;
  for (let n = 1; n <= 17; n++) {
    term *= r * inverse(n);
    sum += term;
  }
  for (let i = 0; i < k; i++) sum *= 2;
  for (let i = 0; i > k; i--) sum *= 0.5;
  return sum;
}

const pow = (x: number, y: number): number => (x <= 0 ? 0 : exp(y * ln(x)));

// atan t: folded into [0, 1], halved twice (atan t = 2 atan(t / (1 + √(1 + t²)))), then its series
function atan(t: number): number {
  const negative = t < 0;
  if (negative) t = -t;
  const inverted = t > 1;
  if (inverted) t = 1 / t;
  t = t / (1 + Math.sqrt(1 + t * t));
  t = t / (1 + Math.sqrt(1 + t * t));
  const t2 = t * t;
  let term = t;
  let sum = 0;
  for (let n = 1; n <= 31; n += 2) {
    sum += (n % 4 === 1 ? term : -term) / n;
    term *= t2;
  }
  let angle = 4 * sum;
  if (inverted) angle = PI / 2 - angle;
  return negative ? -angle : angle;
}

export function atan2(y: number, x: number): number {
  if (x > 0) return atan(y / x);
  if (x < 0) return y >= 0 ? atan(y / x) + PI : atan(y / x) - PI;
  if (y > 0) return PI / 2;
  if (y < 0) return -PI / 2;
  return 0;
}

// Math.round of JavaScript and round() of Dart differ on negative halves; this is the same on both
export const roundHalfUp = (x: number): number => Math.floor(x + 0.5);

// ---------------------------------------------------------------- sRGB, CIE L*a*b*, contrast (channels 0..1)

export const lin = (c: number): number => (c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4));
export const gam = (c: number): number => (c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1 / 2.4) - 0.055);

const HEX = /^#?([0-9a-f]{6}|[0-9a-f]{8})$/i;

/** '#RRGGBB' or '#RRGGBBAA' to { r, g, b, a }, channels 0..1. */
export function parseColor(hex: string): Rgb {
  const n = HEX.exec(hex)?.[1];
  if (n === undefined) throw new RangeError(`Not a #RRGGBB or #RRGGBBAA colour: ${hex}`);
  const channel = (i: number) => parseInt(n.slice(i, i + 2), 16) / 255;
  return { r: channel(0), g: channel(2), b: channel(4), a: n.length === 8 ? channel(6) : 1 };
}

/** '#RRGGBB' of a colour, each channel clamped to 0..1 and rounded half up; alpha is ignored. */
export function toHex({ r, g, b }: Rgb): string {
  const byte = (v: number) => roundHalfUp(Math.min(1, Math.max(0, v)) * 255);
  return (
    '#' +
    [r, g, b]
      .map((v) => byte(v).toString(16).padStart(2, '0'))
      .join('')
      .toUpperCase()
  );
}

/** A translucent colour seen over an opaque one. */
export const over = (top: Rgb, bottom: Rgb): Rgb => ({
  r: top.r * top.a + bottom.r * (1 - top.a),
  g: top.g * top.a + bottom.g * (1 - top.a),
  b: top.b * top.a + bottom.b * (1 - top.a),
  a: 1,
});

export const luminance = ({ r, g, b }: Rgb): number => 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);

export function contrastOf(x: Rgb, y: Rgb): number {
  const p = luminance(x);
  const q = luminance(y);
  return p > q ? (p + 0.05) / (q + 0.05) : (q + 0.05) / (p + 0.05);
}

/** WCAG contrast of two colours; a translucent foreground is seen over the background. */
export function contrast(foreground: string, background: string): number {
  const back = parseColor(background);
  return contrastOf(over(parseColor(foreground), back), back);
}

export function toLab({ r, g, b }: Rgb): Lab {
  const lr = lin(r);
  const lg = lin(g);
  const lb = lin(b);
  const x = (0.4124 * lr + 0.3576 * lg + 0.1805 * lb) / 0.95047;
  const y = 0.2126 * lr + 0.7152 * lg + 0.0722 * lb;
  const z = (0.0193 * lr + 0.1192 * lg + 0.9505 * lb) / 1.08883;
  const f = (t: number) => (t > 216 / 24389 ? pow(t, 1 / 3) : ((24389 / 27) * t + 16) / 116);
  const fx = f(x);
  const fy = f(y);
  const fz = f(z);
  return { L: 116 * fy - 16, a: 500 * (fx - fy), b: 200 * (fy - fz) };
}

export function fromLab({ L, a, b }: Lab): Rgb {
  const fy = (L + 16) / 116;
  const fx = fy + a / 500;
  const fz = fy - b / 200;
  const inv = (t: number) => (t * t * t > 216 / 24389 ? t * t * t : (116 * t - 16) / (24389 / 27));
  const x = inv(fx) * 0.95047;
  const y = inv(fy);
  const z = inv(fz) * 1.08883;
  return {
    r: gam(3.2406 * x - 1.5372 * y - 0.4986 * z),
    g: gam(-0.9689 * x + 1.8758 * y + 0.0415 * z),
    b: gam(0.0557 * x - 0.204 * y + 1.057 * z),
    a: 1,
  };
}

export const chroma = (a: number, b: number): number => Math.sqrt(a * a + b * b);
export const distance = (p: Lab, q: Lab): number =>
  Math.sqrt((p.L - q.L) * (p.L - q.L) + (p.a - q.a) * (p.a - q.a) + (p.b - q.b) * (p.b - q.b));
export const inGamut = ({ r, g, b }: Rgb): boolean => [r, g, b].every((v) => v >= -1e-4 && v <= 1 + 1e-4);
export const labOfHex = (hex: string): Lab => toLab(parseColor(hex));
