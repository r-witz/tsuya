// Button, IconButton and Spinner (DESIGN.md, Button, IconButton, Spinner; G5, G6): values per variant and size,
// links, loading, toggles, custom sizes and the spinner's semantics.
import { afterEach, expect, test } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Buttons from './fixtures/Buttons.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

afterEach(async () => {
  await commands.emulateMedia({ reducedMotion: null });
});

test('each variant has its colours', async () => {
  const screen = await render(Buttons);
  const button = (name: string) => screen.getByRole('button', { name, exact: true }).element();
  expect(hexOf(button('primary'), 'background-color')).toBe(light.color.accent);
  expect(hexOf(button('primary'))).toBe(light.color.onAccent);
  expect(rgbaOf(button('secondary'), 'background-color')).toEqual(rgbaOfHex(light.color.fill));
  expect(rgbaOf(button('secondary'), 'border-top-color')).toEqual(rgbaOfHex(light.color.border));
  expect(hexOf(button('secondary'))).toBe(light.color.text);
  expect(rgbaOf(button('ghost'), 'background-color')).toEqual([0, 0, 0, 0]);
  expect(hexOf(button('danger'), 'background-color')).toBe(light.color.danger);
  expect(hexOf(button('danger'))).toBe(light.color.onStatus);
  expect(rgbaOf(button('glass'), 'background-color')).toEqual(rgbaOfHex(light.color.glassControl));
  expect(style(button('glass'), 'backdrop-filter')).toMatch(/blur/);
});

test('sizes: height, side padding, type and icon; a pill; the icon 8 from the label', async () => {
  const screen = await render(Buttons);
  for (const [size, height, padding, font, icon] of [
    ['sm', 32, '12px', '13px', 16],
    ['md', 44, '20px', '15px', 20],
    ['lg', 56, '32px', '15px', 24],
  ] as const) {
    const button = screen.getByTestId(`sized-${size}`).element();
    expect(box(button).height, size).toBe(height);
    expect(style(button, 'padding-left'), size).toBe(padding);
    expect(style(button, 'font-size'), size).toBe(font);
    expect(style(button, 'border-top-left-radius'), size).toBe('999px');
    const glyph = button.querySelector('svg');
    expect(glyph && box(glyph).width, size).toBe(icon);
    expect(style(button, 'column-gap'), size).toBe('8px');
  }
});

test('a press calls onclick; Enter and Space press too', async () => {
  const pressed: string[] = [];
  const screen = await render(Buttons, { onpress: (name: string) => pressed.push(name) });
  await screen.getByRole('button', { name: 'primary', exact: true }).click();
  screen.getByRole('button', { name: 'secondary', exact: true }).element().focus();
  await userEvent.keyboard('{Enter}');
  await userEvent.keyboard(' ');
  expect(pressed).toEqual(['primary', 'secondary', 'secondary']);
});

test('loading: a spinner takes the icon place or comes first, the width stays, busy, presses ignored', async () => {
  const pressed: string[] = [];
  const screen = await render(Buttons, { onpress: (name: string) => pressed.push(name) });
  const plain = screen.getByTestId('plain').element();
  const sized = screen.getByTestId('sized-md').element();
  const widths = [box(plain).width, box(sized).width];
  await screen.rerender({ loading: true });
  // to the layout's sub-pixel unit
  expect(box(plain).width).toBeCloseTo(widths[0] ?? 0, 1);
  expect(box(sized).width).toBeCloseTo(widths[1] ?? 0, 1);
  expect(plain.getAttribute('aria-busy')).toBe('true');
  expect(plain.querySelector('.t-spinner')?.getAttribute('aria-hidden')).toBe('true');
  expect(sized.querySelector('[data-testid="icon"]')).toBeNull();
  await screen.getByTestId('plain').click();
  expect(pressed).toEqual([]);
  await expect.element(screen.getByRole('button', { name: 'Send the message' })).toBeInTheDocument();
  await screen.rerender({ loading: false });
  expect(plain.hasAttribute('aria-busy')).toBe(false);
  expect(plain.getAttribute('style') ?? '').not.toContain('width');
});

test('a link with href, without it when disabled; a disabled button is dimmed', async () => {
  const screen = await render(Buttons);
  await expect.element(screen.getByRole('link', { name: 'Settings' })).toHaveAttribute('href', '/settings');
  await screen.rerender({ disabled: true });
  const link = screen.getByRole('link', { name: 'Settings' });
  await expect.element(link).not.toHaveAttribute('href');
  await expect.element(link).toHaveAttribute('aria-disabled', 'true');
  const sized = screen.getByTestId('sized-md');
  await expect.element(sized).toBeDisabled();
  expect(style(sized.element(), 'opacity')).toBe('0.38');
});

test('a label that does not fit ends with an ellipsis on one line', async () => {
  const screen = await render(Buttons);
  const button = screen.getByRole('button', { name: 'A label far too long to fit' }).element();
  const label = button.querySelector('.t-button-label') as HTMLElement;
  expect(box(button).width).toBe(120);
  expect(box(button).height).toBe(44);
  expect(style(label, 'text-overflow')).toBe('ellipsis');
  expect(label.scrollWidth).toBeGreaterThan(label.clientWidth);
});

test('an icon button: named, round, sized; a toggle is pressed and accent-filled', async () => {
  const screen = await render(Buttons);
  const shuffle = screen.getByRole('button', { name: 'Shuffle' });
  await expect.element(shuffle).toHaveAttribute('aria-pressed', 'false');
  expect(box(shuffle.element())).toMatchObject({ width: 44, height: 44 });
  expect(style(shuffle.element(), 'border-top-left-radius')).toBe('999px');
  expect(box(screen.getByRole('button', { name: 'Small' }).element()).width).toBe(32);
  const large = screen.getByRole('button', { name: 'Large' }).element();
  expect(box(large).width).toBe(56);
  expect(rgbaOf(large)).toEqual(rgbaOfHex(light.color.textMuted));
  await screen.rerender({ pressed: true });
  await expect.element(shuffle).toHaveAttribute('aria-pressed', 'true');
  // after the background's transition
  await expect.poll(() => hexOf(shuffle.element(), 'background-color')).toBe(light.color.accent);
  expect(hexOf(shuffle.element())).toBe(light.color.onAccent);
});

test('a custom icon button size is kept from 40 to 72, its icon 38 % of it and at least 18', async () => {
  const screen = await render(Buttons);
  const play = () => screen.getByRole('button', { name: 'Play' }).element();
  const icon = () => box(play().querySelector('svg') as Element).width;
  expect(box(play()).width).toBe(64);
  expect(icon()).toBeCloseTo(24.32, 1);
  await screen.rerender({ custom: 90 });
  expect(box(play()).width).toBe(72);
  await screen.rerender({ custom: 20 });
  expect(box(play()).width).toBe(40);
  expect(icon()).toBe(18);
});

test('a spinner alone is a progress bar named with the loading label, and keeps turning under reduced motion', async () => {
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  const screen = await render(Buttons);
  const spinners = screen.getByRole('progressbar');
  await expect.element(spinners.nth(0)).toHaveAccessibleName('Loading');
  await expect.element(spinners.nth(1)).toHaveAccessibleName('Loading the album');
  const svg = spinners.nth(0).element().querySelector('svg') as SVGElement;
  expect(box(spinners.nth(0).element()).width).toBe(20);
  expect(box(spinners.nth(1).element()).width).toBe(24);
  expect(svg.getAnimations().map((animation) => animation.effect?.getTiming().duration)).toEqual([800]);
});
