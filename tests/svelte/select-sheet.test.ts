// Select on a phone (DESIGN.md, Select; G5, G6): below the tablet width the options open in a sheet
// titled by the select's label, the listbox taking the focus and the arrows; a choice or Escape closes it and focus
// goes back to the trigger. `sheetOnPhone={false}`, or a wider window, keeps the panel.
import { beforeEach, expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import Selects from './fixtures/Selects.svelte';

const sheet = () => document.querySelector<HTMLDialogElement>('.t-select-sheet');

beforeEach(async () => {
  await page.viewport(390, 700);
});

test('opens in a sheet titled by the label, the listbox focused; the arrows and Enter choose, focus back on the trigger', async () => {
  const screen = await render(Selects);
  const trigger = screen.getByRole('combobox', { name: 'Country' });
  await trigger.click();
  expect(sheet()?.open).toBe(true);
  expect(screen.getByRole('dialog', { name: 'Country' }).element()).toBe(sheet());
  const listbox = screen.getByRole('listbox', { name: 'Country' }).element();
  expect(sheet()?.contains(listbox)).toBe(true);
  expect(document.activeElement).toBe(listbox);
  // it opens on the first option, as the panel does
  await userEvent.keyboard('{ArrowDown}');
  const active = document.getElementById(listbox.getAttribute('aria-activedescendant') ?? '');
  expect(active?.textContent.trim()).toBe('Germany');
  await userEvent.keyboard('{Enter}');
  expect(sheet()?.open).toBe(false);
  expect(trigger.element().textContent).toContain('Germany');
  expect(document.activeElement).toBe(trigger.element());
});

test('a tap on an option chooses it; Escape closes without choosing', async () => {
  const screen = await render(Selects);
  const trigger = screen.getByRole('combobox', { name: 'Country' });
  await trigger.click();
  await screen.getByRole('option', { name: 'Italy' }).click();
  expect(sheet()?.open).toBe(false);
  expect(trigger.element().textContent).toContain('Italy');
  await trigger.click();
  await userEvent.keyboard('{ArrowDown}{Escape}');
  expect(sheet()?.open).toBe(false);
  expect(trigger.element().textContent).toContain('Italy');
  expect(document.activeElement).toBe(trigger.element());
});

test('sheetOnPhone={false} keeps the panel on a phone; a wider window keeps it too', async () => {
  const screen = await render(Selects, { sheetOnPhone: false });
  await screen.getByRole('combobox', { name: 'Country' }).click();
  expect(sheet()).toBeNull();
  expect(screen.getByRole('listbox', { name: 'Country' }).element().closest('dialog')).toBeNull();
  await screen.unmount();
  await page.viewport(800, 600);
  const wide = await render(Selects);
  await wide.getByRole('combobox', { name: 'Country' }).click();
  expect(sheet()).toBeNull();
});

test('opens with the selected option in view, however far down the list it is', async () => {
  await page.viewport(390, 500);
  const screen = await render(Selects, { country: 'A20' });
  await screen.getByRole('combobox', { name: 'Country' }).click();
  const node = sheet() as HTMLDialogElement;
  await Promise.allSettled(node.getAnimations().map((animation) => animation.finished));
  const option = screen.getByRole('option', { name: 'Asia 21' }).element().getBoundingClientRect();
  const box = node.getBoundingClientRect();
  expect(option.top).toBeGreaterThanOrEqual(box.top);
  expect(option.bottom).toBeLessThanOrEqual(box.bottom);
});
