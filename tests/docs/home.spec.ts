// The home page's cover picker: picking a different cover changes the page's accent.
import { expect, test } from '@playwright/test';

test('picking a different cover changes the accent', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('button', { name: 'Ember' })).toHaveAttribute('aria-pressed', 'true');

  const action = page.getByRole('link', { name: 'Get started' });
  const accentColor = () => action.evaluate((el) => getComputedStyle(el).backgroundColor);
  const before = await accentColor();

  await page.getByRole('button', { name: 'Reef' }).click();
  await expect(page.getByRole('button', { name: 'Reef' })).toHaveAttribute('aria-pressed', 'true');
  await expect.poll(accentColor).not.toBe(before);
});
