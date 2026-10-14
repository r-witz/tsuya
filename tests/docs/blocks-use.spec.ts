// What each block does when it is used: the rules of its page, as behaviour. The frame, its switches and
// axe are in blocks.spec.ts.
import { expect, test } from '@playwright/test';

import { frameOf } from './blocks-support.ts';

test('content page: another album changes the accent of the page', async ({ page }) => {
  await page.goto('/blocks/content-page');
  const frame = frameOf(page, 'Content page');
  const play = frame.getByRole('button', { name: 'Play' });
  await expect(play).toBeVisible();
  const before = await play.evaluate((el) => getComputedStyle(el).backgroundColor);
  await frame.getByRole('button', { name: /Tidepool Letters/ }).click();
  await expect(frame.getByRole('heading', { level: 1, name: 'Tidepool Letters' })).toBeVisible();
  await expect.poll(() => play.evaluate((el) => getComputedStyle(el).backgroundColor)).not.toBe(before);
});

test('library: no result, loading and empty states', async ({ page }) => {
  await page.goto('/blocks/library');
  const frame = frameOf(page, 'Library and grid');
  await expect(frame.getByRole('button', { name: /Slow Burn/ })).toBeVisible();

  await frame.getByRole('searchbox', { name: 'Search albums' }).fill('zzz');
  await expect(frame.getByRole('heading', { name: 'No album matches' })).toBeVisible();
  await frame.getByRole('button', { name: 'Clear search and filters' }).click();
  await expect(frame.getByRole('button', { name: /Slow Burn/ })).toBeVisible();

  const state = frame.getByRole('radiogroup', { name: 'State shown' });
  await state.getByRole('radio', { name: 'Loading' }).check({ force: true });
  await expect(frame.locator('[aria-busy="true"]')).toBeVisible();
  await expect(frame.getByRole('button', { name: /Slow Burn/ })).toHaveCount(0);

  await state.getByRole('radio', { name: 'Empty' }).check({ force: true });
  await expect(frame.getByRole('heading', { name: 'Your library is empty' })).toBeVisible();
  await frame.getByRole('button', { name: 'Add albums' }).click();
  await expect(frame.getByRole('button', { name: /Slow Burn/ })).toBeVisible();
});

test('library: hovering an item lights the ambient background with its cover', async ({ page }) => {
  await page.goto('/blocks/library');
  const frame = frameOf(page, 'Library and grid');
  const lit = () => frame.locator('.t-ambient i[data-on]').evaluate((el) => getComputedStyle(el).backgroundImage);
  const before = await lit();
  await frame.getByRole('button', { name: /Violet Hour/ }).hover();
  await expect.poll(lit).not.toBe(before);
});

test('settings: a switch applies at once, the destructive row asks first, the sidebar picks a section', async ({
  page,
}) => {
  await page.goto('/blocks/settings');
  const frame = frameOf(page, 'Settings');
  const digest = frame.getByRole('switch', { name: 'Weekly digest' });
  await expect(digest).not.toBeChecked();
  await digest.check({ force: true });
  await expect(digest).toBeChecked();
  await expect(frame.getByRole('button', { name: /save/i })).toHaveCount(0);

  const remove = frame.getByRole('button', { name: 'Delete account' });
  await remove.click();
  const dialog = page.getByRole('dialog', { name: 'Delete your account?' });
  await expect(dialog).toBeVisible();
  await expect(dialog.getByRole('button', { name: 'Keep my account' })).toBeFocused();
  await page.keyboard.press('Escape');
  await expect(dialog).toHaveCount(0);
  await expect(remove).toBeFocused();

  // desktop: a sidebar, and one section at a time
  await page
    .getByRole('radiogroup', { name: 'Example width' })
    .getByRole('radio', { name: /Desktop/ })
    .check({ force: true });
  await expect(frame.getByRole('navigation', { name: 'Settings sections' })).toBeVisible();
  await expect(frame.getByRole('switch', { name: 'Reduce motion' })).toHaveCount(0);
  await frame.getByRole('button', { name: 'Appearance' }).click();
  await expect(frame.getByRole('switch', { name: 'Reduce motion' })).toBeVisible();
  await expect(frame.getByRole('switch', { name: 'Weekly digest' })).toHaveCount(0);
});

test('forms: on blur, then on input once in error; on submit, focus goes to the first error', async ({ page }) => {
  await page.goto('/blocks/forms');
  const frame = frameOf(page, 'Forms');
  const name = frame.getByRole('textbox', { name: 'Name' });
  const email = frame.getByRole('textbox', { name: 'Email' });
  const nameError = frame.getByText('Enter your name, at least 2 letters.');

  // typing in a field that has not been left yet shows nothing
  await name.fill('a');
  await expect(nameError).toHaveCount(0);
  // leaving it shows the error, and fixing it clears the error as the text changes
  await email.focus();
  await expect(nameError).toBeVisible();
  await expect(name).toHaveAttribute('aria-invalid', 'true');
  await name.fill('Nora');
  await expect(nameError).toHaveCount(0);
  await expect(name).not.toHaveAttribute('aria-invalid', 'true');
  // a valid field is not checked while typing: only its blur does it again
  await name.fill('N');
  await expect(nameError).toHaveCount(0);
  await email.focus();
  await expect(nameError).toBeVisible();

  // submit: every field is checked, the focus is on the first one in error
  await name.fill('Nora Vale');
  await frame.getByRole('button', { name: 'Send message' }).click();
  await expect(frame.getByText('Enter an email address like nora@example.com.')).toBeVisible();
  await expect(frame.getByText('Choose what your message is about.')).toBeVisible();
  await expect(email).toBeFocused();

  await email.fill('nora@example.com');
  await frame.getByRole('combobox', { name: 'Topic' }).click();
  await page.getByRole('option', { name: 'An idea' }).click();
  await frame.getByRole('button', { name: 'Send message' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Message sent' })).toBeVisible();
});

test('auth: sign in, sign up and reset, each announced by its title', async ({ page }) => {
  await page.goto('/blocks/auth');
  const frame = frameOf(page, 'Auth');
  await expect(frame.getByRole('heading', { name: 'Welcome back' })).toBeVisible();

  // submit with nothing: the focus goes to the first error
  await frame.getByRole('button', { name: 'Sign in' }).click();
  await expect(frame.getByText('Enter your password.')).toBeVisible();
  await expect(frame.getByRole('textbox', { name: 'Email' })).toBeFocused();

  await frame.getByRole('button', { name: 'Create an account' }).click();
  await expect(frame.getByRole('heading', { name: 'Create your account' })).toBeFocused();
  await expect(frame.getByText('Enter your password.')).toHaveCount(0);
  await expect(frame.getByText('At least 8 characters.')).toBeVisible();

  await frame.getByRole('button', { name: 'I already have an account' }).click();
  await frame.getByRole('button', { name: 'Forgot your password?' }).click();
  await expect(frame.getByRole('heading', { name: 'Reset your password' })).toBeFocused();
  await frame.getByRole('textbox', { name: 'Email' }).fill('nora@example.com');
  await frame.getByRole('button', { name: 'Send the link' }).click();
  await expect(frame.getByRole('group', { name: 'Check your inbox' })).toBeVisible();
});

test('auth: the accent is the brand’s, whatever the page’s', async ({ page }) => {
  await page.goto('/blocks/auth');
  const frame = frameOf(page, 'Auth');
  const action = frame.getByRole('button', { name: 'Sign in' });
  const accent = await action.evaluate((el) => getComputedStyle(el).backgroundColor);
  expect(accent).not.toBe('rgb(0, 0, 0)');
  await page
    .getByRole('radiogroup', { name: 'Example mode' })
    .getByRole('radio', { name: 'Dark' })
    .check({ force: true });
  await expect.poll(() => action.evaluate((el) => getComputedStyle(el).backgroundColor)).not.toBe(accent);
});

test('phone shell: the player is lit by its cover, the other tabs are not; a sheet rises from the bottom', async ({
  page,
}) => {
  await page.goto('/blocks/phone-shell');
  const frame = frameOf(page, 'Phone shell');
  const play = frame.getByRole('button', { name: 'Play', exact: true });
  await expect(play).toBeVisible();
  await expect(frame.locator('.t-ambient')).toHaveCount(1);
  const accent = await play.evaluate((el) => getComputedStyle(el).backgroundColor);

  // the next track has another cover, so another accent
  await frame.getByRole('button', { name: 'Next', exact: true }).click();
  await expect(frame.getByRole('heading', { name: 'Tidepool Letters' })).toBeVisible();
  await expect.poll(() => play.evaluate((el) => getComputedStyle(el).backgroundColor)).not.toBe(accent);

  await play.click();
  await expect(frame.getByRole('button', { name: 'Pause', exact: true })).toBeVisible();

  const sheet = page.getByRole('dialog', { name: 'Up next' });
  await frame.getByRole('button', { name: 'Up next' }).click();
  await expect(sheet).toBeVisible();
  await page.keyboard.press('Escape');
  await expect(sheet).toBeHidden();

  // no content leads on the library: the glow, not an ambient image
  await frame.getByRole('tab', { name: 'Library' }).click();
  await expect(frame.getByRole('heading', { name: 'Library' })).toBeVisible();
  await expect(frame.locator('.t-ambient')).toHaveCount(0);
});

test('desktop shell: a sidebar that collapses, a column of at most 1200, the cover lights the screen', async ({
  page,
}) => {
  await page.goto('/blocks/desktop-shell');
  const frame = frameOf(page, 'Desktop shell');
  const sidebar = frame.getByRole('navigation', { name: 'Library' });
  await expect.poll(async () => (await sidebar.boundingBox())?.width).toBe(240);
  await frame.getByRole('button', { name: 'Collapse the sidebar' }).click();
  await expect.poll(async () => (await sidebar.boundingBox())?.width).toBe(72);

  // the content column never grows past 1200, and a few glass layers only
  const main = await frame.locator('div.column').boundingBox();
  expect(main?.width).toBeLessThanOrEqual(1200);
  expect(await frame.locator('.t-glass, .t-glass-control').count()).toBeLessThanOrEqual(3);

  // another track: another cover, another accent, another light
  const play = frame.getByRole('button', { name: 'Play', exact: true });
  const accent = await play.evaluate((el) => getComputedStyle(el).backgroundColor);
  await frame.getByRole('button', { name: 'Next', exact: true }).click();
  await expect(frame.getByRole('heading', { name: 'Tidepool Letters' })).toBeVisible();
  await expect.poll(() => play.evaluate((el) => getComputedStyle(el).backgroundColor)).not.toBe(accent);
});

test('website: the bar folds its links at a phone width, the hero follows the picked cover', async ({ page }) => {
  await page.goto('/blocks/website');
  const frame = frameOf(page, 'Website');
  await expect(frame.getByRole('link', { name: 'Features' })).toBeVisible();
  await expect(frame.getByRole('button', { name: 'More' })).toBeHidden();

  const action = frame.getByRole('button', { name: 'Get Cadence' });
  const accent = await action.evaluate((el) => getComputedStyle(el).backgroundColor);
  await frame.getByRole('button', { name: 'Reef', exact: true }).click();
  await expect(frame.getByRole('button', { name: 'Reef', exact: true })).toHaveAttribute('aria-pressed', 'true');
  await expect.poll(() => action.evaluate((el) => getComputedStyle(el).backgroundColor)).not.toBe(accent);

  await page
    .getByRole('radiogroup', { name: 'Example width' })
    .getByRole('radio', { name: /Phone/ })
    .check({ force: true });
  await expect(frame.getByRole('link', { name: 'Features' })).toBeHidden();
  await frame.getByRole('button', { name: 'More' }).click();
  const link = page.getByRole('link', { name: 'Features' });
  await expect(link).toBeVisible();
  await link.click();
  await expect(link).toBeHidden();
});

test('dashboard-lite: the period changes the figures, which are tabular', async ({ page }) => {
  await page.goto('/blocks/dashboard');
  const frame = frameOf(page, 'Dashboard-lite');
  const plays = frame.getByRole('term').filter({ hasText: 'Plays' });
  await expect(frame.getByText('84,310')).toBeVisible();
  expect(await frame.getByText('84,310').evaluate((el) => getComputedStyle(el).fontVariantNumeric)).toContain(
    'tabular-nums',
  );
  await frame.getByRole('radiogroup', { name: 'Period' }).getByRole('radio', { name: '7 days' }).check({ force: true });
  await expect(frame.getByText('18,420')).toBeVisible();
  await expect(frame.getByText('84,310')).toHaveCount(0);
  await expect(plays).toBeVisible();
});

test('states: empty, error and offline each have a title, a sentence and one action', async ({ page }) => {
  await page.goto('/blocks/states');
  const frame = frameOf(page, 'Empty, error and offline');
  const state = frame.getByRole('radiogroup', { name: 'State shown' });

  await expect(frame.getByRole('heading', { name: 'No downloads yet' })).toBeVisible();
  await expect(frame.getByRole('button', { name: 'Browse albums' })).toBeVisible();

  // an error replaces the content, is announced, and its action shows loading while it retries
  await state.getByRole('radio', { name: 'Error' }).check({ force: true });
  await expect(frame.getByRole('alert')).toContainText('We could not load your downloads');
  await frame.getByRole('button', { name: 'Try again' }).click();
  await expect(frame.getByRole('button', { name: 'Try again' })).toHaveAttribute('aria-busy', 'true');
  await expect(frame.getByRole('listitem').or(frame.getByText('Slow Burn')).first()).toBeVisible();
  await expect(frame.getByRole('alert')).toHaveCount(0);

  // offline lasts: a banner above content that still works, then a toast when the connection is back. A forced check
  // clicks wherever the control is, and the sticky top bar may cover it after the error's retry: centre it first
  await state.evaluate((el) => {
    el.scrollIntoView({ block: 'center' });
  });
  await state.getByRole('radio', { name: 'Offline' }).check({ force: true });
  await expect(frame.getByRole('group', { name: 'You are offline' })).toBeVisible();
  await expect(frame.getByText('Tidepool Letters')).toBeVisible();
  await frame.getByRole('button', { name: 'Retry' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Back online' })).toBeVisible();
  await expect(frame.getByRole('group', { name: 'You are offline' })).toHaveCount(0);
});
