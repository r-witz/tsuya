// TabBar (DESIGN.md, TabBar, Screen; G5, G6, G13, G14): glass, floating in the dock of a screen, the items sharing its
// width, the current tab, choosing with a press or the keyboard, a press on the current tab scrolling to the top, a
// badge pinned to an icon and read after the label.
import { beforeEach, expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light, radius, size } from '../../packages/core/src/tokens.ts';
import TabBars from './fixtures/TabBars.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();
const output = () => document.querySelector('[data-testid="value"]')?.textContent;

beforeEach(async () => {
  await page.viewport(390, 700);
});

test('glass, floating 12 from the edges of the screen, the items sharing its width', async () => {
  const screen = await render(TabBars);
  const bar = screen.getByRole('tablist', { name: 'Sections' }).element();
  expect(bar.classList.contains('t-glass')).toBe(true);
  expect(box(bar).height).toBeGreaterThanOrEqual(size.dock);
  expect(style(bar, 'border-top-left-radius')).toBe(`${String(radius.lg)}px`);
  expect([box(bar).left, innerWidth - box(bar).right, innerHeight - box(bar).bottom]).toEqual([12, 12, 12]);
  const widths = [...bar.querySelectorAll('[role="tab"]')].map((tab) => Math.round(box(tab).width));
  expect(new Set(widths).size).toBe(1);
});

test('an item: an icon 24 over a micro label in text-muted; the current one in a capsule, accent and 700', async () => {
  const screen = await render(TabBars);
  const home = screen.getByRole('tab', { name: 'Home' }).element();
  const library = screen.getByRole('tab', { name: 'Library' }).element();
  expect(home.getAttribute('aria-selected')).toBe('true');
  const icon = home.querySelector('[data-testid="icon"]') as Element;
  expect([box(icon).width, box(icon).height]).toEqual([24, 24]);
  const label = (tab: Element) => tab.querySelector('.t-tab-bar-label') as Element;
  expect(style(label(library), 'font-size')).toBe('11px');
  expect(rgbaOf(label(library))).toEqual(rgbaOfHex(light.color.textMuted));
  expect(style(label(library), 'text-overflow')).toBe('ellipsis');
  expect(rgbaOf(home, 'background-color')).toEqual(rgbaOfHex(light.color.fillStrong));
  expect(style(home, 'border-top-left-radius')).toBe(`${String(radius.full)}px`);
  expect(hexOf(icon)).toBe(light.color.accent);
  expect(hexOf(label(home))).toBe(light.color.text);
  expect(style(label(home), 'font-weight')).toBe('700');
  expect(rgbaOf(library, 'background-color')).toEqual([0, 0, 0, 0]);
});

test('a press chooses a tab; arrows move without choosing, Enter chooses; one tab stop', async () => {
  const screen = await render(TabBars);
  await screen.getByRole('tab', { name: 'Library' }).click();
  expect(output()).toBe('library');
  await expect.element(screen.getByRole('tab', { name: 'Library' })).toHaveAttribute('aria-selected', 'true');
  await expect.element(screen.getByRole('tab', { name: 'Home' })).toHaveAttribute('aria-selected', 'false');
  const tabs = [...document.querySelectorAll<HTMLElement>('[role="tab"]')];
  expect(tabs.map((tab) => tab.tabIndex)).toEqual([-1, 0, -1, -1]);
  await userEvent.keyboard('{ArrowRight}');
  await expect.element(screen.getByRole('tab', { name: /^Inbox/ })).toHaveFocus();
  expect(output()).toBe('library');
  await userEvent.keyboard('{Enter}');
  expect(output()).toBe('inbox');
});

test('a press on the current tab scrolls the page to the top', async () => {
  const screen = await render(TabBars);
  scrollTo({ top: 400, behavior: 'instant' });
  expect(scrollY).toBe(400);
  await screen.getByRole('tab', { name: 'Home' }).click();
  await expect.poll(() => scrollY).toBe(0);
  expect(output()).toBe('');
});

test('in a scroll container, a press on the current tab scrolls that container to the top, not the window', async () => {
  const screen = await render(TabBars, { scroller: true });
  const scroller = screen.getByTestId('scroller').element();
  scroller.scrollTo({ top: 300, behavior: 'instant' });
  scrollTo({ top: 100, behavior: 'instant' });
  expect(scroller.scrollTop).toBe(300);
  await screen.getByRole('tab', { name: 'Home' }).click();
  await expect.poll(() => scroller.scrollTop).toBe(0);
  expect(scrollY).toBe(100);
});

test('a badge is pinned to the icon, and what it means is read after the label', async () => {
  const screen = await render(TabBars);
  // the hidden words are a block of their own, which a name computation may set apart with a space
  const inbox = screen.getByRole('tab', { name: /^Inbox ?, 3 new$/ }).element();
  const badge = inbox.querySelector('.t-badge') as Element;
  const icon = inbox.querySelector('svg') as Element;
  expect(badge.textContent).toBe('3');
  expect(box(badge).right).toBeGreaterThan(box(icon).right);
  expect(box(badge).top).toBeLessThan(box(icon).top);
});

test('right to left, the first tab is on the right and the arrows follow', async () => {
  const screen = await render(TabBars, { dir: 'rtl' });
  const [home, library] = [
    screen.getByRole('tab', { name: 'Home' }).element() as HTMLElement,
    screen.getByRole('tab', { name: 'Library' }).element(),
  ];
  expect(box(home).left).toBeGreaterThan(box(library).left);
  home.focus();
  await userEvent.keyboard('{ArrowLeft}');
  await expect.element(screen.getByRole('tab', { name: 'Library' })).toHaveFocus();
});
