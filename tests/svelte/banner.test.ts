// Banner (DESIGN.md, Banner; G5, G13): a status icon, a fill at 13 % with a ring at 32 %, a title and a message, the
// actions at the end, under the message when the banner is narrow; an optional close button named by the close label.
import { expect, test } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light, radius } from '../../packages/core/src/tokens.ts';
import Banners from './fixtures/Banners.svelte';
import { rgbaOf, rgbaOfHex } from './support.ts';

const box = (element: Element) => element.getBoundingClientRect();
const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);

test('named by its title, a status icon, radius-md, padding 12 16, the title and message types', async () => {
  const screen = await render(Banners, { tone: 'danger' });
  const banner = screen.getByRole('group', { name: 'Sync paused' }).element();
  expect(banner.querySelector('.t-glyph')).not.toBeNull();
  expect(style(banner, 'border-top-left-radius')).toBe(`${String(radius.md)}px`);
  expect([style(banner, 'padding-top'), style(banner, 'padding-left')]).toEqual(['12px', '16px']);
  const title = screen.getByText('Sync paused').element();
  expect(style(title, 'font-size')).toBe('15px');
  expect(style(title, 'font-weight')).toBe('600');
  const message = screen.getByText(/Your changes will upload/).element();
  expect(style(message, 'font-size')).toBe('13px');
});

test('the fill is the tone colour at 13 %, the ring at 32 %', async () => {
  const screen = await render(Banners, { tone: 'danger' });
  const banner = screen.getByRole('group', { name: 'Sync paused' }).element();
  const danger = rgbaOfHex(light.color.danger);
  expect(rgbaOf(banner, 'background-color')).toEqual([danger[0], danger[1], danger[2], 0.13]);
  expect(rgbaOf(banner, 'border-top-color')).toEqual([danger[0], danger[1], danger[2], 0.32]);
});

test('each tone has its own icon; warning and danger share one, told apart by colour', async () => {
  const paths: Record<string, string | null> = {};
  for (const tone of ['info', 'success', 'warning', 'danger'] as const) {
    const screen = await render(Banners, { tone });
    const icon = screen.getByRole('group', { name: 'Sync paused' }).element().querySelector('.t-glyph path');
    paths[tone] = icon?.getAttribute('d') ?? null;
    await screen.unmount();
  }
  expect(paths['warning']).toBe(paths['danger']);
  expect(new Set(Object.values(paths)).size).toBe(3);
});

test('wide enough, the actions sit on the row of the message, at the end', async () => {
  const screen = await render(Banners, { narrow: false });
  const title = screen.getByText('Sync paused').element();
  const message = screen.getByText(/Your changes will upload/).element();
  const retry = screen.getByRole('button', { name: 'Retry' }).element();
  const center = box(retry).top + box(retry).height / 2;
  // on the row of the title and the message together, not under them
  expect(center).toBeGreaterThan(box(title).top);
  expect(center).toBeLessThan(box(message).bottom);
  expect(box(retry).left).toBeGreaterThan(box(message).right);
});

test('too narrow, the actions wrap under the message', async () => {
  const screen = await render(Banners, { narrow: true });
  const message = screen.getByText(/Your changes will upload/).element();
  const retry = screen.getByRole('button', { name: 'Retry' }).element();
  expect(box(retry).top).toBeGreaterThan(box(message).bottom - 1);
});

test('no onclose, no close button; onclose shows one named by the close label and calls it', async () => {
  const screen = await render(Banners, { closable: false });
  expect(screen.getByRole('button', { name: 'Close' }).elements()).toHaveLength(0);
  let closed = false;
  await screen.rerender({ closable: true, onclose: () => (closed = true) });
  await screen.getByRole('button', { name: 'Close' }).click();
  expect(closed).toBe(true);
});

test('the actions are real buttons, reachable by keyboard', async () => {
  const screen = await render(Banners);
  await userEvent.tab();
  await expect.element(screen.getByRole('button', { name: 'Retry' })).toHaveFocus();
});
