// Tabs (DESIGN.md, Tabs; G5, G6, G13, G14): a tab list with one tab stop, arrows that select (or only move, manual),
// Home and End, the selected tab in --t-text with a 2 px accent bar that slides, and the panels named by their tabs.
import { flushSync } from 'svelte';
import { afterEach, beforeEach, expect, test } from 'vitest';
import { commands, page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import { prefersReducedMotion } from 'svelte/motion';
import Tabbed from './fixtures/Tabbed.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const focused = () => document.activeElement?.textContent.trim();
const bar = (tab: Element) => getComputedStyle(tab, '::before');

beforeEach(async () => {
  await page.viewport(800, 600);
});

afterEach(async () => {
  await commands.emulateMedia({ reducedMotion: null });
});

test('a tab list of tabs tied to their panels; the first is selected while there is no value', async () => {
  const screen = await render(Tabbed);
  const list = screen.getByRole('tablist', { name: 'Product' });
  await expect.element(list).toBeVisible();
  const [overview, reviews] = screen.getByRole('tab').elements();
  await expect.element(screen.getByRole('tab', { name: 'Overview' })).toHaveAttribute('aria-selected', 'true');
  const panel = screen.getByRole('tabpanel', { name: 'Overview' });
  await expect.element(panel).toHaveTextContent('The overview of the product.');
  expect(overview?.getAttribute('aria-controls')).toBe(panel.element().id);
  // only the selected panel shows, and only its content renders
  expect(screen.container.querySelectorAll('[role="tabpanel"]:not([hidden])')).toHaveLength(1);
  expect(screen.container.querySelectorAll('[role="tabpanel"] p')).toHaveLength(1);
  // spec values: control-md tall, body-strong, text-muted; selected in text with a 2 px accent bar under the label
  expect(overview?.getBoundingClientRect().height).toBe(44);
  expect(getComputedStyle(reviews as Element).fontWeight).toBe(getComputedStyle(overview as Element).fontWeight);
  expect(hexOf(reviews as Element, 'color')).toBe(light.color.textMuted.slice(0, 7));
  expect(hexOf(overview as Element, 'color')).toBe(light.color.text.slice(0, 7));
  expect(bar(overview as Element).height).toBe('2px');
  expect(rgbaOf(overview as Element, 'background-color', '::before')).toEqual(rgbaOfHex(light.color.accent));
  expect(bar(reviews as Element).content).toBe('none');
});

test('one tab stop; arrows select and wrap; Home and End; a disabled tab is skipped', async () => {
  const screen = await render(Tabbed, { disabled: 'Reviews' });
  (screen.getByRole('tab', { name: 'Overview' }).element() as HTMLElement).focus();
  await userEvent.keyboard('{ArrowRight}');
  expect(focused()).toBe('Details');
  await expect.element(screen.getByRole('tab', { name: 'Details' })).toHaveAttribute('aria-selected', 'true');
  await expect.element(screen.getByRole('tabpanel', { name: 'Details' })).toBeVisible();
  await userEvent.keyboard('{ArrowRight}');
  expect(focused()).toBe('Overview');
  await userEvent.keyboard('{End}');
  expect(focused()).toBe('Details');
  await userEvent.keyboard('{Home}');
  expect(focused()).toBe('Overview');
  expect(screen.container.querySelectorAll('[role="tab"][tabindex="0"]')).toHaveLength(1);
});

test('manual: arrows move focus only, Enter selects; a press selects and the value follows', async () => {
  const screen = await render(Tabbed, { manual: true });
  const value = screen.getByTestId('value');
  (screen.getByRole('tab', { name: 'Overview' }).element() as HTMLElement).focus();
  await userEvent.keyboard('{ArrowRight}');
  expect(focused()).toBe('Reviews');
  await expect.element(screen.getByRole('tab', { name: 'Reviews' })).toHaveAttribute('aria-selected', 'false');
  await userEvent.keyboard('{Enter}');
  await expect.element(screen.getByRole('tab', { name: 'Reviews' })).toHaveAttribute('aria-selected', 'true');
  await expect.element(value).toHaveTextContent('Reviews');
  await screen.getByRole('tab', { name: 'Details' }).click();
  await expect.element(value).toHaveTextContent('Details');
});

test('right to left, the arrows follow the visual order', async () => {
  const screen = await render(Tabbed, { dir: 'rtl' });
  (screen.getByRole('tab', { name: 'Overview' }).element() as HTMLElement).focus();
  await userEvent.keyboard('{ArrowLeft}');
  expect(focused()).toBe('Reviews');
  const [overview, reviews] = screen.getByRole('tab').elements();
  expect(reviews?.getBoundingClientRect().right).toBeLessThanOrEqual(overview?.getBoundingClientRect().left ?? 0);
});

test('the bar slides to the new tab, at once under reduced motion', async () => {
  const screen = await render(Tabbed);
  const bars = () =>
    document.getAnimations().filter((animation) => (animation.effect as KeyframeEffect | null)?.pseudoElement);
  const reviews = screen.getByRole('tab', { name: 'Reviews' });
  // pressed and updated at once, so that a slow run does not see the slide already over
  (reviews.element() as HTMLElement).click();
  flushSync();
  expect(bars().map((animation) => (animation.effect as KeyframeEffect).target)).toEqual([reviews.element()]);
  await Promise.all(bars().map((animation) => animation.finished));
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  // WebKit updates the page's media queries at its next frame
  await expect.poll(() => prefersReducedMotion.current).toBe(true);
  (screen.getByRole('tab', { name: 'Overview' }).element() as HTMLElement).click();
  flushSync();
  expect(bars()).toEqual([]);
});

test('too many tabs scroll sideways; the focused one comes into view', async () => {
  const screen = await render(Tabbed, { many: true });
  const list = screen.getByRole('tablist').element();
  expect(list.scrollWidth).toBeGreaterThan(list.clientWidth);
  (screen.getByRole('tab', { name: 'Section 1' }).element() as HTMLElement).focus();
  await userEvent.keyboard('{End}');
  const last = screen.getByRole('tab', { name: 'Section 12' }).element().getBoundingClientRect();
  expect(last.right).toBeLessThanOrEqual(list.getBoundingClientRect().right + 0.5);
  expect(document.documentElement.scrollWidth).toBeLessThanOrEqual(document.documentElement.clientWidth);
});
