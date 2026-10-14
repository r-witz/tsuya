// Top layer (G8): a dialog or a popover above everything, even a bar with the highest z-index, where it is
// in the document: it keeps the accent of the region that opened it.
import { expect, test } from 'vitest';
import { render } from 'vitest-browser-svelte';

import TopLayer from './fixtures/TopLayer.svelte';
import { hexOf } from './support.ts';

// what is on screen at the centre of an element
function onTop(element: Element): Element | null {
  const { left, top, width, height } = element.getBoundingClientRect();
  return document.elementFromPoint(left + width / 2, top + height / 2);
}

test('a modal dialog: above the bar, in place, with the accent of its region', async () => {
  const screen = await render(TopLayer, { dialog: true });
  const dialog = screen.getByTestId('dialog').element() as HTMLDialogElement;
  expect(dialog.matches(':modal')).toBe(true);
  expect(dialog.parentElement).toBe(screen.getByTestId('region').element());
  expect(dialog.contains(onTop(dialog))).toBe(true);
  expect(hexOf(screen.getByTestId('in-dialog').element())).toBe('#7A3FB0');
  await screen.rerender({ dialog: false });
  expect(document.querySelector('dialog')).toBeNull();
});

test('a dialog that is not modal', async () => {
  const screen = await render(TopLayer, { dialog: true, modal: false });
  const dialog = screen.getByTestId('dialog').element() as HTMLDialogElement;
  expect(dialog.open).toBe(true);
  expect(dialog.matches(':modal')).toBe(false);
});

test('a popover: shown above the bar, in place, closed when it goes', async () => {
  const screen = await render(TopLayer, { popover: true });
  const popover = screen.getByTestId('popover').element() as HTMLElement;
  expect(popover.matches(':popover-open')).toBe(true);
  expect(popover.popover).toBe('manual');
  expect(popover.contains(onTop(popover))).toBe(true);
  expect(hexOf(screen.getByTestId('in-popover').element())).toBe('#7A3FB0');
  await screen.rerender({ popover: false });
  expect(popover.isConnected).toBe(false);
});
