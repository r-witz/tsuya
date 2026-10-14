// Right to left (G14): the field of a select and of a combobox mirror, and their panels line up with the start of
// the field, its right edge.
import { beforeEach, expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import Banners from './fixtures/Banners.svelte';
import Comboboxes from './fixtures/Comboboxes.svelte';
import CommandPalettes from './fixtures/CommandPalettes.svelte';
import Menus from './fixtures/Menus.svelte';
import Popovers from './fixtures/Popovers.svelte';
import Dialogs from './fixtures/Dialogs.svelte';
import Selects from './fixtures/Selects.svelte';
import Sheets from './fixtures/Sheets.svelte';

const box = (element: Element) => element.getBoundingClientRect();

beforeEach(async () => {
  await page.viewport(800, 600);
});

test('a banner: the icon at the right, its actions at the end, the left', async () => {
  const screen = await render(Banners, { dir: 'rtl' });
  const banner = screen.getByRole('group', { name: 'Sync paused' }).element();
  const icon = banner.querySelector('.t-glyph') as Element;
  const message = screen.getByText(/Your changes will upload/).element();
  const retry = screen.getByRole('button', { name: 'Retry' }).element();
  expect(box(icon).left).toBeGreaterThan(box(message).right);
  expect(box(retry).left).toBeLessThan(box(message).left);
});

test('a dialog: the actions still at the end, now the left (Cancel before Delete in the DOM)', async () => {
  const screen = await render(Dialogs, { dir: 'rtl' });
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  const cancel = screen.getByRole('button', { name: 'Cancel' }).element();
  const danger = screen.getByRole('button', { name: 'Delete' }).element();
  expect(box(danger).right).toBeLessThan(box(cancel).left);
});

test('a command palette: the search glyph at the right, the commands aligned to the right', async () => {
  const screen = await render(CommandPalettes, { dir: 'rtl' });
  await screen.getByRole('button', { name: 'Commands' }).click();
  const field = screen.getByRole('combobox').element();
  const glyph = (field.closest('.t-text-input') as Element).querySelector('.t-glyph') as Element;
  expect(box(glyph).left).toBeGreaterThan(box(field).left);
  const option = screen.getByRole('option', { name: 'New file' }).element();
  const label = option.querySelector('.t-option-label') as Element;
  expect(Math.round(box(option).right - box(label).right)).toBe(12);
});

test('a side sheet: from the left edge, not the right', async () => {
  const screen = await render(Sheets, { dir: 'rtl', side: 'end' });
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = screen.getByRole('dialog').element();
  await Promise.allSettled(sheet.getAnimations().map((animation) => animation.finished));
  expect(box(sheet).left).toBeCloseTo(0, 0);
  expect(box(sheet).right).toBeCloseTo(400, 0);
});

test('a select: the chevron at the left, the value from the right, the panel under the right edge', async () => {
  const screen = await render(Selects, { dir: 'rtl', country: 'FR' });
  const trigger = screen.getByRole('combobox', { name: 'Country' }).element();
  const value = trigger.querySelector('.t-select-trigger-value') as Element;
  const chevron = trigger.querySelector('svg') as Element;
  expect(box(chevron).right).toBeLessThan(box(value).left);
  expect(getComputedStyle(trigger).direction).toBe('rtl');
  // the label sits at the right of its box
  const text = document.createRange();
  text.selectNodeContents(value);
  expect(box(value).right - text.getBoundingClientRect().right).toBeLessThan(1);
  await screen.getByRole('combobox', { name: 'Country' }).click();
  const panel = screen.getByRole('listbox', { name: 'Country' }).element();
  expect(box(panel).right).toBeCloseTo(box(trigger).right, 0);
});

test('a combobox: the panel under the right edge of the field', async () => {
  const screen = await render(Comboboxes, { dir: 'rtl' });
  const input = screen.getByRole('combobox', { name: 'City' });
  await input.click();
  await userEvent.keyboard('{ArrowDown}');
  const field = input.element().closest('.t-text-input') as Element;
  const panel = screen.getByRole('listbox', { name: 'City' }).element().closest('.t-panel') as Element;
  expect(box(panel).right).toBeCloseTo(box(field).right, 0);
  expect(getComputedStyle(input.element()).direction).toBe('rtl');
});

test('a menu: under its opener at its end edge, the left one; its items mirror', async () => {
  const screen = await render(Menus, { dir: 'rtl' });
  const more = screen.getByRole('button', { name: 'More' });
  await more.click();
  const panel = screen.getByRole('menu', { name: 'More' }).element();
  await expect.element(panel).toBeVisible();
  expect(box(panel).left).toBeCloseTo(box(more.element()).left, 0);
  await userEvent.keyboard('{Escape}');
  await screen.getByRole('button', { name: 'Actions' }).click();
  const rename = screen.getByRole('menuitem', { name: 'Rename' }).element();
  const icon = rename.querySelector('[data-testid="icon"]') as Element;
  expect(box(icon).left).toBeGreaterThan(box(rename.querySelector('.t-menu-item-label') as Element).right);
});

test('a popover: under its opener at its start edge, the right one', async () => {
  const screen = await render(Popovers, { dir: 'rtl' });
  const filters = screen.getByRole('button', { name: 'Filters' });
  await filters.click();
  const panel = screen.getByRole('dialog', { name: 'Filters' }).element();
  await expect.element(panel).toBeVisible();
  expect(box(panel).right).toBeCloseTo(box(filters.element()).right, 0);
});
