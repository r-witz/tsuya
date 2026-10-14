// Shared helpers of the Playwright specs: a page at an origin of its own that serves packages/core (CSS, fonts, the
// built modules), computed colours as numbers, and the pixels of a screenshot decoded in the page.
import { readFileSync } from 'node:fs';

import type { Page } from '@playwright/test';

export const ORIGIN = 'https://tsuya.test';
const CORE = new URL('../../packages/core/', import.meta.url);
const TYPES: Record<string, string> = { css: 'text/css', js: 'text/javascript', png: 'image/png', woff2: 'font/woff2' };

/**
 * The head of a page that uses all of @tsuya/core: its CSS, and its built modules (`npm run build -w packages/core`)
 * as `window.tsuya`, set before the page's load event.
 */
export const HEAD = `<link rel="stylesheet" href="/core/src/css/tsuya.css"><script type="module">import * as tsuya from '/core/dist/index.js'; window.tsuya = tsuya;</script>`;

/** Opens a page with `body` at https://tsuya.test/, which serves packages/core under /core/. */
export async function open(page: Page, body: string, head = HEAD): Promise<void> {
  await page.route(`${ORIGIN}/**`, (route) => {
    const path = new URL(route.request().url()).pathname;
    if (path === '/') {
      const html = `<!doctype html><html><head><meta charset="utf-8">${head}</head><body>${body}</body></html>`;
      return route.fulfill({ contentType: 'text/html', body: html });
    }
    if (!path.startsWith('/core/')) return route.fulfill({ status: 404 });
    try {
      const file = readFileSync(new URL(path.slice('/core/'.length), CORE));
      return route.fulfill({
        contentType: TYPES[path.split('.').pop() ?? ''] ?? 'application/octet-stream',
        body: file,
      });
    } catch {
      return route.fulfill({ status: 404 });
    }
  });
  await page.goto(`${ORIGIN}/`);
}

/**
 * [r, g, b, a] of a computed colour, channels 0..255 rounded to integers and alpha 0..1 to three places, whatever the
 * engine writes: rgb() or color(srgb).
 */
export function rgba(page: Page, selector: string, property: string, pseudo?: string): Promise<number[]> {
  return page.evaluate(
    ({ selector, property, pseudo }) => {
      const element = document.querySelector(selector);
      if (!element) throw new Error(`no ${selector}`);
      const value = getComputedStyle(element, pseudo).getPropertyValue(property);
      const numbers = (value.match(/-?[\d.]+(e-?\d+)?/g) ?? []).map(Number);
      const [r = 0, g = 0, b = 0] = value.startsWith('color(') ? numbers.map((v) => v * 255) : numbers;
      const alpha = value.includes('/') || value.startsWith('rgba') ? (numbers[3] ?? 1) : 1;
      return [...[r, g, b].map(Math.round), Math.round(alpha * 1000) / 1000];
    },
    { selector, property, pseudo },
  );
}

/** A computed style property of the first element matching `selector`. */
export function style(page: Page, selector: string, property: string, pseudo?: string): Promise<string> {
  return page.evaluate(
    ({ selector, property, pseudo }) => {
      const element = document.querySelector(selector);
      if (!element) throw new Error(`no ${selector}`);
      return getComputedStyle(element, pseudo).getPropertyValue(property);
    },
    { selector, property, pseudo },
  );
}

/** The RGBA bytes of a region of the page, row by row: a screenshot, decoded in the page. */
export async function pixels(
  page: Page,
  clip: { x: number; y: number; width: number; height: number },
): Promise<Uint8Array> {
  const png = await page.screenshot({ clip, animations: 'disabled', scale: 'css' });
  const base64 = await page.evaluate(async (png) => {
    const bitmap = await createImageBitmap(await (await fetch(`data:image/png;base64,${png}`)).blob());
    const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
    const context = canvas.getContext('2d');
    if (!context) throw new Error('no 2D canvas');
    context.drawImage(bitmap, 0, 0);
    const data = context.getImageData(0, 0, bitmap.width, bitmap.height).data;
    // as base64: an array of millions of numbers is slow to send back
    let binary = '';
    for (let i = 0; i < data.length; i += 0x8000) binary += String.fromCharCode(...data.subarray(i, i + 0x8000));
    return btoa(binary);
  }, png.toString('base64'));
  return new Uint8Array(Buffer.from(base64, 'base64'));
}

/** Hex '#RRGGBB' or '#RRGGBBAA' to channels 0..255 and alpha 0..1 to three places, as `rgba` gives them. */
export function hex(value: string): number[] {
  const n = /^#([0-9a-f]{6})([0-9a-f]{2})?$/i.exec(value);
  if (!n?.[1]) throw new Error(`not a hex colour: ${value}`);
  const [r, g, b] = [0, 2, 4].map((i) => parseInt(n[1]?.slice(i, i + 2) ?? '0', 16));
  return [r ?? 0, g ?? 0, b ?? 0, n[2] ? Math.round((parseInt(n[2], 16) / 255) * 1000) / 1000 : 1];
}
