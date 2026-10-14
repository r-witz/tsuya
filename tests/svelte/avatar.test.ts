// Avatar (DESIGN.md, Avatar; G1, G5): the photo, initials on fill, a gradient of the person's colours checked for
// 4.5:1 on its darker colour and falling back to fill, size, and the accessible name.
import { expect, test } from 'vitest';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Avatars from './fixtures/Avatars.svelte';
import { rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('a photo: round, the img named by the label, no extra role', async () => {
  const screen = await render(Avatars);
  const container = screen.getByTestId('photo').element();
  await expect.poll(() => container.querySelector('img')?.complete).toBe(true);
  const img = container.querySelector('img') as HTMLImageElement;
  expect(img.alt).toBe('Jamie Doe');
  expect(box(container).width).toBe(40);
  expect(box(container).height).toBe(40);
  expect(style(container.querySelector('.t-avatar-circle') as Element, 'border-radius')).toBe('999px');
  expect(container.hasAttribute('role')).toBe(false);
});

test('initials on fill, named through role=img since there is no img element', async () => {
  const screen = await render(Avatars);
  const container = screen.getByTestId('plain-initials').element();
  expect(container.getAttribute('role')).toBe('img');
  expect(container.getAttribute('aria-label')).toBe('Jamie Doe');
  const initials = container.querySelector('.t-avatar-initials') as HTMLElement;
  expect(initials.textContent).toBe('JD');
  expect(initials.getAttribute('aria-hidden')).toBe('true');
  expect(style(initials, 'font-weight')).toBe('600');
  expect(rgbaOf(container.querySelector('.t-avatar-circle') as Element, 'background-color')).toEqual(
    rgbaOfHex(light.color.fill),
  );
  expect(rgbaOf(initials, 'color')).toEqual(rgbaOfHex(light.color.textMuted));
});

test('a gradient that keeps 4.5:1 on its darker colour (checked regardless of order) shows in white', async () => {
  const screen = await render(Avatars);
  const container = screen.getByTestId('gradient-pass').element();
  expect(style(container.querySelector('.t-avatar-circle') as Element, 'background-image')).toContain(
    'linear-gradient',
  );
  expect(rgbaOf(container.querySelector('.t-avatar-initials') as Element, 'color')).toEqual([255, 255, 255, 1]);
});

test('a gradient whose darker colour would not keep 4.5:1 falls back to fill', async () => {
  const screen = await render(Avatars);
  const container = screen.getByTestId('gradient-fail').element();
  const circle = container.querySelector('.t-avatar-circle') as Element;
  expect(style(circle, 'background-image')).toBe('none');
  expect(rgbaOf(circle, 'background-color')).toEqual(rgbaOfHex(light.color.fill));
  expect(rgbaOf(container.querySelector('.t-avatar-initials') as Element, 'color')).toEqual(
    rgbaOfHex(light.color.textMuted),
  );
});

test('a photo that fails to load falls back to the initials', async () => {
  const screen = await render(Avatars);
  const container = screen.getByTestId('broken-photo').element();
  await expect.poll(() => container.querySelector('img')).toBeNull();
  expect(container.querySelector('.t-avatar-initials')?.textContent).toBe('BR');
  expect(container.getAttribute('aria-label')).toBe('Bo Reyes');
});

test('without a label and no photo, it is decorative', async () => {
  const screen = await render(Avatars);
  const container = screen.getByTestId('no-label').element();
  expect(container.getAttribute('aria-hidden')).toBe('true');
  expect(container.hasAttribute('role')).toBe(false);
});

test('a custom size scales the initials to 36 % of it', async () => {
  const screen = await render(Avatars);
  const container = screen.getByTestId('sized').element();
  expect(box(container).width).toBe(64);
  expect(parseFloat(style(container.querySelector('.t-avatar-initials') as Element, 'font-size'))).toBeCloseTo(
    64 * 0.36,
    1,
  );
});
