// Anchored position: side and alignment in the writing direction, the gap, the flip, the shift that keeps
// the margin, the height there is, and following scroll.
import { beforeEach, describe, expect, test } from 'vitest';
import { page } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { place, type PlaceOptions } from '../../packages/core/src/primitives/anchored.ts';
import Anchored from './fixtures/Anchored.svelte';

const ANCHOR = { left: 100, top: 100, width: 100, height: 40 };
const SIZE = { width: 200, height: 150 };
const VIEWPORT = { width: 800, height: 600 };
const at = (anchor: Partial<typeof ANCHOR>, options: Partial<PlaceOptions> = {}) =>
  place({ ...ANCHOR, ...anchor }, SIZE, VIEWPORT, { gap: 4, margin: 16, ...options });

describe('place', () => {
  test('below the anchor at its start, the gap away, with the height down to the margin', () => {
    expect(at({})).toEqual({ x: 100, y: 144, side: 'bottom', maxHeight: 440, maxWidth: 768 });
  });

  test('flips to the side with more room, and keeps its side when the other has no more', () => {
    expect(at({ top: 500 })).toEqual({ x: 100, y: 346, side: 'top', maxHeight: 480, maxWidth: 768 });
    expect(at({}, { side: 'top' })).toEqual({ x: 100, y: 144, side: 'bottom', maxHeight: 440, maxWidth: 768 });
    // 260 above and below: too tall for either, it stays on top with the height there is
    const tall = place({ ...ANCHOR, top: 280 }, { width: 200, height: 700 }, VIEWPORT, {
      gap: 4,
      margin: 16,
      side: 'top',
    });
    expect(tall).toEqual({ x: 100, y: 16, side: 'top', maxHeight: 260, maxWidth: 768 });
  });

  test('aligns its end or centre, mirrored right to left, and shifts to keep the margin', () => {
    expect(at({ left: 300 }, { align: 'end' }).x).toBe(200);
    expect(at({}, { align: 'center' }).x).toBe(50);
    expect(at({ left: 300 }, { rtl: true }).x).toBe(200);
    expect(at({}, { rtl: true, align: 'end' }).x).toBe(100);
    expect(at({ left: 0 }, { align: 'end' }).x).toBe(16);
    expect(at({ left: 750 }).x).toBe(584);
  });

  test('at the start or end side, in the writing direction, flipped when the other side has more room', () => {
    expect(at({}, { side: 'end' })).toEqual({ x: 204, y: 100, side: 'end', maxHeight: 568, maxWidth: 580 });
    expect(at({ left: 400 }, { side: 'start' })).toEqual({
      x: 196,
      y: 100,
      side: 'start',
      maxHeight: 568,
      maxWidth: 380,
    });
    expect(at({}, { side: 'end', rtl: true })).toEqual({
      x: 204,
      y: 100,
      side: 'start',
      maxHeight: 568,
      maxWidth: 580,
    });
    expect(at({ top: 500 }, { side: 'end', align: 'end' }).y).toBe(390);
  });
});

describe('place at the start or end side, with no room for the width on either', () => {
  const narrow = { width: 320, height: 600 };
  const wide = { width: 240, height: 40 };
  const tip = (anchor: Partial<typeof ANCHOR>, options: Partial<PlaceOptions> = {}) =>
    place({ ...ANCHOR, ...anchor }, wide, narrow, { gap: 4, margin: 16, side: 'start', ...options });

  test('goes on the side with more room, its width capped at that room, still the margin inside', () => {
    // 80 on the left and 100 on the right, between the gap and the margin: to the right, 100 wide
    expect(tip({})).toEqual({ x: 204, y: 100, side: 'end', maxHeight: 568, maxWidth: 100 });
    // the other way round: to the left, 100 wide, its left edge at the margin
    expect(tip({ left: 120 }, { side: 'end' })).toEqual({
      x: 16,
      y: 100,
      side: 'start',
      maxHeight: 568,
      maxWidth: 100,
    });
    // the same in the other writing direction
    expect(tip({}, { rtl: true })).toEqual({ x: 204, y: 100, side: 'start', maxHeight: 568, maxWidth: 100 });
  });

  test('stays on its side when the other has no more room, its width capped there', () => {
    // 90 on both sides
    expect(tip({ left: 110 })).toEqual({ x: 16, y: 100, side: 'start', maxHeight: 568, maxWidth: 90 });
    expect(tip({ left: 110 }, { side: 'end' })).toEqual({ x: 214, y: 100, side: 'end', maxHeight: 568, maxWidth: 90 });
  });

  test('keeps its width when it fits', () => {
    expect(tip({ left: 140, width: 20 }, { side: 'end' }).x).toBe(164);
    expect(
      place({ ...ANCHOR, left: 400 }, { width: 100, height: 40 }, VIEWPORT, { gap: 4, margin: 16, side: 'start' })
        .maxWidth,
    ).toBe(380);
  });
});

describe('anchored', () => {
  beforeEach(async () => {
    await page.viewport(800, 600);
  });

  const box = (element: Element) => {
    const { left, top } = element.getBoundingClientRect();
    return { left, top };
  };

  test('places the element fixed under its anchor, and over it when there is more room above', async () => {
    const screen = await render(Anchored, { align: 'end' });
    const floating = screen.getByTestId('floating').element() as HTMLElement;
    await expect.poll(() => box(floating)).toEqual({ left: 16, top: 144 });
    expect(floating.dataset['side']).toBe('bottom');
    expect(floating.style.maxHeight).toBe('440px');
    await screen.rerender({ top: 500, align: 'start' });
    // a new anchor position is read on the next scroll or resize
    dispatchEvent(new Event('resize'));
    await expect.poll(() => box(floating)).toEqual({ left: 100, top: 346 });
    expect(floating.dataset['side']).toBe('top');
  });

  test('follows the anchor when its box scrolls', async () => {
    const screen = await render(Anchored);
    const floating = screen.getByTestId('floating').element() as HTMLElement;
    await expect.poll(() => box(floating).top).toBe(144);
    screen.getByTestId('box').element().scrollTop = 50;
    await expect.poll(() => box(floating).top).toBe(94);
  });

  test('taller than the room, it scrolls inside, and its own scroll moves nothing', async () => {
    const screen = await render(Anchored, { tall: true });
    const floating = screen.getByTestId('floating').element() as HTMLElement;
    await expect.poll(() => floating.clientHeight).toBe(440);
    floating.scrollTop = 200;
    await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    expect(floating.scrollTop).toBe(200);
    expect(box(floating).top).toBe(144);
  });

  test('it lines up with the box of its anchor, not the scale a press gives it', async () => {
    const screen = await render(Anchored, { scale: 0.5 });
    const floating = screen.getByTestId('floating').element() as HTMLElement;
    await expect.poll(() => box(floating)).toEqual({ left: 100, top: 144 });
  });

  test('right to left, its start is the right edge of the anchor', async () => {
    const screen = await render(Anchored, { dir: 'rtl' });
    const floating = screen.getByTestId('floating').element() as HTMLElement;
    // the anchor's right edge at 200, minus the width, kept 16 from the edge
    await expect.poll(() => box(floating).left).toBe(16);
  });
});
