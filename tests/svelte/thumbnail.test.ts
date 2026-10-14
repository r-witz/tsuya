// Thumbnail (DESIGN.md, Thumbnail; G13): ratio, the radius that grows with the width, the hairline, the placeholder
// and its icon while there is no image or it fails to load, and the decorative default.
import { expect, test } from 'vitest';
import { render } from 'vitest-browser-svelte';

import { light, radius, size } from '../../packages/core/src/tokens.ts';
import Thumbnails from './fixtures/Thumbnails.svelte';
import { rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('a loaded picture: the img with its alt, decoded at the display size', async () => {
  const screen = await render(Thumbnails);
  const container = screen.getByTestId('loaded').element();
  await expect.poll(() => container.querySelector('img')?.complete).toBe(true);
  const img = container.querySelector('img') as HTMLImageElement;
  expect(img.alt).toBe('Album cover');
  expect(img.getAttribute('width')).toBe('48');
  expect(img.getAttribute('height')).toBe('48');
  expect(img.getAttribute('decoding')).toBe('async');
});

test('without alt the picture is decorative', async () => {
  const screen = await render(Thumbnails);
  const container = screen.getByTestId('no-alt').element();
  await expect.poll(() => container.querySelector('img')?.complete).toBe(true);
  expect((container.querySelector('img') as HTMLImageElement).alt).toBe('');
});

test('without an image, the fill placeholder shows its icon', async () => {
  const screen = await render(Thumbnails);
  const container = screen.getByTestId('empty').element();
  expect(container.querySelector('img')).toBeNull();
  expect(container.querySelector('[data-testid="placeholder-icon"]')).not.toBeNull();
  expect(rgbaOf(container, 'background-color')).toEqual(rgbaOfHex(light.color.fill));
});

test('an icon given without a size is sized to the icon size of the scale', async () => {
  const screen = await render(Thumbnails);
  const icon = screen.getByTestId('bare-icon').element().querySelector('svg') as SVGElement;
  expect(icon.getBoundingClientRect().width).toBe(size.icon);
  expect(icon.getBoundingClientRect().height).toBe(size.icon);
});

test('a picture that fails to load falls back to the placeholder', async () => {
  const screen = await render(Thumbnails);
  const container = screen.getByTestId('broken').element();
  await expect.poll(() => container.querySelector('img')).toBeNull();
  expect(container.querySelector('[data-testid="placeholder-icon"]')).not.toBeNull();
});

test('a 1 px border hairline over the picture', async () => {
  const screen = await render(Thumbnails);
  const container = screen.getByTestId('loaded').element();
  expect(style(container, 'outline-width')).toBe('1px');
  expect(style(container, 'outline-offset')).toBe('-1px');
  expect(rgbaOf(container, 'outline-color')).toEqual(rgbaOfHex(light.color.border));
});

test('square by default, portrait 2:3 and wide 16:9', async () => {
  const screen = await render(Thumbnails);
  const square = box(screen.getByTestId('loaded').element());
  const portrait = box(screen.getByTestId('portrait').element());
  const wide = box(screen.getByTestId('wide').element());
  expect(square.width).toBe(48);
  expect(square.height).toBe(48);
  expect(portrait.width).toBe(48);
  expect(portrait.height).toBeCloseTo(72, 0);
  expect(wide.width).toBe(48);
  expect(wide.height).toBeCloseTo(27, 0);
});

test('the radius grows with the width: xs up to 40, sm up to 64, md up to 160, lg above', async () => {
  const screen = await render(Thumbnails);
  const radiusOf = (name: string) => style(screen.getByTestId(name).element(), 'border-top-left-radius');
  expect(radiusOf('xs')).toBe(`${String(radius.xs)}px`);
  expect(radiusOf('sm')).toBe(`${String(radius.sm)}px`);
  expect(radiusOf('md')).toBe(`${String(radius.md)}px`);
  expect(radiusOf('lg')).toBe(`${String(radius.lg)}px`);
});
