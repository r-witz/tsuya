// Popover (DESIGN.md, Popover; G5, G6, G8, G13): the opener, the panel under it at its start edge with padding 16,
// focus moving in only from the keyboard, its controls, Escape, a press outside and focus leaving.
import { beforeEach, expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light, radius } from '../../packages/core/src/tokens.ts';
import Popovers from './fixtures/Popovers.svelte';
import { hexOf } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();
// hidden, it leaves the accessibility tree: found by its opener
const panelOf = (trigger: Element) =>
  document.getElementById(trigger.getAttribute('aria-controls') ?? '') as HTMLElement;
const shown = (panel: Element) => panel.matches(':popover-open');

beforeEach(async () => {
  await page.viewport(800, 600);
});

test('a press opens it under its opener at its start edge, named by it, padded 16; focus stays on the opener', async () => {
  const screen = await render(Popovers);
  const trigger = screen.getByRole('button', { name: 'Filters' });
  await expect.element(trigger).toHaveAttribute('aria-haspopup', 'dialog');
  await trigger.click();
  const panel = screen.getByRole('dialog', { name: 'Filters' });
  await expect.element(panel).toBeVisible();
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'true');
  await expect.element(trigger).toHaveFocus();
  const [content, opener] = [box(panel.element()), box(trigger.element())];
  expect(content.left).toBeCloseTo(opener.left, 0);
  expect(content.top).toBeCloseTo(opener.bottom + 4, 0);
  expect(style(panel.element(), 'padding-top')).toBe('16px');
  expect(style(panel.element(), 'border-top-left-radius')).toBe(`${String(radius.md)}px`);
  expect(hexOf(panel.element(), 'background-color')).toBe(light.color.surface);
});

test('opened from the keyboard, focus moves to its first control, or to the panel without one', async () => {
  const screen = await render(Popovers);
  (screen.getByRole('button', { name: 'Filters' }).element() as HTMLElement).focus();
  await userEvent.keyboard('{Enter}');
  await expect.element(screen.getByRole('checkbox', { name: 'Unread only' })).toHaveFocus();
  await userEvent.keyboard('{Escape}');
  const details = screen.getByRole('button', { name: 'Details' });
  (details.element() as HTMLElement).focus();
  await userEvent.keyboard(' ');
  await expect.element(screen.getByRole('dialog', { name: 'Details' })).toHaveFocus();
});

test('its controls work inside it, and an action in it can close it', async () => {
  const screen = await render(Popovers);
  const trigger = screen.getByRole('button', { name: 'Filters' });
  await trigger.click();
  await screen.getByRole('checkbox', { name: 'Unread only' }).click();
  expect(document.querySelector('[data-testid="unread"]')?.textContent).toBe('true');
  expect(shown(panelOf(trigger.element()))).toBe(true);
  await screen.getByRole('button', { name: 'Apply' }).click();
  await expect.poll(() => shown(panelOf(trigger.element()))).toBe(false);
});

test('Escape closes it and focus goes back; a press outside and focus leaving close it', async () => {
  const screen = await render(Popovers);
  const trigger = screen.getByRole('button', { name: 'Filters' });
  const panel = panelOf(trigger.element());
  (trigger.element() as HTMLElement).focus();
  await userEvent.keyboard('{Enter}');
  await expect.element(screen.getByRole('checkbox', { name: 'Unread only' })).toHaveFocus();
  await userEvent.keyboard('{Escape}');
  await expect.poll(() => shown(panel)).toBe(false);
  await expect.element(trigger).toHaveFocus();
  await trigger.click();
  await expect.poll(() => shown(panel)).toBe(true);
  await screen.getByRole('button', { name: 'After' }).click();
  await expect.poll(() => shown(panel)).toBe(false);
  await trigger.click();
  await expect.poll(() => shown(panel)).toBe(true);
  (screen.getByRole('button', { name: 'After' }).element() as HTMLElement).focus();
  await expect.poll(() => shown(panel)).toBe(false);
});

test('aligned to its end, the panel lines up with the end edge of its opener', async () => {
  const screen = await render(Popovers);
  const details = screen.getByRole('button', { name: 'Details' });
  await details.click();
  const panel = screen.getByRole('dialog', { name: 'Details' });
  await expect.element(panel).toBeVisible();
  expect(box(panel.element()).right).toBeCloseTo(box(details.element()).right, 0);
});
