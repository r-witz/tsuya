// Skeleton and Skeleton.Text (DESIGN.md, Skeleton; G9, G13): the final size and radius, the pulse stopped under
// reduced motion, hidden from screen readers in a busy region, and the lines of Skeleton.Text.
import { expect, test } from 'vitest';
import { commands } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { radius } from '../../packages/core/src/tokens.ts';
import Skeletons from './fixtures/Skeletons.svelte';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('a block at the final size of what loads, the radius of the real element', async () => {
  const screen = await render(Skeletons);
  const avatar = screen.getByTestId('avatar-skeleton').element();
  expect(box(avatar)).toMatchObject({ width: 40, height: 40 });
  expect(style(avatar, 'border-radius')).toBe(`${String(radius.full)}px`);
  const title = screen.getByTestId('title-skeleton').element();
  expect(box(title).height).toBe(16);
  expect(style(title, 'border-radius')).toBe(`${String(radius.xs)}px`);
});

test('without width, height or radius: fills its container, a text line tall, the xs radius', async () => {
  const screen = await render(Skeletons);
  const bare = screen.getByTestId('bare-skeleton').element();
  const row = screen.getByTestId('row').element();
  expect(box(bare).width).toBeCloseTo(box(row).width, 0);
  expect(box(bare).height).toBeGreaterThan(0);
  expect(style(bare, 'border-radius')).toBe(`${String(radius.xs)}px`);
});

test('hidden from screen readers, which hear the region that loads is busy, not the blocks', async () => {
  const screen = await render(Skeletons);
  for (const id of ['avatar-skeleton', 'paragraph']) {
    const block = screen.getByTestId(id).element();
    expect(block.getAttribute('aria-hidden')).toBe('true');
    // hidden, a block would say it to no one
    expect(block.hasAttribute('aria-busy')).toBe(false);
  }
  expect(screen.getByTestId('region').element().getAttribute('aria-busy')).toBe('true');
});

test('a slow opacity pulse, 0.5 to 1 over 1.6 s, stopped under reduced motion', async () => {
  const screen = await render(Skeletons);
  const avatar = screen.getByTestId('avatar-skeleton').element();
  expect(style(avatar, 'animation-duration')).toBe('1.6s');
  expect(style(avatar, 'animation-iteration-count')).toBe('infinite');
  expect(style(avatar, 'animation-direction')).toBe('alternate');
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  await expect.poll(() => style(avatar, 'animation-name')).toBe('none');
  await commands.emulateMedia({ reducedMotion: null });
});

test('Skeleton.Text renders its lines, the last one shorter; a single line stays full width', async () => {
  const screen = await render(Skeletons);
  const paragraph = screen.getByTestId('paragraph').element();
  const lines = [...paragraph.querySelectorAll('.t-skeleton')];
  expect(lines).toHaveLength(4);
  for (const line of lines.slice(0, -1)) expect(style(line, 'width')).toBe(`${String(box(paragraph).width)}px`);
  expect(box(lines[3] as Element).width).toBeCloseTo(box(paragraph).width * 0.6, 0);
  expect(paragraph.getAttribute('aria-hidden')).toBe('true');

  const single = screen.getByTestId('single-line').element();
  const onlyLine = single.querySelector('.t-skeleton') as Element;
  expect(style(onlyLine, 'width')).toBe(`${String(box(single).width)}px`);
});
