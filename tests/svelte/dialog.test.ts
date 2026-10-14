// Dialog (DESIGN.md, Dialog; G5, G6, G8, G13): a native <dialog> shown with showModal, fading and growing from 0.98
// over base (instant under reduced motion); focus trapped, initial focus on Dialog.Close unless an action marks its
// own autofocus, restored to the trigger on close; Escape and a press on the scrim close unless dismissible={false}
// (Dialog.Close still does); alert gives it role="alertdialog".
import { flushSync } from 'svelte';
import { afterEach, beforeEach, expect, test } from 'vitest';
import { commands, page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light, radius } from '../../packages/core/src/tokens.ts';
import Dialogs from './fixtures/Dialogs.svelte';
import Nested from './fixtures/Nested.svelte';
import { pressScrim, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const content = (screen: { getByTestId: (id: string) => { element: () => Element } }) =>
  screen.getByTestId('content').element() as HTMLDialogElement;

beforeEach(async () => {
  await page.viewport(800, 600);
});

afterEach(async () => {
  await commands.emulateMedia({ reducedMotion: null });
});

test('opens on its trigger, named and described, closes on Cancel, focus back on the trigger', async () => {
  const screen = await render(Dialogs);
  const trigger = screen.getByRole('button', { name: 'Delete photo' }).element() as HTMLElement;
  // a real click, so the browser focuses the trigger first: showModal() remembers it to restore it later
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  const dialog = content(screen);
  expect(dialog.open).toBe(true);
  expect(dialog.getAttribute('role')).toBeNull();
  expect(screen.getByRole('dialog', { name: 'Delete this photo?' }).elements()).toHaveLength(1);
  expect(dialog.getAttribute('aria-describedby')).toBe(screen.getByText('This cannot be undone.').element().id);
  await screen.getByRole('button', { name: 'Cancel' }).click();
  expect(dialog.open).toBe(false);
  expect(document.activeElement).toBe(trigger);
});

test('alert gives it role="alertdialog"', async () => {
  const screen = await render(Dialogs, { alert: true });
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  expect(screen.getByRole('alertdialog').elements()).toHaveLength(1);
});

test('on a tall phone it is centred both ways (margin: auto in the top layer), as in Flutter', async () => {
  await page.viewport(390, 844);
  const screen = await render(Dialogs);
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  const box = content(screen).getBoundingClientRect();
  expect(box.left + box.width / 2).toBeCloseTo(195, 0);
  expect(box.top + box.height / 2).toBeCloseTo(422, 0);
});

test('spec values: at most 420 wide (560 for size lg), radius-lg, padding-24, surface, shadow-lg, the scrim', async () => {
  const screen = await render(Dialogs);
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  const dialog = content(screen);
  expect(style(dialog, 'max-width')).toBe('420px');
  expect(style(dialog, 'border-top-left-radius')).toBe(`${String(radius.lg)}px`);
  expect(style(dialog, 'padding-top')).toBe('24px');
  expect(rgbaOf(dialog, 'background-color')).toEqual(rgbaOfHex(light.color.surface));
  expect(rgbaOf(dialog, 'background-color', '::backdrop')).toEqual(rgbaOfHex(light.color.scrim));
  const title = screen.getByText('Delete this photo?').element();
  expect(style(title, 'font-size')).toBe('22px');
  const description = screen.getByText('This cannot be undone.').element();
  expect(rgbaOf(description, 'color')).toEqual(rgbaOfHex(light.color.textMuted));
  await screen.getByRole('button', { name: 'Cancel' }).click();
  await screen.rerender({ size: 'lg' });
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  expect(style(content(screen), 'max-width')).toBe('560px');
});

test('fades and grows in; at once under reduced motion', async () => {
  const screen = await render(Dialogs);
  const trigger = screen.getByRole('button', { name: 'Delete photo' }).element() as HTMLElement;
  trigger.click();
  flushSync();
  expect(content(screen).getAnimations().length).toBeGreaterThan(0);
  await expect.element(content(screen)).toHaveStyle({ opacity: '1' });
  await screen.getByRole('button', { name: 'Cancel' }).click();
  // the close transition, started under normal motion, must be over before reduced motion is asked below
  await Promise.allSettled(
    content(screen)
      .getAnimations()
      .map((animation) => animation.finished),
  );
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  trigger.click();
  flushSync();
  expect(content(screen).getAnimations()).toEqual([]);
  expect(style(content(screen), 'opacity')).toBe('1');
});

test('initial focus on Cancel, the least destructive action; an autofocus action overrides it', async () => {
  const screen = await render(Dialogs);
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  await expect.element(screen.getByRole('button', { name: 'Cancel' })).toHaveFocus();
  await screen.getByRole('button', { name: 'Cancel' }).click();
  await screen.rerender({ autofocusPrimary: true });
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  await expect.element(screen.getByRole('button', { name: 'Delete' })).toHaveFocus();
});

test('focus is trapped: Tab and Shift+Tab cycle between Cancel and Delete only', async () => {
  const screen = await render(Dialogs);
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  await expect.element(screen.getByRole('button', { name: 'Cancel' })).toHaveFocus();
  await userEvent.tab();
  await expect.element(screen.getByRole('button', { name: 'Delete' })).toHaveFocus();
  await userEvent.tab();
  await expect.element(screen.getByRole('button', { name: 'Cancel' })).toHaveFocus();
  await userEvent.tab({ shift: true });
  await expect.element(screen.getByRole('button', { name: 'Delete' })).toHaveFocus();
});

test('Escape and a press on the scrim close it; a press inside does not', async () => {
  const screen = await render(Dialogs);
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  const dialog = content(screen);
  dialog.dispatchEvent(
    new MouseEvent('click', {
      bubbles: true,
      clientX: dialog.getBoundingClientRect().left + 10,
      clientY: dialog.getBoundingClientRect().top + 10,
    }),
  );
  flushSync();
  expect(dialog.open).toBe(true);
  pressScrim(dialog);
  flushSync();
  expect(dialog.open).toBe(false);
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  await userEvent.keyboard('{Escape}');
  expect(content(screen).open).toBe(false);
});

test('dismissible={false}: Escape and the scrim do nothing, but Cancel still closes it', async () => {
  const screen = await render(Dialogs, { dismissible: false });
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  const dialog = content(screen);
  await userEvent.keyboard('{Escape}');
  expect(dialog.open).toBe(true);
  pressScrim(dialog);
  flushSync();
  expect(dialog.open).toBe(true);
  await screen.getByRole('button', { name: 'Cancel' }).click();
  expect(dialog.open).toBe(false);
});

test('dismissible={false}: closedby="none", and a native cancel (a close request the browser makes itself) is prevented', async () => {
  const screen = await render(Dialogs, { dismissible: false });
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  const dialog = content(screen);
  expect(dialog.getAttribute('closedby')).toBe('none');
  const cancel = new Event('cancel', { cancelable: true });
  dialog.dispatchEvent(cancel);
  expect(cancel.defaultPrevented).toBe(true);
});

test('dismissible: a native cancel is not prevented', async () => {
  const screen = await render(Dialogs);
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  const dialog = content(screen);
  expect(dialog.hasAttribute('closedby')).toBe(false);
  const cancel = new Event('cancel', { cancelable: true });
  dialog.dispatchEvent(cancel);
  expect(cancel.defaultPrevented).toBe(false);
});

test('closed, it takes no press and is not displayed (its own display rule must not beat the closed state)', async () => {
  const screen = await render(Dialogs);
  const dialog = content(screen);
  expect(dialog.open).toBe(false);
  expect(style(dialog, 'display')).toBe('none');
  expect(document.elementFromPoint(window.innerWidth / 2, window.innerHeight / 2)).not.toBe(dialog);
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  await screen.getByRole('button', { name: 'Cancel' }).click();
  await expect.poll(() => style(dialog, 'display')).toBe('none');
});

test('aria-describedby and aria-labelledby point only at a description and a title that are rendered', async () => {
  const bare = await render(Nested, { kind: 'dialog', withTitle: false });
  expect(content(bare).hasAttribute('aria-describedby')).toBe(false);
  expect(content(bare).hasAttribute('aria-labelledby')).toBe(false);
  await bare.unmount();
  const full = await render(Nested, { kind: 'dialog', withDescription: true });
  const dialog = content(full);
  expect(dialog.getAttribute('aria-describedby')).toBe(full.getByText('Some detail.').element().id);
  expect(dialog.getAttribute('aria-labelledby')).toBe(full.getByText('Outer dialog').element().id);
});

for (const key of ['{Enter}', ' ']) {
  test(`pressing ${key === ' ' ? 'Space' : 'Enter'} on a button inside does not dismiss it (a keyboard click has no position)`, async () => {
    const screen = await render(Nested, { kind: 'dialog' });
    (screen.getByRole('button', { name: 'Notify' }).element() as HTMLElement).focus();
    await userEvent.keyboard(key);
    await expect.element(screen.getByRole('status')).toBeVisible();
    expect(content(screen).open).toBe(true);
  });
}

test('a select sheet on a phone, inside it: choosing an option leaves the dialog open', async () => {
  await page.viewport(390, 700);
  const screen = await render(Nested, { kind: 'dialog' });
  await screen.getByRole('combobox', { name: 'Country' }).click();
  await screen.getByRole('option', { name: 'Germany' }).click();
  expect(content(screen).open).toBe(true);
});

test('a sheet inside it: a press on a button in the sheet leaves the dialog open', async () => {
  const screen = await render(Nested, { kind: 'dialog' });
  await screen.getByRole('button', { name: 'Open sheet' }).click();
  await screen.getByRole('button', { name: 'In sheet' }).click();
  expect(content(screen).open).toBe(true);
});
