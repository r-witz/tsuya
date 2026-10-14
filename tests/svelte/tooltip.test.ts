// Tooltip (DESIGN.md, Tooltip and IconButton; G5, G6, G13): after the delay on a mouse, at once on keyboard focus,
// never on touch; it stays while the pointer is over it, Escape and a press hide it; inverted colours, caption type,
// at most 240 wide, above its trigger; it describes its trigger, or repeats an icon button's label out of the tree.
import { beforeEach, expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light, radius } from '../../packages/core/src/tokens.ts';
import Tooltips from './fixtures/Tooltips.svelte';
import { rgbaOf, rgbaOfHex } from './support.ts';

const box = (element: Element) => element.getBoundingClientRect();
const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const shown = (element: Element) => element.matches(':popover-open');
const wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

beforeEach(async () => {
  await page.viewport(800, 600);
});

test('on a mouse it shows after the delay, above its trigger, inverted, and describes it', async () => {
  const screen = await render(Tooltips);
  const trigger = screen.getByRole('button', { name: 'Copy link' }).element();
  const tip = document.getElementById(trigger.getAttribute('aria-describedby') ?? '') as HTMLElement;
  expect(tip.getAttribute('role')).toBe('tooltip');
  expect(tip.textContent.trim()).toBe('Copies the address of this page');
  await userEvent.hover(trigger);
  await wait(250);
  expect(shown(tip)).toBe(false);
  await expect.poll(() => shown(tip), { timeout: 1500 }).toBe(true);
  expect(rgbaOf(tip, 'background-color')).toEqual(rgbaOfHex(light.color.text));
  expect(rgbaOf(tip)).toEqual(rgbaOfHex(light.color.bg));
  expect(style(tip, 'border-top-left-radius')).toBe(`${String(radius.xs)}px`);
  expect([style(tip, 'padding-top'), style(tip, 'padding-left')]).toEqual(['4px', '8px']);
  expect(style(tip, 'font-size')).toBe('12px');
  expect(style(tip, 'max-width')).toBe('240px');
  expect(box(tip).bottom).toBeCloseTo(box(trigger).top - 4, 0);
  expect(box(tip).left + box(tip).width / 2).toBeCloseTo(box(trigger).left + box(trigger).width / 2, 0);
});

test('it stays while the pointer is over it, and hides when the pointer leaves both', async () => {
  const screen = await render(Tooltips);
  const trigger = screen.getByRole('button', { name: 'Copy link' }).element();
  const tip = document.getElementById(trigger.getAttribute('aria-describedby') ?? '') as HTMLElement;
  await userEvent.hover(trigger);
  await expect.poll(() => shown(tip), { timeout: 1500 }).toBe(true);
  await userEvent.hover(tip);
  await wait(400);
  expect(shown(tip)).toBe(true);
  await userEvent.hover(screen.getByRole('button', { name: 'Before' }));
  await expect.poll(() => shown(tip)).toBe(false);
});

test('keyboard focus shows it at once; Escape hides it; so does a press', async () => {
  const screen = await render(Tooltips);
  const trigger = screen.getByRole('button', { name: 'Copy link' }).element();
  const tip = document.getElementById(trigger.getAttribute('aria-describedby') ?? '') as HTMLElement;
  (screen.getByRole('button', { name: 'Before' }).element() as HTMLElement).focus();
  await userEvent.tab();
  expect(shown(tip)).toBe(true);
  await userEvent.keyboard('{Escape}');
  expect(shown(tip)).toBe(false);
  await userEvent.tab({ shift: true });
  await userEvent.tab();
  expect(shown(tip)).toBe(true);
  await userEvent.click(trigger);
  expect(shown(tip)).toBe(false);
});

test('never on touch', async () => {
  const screen = await render(Tooltips);
  const trigger = screen.getByRole('button', { name: 'Copy link' }).element();
  const tip = document.getElementById(trigger.getAttribute('aria-describedby') ?? '') as HTMLElement;
  // the mouse away from where the last test left it
  await userEvent.hover(screen.getByRole('button', { name: 'Before' }));
  trigger.dispatchEvent(new PointerEvent('pointerenter', { pointerType: 'touch' }));
  await wait(800);
  expect(shown(tip)).toBe(false);
});

test("an icon button's label shows as its tooltip, out of the accessibility tree; tooltip={false} has none", async () => {
  const screen = await render(Tooltips);
  const share = screen.getByRole('button', { name: 'Share' }).element();
  expect(share.hasAttribute('aria-describedby')).toBe(false);
  const tip = share.nextElementSibling as HTMLElement;
  expect(tip.getAttribute('role')).toBe('tooltip');
  expect(tip.getAttribute('aria-hidden')).toBe('true');
  await userEvent.hover(share);
  await expect.poll(() => shown(tip), { timeout: 1500 }).toBe(true);
  expect(tip.textContent.trim()).toBe('Share');
  const shuffle = screen.getByRole('button', { name: 'Shuffle' }).element();
  expect(shuffle.nextElementSibling?.getAttribute('role')).not.toBe('tooltip');
});

test('Escape hides a tooltip the pointer shows and goes on to the open panel', async () => {
  const screen = await render(Tooltips);
  const trigger = screen.getByRole('button', { name: 'Copy link' }).element();
  const tip = document.getElementById(trigger.getAttribute('aria-describedby') ?? '') as HTMLElement;
  await userEvent.hover(trigger);
  await expect.poll(() => shown(tip), { timeout: 1500 }).toBe(true);
  const select = screen.getByRole('combobox', { name: 'Country' });
  (select.element() as HTMLElement).focus();
  await userEvent.keyboard('{ArrowDown}');
  await expect.element(select).toHaveAttribute('aria-expanded', 'true');
  await userEvent.keyboard('{Escape}');
  expect(shown(tip)).toBe(false);
  await expect.element(select).toHaveAttribute('aria-expanded', 'false');
});

test('Escape on the control whose tooltip shows hides the tooltip only; the next one closes the panel around it', async () => {
  const screen = await render(Tooltips);
  const opener = screen.getByRole('button', { name: 'Share options' });
  (opener.element() as HTMLElement).focus();
  await userEvent.keyboard('{Enter}');
  const copy = screen.getByRole('button', { name: 'Copy' }).element();
  await expect.poll(() => document.activeElement).toBe(copy);
  const tip = copy.nextElementSibling as HTMLElement;
  await expect.poll(() => shown(tip)).toBe(true);
  const panel = copy.closest('[popover]') as HTMLElement;
  await userEvent.keyboard('{Escape}');
  expect(shown(tip)).toBe(false);
  expect(panel.matches(':popover-open')).toBe(true);
  await userEvent.keyboard('{Escape}');
  await expect.poll(() => panel.matches(':popover-open')).toBe(false);
});
