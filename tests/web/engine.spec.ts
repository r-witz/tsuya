// accentFromImage in the browsers, through the built modules: a canvas and a decoded PNG give the
// accent of their pixels, a large image is sampled down, and an image the page cannot read is refused with a message.
import { readFileSync } from 'node:fs';

import { expect, test } from '@playwright/test';

import { accentFromPixels, type ImageAccent } from '../../packages/core/src/engine/color.ts';
import { open } from './support.ts';

type Tsuya = typeof import('../../packages/core/src/index.ts');
interface ImageCase extends ImageAccent {
  name: string;
  width: number;
  height: number;
  rgba: string;
}

const read = (path: string) => readFileSync(new URL(path, import.meta.url));
const grain = read('../../packages/core/src/css/grain.png');
const cases = JSON.parse(read('../../spec/cases.json').toString('utf8')) as { images: ImageCase[] };

test('a canvas and the PNG made from it give the accent of their pixels', async ({ page }) => {
  await open(page, '');
  const teal = cases.images.find((c) => c.name === 'teal-wrap');
  if (!teal) throw new Error('no teal-wrap case');
  const result = await page.evaluate(async ({ rgba, width, height }) => {
    const { tsuya } = window as unknown as { tsuya: Tsuya };
    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;
    const bytes = Uint8ClampedArray.from(atob(rgba), (c) => c.charCodeAt(0));
    canvas.getContext('2d')?.putImageData(new ImageData(bytes, width, height), 0, 0);
    const image = new Image();
    image.src = canvas.toDataURL('image/png');
    await image.decode();
    return { canvas: tsuya.accentFromImage(canvas), image: tsuya.accentFromImage(image) };
  }, teal);
  const expected = { seed: teal.seed, light: teal.light, dark: teal.dark, ambient: teal.ambient };
  expect(result.canvas).toEqual(expected);
  expect(result.image).toEqual(expected);
});

test('a large image is sampled at most 256 pixels on a side', async ({ page }) => {
  await open(page, '');
  const result = await page.evaluate(() => {
    const { tsuya } = window as unknown as { tsuya: Tsuya };
    const canvas = document.createElement('canvas');
    canvas.width = 1200;
    canvas.height = 600;
    const context = canvas.getContext('2d');
    if (!context) throw new Error('no 2D canvas');
    context.fillStyle = '#2A9D8F';
    context.fillRect(0, 0, 1200, 600);
    return tsuya.accentFromImage(canvas);
  });
  const teal = new Uint8Array(256 * 128 * 4).map((_, i) => [0x2a, 0x9d, 0x8f, 255][i % 4] ?? 0);
  expect(result).toEqual(accentFromPixels(teal, 256, 128));
});

test('an image that is not loaded, or cross-origin without CORS, is refused with a message', async ({ page }) => {
  await page.route('https://images.test/**', (route) =>
    route.fulfill({
      contentType: 'image/png',
      body: grain,
      headers: route.request().headers()['origin'] ? { 'access-control-allow-origin': '*' } : {},
    }),
  );
  await open(page, '');
  const result = await page.evaluate(async () => {
    const { tsuya } = window as unknown as { tsuya: Tsuya };
    const attempt = (image: HTMLImageElement) => {
      try {
        return tsuya.accentFromImage(image).seed;
      } catch (error) {
        return (error as Error).message;
      }
    };
    const load = async (crossOrigin: string | null) => {
      const image = new Image();
      image.crossOrigin = crossOrigin;
      image.src = `https://images.test/grain.png?cors=${String(crossOrigin)}`;
      await image.decode();
      return image;
    };
    return {
      notLoaded: attempt(new Image()),
      withoutCors: attempt(await load(null)),
      withCors: attempt(await load('anonymous')),
    };
  });
  expect(result.notLoaded).toBe('accentFromImage: the image is not loaded');
  expect(result.withoutCors).toBe('accentFromImage: the image is cross-origin; serve it with CORS headers');
  // the grain is grey: no seed, the neutral pair
  expect(result.withCors).toBeNull();
});

test('a 256 × 256 image (printed, not a gate)', async ({ page }, info) => {
  await open(page, '');
  const times = await page.evaluate(() => {
    const { tsuya } = window as unknown as { tsuya: Tsuya };
    // noise, as the Node timing in tests/core/color.test.ts
    let seed = 1;
    const pixels = new Uint8Array(256 * 256 * 4);
    for (let i = 0; i < pixels.length; i++) {
      seed = (Math.imul(seed, 1103515245) + 12345) & 0x7fffffff;
      pixels[i] = i % 4 === 3 ? 255 : seed & 255;
    }
    const time = () => {
      const start = performance.now();
      tsuya.accentFromPixels(pixels, 256, 256);
      return performance.now() - start;
    };
    const first = time();
    const runs = Array.from({ length: 10 }, time).sort((a, b) => a - b);
    return { first, median: runs.slice(4, 6).reduce((sum, ms) => sum + ms, 0) / 2 };
  });
  console.log(
    `accentFromPixels, 256 × 256 noise in ${info.project.name}: ${times.median.toFixed(1)} ms per image ` +
      `(the first: ${times.first.toFixed(1)} ms)`,
  );
  expect(times.median).toBeGreaterThan(0);
});
