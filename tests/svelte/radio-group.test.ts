// RadioGroup and Radio (DESIGN.md, RadioGroup; G5, G6): values, a fieldset named by its legend, native one-tab-stop
// and arrow selection, disabled.
import { expect, test } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import RadioGroups from './fixtures/RadioGroups.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string, pseudo?: string) =>
  getComputedStyle(element, pseudo).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('values: the group named by its legend, the circle, its boundary and dot', async () => {
  const screen = await render(RadioGroups);
  await expect.element(screen.getByRole('radiogroup', { name: 'Size' })).toBeInTheDocument();
  // unselected: its boundary shows (the selected one's turns transparent under its accent fill, checked below)
  const unselected = screen.getByRole('radio', { name: 'Small' }).element();
  const square = unselected.closest('label')?.querySelector('.t-radio-box') as HTMLElement;
  expect(box(square)).toMatchObject({ width: 20, height: 20 });
  const frame = square.querySelector('.t-radio-frame') as HTMLElement;
  expect(parseFloat(style(frame, 'border-top-width'))).toBeGreaterThanOrEqual(1);
  expect(parseFloat(style(frame, 'border-top-width'))).toBeLessThanOrEqual(1.5);
  expect(rgbaOf(frame, 'border-top-color')).toEqual(rgbaOfHex(light.color.borderStrong));
  expect(style(frame, 'border-top-left-radius')).toBe('999px');
});

test('selected: accent fill and a visible on-accent dot; the other option has none', async () => {
  const screen = await render(RadioGroups);
  const medium = screen.getByRole('radio', { name: 'Medium' }).element();
  const small = screen.getByRole('radio', { name: 'Small' }).element();
  const frame = (box: Element) => box.closest('label')?.querySelector('.t-radio-frame') as HTMLElement;
  expect(hexOf(frame(medium), 'background-color')).toBe(light.color.accent);
  expect(style(frame(medium), 'scale', '::after')).toBe('1');
  expect(rgbaOf(frame(small), 'background-color')).toEqual([0, 0, 0, 0]);
  expect(style(frame(small), 'scale', '::after')).toBe('0');
});

test('a press selects a radio and deselects the previous one', async () => {
  const screen = await render(RadioGroups);
  const small = screen.getByRole('radio', { name: 'Small' });
  const medium = screen.getByRole('radio', { name: 'Medium' });
  await expect.element(medium).toBeChecked();
  await small.click();
  await expect.element(small).toBeChecked();
  await expect.element(medium).not.toBeChecked();
});

test('one tab stop lands on the checked radio; arrows move and select', async () => {
  const screen = await render(RadioGroups);
  const before = document.createElement('button');
  document.body.prepend(before);
  before.focus();
  await userEvent.tab();
  await expect.element(screen.getByRole('radio', { name: 'Medium' })).toHaveFocus();
  await userEvent.keyboard('{ArrowDown}');
  await expect.element(screen.getByRole('radio', { name: 'Large' })).toHaveFocus();
  await expect.element(screen.getByRole('radio', { name: 'Large' })).toBeChecked();
  before.remove();
});

test('a disabled radio is dimmed and skipped by arrow navigation', async () => {
  const screen = await render(RadioGroups, { disabled: true });
  const large = screen.getByRole('radio', { name: 'Large' });
  await expect.element(large).toBeDisabled();
  const row = large.element().closest('label') as HTMLElement;
  expect(style(row, 'opacity')).toBe('0.38');
  screen.getByRole('radio', { name: 'Medium' }).element().focus();
  await userEvent.keyboard('{ArrowDown}');
  // skips the disabled Large and wraps to Small
  await expect.element(screen.getByRole('radio', { name: 'Small' })).toHaveFocus();
});
