// Progress (DESIGN.md, Progress; G5, G9, G13): a native progress bar, its track and radius, the thin variant, the
// indeterminate sweep every 1.2 s kept under reduced motion, and a value that can toggle to and from indeterminate.
import { expect, test } from 'vitest';
import { commands } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Progresses from './fixtures/Progresses.svelte';
import { painted, pixelAt, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string, pseudo?: string) =>
  getComputedStyle(element, pseudo).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('a determinate bar: space-4 tall, radius full, its value, named', async () => {
  const screen = await render(Progresses);
  const bar = screen.getByTestId('determinate').element() as HTMLProgressElement;
  expect(box(bar).height).toBe(4);
  expect(style(bar, 'border-radius')).toBe('999px');
  expect(bar.value).toBe(0.42);
  expect(bar.max).toBe(1);
  expect(bar.position).toBeCloseTo(0.42, 5);
  expect(rgbaOf(bar, 'color')).toEqual(rgbaOfHex(light.color.accent));
  expect(rgbaOf(bar, 'background-color')).toEqual(rgbaOfHex(light.color.track));
  const named = screen.getByRole('progressbar', { name: 'Uploading photo.jpg' });
  await expect.element(named).toBeInTheDocument();
});

test('a thin variant is 2 tall', async () => {
  const screen = await render(Progresses);
  expect(box(screen.getByTestId('thin').element()).height).toBe(2);
});

// whether a painted pixel is the accent
const accent = (pixel: number[]) =>
  rgbaOfHex(light.color.accent)
    .slice(0, 3)
    .every((channel, i) => Math.abs(channel - (pixel[i] ?? 0)) <= 8);

// the sweep paused a quarter of the way through, as painted
async function quarter(bar: Element): Promise<ImageData> {
  const [sweep] = bar.getAnimations();
  expect(sweep?.effect?.getTiming()).toMatchObject({ duration: 1200, iterations: Infinity });
  sweep?.pause();
  if (sweep) sweep.currentTime = 300;
  return painted(bar);
}

test('without a value, a third of the bar sweeps across every 1.2 s, kept under reduced motion', async () => {
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  const screen = await render(Progresses);
  const bar = screen.getByTestId('indeterminate').element() as HTMLProgressElement;
  expect(bar.hasAttribute('value')).toBe(false);
  expect(bar.matches(':indeterminate')).toBe(true);
  // a quarter of the way, the third covers the start of the bar
  const image = await quarter(bar);
  expect([1 / 12, 3 / 12, 5 / 12, 11 / 12].map((at) => accent(pixelAt(image, at)))).toEqual([true, true, false, false]);
  await commands.emulateMedia({ reducedMotion: null });
});

test('right to left, the third sweeps from the right', async () => {
  const screen = await render(Progresses, { dir: 'rtl' });
  const image = await quarter(screen.getByTestId('indeterminate').element());
  expect([1 / 12, 7 / 12, 9 / 12, 11 / 12].map((at) => accent(pixelAt(image, at)))).toEqual([false, false, true, true]);
});

test('a value can toggle to and from indeterminate', async () => {
  const screen = await render(Progresses, { toggled: 0.3 });
  expect(screen.getByTestId('toggle').element().hasAttribute('value')).toBe(true);
  await screen.rerender({ toggled: undefined });
  expect(screen.getByTestId('toggle').element().hasAttribute('value')).toBe(false);
  expect(screen.getByTestId('toggle').element().matches(':indeterminate')).toBe(true);
  await screen.rerender({ toggled: 0.6 });
  const after = screen.getByTestId('toggle').element() as HTMLProgressElement;
  expect(after.hasAttribute('value')).toBe(true);
  expect(after.value).toBe(0.6);
});
