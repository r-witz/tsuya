// Roving focus (G6, G14): one tab stop, arrows in visual order, Home and End, wrap, type-ahead, disabled
// items, and a tab stop that follows the selection.
import { expect, test, vi } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { TYPEAHEAD_TIMEOUT } from '../../packages/core/src/primitives/typeahead.ts';
import Roving from './fixtures/Roving.svelte';

const focused = () => document.activeElement?.textContent;

test('one tab stop: the selected item, else the first; Tab leaves the group', async () => {
  const screen = await render(Roving, { selected: 2 });
  screen.getByRole('button', { name: 'Before' }).element().focus();
  await userEvent.tab();
  expect(focused()).toBe('Blueberry');
  await userEvent.tab();
  expect(focused()).toBe('After');
  await userEvent.tab({ shift: true });
  expect(focused()).toBe('Blueberry');
  await screen.rerender({ selected: -1 });
  screen.getByRole('button', { name: 'Before' }).element().focus();
  await userEvent.tab();
  expect(focused()).toBe('Apple');
});

test('arrows move and wrap, Home and End go to the ends, disabled items are skipped', async () => {
  const moved: string[] = [];
  const screen = await render(Roving, { disabled: [1], onmove: (label: string) => moved.push(label) });
  screen.getByRole('radio', { name: 'Apple' }).element().focus();
  await userEvent.keyboard('{ArrowRight}');
  expect(focused()).toBe('Blueberry');
  await userEvent.keyboard('{ArrowDown}');
  expect(focused()).toBe('Cherry');
  await userEvent.keyboard('{ArrowRight}');
  expect(focused()).toBe('Apple');
  await userEvent.keyboard('{ArrowUp}');
  expect(focused()).toBe('Cherry');
  await userEvent.keyboard('{Home}');
  expect(focused()).toBe('Apple');
  await userEvent.keyboard('{End}');
  expect(focused()).toBe('Cherry');
  expect(moved).toEqual(['Blueberry', 'Cherry', 'Apple', 'Cherry', 'Apple', 'Cherry']);
  // the tab stop is the item focused last
  const tabbable = screen.container.querySelectorAll('[role="radio"][tabindex="0"]');
  expect([...tabbable].map((item) => item.textContent)).toEqual(['Cherry']);
});

test('right to left, the arrows follow the visual order', async () => {
  const screen = await render(Roving, { dir: 'rtl' });
  screen.getByRole('radio', { name: 'Apple' }).element().focus();
  await userEvent.keyboard('{ArrowLeft}');
  expect(focused()).toBe('Banana');
  await userEvent.keyboard('{ArrowRight}');
  expect(focused()).toBe('Apple');
});

test('one orientation, no wrap, and disabled items that take focus', async () => {
  const screen = await render(Roving, {
    disabled: [1],
    options: { orientation: 'horizontal', wrap: false, disabledFocusable: true },
  });
  screen.getByRole('radio', { name: 'Apple' }).element().focus();
  await userEvent.keyboard('{ArrowDown}');
  expect(focused()).toBe('Apple');
  await userEvent.keyboard('{ArrowLeft}');
  expect(focused()).toBe('Apple');
  await userEvent.keyboard('{ArrowRight}');
  expect(focused()).toBe('Banana');
  await userEvent.keyboard('{End}{ArrowRight}');
  expect(focused()).toBe('Cherry');
});

test('typed letters find an item; the same letter again moves on; the search ends after a pause', async () => {
  // the page's clock stands still between keys, so a slow machine cannot end a search the test is still typing
  vi.useFakeTimers({ toFake: ['setTimeout', 'clearTimeout'] });
  const screen = await render(Roving, { options: { typeahead: true } });
  screen.getByRole('radio', { name: 'Apple' }).element().focus();
  await userEvent.keyboard('b');
  expect(focused()).toBe('Banana');
  await userEvent.keyboard('b');
  expect(focused()).toBe('Blueberry');
  vi.advanceTimersByTime(TYPEAHEAD_TIMEOUT);
  await userEvent.keyboard('ch');
  expect(focused()).toBe('Cherry');
  vi.advanceTimersByTime(TYPEAHEAD_TIMEOUT);
  await userEvent.keyboard('blu');
  expect(focused()).toBe('Blueberry');
  vi.useRealTimers();
});

test('the tab stop follows a selection made elsewhere, and survives items that go', async () => {
  const screen = await render(Roving, { selected: 0 });
  await screen.rerender({ selected: 3 });
  await expect.poll(() => screen.container.querySelector('[role="radio"][tabindex="0"]')?.textContent).toBe('Cherry');
  await screen.rerender({ items: ['Apple', 'Banana'], selected: -1 });
  await expect
    .poll(() => [...screen.container.querySelectorAll('[role="radio"][tabindex="0"]')].map((i) => i.textContent))
    .toEqual(['Apple']);
});
