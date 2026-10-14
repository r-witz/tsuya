// The docs' own blocks: code blocks in both modes, the HTML of the examples, the live preview's mode, the images of
// the Flutter gallery, and the spacing of a component page.
import { expect, test, type Page } from '@playwright/test';

import { open, PAGES } from './support.ts';

/** The tokens of every code block whose colour reads under 4.5:1 on the block's background, as they render. */
async function lowContrastTokens(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    const luminance = (css: string): number => {
      const [r = 0, g = 0, b = 0] = (css.match(/[\d.]+/g) ?? []).slice(0, 3).map((v) => {
        const c = Number(v) / 255;
        return c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
      });
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    };
    const out: string[] = [];
    for (const pre of document.querySelectorAll('pre.shiki')) {
      const background = luminance(getComputedStyle(pre).backgroundColor);
      for (const span of pre.querySelectorAll('span')) {
        if (!span.textContent.trim() || span.children.length) continue;
        const [hi, lo] = [luminance(getComputedStyle(span).color), background].sort((a, b) => b - a) as [
          number,
          number,
        ];
        const ratio = (hi + 0.05) / (lo + 0.05);
        if (ratio < 4.5) out.push(`"${span.textContent.trim().slice(0, 16)}" ${ratio.toFixed(2)}`);
      }
    }
    return [...new Set(out)].slice(0, 6);
  });
}

test('code blocks: every token reads at 4.5:1 or more in both modes, from the system mode and from the menu', async ({
  page,
}) => {
  for (const mode of ['light', 'dark'] as const) {
    await page.emulateMedia({ colorScheme: mode });
    // Svelte, TypeScript, Dart, shell and CSS blocks
    for (const path of ['/components/button', '/components/menu', '/components/top-bar', '/getting-started']) {
      await open(page, path);
      expect(await page.locator('pre.shiki').count(), path).toBeGreaterThan(0);
      expect(await lowContrastTokens(page), `${path}, system ${mode}`).toEqual([]);
    }
  }
  for (const [system, forced] of [
    ['dark', 'Light'],
    ['light', 'Dark'],
  ] as const) {
    await page.emulateMedia({ colorScheme: system });
    await page.getByRole('button', { name: 'Mode' }).click();
    await page.getByRole('menuitemradio', { name: forced }).click();
    expect(await lowContrastTokens(page), `forced ${forced}`).toEqual([]);
  }
});

test("every component page folds the HTML of each example under its code: the markup alone, nothing of Svelte's", async ({
  request,
}) => {
  for (const { slug } of PAGES.filter((entry) => entry.slug.startsWith('components/'))) {
    const page = await (await request.get(`/${slug}`)).text();
    // the code as it reads: without shiki's spans, its `<` and `&` decoded
    const blocks = [...page.matchAll(/<details class="markup"><summary>HTML<\/summary>([^]*?)<\/details>/g)].map(
      ([, block = '']) =>
        block
          .replace(/<[^>]+>/g, '')
          .replace(/&#x3C;/g, '<')
          .replace(/&#x26;|&amp;/g, '&'),
    );
    expect(blocks.length, slug).toBeGreaterThan(0);
    for (const block of blocks) {
      expect(block, slug).toMatch(/class="t-/);
      // hydration comments, scoped classes, the image events held until hydration, the marker the load cuts on
      expect(block, slug).not.toMatch(/<!--|svelte-|__e|tsuya-example/);
    }
  }
});

test('the live preview takes the site mode, follows it, and keeps what the reader picked on the stage', async ({
  page,
}) => {
  await page.emulateMedia({ colorScheme: 'dark' });
  await open(page, '/components/button');
  const stage = page.locator('.stage').first();
  await expect(stage).toHaveAttribute('data-theme', 'dark');
  const setSite = async (name: string) => {
    await page.getByRole('button', { name: 'Mode' }).click();
    await page.getByRole('menuitemradio', { name }).click();
  };
  await setSite('Light');
  await expect(stage).toHaveAttribute('data-theme', 'light');
  // the reader picks Dark on the stage: the site mode no longer moves it
  await page.locator('.controls').first().getByRole('radio', { name: 'Dark' }).check();
  await setSite('Dark');
  await setSite('Light');
  await expect(stage).toHaveAttribute('data-theme', 'dark');
});

test("the gallery's images carry their height as well as their width", async ({ page }) => {
  await page.goto('/components/menu', { waitUntil: 'domcontentloaded' });
  const images = page.locator('figure.shots img');
  expect(await images.count()).toBe(2);
  for (const img of await images.all()) {
    await expect(img).toHaveAttribute('width', '390');
    await expect(img).toHaveAttribute('height', /^\d{3,4}$/);
    // and they are the file's own size, not a guess
    await img.scrollIntoViewIfNeeded();
    await expect.poll(() => img.evaluate((el: HTMLImageElement) => el.naturalHeight)).toBeGreaterThan(0);
    expect(await img.evaluate((el: HTMLImageElement) => [el.naturalWidth, el.naturalHeight])).toEqual([
      Number(await img.getAttribute('width')),
      Number(await img.getAttribute('height')),
    ]);
  }
});

test("the upload tile's icon is no bigger than 32 px", async ({ page }) => {
  await open(page, '/');
  const icon = await page.locator('label.upload svg').boundingBox();
  expect(icon?.width).toBeLessThanOrEqual(32);
  expect(icon?.height).toBeLessThanOrEqual(32);
});

test('a component page: air under the title block and above each section', async ({ page }) => {
  await open(page, '/components/button');
  const gaps = await page.evaluate(() => {
    const header = document.querySelector('main header') as Element;
    const lead = header.nextElementSibling as Element;
    const preview = [...document.querySelectorAll('main h2')].find((h) => h.textContent === 'Preview') as Element;
    const before = preview.previousElementSibling as Element;
    return {
      header: lead.getBoundingClientRect().top - header.getBoundingClientRect().bottom,
      preview: preview.getBoundingClientRect().top - before.getBoundingClientRect().bottom,
    };
  });
  expect(gaps.header, 'between the title block and the lead').toBeGreaterThanOrEqual(16);
  expect(gaps.preview, 'above "Preview"').toBeGreaterThanOrEqual(32);
});
