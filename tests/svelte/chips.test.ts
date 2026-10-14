// Chip and ChipGroup (DESIGN.md, Chip; G5, G6, G14): values, a standalone toggle, single (radio) and multiple
// (toggle buttons) groups, roving focus, disabled, right to left.
import { expect, test } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Chips from './fixtures/Chips.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('values: height, radius, side padding, type, icon muted, fill and hairline', async () => {
  const screen = await render(Chips);
  const chip = screen.getByRole('button', { name: 'Glass', exact: true }).element();
  expect(box(chip).height).toBe(32);
  expect(style(chip, 'border-top-left-radius')).toBe('12px');
  expect(style(chip, 'padding-left')).toBe('12px');
  expect(style(chip, 'font-size')).toBe('13px');
  expect(rgbaOf(chip, 'background-color')).toEqual(rgbaOfHex(light.color.fill));
  expect(rgbaOf(chip, 'border-top-color')).toEqual(rgbaOfHex(light.color.border));
  const popular = screen.getByRole('radio', { name: 'Popular' }).element();
  const icon = popular.querySelector('svg') as SVGElement;
  expect(box(icon).width).toBe(16);
  expect(rgbaOf(icon)).toEqual(rgbaOfHex(light.color.textMuted));
});

test('selected: accent fill and on-accent text and icon; a glass variant', async () => {
  const screen = await render(Chips);
  const starred = screen.getByRole('button', { name: 'Starred' }).element();
  expect(hexOf(starred, 'background-color')).toBe(light.color.accent);
  expect(hexOf(starred)).toBe(light.color.onAccent);
  expect(hexOf(starred.querySelector('svg') as SVGElement)).toBe(light.color.onAccent);
  expect(style(starred, 'backdrop-filter')).toMatch(/blur/);
});

test('a standalone chip is a toggle button; a press flips it', async () => {
  const screen = await render(Chips);
  const chip = screen.getByRole('button', { name: 'Glass', exact: true });
  await expect.element(chip).toHaveAttribute('aria-pressed', 'false');
  await chip.click();
  await expect.element(chip).toHaveAttribute('aria-pressed', 'true');
});

test('single selection: radio semantics, one tab stop, arrows move without selecting, Space selects', async () => {
  const screen = await render(Chips);
  const recent = screen.getByRole('radio', { name: 'Recent' });
  const popular = screen.getByRole('radio', { name: 'Popular' });
  await expect.element(recent).toHaveAttribute('aria-checked', 'true');
  await expect.element(popular).toHaveAttribute('aria-checked', 'false');
  expect(recent.element().getAttribute('tabindex')).toBe('0');
  expect(popular.element().getAttribute('tabindex')).toBe('-1');
  recent.element().focus();
  await userEvent.keyboard('{ArrowRight}');
  expect(document.activeElement?.textContent.trim()).toBe('Popular');
  // the move alone does not select
  await expect.element(recent).toHaveAttribute('aria-checked', 'true');
  await userEvent.keyboard(' ');
  await expect.element(popular).toHaveAttribute('aria-checked', 'true');
  await expect.element(recent).toHaveAttribute('aria-checked', 'false');
  expect(popular.element().getAttribute('tabindex')).toBe('0');
});

test('multiple selection: toggle buttons, independently pressed', async () => {
  const screen = await render(Chips);
  const sale = screen.getByRole('button', { name: 'Sale' });
  const fresh = screen.getByRole('button', { name: 'New' });
  await expect.element(sale).toHaveAttribute('aria-pressed', 'false');
  await sale.click();
  await expect.element(sale).toHaveAttribute('aria-pressed', 'true');
  await expect.element(fresh).toHaveAttribute('aria-pressed', 'false');
  await fresh.click();
  await expect.element(fresh).toHaveAttribute('aria-pressed', 'true');
  await expect.element(sale).toHaveAttribute('aria-pressed', 'true');
});

test('a disabled chip is dimmed, skipped by the roving focus and not pressable', async () => {
  const screen = await render(Chips, { disabled: true });
  const az = screen.getByRole('radio', { name: 'A–Z' });
  await expect.element(az).toBeDisabled();
  expect(style(az.element(), 'opacity')).toBe('0.38');
  screen.getByRole('radio', { name: 'Popular' }).element().focus();
  await userEvent.keyboard('{ArrowRight}');
  // wraps past the disabled chip back to Recent
  expect(document.activeElement?.textContent.trim()).toBe('Recent');
});

test('right to left, the arrows follow the visual order', async () => {
  const screen = await render(Chips, { dir: 'rtl' });
  screen.getByRole('radio', { name: 'Recent' }).element().focus();
  await userEvent.keyboard('{ArrowLeft}');
  expect(document.activeElement?.textContent.trim()).toBe('Popular');
});
