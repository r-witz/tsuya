// The sidebar (DESIGN.md, Sidebar; G5, G6, G13): 240 wide, items control-sm tall in text-muted, the current one on
// fill-strong, groups named by their labels, counts; collapsed, 72 wide with the icons only, still named, their labels
// as tooltips.
import { expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light, radius } from '../../packages/core/src/tokens.ts';
import Sidebars from './fixtures/Sidebars.svelte';
import { rgbaOf, rgbaOfHex } from './support.ts';

const box = (element: Element) => element.getBoundingClientRect();
const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const shown = (element: Element) => element.matches(':popover-open');
const wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
// the tooltip that shows a label
const tipOf = (text: string) =>
  [...document.querySelectorAll('[role="tooltip"]')].find((tip) => tip.textContent.trim() === text) as HTMLElement;

test('items, the current one, groups and a count', async () => {
  let created = 0;
  const screen = await render(Sidebars, { onnew: () => (created += 1) });
  const sidebar = screen.getByRole('navigation', { name: 'Library' }).element();
  expect(box(sidebar).width).toBe(240);
  expect(style(sidebar, 'padding-top')).toBe('12px');
  const home = screen.getByRole('link', { name: 'Home' }).element();
  expect(home.getAttribute('aria-current')).toBe('page');
  expect(rgbaOf(home, 'background-color')).toEqual(rgbaOfHex(light.color.fillStrong));
  expect(rgbaOf(home)).toEqual(rgbaOfHex(light.color.text));
  const albums = screen.getByRole('link', { name: 'Albums 12' }).element();
  expect(box(albums).height).toBe(32);
  expect(style(albums, 'border-top-left-radius')).toBe(`${String(radius.sm)}px`);
  expect(style(albums, 'font-size')).toBe('13px');
  expect(rgbaOf(albums)).toEqual(rgbaOfHex(light.color.textMuted));
  expect((albums.querySelector('svg') as Element).getBoundingClientRect().width).toBe(20);
  await expect.element(screen.getByRole('group', { name: 'Playlists' })).toBeVisible();
  await screen.getByRole('button', { name: 'New playlist' }).click();
  expect(created).toBe(1);
});

test('collapsed: 72 wide, icons only, every item and group still named', async () => {
  const screen = await render(Sidebars, { collapsed: true });
  expect(box(screen.getByTestId('sidebar').element()).width).toBe(72);
  const albums = screen.getByRole('link', { name: 'Albums' });
  await expect.element(albums).toBeVisible();
  expect(box(albums.element()).width).toBe(48);
  expect(albums.element().textContent).not.toContain('12');
  // the group keeps its name, its label takes no room
  const group = screen.getByRole('group', { name: 'Library' }).element();
  expect(box(group).top).toBe(box(albums.element()).top);
});

test('collapsed, an item shows its label as a tooltip at its end, on a mouse and at once on keyboard focus', async () => {
  await page.viewport(800, 600);
  const screen = await render(Sidebars, { collapsed: true });
  const home = screen.getByRole('link', { name: 'Home' }).element() as HTMLElement;
  const albums = screen.getByRole('link', { name: 'Albums' }).element();
  const tip = tipOf('Albums');
  // it repeats the item's own name, out of the tree
  expect(tip.getAttribute('aria-hidden')).toBe('true');
  expect(albums.hasAttribute('aria-describedby')).toBe(false);
  await userEvent.hover(albums);
  await expect.poll(() => shown(tip), { timeout: 1500 }).toBe(true);
  expect(box(tip).left).toBeCloseTo(box(albums).right + 4, 0);
  await userEvent.hover(home);
  await expect.poll(() => shown(tip)).toBe(false);
  home.focus();
  await userEvent.tab();
  expect(shown(tip)).toBe(true);
});

test('expanded, its labels show, and no tooltip', async () => {
  await page.viewport(800, 600);
  const screen = await render(Sidebars);
  await userEvent.hover(screen.getByRole('link', { name: 'Albums 12' }));
  await wait(800);
  expect(shown(tipOf('Albums'))).toBe(false);
});

test('a tooltip goes when its sidebar expands, and follows its label', async () => {
  const screen = await render(Sidebars, { collapsed: true });
  (screen.getByRole('link', { name: 'Home' }).element() as HTMLElement).focus();
  await userEvent.tab();
  expect(shown(tipOf('Albums'))).toBe(true);
  await screen.rerender({ collapsed: false });
  expect(shown(tipOf('Albums'))).toBe(false);
  await screen.rerender({ collapsed: true, albums: 'Records' });
  await expect.poll(() => tipOf('Records')).toBeDefined();
});
