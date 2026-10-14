// Dismissable layer (G6, G8): Escape closes the topmost layer only, a press outside closes the layers it is
// outside of, focus leaving closes a non-modal layer, and a layer in a modal dialog closes before the dialog.
import { expect, test } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import Layers from './fixtures/Layers.svelte';

async function open() {
  const entries: string[] = [];
  const screen = await render(Layers, { log: (entry: string) => entries.push(entry) });
  await screen.getByRole('button', { name: 'Outer' }).click();
  await screen.getByRole('button', { name: 'Inner' }).click();
  await expect.element(screen.getByTestId('inner')).toBeInTheDocument();
  return { screen, entries };
}

test('Escape closes the topmost layer, then the next', async () => {
  const { screen, entries } = await open();
  await userEvent.keyboard('{Escape}');
  await expect.element(screen.getByTestId('inner')).not.toBeInTheDocument();
  await expect.element(screen.getByTestId('outer')).toBeInTheDocument();
  await userEvent.keyboard('{Escape}');
  await expect.element(screen.getByTestId('outer')).not.toBeInTheDocument();
  expect(entries).toEqual(['inner: escape', 'outer: escape']);
});

test('a press in a layer closes the layers above it; a press outside closes them all', async () => {
  const { screen, entries } = await open();
  await screen.getByText('Outer layer').click();
  await expect.element(screen.getByTestId('inner')).not.toBeInTheDocument();
  await screen.getByRole('button', { name: 'Inner' }).click();
  await screen.getByRole('button', { name: 'In inner' }).click();
  await expect.element(screen.getByTestId('inner')).toBeInTheDocument();
  await screen.getByRole('button', { name: 'Elsewhere' }).click();
  await expect.element(screen.getByTestId('outer')).not.toBeInTheDocument();
  expect(entries).toEqual(['inner: outside', 'inner: outside', 'outer: outside']);
});

test('the trigger counts as inside: it closes its own layer by its click', async () => {
  const { screen, entries } = await open();
  await screen.getByRole('button', { name: 'Inner' }).click();
  await expect.element(screen.getByTestId('inner')).not.toBeInTheDocument();
  await expect.element(screen.getByTestId('outer')).toBeInTheDocument();
  expect(entries).toEqual([]);
});

test('focus that leaves a layer closes it', async () => {
  const { screen, entries } = await open();
  screen.getByRole('button', { name: 'In inner' }).element().focus();
  screen.getByRole('button', { name: 'Elsewhere' }).element().focus();
  await expect.element(screen.getByTestId('outer')).not.toBeInTheDocument();
  expect(entries).toEqual(['inner: focus', 'outer: focus']);
});

test('in a modal dialog, Escape closes the layer first, then the dialog', async () => {
  const entries: string[] = [];
  const screen = await render(Layers, { log: (entry: string) => entries.push(entry) });
  await screen.getByRole('button', { name: 'Dialog' }).click();
  const dialog = screen.getByRole('dialog', { name: 'Settings' });
  await expect.element(dialog).toBeInTheDocument();
  await screen.getByRole('button', { name: 'Menu' }).click();
  await expect.element(screen.getByTestId('menu')).toBeInTheDocument();
  await userEvent.keyboard('{Escape}');
  await expect.element(screen.getByTestId('menu')).not.toBeInTheDocument();
  expect((dialog.element() as HTMLDialogElement).open).toBe(true);
  await userEvent.keyboard('{Escape}');
  await expect.element(dialog).not.toBeInTheDocument();
  expect(entries).toEqual(['menu: escape', 'dialog: escape']);
});
