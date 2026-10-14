// Every page, in both modes: loads without a console error or warning, and axe-core finds no violation. And the two
// files for agents: /llms.txt and /DESIGN.md.
import { readFileSync } from 'node:fs';

import { expect, test } from '@playwright/test';

import { axeViolations, PAGES, trackConsoleErrors, open } from './support.ts';

for (const mode of ['light', 'dark'] as const) {
  test.describe(`${mode} mode`, () => {
    for (const { slug, title } of PAGES) {
      test(`${title}: no console error or warning, no axe violation`, async ({ page }) => {
        await page.emulateMedia({ colorScheme: mode });
        const errors = trackConsoleErrors(page);
        await open(page, `/${slug}`);
        expect(errors, 'console errors and warnings').toEqual([]);
        expect(await axeViolations(page), 'axe violations').toEqual([]);
      });
    }
  });
}

test('the colour pickers are prerendered with their colour, before any script runs', async ({ request }) => {
  for (const [slug, count] of [
    ['material', 1],
    ['theming', 2],
  ] as const) {
    const html = await (await request.get(`/${slug}`)).text();
    const pickers = html.match(/<input[^>]*type="color"[^>]*>/g) ?? [];
    expect(pickers, slug).toHaveLength(count);
    for (const picker of pickers) expect(picker, slug).toMatch(/value="#[0-9a-fA-F]{6}"/);
  }
});

test("llms.txt links every page with its summary, and /DESIGN.md is the repository's DESIGN.md", async ({
  request,
}) => {
  const index = await (await request.get('/llms.txt')).text();
  expect(index).toContain('[DESIGN.md](/DESIGN.md)');
  for (const { slug, title, summary } of PAGES) expect(index).toContain(`- [${title}](/${slug}): ${summary}\n`);
  const design = await request.get('/DESIGN.md');
  expect(design.headers()['content-type']).toContain('text/markdown');
  expect(await design.text()).toBe(readFileSync(new URL('../../DESIGN.md', import.meta.url), 'utf8'));
});
