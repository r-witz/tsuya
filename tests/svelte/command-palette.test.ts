// CommandPalette (DESIGN.md, CommandPalette; G5, G6, G13): a dialog at most 560 wide near the top, a
// search field without a visible label over the commands in their groups, in the order given; typing filters with
// the first command active, the arrows move, Enter or a press runs it, closing first; Escape closes; no match shows
// noResults; the number of results is announced.
import { afterEach, beforeEach, expect, test, vi } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { space } from '../../packages/core/src/tokens.ts';
import CommandPalettes from './fixtures/CommandPalettes.svelte';

const palette = () => document.querySelector('.t-command-palette') as HTMLDialogElement;
const field = () => document.querySelector('.t-command-palette input') as HTMLInputElement;
const options = () =>
  [...document.querySelectorAll('.t-command-palette [role="option"]')].map((option) => option.textContent.trim());
const active = () => {
  const id = field().getAttribute('aria-activedescendant');
  return id ? document.getElementById(id)?.textContent.trim() : undefined;
};

beforeEach(async () => {
  await page.viewport(800, 600);
});

afterEach(async () => {
  await userEvent.keyboard('{Escape}');
});

test('a dialog named by the search label, 560 wide, near the top; the field has the focus, the first command is active', async () => {
  const screen = await render(CommandPalettes);
  await screen.getByRole('button', { name: 'Commands' }).click();
  expect(screen.getByRole('dialog', { name: 'Search' }).element()).toBe(palette());
  // the layout box: the scale it grows from does not count
  expect(palette().offsetWidth).toBe(560);
  expect(palette().offsetTop).toBe(space['64']);
  expect(document.activeElement).toBe(field());
  expect(field().getAttribute('aria-label')).toBe('Search');
  expect(field().getAttribute('role')).toBe('combobox');
  expect(field().getAttribute('aria-controls')).toBe(screen.getByRole('listbox').element().id);
  expect(active()).toBe('Open file');
});

test('the groups in the order given, each named by its heading', async () => {
  const screen = await render(CommandPalettes);
  await screen.getByRole('button', { name: 'Commands' }).click();
  const groups = screen.getByRole('group').elements();
  expect(
    groups.map(
      (group) =>
        group.getAttribute('aria-labelledby') &&
        document.getElementById(group.getAttribute('aria-labelledby') as string)?.textContent,
    ),
  ).toEqual(['Recent', 'Files', 'Settings']);
  expect(options()).toEqual(['Open file', 'New file', 'Save', 'Open file', 'Write a note', 'Change theme']);
});

test('typing filters, the first command found active; Enter closes, then runs it, focus back on the opener', async () => {
  const onselect = vi.fn();
  const screen = await render(CommandPalettes, { onselect });
  await screen.getByRole('button', { name: 'Commands' }).click();
  await userEvent.keyboard('THE');
  expect(options()).toEqual(['Change theme']);
  expect(screen.getByRole('group').elements()).toHaveLength(1);
  expect(active()).toBe('Change theme');
  await userEvent.keyboard('{Enter}');
  await expect.poll(() => onselect.mock.calls).toEqual([[{ value: 'theme', label: 'Change theme' }]]);
  expect(palette().open).toBe(false);
  expect(document.activeElement).toBe(screen.getByRole('button', { name: 'Commands' }).element());
});

test('the arrows move through the commands, past a disabled one, without wrapping', async () => {
  const screen = await render(CommandPalettes);
  await screen.getByRole('button', { name: 'Commands' }).click();
  await userEvent.keyboard('{ArrowDown}');
  expect(active()).toBe('New file');
  await userEvent.keyboard('{ArrowDown}');
  expect(active()).toBe('Open file');
  expect(field().getAttribute('aria-activedescendant')).toBe(
    document.querySelectorAll('.t-command-palette [role="option"]')[3]?.id,
  );
  await userEvent.keyboard('{ArrowUp}{ArrowUp}{ArrowUp}');
  expect(active()).toBe('Open file');
  expect(field().getAttribute('aria-activedescendant')).toBe(
    document.querySelectorAll('.t-command-palette [role="option"]')[0]?.id,
  );
});

test('a press runs a command; the pointer makes it active', async () => {
  const onselect = vi.fn();
  const screen = await render(CommandPalettes, { onselect });
  await screen.getByRole('button', { name: 'Commands' }).click();
  await screen.getByRole('option', { name: 'New file' }).hover();
  expect(active()).toBe('New file');
  await screen.getByRole('option', { name: 'New file' }).click();
  await expect.poll(() => onselect.mock.calls).toEqual([[{ value: 'new', label: 'New file' }]]);
});

test('a disabled command does not run', async () => {
  const onselect = vi.fn();
  const screen = await render(CommandPalettes, { onselect });
  await screen.getByRole('button', { name: 'Commands' }).click();
  await screen.getByRole('option', { name: 'Save' }).click({ force: true });
  expect(onselect).not.toHaveBeenCalled();
  expect(palette().open).toBe(true);
});

test('a command that moves the focus keeps it there', async () => {
  const screen = await render(CommandPalettes);
  await screen.getByRole('button', { name: 'Commands' }).click();
  await userEvent.keyboard('note{Enter}');
  await expect.poll(() => document.activeElement).toBe(screen.getByRole('textbox', { name: 'Note' }).element());
});

test('no match shows noResults; the number of results is announced once typing pauses', async () => {
  const screen = await render(CommandPalettes);
  await screen.getByRole('button', { name: 'Commands' }).click();
  // a modal makes the rest of the page inert, live regions included: the count goes to one inside the palette
  const live = () => palette().querySelector('[data-tsuya-live="polite"]')?.textContent;
  await userEvent.keyboard('file');
  await expect.poll(live).toBe('3 results');
  await userEvent.keyboard('zz');
  expect(screen.getByText('No results').elements()).toHaveLength(1);
  expect(field().getAttribute('aria-activedescendant')).toBeNull();
  await expect.poll(live).toBe('No results');
  await userEvent.keyboard('{Enter}');
  expect(palette().open).toBe(true);
});

test('opened again with an empty search, the first command is active again', async () => {
  const screen = await render(CommandPalettes);
  await screen.getByRole('button', { name: 'Commands' }).click();
  expect(active()).toBe('Open file');
  await userEvent.keyboard('{ArrowDown}');
  expect(active()).not.toBe('Open file');
  await userEvent.keyboard('{Escape}');
  await screen.getByRole('button', { name: 'Commands' }).click();
  expect(active()).toBe('Open file');
});

test('Enter that confirms an IME composition does not run a command', async () => {
  const onselect = vi.fn();
  const screen = await render(CommandPalettes, { onselect });
  await screen.getByRole('button', { name: 'Commands' }).click();
  const enter = new KeyboardEvent('keydown', { key: 'Enter', isComposing: true, bubbles: true, cancelable: true });
  field().dispatchEvent(enter);
  expect(enter.defaultPrevented).toBe(false);
  expect(onselect).not.toHaveBeenCalled();
  expect(palette().open).toBe(true);
});

test('Escape closes without running; opened again, the search starts empty', async () => {
  const onselect = vi.fn();
  const screen = await render(CommandPalettes, { onselect });
  await screen.getByRole('button', { name: 'Commands' }).click();
  await userEvent.keyboard('theme{Escape}');
  expect(palette().open).toBe(false);
  expect(onselect).not.toHaveBeenCalled();
  expect(document.activeElement).toBe(screen.getByRole('button', { name: 'Commands' }).element());
  await screen.getByRole('button', { name: 'Commands' }).click();
  expect(field().value).toBe('');
  expect(options()).toHaveLength(6);
});
