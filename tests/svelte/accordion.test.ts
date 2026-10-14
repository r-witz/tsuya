// Accordion (DESIGN.md, Accordion; G5, G6, G9, G13): headers that are buttons in headings with their expanded state,
// regions named by them, one or several open, the chevron that turns over, the row values, and the height that
// animates, at once under reduced motion.
import { afterEach, expect, test } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Accordions from './fixtures/Accordions.svelte';
import { rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);

afterEach(async () => {
  await commands.emulateMedia({ reducedMotion: null });
});

test('headers are buttons in headings, tied to their regions, with the values of a row', async () => {
  const screen = await render(Accordions);
  const shipping = screen.getByRole('button', { name: 'Shipping' });
  await expect.element(shipping).toHaveAttribute('aria-expanded', 'false');
  expect(shipping.element().parentElement?.tagName).toBe('H3');
  const region = document.getElementById(shipping.element().getAttribute('aria-controls') ?? '');
  expect(region?.getAttribute('role')).toBe('region');
  expect(region?.getAttribute('aria-labelledby')).toBe(shipping.element().id);
  expect(region?.hidden).toBe(true);
  // a row: at least --t-size-row tall, --t-space-8 above and below, body-strong; a 16 chevron in text-muted
  const button = shipping.element();
  expect(button.getBoundingClientRect().height).toBe(56);
  expect(style(button, 'padding-top')).toBe('8px');
  expect(style(button, 'font-weight')).toBe('600');
  const chevron = button.querySelector('svg') as Element;
  expect(chevron.getBoundingClientRect().width).toBe(16);
  expect(rgbaOf(chevron)).toEqual(rgbaOfHex(light.color.textMuted));
  // a hairline between items
  const items = screen.container.querySelectorAll('.t-accordion-item');
  expect(style(items[0] as Element, 'border-top-style')).toBe('none');
  expect(style(items[1] as Element, 'border-top-width')).toBe('1px');
});

test('single: opening one closes the other; a press on the open one closes it', async () => {
  const screen = await render(Accordions);
  const value = screen.getByTestId('value');
  await screen.getByRole('button', { name: 'Shipping' }).click();
  await expect.element(screen.getByRole('region', { name: 'Shipping' })).toBeVisible();
  await expect.element(value).toHaveTextContent('shipping');
  await screen.getByRole('button', { name: 'Returns' }).click();
  await expect.element(value).toHaveTextContent('returns');
  await expect.element(screen.getByRole('button', { name: 'Shipping' })).toHaveAttribute('aria-expanded', 'false');
  await expect.poll(() => screen.container.querySelectorAll('[role="region"]:not([hidden])').length).toBe(1);
  await screen.getByRole('button', { name: 'Returns' }).click();
  await expect.element(screen.getByRole('button', { name: 'Returns' })).toHaveAttribute('aria-expanded', 'false');
  await expect.element(value).toHaveTextContent('');
});

test('multiple: several stay open; Enter and Space toggle; a disabled item does not', async () => {
  const screen = await render(Accordions, { type: 'multiple', disabled: 'warranty' });
  const value = screen.getByTestId('value');
  (screen.getByRole('button', { name: 'Shipping' }).element() as HTMLElement).focus();
  await userEvent.keyboard('{Enter}');
  await userEvent.tab();
  await userEvent.keyboard(' ');
  await expect.element(value).toHaveTextContent('shipping,returns');
  // Tab reaches the button inside the open region before the next header
  await userEvent.tab();
  expect(document.activeElement?.textContent.trim()).toBe('Start a return');
  await expect.element(screen.getByRole('button', { name: 'Warranty' })).toBeDisabled();
});

test('the chevron turns over and the height opens, at once under reduced motion', async () => {
  const screen = await render(Accordions);
  const shipping = screen.getByRole('button', { name: 'Shipping' });
  // pressed at once, so that a slow run does not see the opening already over
  (shipping.element() as HTMLElement).click();
  const region = document.getElementById(shipping.element().getAttribute('aria-controls') ?? '') as HTMLElement;
  await expect.poll(() => region.getAnimations()).toHaveLength(1);
  await Promise.all(region.getAnimations().map((animation) => animation.finished));
  await expect.poll(() => style(shipping.element().querySelector('svg') as Element, 'rotate')).toBe('180deg');
  expect(style(region.firstElementChild as Element, 'padding-top')).toBe('16px');
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  await shipping.click();
  await expect.poll(() => region.hidden).toBe(true);
  expect(region.getAnimations()).toEqual([]);
});
