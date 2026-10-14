// Switch (DESIGN.md, Switch; G5, G6, G9, G14): values, on/off colours, its label, its name, keyboard, disabled, reduced
// motion, RTL.
import { afterEach, expect, test, vi } from 'vitest';
import { commands, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Switches from './fixtures/Switches.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

afterEach(async () => {
  await commands.emulateMedia({ reducedMotion: null });
});

test('values: the track and thumb sizes, off colours', async () => {
  const screen = await render(Switches);
  const wifi = screen.getByRole('switch', { name: 'Wi-Fi' }).element();
  const outer = wifi.closest('.t-switch') as HTMLElement;
  const track = outer.querySelector('.t-switch-track') as HTMLElement;
  const thumb = outer.querySelector('.t-switch-thumb') as HTMLElement;
  expect(box(track)).toMatchObject({ width: 48, height: 28 });
  expect(box(thumb)).toMatchObject({ width: 24, height: 24 });
  expect(rgbaOf(track, 'background-color')).toEqual(rgbaOfHex(light.color.borderStrong));
  expect(hexOf(thumb, 'background-color')).toBe(light.color.thumb);
  // 2 from the start edge
  expect(Math.round(box(thumb).left - box(track).left)).toBe(2);
});

test('a press turns it on: accent track, on-accent thumb slid to the end', async () => {
  const screen = await render(Switches);
  const wifi = screen.getByRole('switch', { name: 'Wi-Fi' });
  const outer = () => wifi.element().closest('.t-switch') as HTMLElement;
  const track = () => outer().querySelector('.t-switch-track') as HTMLElement;
  const thumb = () => outer().querySelector('.t-switch-thumb') as HTMLElement;
  await expect.element(wifi).not.toBeChecked();
  await wifi.click();
  await expect.element(wifi).toBeChecked();
  await expect.poll(() => hexOf(track(), 'background-color')).toBe(light.color.accent);
  expect(hexOf(thumb(), 'background-color')).toBe(light.color.onAccent);
  await expect.poll(() => Math.round(box(track()).right - box(thumb()).right)).toBe(2);
});

test('its label is visible, beside the track, in body, and the whole control presses', async () => {
  const screen = await render(Switches);
  const wifi = screen.getByRole('switch', { name: 'Wi-Fi' });
  const text = screen.getByText('Wi-Fi');
  await expect.element(text).toBeVisible();
  await expect.element(text).toHaveClass('t-switch-text');
  const outer = wifi.element().closest('.t-switch') as HTMLElement;
  const track = outer.querySelector('.t-switch-track') as HTMLElement;
  expect(style(text.element(), 'font-size')).toBe('15px');
  expect(style(text.element(), 'font-weight')).toBe('500');
  // 12 from the track, at its end side
  expect(Math.round(box(text.element()).left - box(track).right)).toBe(12);
  await text.click();
  await expect.element(wifi).toBeChecked();
});

test('without a label, a switch in a ListItem is named by the row and described by its subtitle', async () => {
  const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
  const screen = await render(Switches, { variant: 'row' });
  const wifi = screen.getByRole('switch', { name: 'Wi-Fi' });
  await expect.element(wifi).toHaveAccessibleDescription('Connected');
  expect(screen.container.querySelector('.t-switch-text')).toBeNull();
  await wifi.click();
  await expect.element(wifi).toBeChecked();
  expect(warn).not.toHaveBeenCalled();
  warn.mockRestore();
});

test('a label-less switch outside a row needs an aria-label; without any name it warns in development', async () => {
  const warn = vi.spyOn(console, 'warn').mockImplementation(() => {});
  const named = await render(Switches, { variant: 'aria' });
  await expect.element(named.getByRole('switch', { name: 'Wi-Fi' })).toBeInTheDocument();
  await named.unmount();
  const labelled = await render(Switches);
  await expect.element(labelled.getByRole('switch', { name: 'Wi-Fi' })).toBeInTheDocument();
  await labelled.unmount();
  expect(warn).not.toHaveBeenCalled();
  const bare = await render(Switches, { variant: 'bare' });
  await expect.element(bare.getByRole('switch')).toBeInTheDocument();
  await expect.poll(() => warn.mock.calls.length).toBe(1);
  expect(String(warn.mock.calls[0]?.[0])).toMatch(/<Switch> has no accessible name/);
  warn.mockRestore();
});

test('Space toggles it from the keyboard', async () => {
  const screen = await render(Switches);
  const wifi = screen.getByRole('switch', { name: 'Wi-Fi' });
  wifi.element().focus();
  await userEvent.keyboard(' ');
  await expect.element(wifi).toBeChecked();
});

test('a disabled switch is dimmed and not focusable', async () => {
  const screen = await render(Switches, { disabled: true });
  const wifi = screen.getByRole('switch', { name: 'Wi-Fi' });
  await expect.element(wifi).toBeDisabled();
  const outer = wifi.element().closest('.t-switch') as HTMLElement;
  expect(style(outer, 'opacity')).toBe('0.38');
});

test('reduced motion: the thumb jumps instead of sliding', async () => {
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  const screen = await render(Switches);
  const wifi = screen.getByRole('switch', { name: 'Wi-Fi' });
  const thumb = wifi.element().closest('.t-switch')?.querySelector('.t-switch-thumb') as HTMLElement;
  expect(style(thumb, 'transition-duration')).toBe('0s');
  await wifi.click();
  await expect.element(wifi).toBeChecked();
});

test('right to left, the off thumb rests on the visual right', async () => {
  const screen = await render(Switches, { dir: 'rtl' });
  const wifi = screen.getByRole('switch', { name: 'Wi-Fi' }).element();
  const outer = wifi.closest('.t-switch') as HTMLElement;
  const track = outer.querySelector('.t-switch-track') as HTMLElement;
  const thumb = outer.querySelector('.t-switch-thumb') as HTMLElement;
  expect(Math.round(box(track).right - box(thumb).right)).toBe(2);
});
