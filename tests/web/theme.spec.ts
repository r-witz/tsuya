// The mode before the first paint (DESIGN.md, Theme and mode): on a light system, a forced or persisted dark mode
// must not paint a light page first. Inline scripts run before the first paint, so the background the document has
// when the body's first script runs is the one the first frame has.
import { expect, test } from '@playwright/test';

import { themeScript } from '../../packages/core/src/dom/theme.ts';
import { dark, light } from '../../packages/core/src/tokens.ts';
import { HEAD, hex, open } from './support.ts';

const RECORD = `<script>window.firstFrame = getComputedStyle(document.documentElement).backgroundColor</script>`;

// the html background the page had at the body's first script
const firstFrame = (page: import('@playwright/test').Page) =>
  page.evaluate(() => {
    const value = (window as unknown as { firstFrame: string }).firstFrame;
    return (value.match(/\d+/g) ?? []).slice(0, 3).map(Number);
  });

test.use({ colorScheme: 'light' });

test('without the script, a persisted dark mode paints the system light first', async ({ page }) => {
  await page.addInitScript(() => {
    localStorage.setItem('tsuya-mode', 'dark');
  });
  await open(page, `${RECORD}<p>page</p>`);
  expect(await firstFrame(page)).toEqual(hex(light.color.bg).slice(0, 3));
});

test('the theme script makes the first frame dark on a light system', async ({ page }) => {
  await page.addInitScript(() => {
    localStorage.setItem('tsuya-mode', 'dark');
  });
  await open(page, `${RECORD}<p>page</p>`, `<script>${themeScript()}</script>${HEAD}`);
  expect(await firstFrame(page)).toEqual(hex(dark.color.bg).slice(0, 3));
});

test('a fixed mode written on <html> in the page itself makes the first frame dark', async ({ page }) => {
  await open(page, '', HEAD);
  // open() writes its own <html>: serve one with the attribute, as an app's app.html does
  await page.route('https://tsuya.test/fixed', (route) =>
    route.fulfill({
      contentType: 'text/html',
      body: `<!doctype html><html data-theme="dark"><head><meta charset="utf-8"><link rel="stylesheet" href="/core/src/css/tsuya.css"></head><body>${RECORD}</body></html>`,
    }),
  );
  await page.goto('https://tsuya.test/fixed');
  expect(await firstFrame(page)).toEqual(hex(dark.color.bg).slice(0, 3));
});

test('a persisted system choice keeps the system mode', async ({ page }) => {
  await page.addInitScript(() => {
    localStorage.setItem('tsuya-mode', 'system');
  });
  await open(page, `${RECORD}<p>page</p>`, `<script>${themeScript()}</script>${HEAD}`);
  expect(await firstFrame(page)).toEqual(hex(light.color.bg).slice(0, 3));
});
