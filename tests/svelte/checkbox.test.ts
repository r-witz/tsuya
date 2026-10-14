// Checkbox (DESIGN.md, Checkbox; G5, G6): values, checked and indeterminate, keyboard, disabled.
import { expect, test } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Checkboxes from './fixtures/Checkboxes.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('values: the row, the box and its boundary, the gap to the label', async () => {
  const screen = await render(Checkboxes);
  const row = screen.getByText('Remember me').element().closest('label') as HTMLElement;
  const square = row.querySelector('.t-checkbox-box') as HTMLElement;
  const frame = row.querySelector('.t-checkbox-frame') as HTMLElement;
  expect(box(row).height).toBeGreaterThanOrEqual(44);
  expect(box(square)).toMatchObject({ width: 20, height: 20 });
  // Firefox rounds the fractional border-width when it reports it back, Chromium keeps it exact
  expect(parseFloat(style(frame, 'border-top-width'))).toBeGreaterThanOrEqual(1);
  expect(parseFloat(style(frame, 'border-top-width'))).toBeLessThanOrEqual(1.5);
  expect(rgbaOf(frame, 'border-top-color')).toEqual(rgbaOfHex(light.color.borderStrong));
  expect(style(frame, 'border-top-left-radius')).toBe('6px');
  const text = row.querySelector('.t-checkbox-text') as HTMLElement;
  expect(box(text).left - box(square).right).toBe(12);
  expect(hexOf(text)).toBe(light.color.text);
});

test('a press checks it; checked fills the box with the accent and an on-accent tick', async () => {
  const screen = await render(Checkboxes);
  const checkbox = screen.getByRole('checkbox', { name: 'Remember me' });
  await expect.element(checkbox).not.toBeChecked();
  await checkbox.click();
  await expect.element(checkbox).toBeChecked();
  const frame = screen.container.querySelector('.t-checkbox-frame') as HTMLElement;
  expect(hexOf(frame, 'background-color')).toBe(light.color.accent);
  const tick = frame.querySelector('svg') as SVGElement;
  expect(tick).toBeTruthy();
  expect(hexOf(tick)).toBe(light.color.onAccent);
  // 2 px on screen, at whatever size the glyph is drawn
  const stroke = tick.querySelector('path') as SVGPathElement;
  expect([style(stroke, 'stroke-width'), style(stroke, 'vector-effect')]).toEqual(['2px', 'non-scaling-stroke']);
  // the label itself toggles it too
  await screen.getByText('Remember me').click();
  await expect.element(checkbox).not.toBeChecked();
});

test('Space toggles it from the keyboard', async () => {
  const screen = await render(Checkboxes);
  const checkbox = screen.getByRole('checkbox', { name: 'Remember me' });
  checkbox.element().focus();
  await userEvent.keyboard(' ');
  await expect.element(checkbox).toBeChecked();
});

test('indeterminate shows a dash and is read as mixed, filled like checked', async () => {
  const screen = await render(Checkboxes, { indeterminate: true });
  const checkbox = screen.getByRole('checkbox', { name: 'Remember me' });
  expect((checkbox.element() as HTMLInputElement).indeterminate).toBe(true);
  const frame = screen.container.querySelector('.t-checkbox-frame') as HTMLElement;
  expect(hexOf(frame, 'background-color')).toBe(light.color.accent);
});

test('G5, G13: a press on an indeterminate checkbox checks it and the dash goes, as the input says', async () => {
  const screen = await render(Checkboxes, { indeterminate: true });
  const checkbox = screen.getByRole('checkbox', { name: 'Remember me' });
  const input = checkbox.element() as HTMLInputElement;
  const frame = screen.container.querySelector('.t-checkbox-frame') as HTMLElement;
  const mark = () => frame.querySelector('svg path')?.getAttribute('d');
  const dash = mark();
  expect(dash).toBeTruthy();
  await checkbox.click();
  expect(input.indeterminate).toBe(false);
  expect(input.checked).toBe(true);
  // a tick now, not the dash; the box stays filled
  expect(mark()).toBeTruthy();
  expect(mark()).not.toBe(dash);
  expect(hexOf(frame, 'background-color')).toBe(light.color.accent);
  await checkbox.click();
  expect(input.checked).toBe(false);
  expect(frame.querySelector('svg')).toBeNull();
});

test('a disabled checkbox is dimmed and not focusable', async () => {
  const screen = await render(Checkboxes, { disabled: true });
  const checkbox = screen.getByRole('checkbox', { name: 'Remember me' });
  await expect.element(checkbox).toBeDisabled();
  const row = screen.getByText('Remember me').element().closest('label') as HTMLElement;
  expect(style(row, 'opacity')).toBe('0.38');
});
