// SegmentedControl (DESIGN.md, SegmentedControl; G5, G6): values, selection, native one-tab-stop and arrow
// selection, icon-only segments, expand, disabled.
import { expect, test } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import SegmentedControls from './fixtures/SegmentedControls.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('values: the track, a segment height, radius, padding and type', async () => {
  const screen = await render(SegmentedControls);
  await expect.element(screen.getByRole('radiogroup', { name: 'View' })).toBeInTheDocument();
  const track = screen.getByRole('radiogroup').element();
  expect(rgbaOf(track, 'background-color')).toEqual(rgbaOfHex(light.color.fill));
  expect(rgbaOf(track, 'border-top-color')).toEqual(rgbaOfHex(light.color.border));
  const list = screen.getByRole('radio', { name: 'List' }).element().closest('.t-segmented-segment') as HTMLElement;
  expect(box(list).height).toBe(36);
  expect(style(list, 'border-top-left-radius')).toBe('12px');
  expect(style(list, 'padding-left')).toBe('16px');
  expect(style(list, 'font-size')).toBe('13px');
  // unselected (List is selected by default, checked below): text-muted
  const map = screen.getByRole('radio', { name: 'Map' }).element().closest('.t-segmented-segment') as HTMLElement;
  expect(rgbaOf(map)).toEqual(rgbaOfHex(light.color.textMuted));
});

test('with no value the first segment is selected; keyboard focus rings the segment', async () => {
  const screen = await render(SegmentedControls);
  const list = screen.getByRole('radio', { name: 'List' });
  await expect.element(list).toBeChecked();
  const segment = list.element().closest('.t-segmented-segment') as HTMLElement;
  expect(style(segment, 'outline-style')).toBe('none');
  const before = document.createElement('button');
  document.body.prepend(before);
  before.focus();
  await userEvent.tab();
  await expect.element(list).toHaveFocus();
  expect(style(segment, 'outline-style')).toBe('solid');
  expect(hexOf(segment, 'outline-color')).toBe(light.color.accent);
  before.remove();
});

test('selected: fill-selected, a shadow and full text colour', async () => {
  const screen = await render(SegmentedControls);
  const list = screen.getByRole('radio', { name: 'List' }).element().closest('.t-segmented-segment') as HTMLElement;
  const grid = screen.getByRole('radio', { name: 'Grid' }).element().closest('.t-segmented-segment') as HTMLElement;
  expect(hexOf(list, 'background-color')).toBe(light.color.fillSelected);
  expect(style(list, 'box-shadow')).not.toBe('none');
  expect(hexOf(list)).toBe(light.color.text);
  expect(rgbaOf(grid, 'background-color')).toEqual([0, 0, 0, 0]);
});

test('a press selects a segment and deselects the previous one', async () => {
  const screen = await render(SegmentedControls);
  const list = screen.getByRole('radio', { name: 'List' });
  const grid = screen.getByRole('radio', { name: 'Grid' });
  await expect.element(list).toBeChecked();
  await grid.click();
  await expect.element(grid).toBeChecked();
  await expect.element(list).not.toBeChecked();
});

test('one tab stop lands on the checked segment; arrows move and select', async () => {
  const screen = await render(SegmentedControls);
  const before = document.createElement('button');
  document.body.prepend(before);
  before.focus();
  await userEvent.tab();
  await expect.element(screen.getByRole('radio', { name: 'List' })).toHaveFocus();
  await userEvent.keyboard('{ArrowRight}');
  await expect.element(screen.getByRole('radio', { name: 'Grid' })).toHaveFocus();
  await expect.element(screen.getByRole('radio', { name: 'Grid' })).toBeChecked();
  before.remove();
});

test('an icon-only segment shows the icon and keeps its label as its name', async () => {
  const screen = await render(SegmentedControls, { icons: true });
  const grid = screen.getByRole('radio', { name: 'Grid' });
  await expect.element(grid).toBeInTheDocument();
  expect(grid.element().closest('.t-segmented-segment')?.querySelector('[data-testid="icon"]')).toBeTruthy();
  expect(grid.element().closest('.t-segmented-segment')?.textContent.trim()).toBe('Grid');
});

test('right to left, the segments mirror visually', async () => {
  const screen = await render(SegmentedControls, { dir: 'rtl' });
  const list = screen.getByRole('radio', { name: 'List' }).element().closest('.t-segmented-segment') as HTMLElement;
  const map = screen.getByRole('radio', { name: 'Map' }).element().closest('.t-segmented-segment') as HTMLElement;
  // List is first in the markup; in RTL the track mirrors so it renders on the visual right
  expect(box(list).left).toBeGreaterThan(box(map).left);
  // arrows follow the visual order too: from Map (now leftmost), right moves toward the middle (Grid)
  screen.getByRole('radio', { name: 'Map' }).element().focus();
  await userEvent.keyboard('{ArrowRight}');
  await expect.element(screen.getByRole('radio', { name: 'Grid' })).toHaveFocus();
});

test('the track holds its segments; expand shares the width equally', async () => {
  const hugging = await render(SegmentedControls);
  const track = hugging.getByRole('radiogroup').element();
  const segments = [...track.querySelectorAll('.t-segmented-segment')].map(box);
  // the hairline and space-4 around the segments, and space-4 between them
  const inside = segments.reduce((sum, each) => sum + each.width, 0) + 4 * (segments.length - 1);
  expect(box(track).width).toBeCloseTo(inside + 2 * (4 + 1), 0);
  await hugging.unmount();
  const screen = await render(SegmentedControls, { expand: true });
  const list = screen.getByRole('radio', { name: 'List' }).element().closest('.t-segmented-segment') as HTMLElement;
  const map = screen.getByRole('radio', { name: 'Map' }).element().closest('.t-segmented-segment') as HTMLElement;
  expect(box(list).width).toBeCloseTo(box(map).width, 0);
  expect(box(list).width).toBeGreaterThan(80);
});
