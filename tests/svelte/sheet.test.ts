// Sheet (DESIGN.md, Sheet; G5, G6, G8, G13): a native <dialog> sliding over duration-sheet with easing-emphasized
// (instant under reduced motion); at most tablet wide, top corners radius-lg, the handle, surface or glass; the side
// variant 400 wide, full height, from the end edge; Escape, the scrim and a drag down past a third of its height (or
// a fling, on touch only) close it; focus trapped and restored.
import { flushSync } from 'svelte';
import { afterEach, beforeEach, expect, test } from 'vitest';
import { commands, page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { breakpoint, radius, space } from '../../packages/core/src/tokens.ts';
import Nested from './fixtures/Nested.svelte';
import Sheets from './fixtures/Sheets.svelte';
import { pressScrim } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const content = (screen: { getByTestId: (id: string) => { element: () => Element } }) =>
  screen.getByTestId('content').element() as HTMLDialogElement;

function pointer(handle: Element, type: string, clientY: number, pointerType = 'touch') {
  handle.dispatchEvent(new PointerEvent(type, { pointerId: 1, clientY, pointerType, bubbles: true }));
}

beforeEach(async () => {
  await page.viewport(390, 700);
});

afterEach(async () => {
  await commands.emulateMedia({ reducedMotion: null });
});

test('opens on its button, named by its title, closes on Done, focus back on the button', async () => {
  const screen = await render(Sheets);
  const button = screen.getByRole('button', { name: 'Share' }).element() as HTMLElement;
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = content(screen);
  expect(sheet.open).toBe(true);
  expect(screen.getByRole('dialog', { name: 'Share album' }).elements()).toHaveLength(1);
  await screen.getByRole('button', { name: 'Done' }).click();
  expect(sheet.open).toBe(false);
  expect(document.activeElement).toBe(button);
});

test('bottom: at most tablet wide, top corners radius-lg, surface with a hairline and shadow-lg', async () => {
  const screen = await render(Sheets);
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = content(screen);
  expect(style(sheet, 'max-width')).toBe(`${String(breakpoint.tablet)}px`);
  expect(style(sheet, 'border-start-start-radius')).toBe(`${String(radius.lg)}px`);
  expect(style(sheet, 'border-start-end-radius')).toBe(`${String(radius.lg)}px`);
  expect(style(sheet, 'border-end-start-radius')).toBe('0px');
  expect(style(sheet, 'box-shadow')).not.toBe('none');
  expect(sheet.classList.contains('t-glass')).toBe(false);
});

test('side="end": 400 wide, the full height, flush with the screen', async () => {
  await page.viewport(800, 700);
  const screen = await render(Sheets, { side: 'end' });
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = content(screen);
  await Promise.allSettled(sheet.getAnimations().map((animation) => animation.finished));
  const box = sheet.getBoundingClientRect();
  expect(box.width).toBeCloseTo(400, 0);
  expect(box.top).toBeCloseTo(0, 0);
  expect(box.bottom).toBeCloseTo(700, 0);
  expect(box.right).toBeCloseTo(800, 0);
});

test('side="end": on a narrow screen it stops space-16 short of the start edge, inside the window (reflow)', async () => {
  await page.viewport(320, 640);
  const screen = await render(Sheets, { side: 'end' });
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = content(screen);
  await Promise.allSettled(sheet.getAnimations().map((animation) => animation.finished));
  const box = sheet.getBoundingClientRect();
  expect(box.left).toBeCloseTo(space['16'], 0);
  expect(box.right).toBeCloseTo(320, 0);
});

test('glass when it opens from a glass surface', async () => {
  const screen = await render(Sheets, { glass: true });
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = content(screen);
  expect(sheet.classList.contains('t-glass')).toBe(true);
  expect(sheet.getAttribute('data-shadow')).toBe('lg');
});

test('slides in; at once under reduced motion', async () => {
  const screen = await render(Sheets);
  const button = screen.getByRole('button', { name: 'Share' }).element() as HTMLElement;
  button.click();
  flushSync();
  expect(content(screen).getAnimations().length).toBeGreaterThan(0);
  await expect.element(content(screen)).toHaveStyle({ translate: 'none' });
  await screen.getByRole('button', { name: 'Done' }).click();
  await Promise.allSettled(
    content(screen)
      .getAnimations()
      .map((animation) => animation.finished),
  );
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  button.click();
  flushSync();
  expect(content(screen).getAnimations()).toEqual([]);
});

test('closed, it takes no press and is not displayed', async () => {
  const screen = await render(Sheets);
  const sheet = content(screen);
  expect(style(sheet, 'display')).toBe('none');
  await screen.getByRole('button', { name: 'Share' }).click();
  await screen.getByRole('button', { name: 'Done' }).click();
  await expect.poll(() => style(sheet, 'display')).toBe('none');
});

test('bottom: sits against the bottom edge of the window, not the top', async () => {
  const screen = await render(Sheets);
  await screen.getByRole('button', { name: 'Share' }).click();
  await expect.poll(() => content(screen).getAnimations().length).toBe(0);
  expect(content(screen).getBoundingClientRect().bottom).toBeCloseTo(window.innerHeight, 0);
});

test('aria-labelledby points only at a title that is rendered', async () => {
  const bare = await render(Nested, { kind: 'sheet', withTitle: false });
  expect(content(bare).hasAttribute('aria-labelledby')).toBe(false);
  await bare.unmount();
  const full = await render(Nested, { kind: 'sheet' });
  expect(content(full).getAttribute('aria-labelledby')).toBe(full.getByText('Outer sheet').element().id);
});

test('Escape and a press on the scrim close it; a press inside does not', async () => {
  const screen = await render(Sheets);
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = content(screen);
  const box = sheet.getBoundingClientRect();
  sheet.dispatchEvent(new MouseEvent('click', { bubbles: true, clientX: box.left + 10, clientY: box.top + 10 }));
  flushSync();
  expect(sheet.open).toBe(true);
  pressScrim(sheet);
  flushSync();
  expect(sheet.open).toBe(false);
  await screen.getByRole('button', { name: 'Share' }).click();
  await userEvent.keyboard('{Escape}');
  expect(content(screen).open).toBe(false);
});

test('focus is trapped and restored to the button that opened it', async () => {
  const screen = await render(Sheets);
  const button = screen.getByRole('button', { name: 'Share' }).element() as HTMLElement;
  await screen.getByRole('button', { name: 'Share' }).click();
  await userEvent.tab();
  await expect.element(screen.getByRole('button', { name: 'Done' })).toHaveFocus();
  await userEvent.tab();
  // one focusable inside: Tab wraps back to it, never reaching the page behind
  await expect.element(screen.getByRole('button', { name: 'Done' })).toHaveFocus();
  await userEvent.keyboard('{Escape}');
  expect(document.activeElement).toBe(button);
});

test('a drag down past a third of its height closes it; a short drag snaps back', async () => {
  const screen = await render(Sheets);
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = content(screen);
  const handle = sheet.querySelector('.t-sheet-handle-row') as Element;
  const height = sheet.getBoundingClientRect().height;
  pointer(handle, 'pointerdown', 0);
  pointer(handle, 'pointermove', height * 0.1);
  pointer(handle, 'pointerup', height * 0.1);
  expect(sheet.open).toBe(true);
  pointer(handle, 'pointerdown', 0);
  pointer(handle, 'pointermove', height * 0.5);
  pointer(handle, 'pointerup', height * 0.5);
  expect(sheet.open).toBe(false);
});

test('a fling closes it even under a third of its height', async () => {
  const screen = await render(Sheets);
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = content(screen);
  const handle = sheet.querySelector('.t-sheet-handle-row') as Element;
  const height = sheet.getBoundingClientRect().height;
  pointer(handle, 'pointerdown', 0);
  pointer(handle, 'pointermove', height * 0.2);
  pointer(handle, 'pointerup', height * 0.2);
  expect(sheet.open).toBe(false);
});

test('a mouse does not drag the handle closed', async () => {
  const screen = await render(Sheets);
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = content(screen);
  const handle = sheet.querySelector('.t-sheet-handle-row') as Element;
  const height = sheet.getBoundingClientRect().height;
  pointer(handle, 'pointerdown', 0, 'mouse');
  pointer(handle, 'pointermove', height, 'mouse');
  pointer(handle, 'pointerup', height, 'mouse');
  expect(sheet.open).toBe(true);
});

test('pressing Enter on a button inside does not dismiss it (a keyboard click has no position)', async () => {
  const screen = await render(Nested, { kind: 'sheet' });
  (screen.getByRole('button', { name: 'Notify' }).element() as HTMLElement).focus();
  await userEvent.keyboard('{Enter}');
  await expect.element(screen.getByRole('status')).toBeVisible();
  expect(content(screen).open).toBe(true);
});
