// Slider (DESIGN.md, Slider; G2, G5, G6, G14): values, the announced value, keyboard, disabled, RTL.
import { expect, test } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Sliders from './fixtures/Sliders.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('values: target tall, the track, the fill to the value, the thumb', async () => {
  const screen = await render(Sliders);
  const slider = screen.getByRole('slider', { name: 'Volume' }).element();
  const outer = slider.closest('.t-slider') as HTMLElement;
  expect(box(outer).height).toBeGreaterThanOrEqual(44);
  const track = outer.querySelector('.t-slider-track') as HTMLElement;
  expect(box(track).height).toBe(4);
  expect(rgbaOf(track, 'background-color')).toEqual(rgbaOfHex(light.color.track));
  const fill = outer.querySelector('.t-slider-fill') as HTMLElement;
  // value 40 of 0-100
  expect(Math.round((box(fill).width / box(track).width) * 100)).toBe(40);
  expect(hexOf(fill, 'background-color')).toBe(light.color.accent);
  const thumb = outer.querySelector('.t-slider-thumb') as HTMLElement;
  expect(box(thumb)).toMatchObject({ width: 20, height: 20 });
  expect(hexOf(thumb, 'background-color')).toBe(light.color.thumb);
  expect(rgbaOf(thumb, 'border-top-color')).toEqual(rgbaOfHex(light.color.borderStrong));
  expect(style(thumb, 'box-shadow')).not.toBe('none');
});

test('the value is announced as a percentage unless valueLabel is given', async () => {
  const screen = await render(Sliders);
  await expect.element(screen.getByRole('slider', { name: 'Volume' })).toHaveAttribute('aria-valuetext', '40 %');
  await screen.rerender({ withLabel: true });
  await expect.element(screen.getByRole('slider', { name: 'Volume' })).toHaveAttribute('aria-valuetext', '40 songs');
});

test('the default range is 0 to 1, a step is a twentieth of it, the announced value is still a percentage', async () => {
  const screen = await render(Sliders, { bare: true, value: 0.5 });
  const slider = screen.getByRole('slider', { name: 'Volume' });
  await expect.element(slider).toHaveAttribute('min', '0');
  await expect.element(slider).toHaveAttribute('max', '1');
  await expect.element(slider).toHaveAttribute('aria-valuetext', '50 %');
  slider.element().focus();
  await userEvent.keyboard('{ArrowRight}');
  await expect.element(slider).toHaveValue('0.55');
  await expect.element(slider).toHaveAttribute('aria-valuetext', '55 %');
  await userEvent.keyboard('{PageUp}');
  await expect.element(slider).toHaveValue('0.65');
  await userEvent.keyboard('{End}');
  await expect.element(slider).toHaveValue('1');
});

test('arrows move by step, Home and End to the ends, PageUp/PageDown by a tenth', async () => {
  const screen = await render(Sliders);
  const slider = screen.getByRole('slider', { name: 'Volume' });
  slider.element().focus();
  await userEvent.keyboard('{ArrowRight}');
  await expect.element(slider).toHaveValue('45');
  await userEvent.keyboard('{ArrowLeft}{ArrowLeft}');
  await expect.element(slider).toHaveValue('35');
  await userEvent.keyboard('{PageUp}');
  await expect.element(slider).toHaveValue('45');
  await userEvent.keyboard('{PageDown}');
  await expect.element(slider).toHaveValue('35');
  await userEvent.keyboard('{Home}');
  await expect.element(slider).toHaveValue('0');
  await userEvent.keyboard('{End}');
  await expect.element(slider).toHaveValue('100');
});

test('G14: right to left, ArrowLeft increases and ArrowRight decreases, with input and change events', async () => {
  const events: string[] = [];
  const screen = await render(Sliders, { dir: 'rtl', record: (name: string) => events.push(name) });
  const slider = screen.getByRole('slider', { name: 'Volume' });
  slider.element().focus();
  await userEvent.keyboard('{ArrowLeft}');
  await expect.element(slider).toHaveValue('45');
  expect(events).toEqual(['input', 'change']);
  await userEvent.keyboard('{ArrowRight}{ArrowRight}');
  await expect.element(slider).toHaveValue('35');
  await userEvent.keyboard('{ArrowLeft}');
  await expect.element(slider).toHaveValue('40');
});

test('PageUp and PageDown send input and change, as the arrows do; nothing at an end', async () => {
  const events: string[] = [];
  const screen = await render(Sliders, { record: (name: string) => events.push(name) });
  const slider = screen.getByRole('slider', { name: 'Volume' });
  slider.element().focus();
  await userEvent.keyboard('{PageUp}');
  await expect.element(slider).toHaveValue('50');
  expect(events).toEqual(['input', 'change']);
  await userEvent.keyboard('{End}');
  events.length = 0;
  await userEvent.keyboard('{PageUp}');
  await expect.element(slider).toHaveValue('100');
  expect(events).toEqual([]);
});

test('PageUp and PageDown move by a tenth, or by a step when a step is bigger', async () => {
  const screen = await render(Sliders, { value: 0, step: 25 });
  const slider = screen.getByRole('slider', { name: 'Volume' });
  slider.element().focus();
  await userEvent.keyboard('{PageUp}');
  await expect.element(slider).toHaveValue('25');
  await userEvent.keyboard('{PageUp}{PageUp}');
  await expect.element(slider).toHaveValue('75');
  await userEvent.keyboard('{PageDown}');
  await expect.element(slider).toHaveValue('50');
});

test('PageUp and PageDown with a modifier are left to the browser, as the arrows are', async () => {
  const screen = await render(Sliders, { value: 40 });
  const slider = screen.getByRole('slider', { name: 'Volume' });
  const input = slider.element();
  input.focus();
  for (const modifier of ['ctrlKey', 'metaKey', 'altKey', 'shiftKey']) {
    for (const key of ['PageUp', 'PageDown']) {
      const event = new KeyboardEvent('keydown', { key, [modifier]: true, bubbles: true, cancelable: true });
      input.dispatchEvent(event);
      expect(event.defaultPrevented, `${modifier} ${key}`).toBe(false);
    }
  }
  await expect.element(slider).toHaveValue('40');
});

test('a disabled slider is dimmed and not focusable', async () => {
  const screen = await render(Sliders, { disabled: true });
  const slider = screen.getByRole('slider', { name: 'Volume' });
  await expect.element(slider).toBeDisabled();
  const outer = slider.element().closest('.t-slider') as HTMLElement;
  expect(style(outer, 'opacity')).toBe('0.38');
});

test('focus shows a ring around the thumb', async () => {
  const screen = await render(Sliders);
  const slider = screen.getByRole('slider', { name: 'Volume' });
  const thumb = slider.element().closest('.t-slider')?.querySelector('.t-slider-thumb') as HTMLElement;
  expect(style(thumb, 'outline-style')).toBe('none');
  slider.element().focus();
  expect(style(thumb, 'outline-style')).toBe('solid');
});

test('right to left, the fill grows from the end', async () => {
  const screen = await render(Sliders, { dir: 'rtl' });
  const slider = screen.getByRole('slider', { name: 'Volume' }).element();
  const outer = slider.closest('.t-slider') as HTMLElement;
  const track = outer.querySelector('.t-slider-track') as HTMLElement;
  const fill = outer.querySelector('.t-slider-fill') as HTMLElement;
  // the fill's right edge meets the track's right edge (it grows from the visual end in RTL)
  expect(Math.round(box(track).right - box(fill).right)).toBe(0);
  expect(Math.round(box(fill).left - box(track).left)).toBeGreaterThan(0);
});

test('a press inside a scroller fires change after input, as outside one', async () => {
  const events: string[] = [];
  const record = (name: string) => events.push(name);
  const screen = await render(Sliders, { record });
  const slider = screen.getByRole('slider', { name: 'Volume' });
  await slider.click({ position: { x: 250, y: 20 } });
  expect(events).toEqual(['input', 'change']);
});
