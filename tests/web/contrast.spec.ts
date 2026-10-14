// G1 on rendered pixels: text and text-muted keep 4.5:1 on glass over white, black and the
// reference images (the images of spec/cases.json), neutral or tinted by the worst accent of the band, and on the
// ambient background of every reference image at its computed opacity. The pixels come from screenshots decoded in
// the page; text is measured against every pixel of the ground it sits on.
import { readFileSync } from 'node:fs';

import { expect, test, type Page } from '@playwright/test';

import { contrastOf, over, parseColor, type Rgb } from '../../packages/core/src/engine/colorspace.ts';
import { dark, light } from '../../packages/core/src/tokens.ts';
import { open, pixels } from './support.ts';

interface ImageCase {
  name: string;
  width: number;
  height: number;
  rgba: string;
  ambient: { light: number; dark: number };
}
const images = (
  JSON.parse(readFileSync(new URL('../../spec/cases.json', import.meta.url), 'utf8')) as { images: ImageCase[] }
).images;

// the worst glass tints of spec/cases.json's checks: a pure blue at the dark end of the light band, the light grey of
// the dark band
const WORST = { light: '#0000FD', dark: '#B6B6B6' };
const MODES = { light, dark };

interface Box {
  x: number;
  y: number;
  width: number;
  height: number;
}

// the lowest contrast of text and text-muted against the pixels of each box, inset to leave its anti-aliased edges;
// one screenshot of the whole page
async function lowest(page: Page, mode: 'light' | 'dark', boxes: Box[]): Promise<number[]> {
  const { width, height } = page.viewportSize() ?? { width: 0, height: 0 };
  const bytes = await pixels(page, { x: 0, y: 0, width, height });
  const text = parseColor(MODES[mode].color.text);
  const muted = parseColor(MODES[mode].color.textMuted);
  return boxes.map((box) => {
    let worst = Infinity;
    for (let y = Math.ceil(box.y) + 4; y < Math.floor(box.y + box.height) - 4; y++) {
      for (let x = Math.ceil(box.x) + 4; x < Math.floor(box.x + box.width) - 4; x++) {
        const i = (y * width + x) * 4;
        const ground: Rgb = {
          r: (bytes[i] ?? 0) / 255,
          g: (bytes[i + 1] ?? 0) / 255,
          b: (bytes[i + 2] ?? 0) / 255,
          a: 1,
        };
        worst = Math.min(worst, contrastOf(text, ground), contrastOf(over(muted, ground), ground));
      }
    }
    return worst;
  });
}

// the reference images as PNG data URLs, made in the page from their RGBA bytes
function dataUrls(page: Page): Promise<string[]> {
  return page.evaluate((images) => {
    return images.map(({ width, height, rgba }) => {
      const canvas = document.createElement('canvas');
      canvas.width = width;
      canvas.height = height;
      const bytes = Uint8ClampedArray.from(atob(rgba), (c) => c.charCodeAt(0));
      canvas.getContext('2d')?.putImageData(new ImageData(bytes, width, height), 0, 0);
      return canvas.toDataURL('image/png');
    });
  }, images);
}

for (const mode of ['light', 'dark'] as const) {
  test.describe(`${mode} mode`, () => {
    // reduced motion: the ambient background shows at its opacity at once, without its cross-fade
    test.use({ colorScheme: mode, viewport: { width: 1280, height: 960 }, reducedMotion: 'reduce' });

    test('text keeps 4.5:1 on glass over white, black and every reference image', async ({ page }) => {
      await open(page, '<div id="grid" style="display: flex; flex-wrap: wrap; width: 1280px"></div>');
      const urls = await dataUrls(page);
      const grounds = ['#FFFFFF', '#000000', ...urls.map((url) => `url(${url}) center / cover`)];
      await page.evaluate(
        ({ grounds, worst }) => {
          const grid = document.getElementById('grid');
          for (const ground of grounds) {
            for (const tint of [null, worst]) {
              const cell = document.createElement('div');
              cell.style.cssText = `position: relative; width: 160px; height: 120px; background: ${ground}`;
              const region = document.createElement('div');
              if (tint) {
                region.className = 't-accent';
                region.style.cssText = `--t-accent-light: ${tint}; --t-accent-dark: ${tint}`;
              }
              region.innerHTML = '<div class="t-glass" style="position: absolute; inset: 30px 0; "></div>';
              cell.append(region);
              grid?.append(cell);
            }
          }
        },
        { grounds, worst: WORST[mode] },
      );
      const boxes = await page.locator('.t-glass').evaluateAll((glasses) =>
        glasses.map((glass) => {
          const { x, y, width, height } = glass.getBoundingClientRect();
          return { x, y, width, height };
        }),
      );
      expect(boxes).toHaveLength(grounds.length * 2);
      for (const [i, ratio] of (await lowest(page, mode, boxes)).entries()) {
        const what = `glass ${i % 2 ? 'tinted' : 'neutral'} over ground ${String(Math.floor(i / 2))}`;
        expect(ratio, what).toBeGreaterThanOrEqual(4.5);
      }
    });

    test('text keeps 4.5:1 on the ambient background of every reference image', async ({ page }) => {
      await open(page, '<div id="grid" style="display: flex; flex-wrap: wrap; width: 1280px"></div>');
      const urls = await dataUrls(page);
      await page.evaluate(
        async ({ urls, opacities }) => {
          const { tsuya } = window as unknown as { tsuya: typeof import('../../packages/core/src/index.ts') };
          // decoded before they are shown, so that the screenshot has them
          await Promise.all(
            urls.map((url) => {
              const image = new Image();
              image.src = url;
              return image.decode();
            }),
          );
          const grid = document.getElementById('grid');
          urls.forEach((url, i) => {
            const surface = document.createElement('div');
            surface.className = 't-surface';
            surface.dataset['grain'] = 'off';
            surface.style.cssText = 'width: 300px; height: 300px; overflow: hidden';
            const ambient = document.createElement('div');
            ambient.className = 't-ambient';
            surface.append(ambient);
            grid?.append(surface);
            tsuya.setAmbient(ambient, url, opacities[i]);
          });
        },
        { urls, opacities: images.map((image) => image.ambient) },
      );
      const surfaces = await page.locator('.t-surface').evaluateAll((all) =>
        all.map((surface) => {
          const { x, y, width } = surface.getBoundingClientRect();
          return { x, y, width, height: 200 };
        }),
      );
      for (const [i, ratio] of (await lowest(page, mode, surfaces)).entries()) {
        expect(ratio, `ambient of ${images[i]?.name ?? String(i)}`).toBeGreaterThanOrEqual(4.5);
      }
    });
  });
}
