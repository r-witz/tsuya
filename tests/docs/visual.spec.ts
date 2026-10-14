// Visual regression: each component page's live preview, light and dark, against a reviewed baseline. A
// change to a component that moves pixels fails here until its new screenshots are looked at and accepted with
// `npm run test:docs -- tests/docs/visual.spec.ts --update-snapshots`.
import { expect, test } from '@playwright/test';

import { PAGES, open } from './support.ts';

const COMPONENTS = PAGES.filter(({ slug }) => slug.startsWith('components/'));

for (const mode of ['light', 'dark'] as const) {
  test.describe(`${mode} mode`, () => {
    for (const { slug, title } of COMPONENTS) {
      test(`${title}: the preview looks as reviewed`, async ({ page }) => {
        await page.emulateMedia({ colorScheme: mode, reducedMotion: 'reduce' });
        await open(page, `/${slug}`);
        // the stage keeps its own mode, light until its control says otherwise
        const controls = page.locator('.controls').first();
        await controls.getByRole('radio', { name: mode === 'dark' ? 'Dark' : 'Light' }).check();
        await page.evaluate(() => document.fonts.ready);
        await expect(page.locator('.stage').first()).toHaveScreenshot(`${slug.replace('/', '-')}-${mode}.png`, {
          animations: 'disabled',
          caret: 'hide',
          // a glyph edge may land a pixel apart between Linux distributions' font rasterisers
          maxDiffPixelRatio: 0.01,
        });
      });
    }
  });
}
