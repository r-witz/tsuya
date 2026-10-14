// spec/cases.json: inputs and the results the TS engine gives for them, and the worst case of each
// contrast check on the tokens. The Dart engine is tested against this file, so both platforms give the same accent
// to the hex digit. scripts/build.mjs runs this file in its own process once it has written src/tokens.ts, so the
// engine reads the new tokens; it prints the JSON.
import { pathToFileURL } from 'node:url';

import { checkMode } from '../packages/core/src/engine/check.ts';
import { accentFromColor, accentFromPixels } from '../packages/core/src/engine/color.ts';
import { dark, glass, light } from '../packages/core/src/tokens.ts';

/**
 * A 31-bit linear congruential generator; Math.imul keeps the product exact.
 * @param {number} seed
 * @returns {Generator<number, never>}
 */
export function* lcg(seed) {
  for (;;) {
    seed = (Math.imul(seed, 1103515245) + 12345) & 0x7fffffff;
    yield seed;
  }
}

const rgba = (hex, alpha = 255) => [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16)).concat(alpha);

function image(width, height, pixel) {
  const pixels = new Uint8Array(width * height * 4);
  for (let y = 0; y < height; y++) for (let x = 0; x < width; x++) pixels.set(pixel(x, y), (y * width + x) * 4);
  return { width, height, pixels };
}

function confetti() {
  const random = lcg(7);
  const palette = ['#F2C14E', '#F78154', '#4D9078', '#B4436C', '#5FAD56', '#2E86AB', '#FFFFFF', '#111111'];
  const blocks = Array.from({ length: 40 * 30 }, () => rgba(palette[random.next().value % palette.length]));
  return image(80, 60, (x, y) => blocks[Math.floor(y / 2) * 40 + Math.floor(x / 2)]);
}

const IMAGES = {
  // a teal split across the 180° bin boundary beats a larger orange that sits in a single bin
  'teal-wrap': () => image(96, 96, (x) => rgba(x < 29 ? '#339B86' : x < 58 ? '#239C8F' : '#D78C5A')),
  checker: () => image(64, 64, (x, y) => rgba((Math.floor(x / 8) + Math.floor(y / 8)) % 2 ? '#D93A3A' : '#2F5FD0')),
  confetti,
  // a 60 % blue square on transparent corners
  alpha: () => image(50, 50, (x, y) => (x >= 10 && x < 40 && y >= 10 && y < 40 ? rgba('#2364EB', 153) : [0, 0, 0, 0])),
  // smaller than the sample grid
  small: () => image(5, 3, (x) => rgba(x < 3 ? '#7A3FB0' : '#E0E0E0')),
  // not a multiple of the grid, a gradient across hues
  'odd-size': () => image(1000, 7, (x) => [Math.floor((255 * x) / 999), 80, Math.floor(255 * (1 - x / 999)), 255]),
  // no colourful pixel: the neutral accent
  grey: () => image(40, 40, (x) => [x * 6, x * 6, x * 6, 255]),
  'danger-red': () => image(48, 48, () => rgba('#C62828')),
  pastel: () => image(48, 48, () => rgba('#FFE6A8')),
  'near-black': () => image(48, 48, () => rgba('#2A0707')),
  white: () => image(48, 48, () => rgba('#FFFFFF')),
  black: () => image(48, 48, () => rgba('#000000')),
};

const SEEDS = [
  '#2A9D8F',
  '#1B2A6B',
  '#22C55E',
  '#C0392B',
  '#E53935',
  '#1F5FBF',
  '#FFE6A8',
  '#2A0707',
  '#9C27B0',
  '#FF9800',
  '#F5B942',
  '#FFFFFF',
  '#000000',
  '#808080',
  '#9A9AA4',
  '#00FF00',
  '#0000FF',
  '#FF00FF',
  '#C62828',
  '#0B7040',
];

/**
 * `count` colours '#RRGGBB' from lcg(seed).
 * @param {number} count
 * @param {number} seed
 * @returns {string[]}
 */
export function randomColors(count, seed) {
  const random = lcg(seed);
  return Array.from(
    { length: count },
    () => '#' + (random.next().value & 0xffffff).toString(16).padStart(6, '0').toUpperCase(),
  );
}

export function buildCases() {
  const cases = {
    colors: [...SEEDS, ...randomColors(1000, 2026)].map(accentFromColor),
    images: Object.entries(IMAGES).map(([name, make]) => {
      const { width, height, pixels } = make();
      return {
        name,
        width,
        height,
        rgba: Buffer.from(pixels).toString('base64'),
        ...accentFromPixels(pixels, width, height),
      };
    }),
    checks: { light: checkMode(light, glass), dark: checkMode(dark, glass) },
  };
  return JSON.stringify(cases, null, 1) + '\n';
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) process.stdout.write(buildCases());
