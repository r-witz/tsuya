// The phone shell (DESIGN.md, TabBar, Screen; G13): the side margins, the ambient background or the glow, a dock that
// floats 12 above the bottom while the page scrolls under it and fades, and never hides the end of the content.
import { beforeEach, expect, test } from 'vitest';
import { page } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import Screens from './fixtures/Screens.svelte';

const IMAGE = 'data:image/gif;base64,R0lGODlhAQABAIAAAP8AAP///yH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==';
const box = (element: Element) => element.getBoundingClientRect();

beforeEach(async () => {
  await page.viewport(390, 700);
});

test('the content keeps the side margins; the glow lights the top without an image, the image with one', async () => {
  const screen = await render(Screens);
  const row = screen.getByTestId('row-1').element();
  expect(box(row).left).toBe(20);
  expect(innerWidth - box(row).right).toBe(20);
  expect(screen.container.querySelector('.t-glow')).not.toBeNull();
  await screen.rerender({ ambient: IMAGE });
  expect(screen.container.querySelector('.t-glow')).toBeNull();
  expect(screen.container.querySelector('.t-ambient')).not.toBeNull();
});

test('the dock floats 12 above the bottom while the page scrolls under it, and the end of the page clears it', async () => {
  const screen = await render(Screens);
  const dock = screen.getByTestId('dock').element();
  expect(box(dock).bottom).toBe(innerHeight - 12);
  expect([box(dock).left, innerWidth - box(dock).right]).toEqual([12, 12]);
  scrollTo(0, 300);
  await expect.poll(() => box(dock).bottom).toBe(innerHeight - 12);
  // a row passes under it
  const under = [...screen.container.querySelectorAll('p')].some(
    (row) => box(row).top < box(dock).bottom && box(row).bottom > box(dock).top,
  );
  expect(under).toBe(true);
  // the content fades into the background under the dock
  expect(getComputedStyle(dock.parentElement as Element, '::before').backgroundImage).toMatch(/^linear-gradient/);
  scrollTo(0, document.documentElement.scrollHeight);
  await expect.poll(() => box(screen.getByTestId('row-40').element()).bottom).toBeLessThanOrEqual(box(dock).top);
});

test('G7: a dock that grew taller (a tab bar at 400 % zoom) still lets the end of the page clear it', async () => {
  await page.viewport(320, 640);
  const screen = await render(Screens, { tall: true });
  const dock = screen.getByTestId('dock').element();
  expect(box(dock).height).toBeGreaterThan(200);
  scrollTo(0, document.documentElement.scrollHeight);
  await expect.poll(() => box(screen.getByTestId('row-40').element()).bottom).toBeLessThanOrEqual(box(dock).top);
});

test('a short page does not scroll, its light kept to it, and puts the dock at the bottom', async () => {
  // a long page scrolled to its end before it
  const long = await render(Screens);
  scrollTo(0, document.documentElement.scrollHeight);
  await long.unmount();
  const screen = await render(Screens, { rows: 2 });
  expect(document.documentElement.scrollHeight).toBe(innerHeight);
  expect(box(screen.getByTestId('dock').element()).bottom).toBe(innerHeight - 12);
});
