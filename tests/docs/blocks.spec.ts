// The Blocks section: the index, and the frame of every live example (mode and width switches),
// in both modes and at both widths, with no console error or warning and no axe violation. What each block does is in
// blocks-use.spec.ts.
import { expect, test } from '@playwright/test';

import { BLOCKS } from '../../apps/docs/src/lib/content/blocks.ts';
import { frameOf } from './blocks-support.ts';
import { axeViolations, trackConsoleErrors, open } from './support.ts';

test('the index lists every block', async ({ page }) => {
  await page.goto('/blocks');
  for (const block of BLOCKS) {
    await expect(page.getByRole('main').getByRole('link', { name: new RegExp(`^${block.title}`) })).toBeVisible();
  }
});

for (const block of BLOCKS) {
  test(`${block.title}: the frame switches mode and width`, async ({ page }) => {
    await page.goto(`/blocks/${block.slug}`);
    const frame = frameOf(page, block.title);
    await expect(frame).toBeVisible();
    await expect(frame).toHaveAttribute('data-theme', 'light');

    await page
      .getByRole('radiogroup', { name: 'Example mode' })
      .getByRole('radio', { name: 'Dark' })
      .check({ force: true });
    await expect(frame).toHaveAttribute('data-theme', 'dark');

    const width = page.getByRole('radiogroup', { name: 'Example width' });
    await width.getByRole('radio', { name: /Phone/ }).check({ force: true });
    await expect.poll(async () => (await frame.boundingBox())?.width).toBe(392);
    await width.getByRole('radio', { name: /Desktop/ }).check({ force: true });
    await expect.poll(async () => (await frame.boundingBox())?.width).toBe(1026);
  });
}

// pages.spec.ts checks every page as it opens; this checks every example in the other mode and at the other width
for (const block of BLOCKS) {
  for (const [mode, width] of [
    ['Dark', 'Desktop'],
    ['Light', 'Desktop'],
    ['Dark', 'Phone'],
  ] as const) {
    test(`${block.title}: no console error or warning, no axe violation in ${mode} at ${width}`, async ({ page }) => {
      const errors = trackConsoleErrors(page);
      await open(page, `/blocks/${block.slug}`);
      await page
        .getByRole('radiogroup', { name: 'Example mode' })
        .getByRole('radio', { name: mode })
        .check({ force: true });
      await page
        .getByRole('radiogroup', { name: 'Example width' })
        .getByRole('radio', { name: new RegExp(width) })
        .check({ force: true });
      await expect(frameOf(page, block.title)).toHaveAttribute('data-theme', mode.toLowerCase());
      expect(errors, 'console errors and warnings').toEqual([]);
      expect(await axeViolations(page), 'axe violations').toEqual([]);
    });
  }
}
