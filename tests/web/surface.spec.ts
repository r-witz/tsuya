// The surface of material.css (DESIGN.md: Ambient background, Glow, Grain, Surface): the grain and its modes, one
// texel per device pixel, the ambient background through setAmbient, and the glow.
import { expect, test, type Page } from '@playwright/test';

import { ambient, dark, light } from '../../packages/core/src/tokens.ts';
import { open, pixels, style } from './support.ts';

const IMAGE = '/core/src/css/grain.png';

function setAmbient(page: Page, id: string, src: string | null, opacity?: { light: number; dark: number }) {
  return page.evaluate(
    ({ id, src, opacity }) => {
      const { tsuya } = window as unknown as { tsuya: typeof import('../../packages/core/src/index.ts') };
      const element = document.getElementById(id);
      if (!element) throw new Error(`no #${id}`);
      tsuya.setAmbient(element, src, opacity);
    },
    { id, src, opacity },
  );
}

// the opacity of each layer of an ambient background, and whether it shows
const layers = (page: Page, id: string) =>
  page.evaluate(
    (id) =>
      [...(document.getElementById(id)?.children ?? [])].map((layer) => ({
        on: layer.hasAttribute('data-on'),
        opacity: Number(getComputedStyle(layer).opacity),
        image: getComputedStyle(layer).backgroundImage.includes('grain.png'),
      })),
    id,
  );

test('the grain lies over the background and the ambient, under the content; all and off', async ({ page }) => {
  const loaded = page.waitForResponse((response) => response.url().endsWith('/grain.png'));
  await open(
    page,
    `<div id="bg" class="t-surface" style="height: 100px"><p>a</p></div>
     <div id="all" class="t-surface" data-grain="all"><p>b</p></div>
     <div id="off" class="t-surface" data-grain="off"><p>c</p></div>`,
  );
  expect((await loaded).status()).toBe(200);
  expect(await style(page, '#bg', 'background-image', '::after')).toContain('grain.png');
  // one texel per device pixel: 64 CSS px at 1x, 32 at 2x (Desktop Safari), 64 / 3 at 3x
  const ratio = await page.evaluate(() => devicePixelRatio);
  const texels = ratio >= 3 ? 3 : ratio >= 2 ? 2 : 1;
  expect(parseFloat(await style(page, '#bg', 'background-size', '::after'))).toBeCloseTo(64 / texels, 2);
  expect(await style(page, '#bg', 'mix-blend-mode', '::after')).toBe('overlay');
  expect(await style(page, '#bg', 'opacity', '::after')).toBe('0.09');
  expect(await style(page, '#bg', 'z-index', '::after')).toBe('-1');
  expect(await style(page, '#bg', 'isolation')).toBe('isolate');
  expect(await style(page, '#all', 'z-index', '::after')).toBe('1');
  expect(await style(page, '#off', 'content', '::after')).toBe('none');
});

test.describe('on a 2x screen', () => {
  test.use({ deviceScaleFactor: 2 });

  test('one texel per device pixel', async ({ page }) => {
    await open(page, '<div id="bg" class="t-surface"></div>');
    expect(await style(page, '#bg', 'background-size', '::after')).toBe('32px auto');
  });
});

test.describe('the ambient background', () => {
  test.use({ reducedMotion: 'reduce' });

  const body = `<div class="t-surface" style="height: 900px"><div id="a" class="t-ambient"></div></div>
    <div class="t-surface" data-theme="dark" style="height: 900px"><div id="b" class="t-ambient"></div></div>`;

  test('shows the image at the opacity of its pair for the mode, never above the maximum', async ({ page }) => {
    await open(page, body);
    await setAmbient(page, 'a', IMAGE, { light: 0.3, dark: 0.45 });
    await setAmbient(page, 'b', IMAGE, { light: 0.3, dark: 0.45 });
    expect(await layers(page, 'a')).toEqual([
      { on: true, opacity: 0.3, image: true },
      { on: false, opacity: 0, image: false },
    ]);
    expect((await layers(page, 'b'))[0]?.opacity).toBe(0.45);
    expect(await page.getAttribute('#a', 'aria-hidden')).toBe('true');
    expect(await style(page, '#a', 'height')).toBe(`${String(ambient.height)}px`);
    expect(await style(page, '#a', 'mask-image')).toContain('linear-gradient');
    // too high for the mode: its maximum
    await setAmbient(page, 'a', IMAGE, { light: 0.9, dark: 0.9 });
    await setAmbient(page, 'b', IMAGE, { light: 0.9, dark: 0.9 });
    expect((await layers(page, 'a'))[1]?.opacity).toBe(light.ambient.maxOpacity);
    expect((await layers(page, 'b'))[1]?.opacity).toBe(dark.ambient.maxOpacity);
  });

  test('a new image takes the other layer, without opacity the safe one, null shows none', async ({ page }) => {
    await open(page, body);
    await setAmbient(page, 'a', IMAGE, { light: 0.3, dark: 0.45 });
    await setAmbient(page, 'a', IMAGE);
    expect(await layers(page, 'a')).toEqual([
      { on: false, opacity: 0, image: true },
      { on: true, opacity: ambient.safeOpacity, image: true },
    ]);
    await setAmbient(page, 'a', null);
    expect((await layers(page, 'a')).map((layer) => layer.on)).toEqual([false, false]);
  });
});

test('a new image cross-fades over --t-duration-ambient', async ({ page }) => {
  await open(page, '<div class="t-surface" style="height: 900px"><div id="a" class="t-ambient"></div></div>');
  await setAmbient(page, 'a', IMAGE, { light: 0.3, dark: 0.45 });
  const durations = await page.evaluate(() =>
    [...(document.getElementById('a')?.children ?? [])].map((layer) =>
      layer.getAnimations().map((a) => a.effect?.getTiming().duration),
    ),
  );
  expect(durations[0]).toEqual([900]);
});

test('the glow: the text colour at the top centre, gone at --t-glow-radius of the width', async ({ page }) => {
  await open(
    page,
    `<div class="t-surface" data-theme="dark" data-grain="off" style="width: 400px; height: 400px">
       <div class="t-glow"><i></i></div></div>`,
  );
  const bytes = await pixels(page, { x: 0, y: 0, width: 400, height: 400 });
  const at = (x: number, y: number) => bytes[(y * 400 + x) * 4] ?? 0;
  const bg = 0x0a;
  const top = Math.round(dark.glow.opacity * 255 + (1 - dark.glow.opacity) * bg);
  expect(Math.abs(at(200, 0) - top)).toBeLessThanOrEqual(1);
  expect(at(200, 120)).toBeGreaterThan(bg);
  expect(at(200, 120)).toBeLessThan(top);
  // 0.6 × 400 = 240 below the top centre, and beyond: the background
  expect(at(200, 245)).toBe(bg);
  expect(at(5, 260)).toBe(bg);
});
