// The docs shell: the top bar fits at every width and its menu reaches every page,
// the mode menu, a skip link, a description and a favicon on every page.
import { expect, test, type Page } from '@playwright/test';

import { PAGES, open } from './support.ts';

const WIDTHS = [375, 600, 768, 900, 1100, 1199, 1440];

test('the top bar: start, centre and end never overlap, and no control is squashed', async ({ page }) => {
  test.setTimeout(120_000);
  for (const width of WIDTHS) {
    await page.setViewportSize({ width, height: 900 });
    await open(page, '/components/menu');
    const found = await page.evaluate(() => {
      const bar = document.querySelector('header.t-top-bar') as HTMLElement;
      const parts = (['.t-top-bar-start', '.t-top-bar-center', '.t-top-bar-end'] as const).map(
        (s) => [s, bar.querySelector(s)?.getBoundingClientRect()] as const,
      );
      const out: string[] = [];
      for (const [i, [a, ra]] of parts.entries())
        for (const [b, rb] of parts.slice(i + 1)) {
          if (!ra || !rb || ra.width === 0 || rb.width === 0) continue;
          const overlap = Math.min(ra.right, rb.right) - Math.max(ra.left, rb.left);
          const rows = Math.min(ra.bottom, rb.bottom) - Math.max(ra.top, rb.top);
          if (overlap > 0.5 && rows > 0.5) out.push(`${a} and ${b} overlap by ${String(Math.round(overlap))}`);
        }
      // the links the reader sees at the centre stay inside the centre (it scrolls sideways when they do not fit)
      const centre = bar.querySelector('.t-top-bar-center') as HTMLElement;
      const centreBox = centre.getBoundingClientRect();
      for (const link of centre.querySelectorAll('a')) {
        const r = link.getBoundingClientRect();
        if (r.width === 0) continue;
        const clipped = r.right > centreBox.right + 0.5 || r.left < centreBox.left - 0.5;
        if (clipped && getComputedStyle(centre).overflowX === 'visible')
          out.push(`"${link.textContent}" leaves the centre, which does not scroll`);
      }
      // the start and the end stay inside the bar, and no control of the end is squashed
      const barBox = bar.getBoundingClientRect();
      for (const el of bar.querySelectorAll('.t-top-bar-start, .t-top-bar-end, .t-top-bar-end *')) {
        const r = el.getBoundingClientRect();
        if (r.width > 0 && (r.left < barBox.left - 0.5 || r.right > barBox.right + 0.5))
          out.push(`${el.className} leaves the bar`);
        if (r.height > 60) out.push(`${el.tagName} is ${String(Math.round(r.height))} tall`);
      }
      return out;
    });
    expect(found, `${String(width)} px`).toEqual([]);
  }
});

/** Every internal link that a reader can follow at this width (the links of a hidden sidebar cannot be). */
async function visibleLinks(page: Page): Promise<string[]> {
  return page.evaluate(() =>
    [...document.querySelectorAll('a[href^="/"]')]
      .filter((a) => (a as HTMLElement).getClientRects().length > 0)
      .map((a) => new URL((a as HTMLAnchorElement).href).pathname.replace(/\/$/, '')),
  );
}

test('at 375 px the bar menu opens and, with the pages it links to, reaches every page of the nav', async ({
  page,
}) => {
  test.setTimeout(180_000);
  await page.setViewportSize({ width: 375, height: 800 });
  await open(page, '/');
  await expect(page.locator('header.t-top-bar nav.t-top-bar-links')).toBeHidden();
  await page.locator('header.t-top-bar').getByRole('button', { name: 'More' }).click();
  const seen = new Set<string>(await visibleLinks(page));
  expect(seen.size, 'the menu lists the top-level links').toBeGreaterThanOrEqual(7);
  const queue = [...seen];
  const visited = new Set<string>();
  while (queue.length) {
    const path = queue.shift() as string;
    if (visited.has(path)) continue;
    visited.add(path);
    await page.goto(path || '/', { waitUntil: 'domcontentloaded' });
    for (const link of await visibleLinks(page))
      if (!seen.has(link)) {
        seen.add(link);
        queue.push(link);
      }
  }
  const missing = PAGES.map(({ slug }) => `/${slug}`.replace(/\/$/, '')).filter((p) => !seen.has(p));
  expect(missing, 'pages that no visible link leads to').toEqual([]);
});

test('the mode menu sets System, Light or Dark', async ({ page }) => {
  await page.emulateMedia({ colorScheme: 'light' });
  await page.setViewportSize({ width: 375, height: 800 });
  await open(page, '/components/button');
  const trigger = page.locator('header.t-top-bar').getByRole('button', { name: 'Mode' });
  await trigger.click();
  await expect(page.getByRole('menuitemradio', { name: 'System' })).toHaveAttribute('aria-checked', 'true');
  await page.getByRole('menuitemradio', { name: 'Dark' }).click();
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  await trigger.click();
  await expect(page.getByRole('menuitemradio', { name: 'Dark' })).toHaveAttribute('aria-checked', 'true');
  await page.getByRole('menuitemradio', { name: 'System' }).click();
  await expect(page.locator('html')).not.toHaveAttribute('data-theme');
});

test('a skip link is the first stop, shows on focus and moves focus to the main content', async ({ page }) => {
  await open(page, '/components/button');
  await page.keyboard.press('Tab');
  const skip = page.getByRole('link', { name: 'Skip to main content' });
  await expect(skip).toBeFocused();
  const box = await skip.boundingBox();
  expect(box && box.x >= 0 && box.y >= 0 && box.width > 40 && box.height > 20, 'visible on focus').toBe(true);
  await page.keyboard.press('Enter');
  await expect(page.locator('main')).toBeFocused();
});

test('every page has one description and the site has a favicon', async ({ page, request }) => {
  test.setTimeout(120_000);
  const bad: string[] = [];
  for (const { slug } of PAGES) {
    await page.goto(`/${slug}`, { waitUntil: 'domcontentloaded' });
    const tags = page.locator('meta[name="description"]');
    const description = (await tags.count()) === 1 ? await tags.getAttribute('content') : null;
    if (!description || description.length < 30 || description.length > 200)
      bad.push(`/${slug}: "${String(description)}"`);
  }
  expect(bad, 'one description of 30 to 200 characters').toEqual([]);
  const href = await page.locator('link[rel="icon"]').getAttribute('href');
  expect(href).toBeTruthy();
  const icon = await request.get(href as string);
  expect(icon.ok()).toBe(true);
  expect(icon.headers()['content-type']).toContain('image/svg+xml');
});
