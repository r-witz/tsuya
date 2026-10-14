// Combobox (DESIGN.md, Combobox; G5, G6, G8): a text field that filters a listbox anchored under it, the keyboard of
// an editable combobox with list autocomplete, Escape that closes then clears, strict and free text, the loading and
// empty states, the number of results announced, and the form value.
import { beforeEach, expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { TYPEAHEAD_TIMEOUT } from '../../packages/core/src/primitives/typeahead.ts';
import Comboboxes from './fixtures/Comboboxes.svelte';

const box = (element: Element) => element.getBoundingClientRect();
const formValue = (form: Element) => new FormData(form as HTMLFormElement).get('city');

beforeEach(async () => {
  await page.viewport(800, 600);
});

async function setup(props: Record<string, unknown> = {}) {
  const screen = await render(Comboboxes, props);
  const input = screen.getByRole('combobox', { name: 'City' });
  const options = () =>
    screen
      .getByRole('option')
      .elements()
      .map((option) => option.textContent.trim());
  const active = () =>
    document.getElementById(input.element().getAttribute('aria-activedescendant') ?? '')?.textContent.trim();
  return { screen, input, options, active, form: screen.getByTestId('form').element() };
}

test('a text field named by its label, collapsed, with list autocomplete and no browser suggestions', async () => {
  const { input } = await setup();
  await expect.element(input).toHaveAttribute('aria-expanded', 'false');
  await expect.element(input).toHaveAttribute('aria-autocomplete', 'list');
  await expect.element(input).toHaveAttribute('autocomplete', 'off');
  expect(box(input.element().closest('.t-text-input') as Element).height).toBe(44);
});

test('typing filters and opens the list under the field; arrows move, Enter chooses', async () => {
  const { screen, input, options, active, form } = await setup();
  await input.click();
  await userEvent.keyboard('l');
  await expect.element(input).toHaveAttribute('aria-expanded', 'true');
  expect(options()).toEqual(['Lyon', 'Lille', 'Marseille', 'Toulouse']);
  // no option is active until an arrow moves
  expect(input.element().getAttribute('aria-activedescendant')).toBeNull();
  const listbox = screen.getByRole('listbox', { name: 'City' }).element();
  const field = input.element().closest('.t-text-input') as Element;
  const panel = listbox.closest('.t-panel') as Element;
  expect(box(panel).top).toBe(box(field).bottom + 4);
  expect(box(panel).left).toBe(box(field).left);
  expect(box(panel).width).toBe(320);
  await userEvent.keyboard('{ArrowDown}{ArrowDown}');
  expect(active()).toBe('Lille');
  await userEvent.keyboard('{ArrowUp}');
  expect(active()).toBe('Lyon');
  await userEvent.keyboard('{Enter}');
  await expect.element(input).toHaveAttribute('aria-expanded', 'false');
  await expect.element(input).toHaveValue('Lyon');
  expect(formValue(form)).toBe('LYO');
  // reopened, every option shows, the chosen one active and ticked
  await userEvent.keyboard('{ArrowDown}');
  expect(options()).toHaveLength(7);
  expect(active()).toBe('Lyon');
  await expect.element(screen.getByRole('option', { name: 'Lyon' })).toHaveAttribute('aria-selected', 'true');
});

test('Enter that confirms an IME composition does not choose the active option', async () => {
  const { input, active, form } = await setup();
  await input.click();
  await userEvent.keyboard('l{ArrowDown}');
  expect(active()).toBe('Lyon');
  const enter = new KeyboardEvent('keydown', { key: 'Enter', isComposing: true, bubbles: true, cancelable: true });
  input.element().dispatchEvent(enter);
  expect(enter.defaultPrevented).toBe(false);
  await expect.element(input).toHaveAttribute('aria-expanded', 'true');
  expect(formValue(form)).toBe('');
  await userEvent.keyboard('{Enter}');
  expect(formValue(form)).toBe('LYO');
});

test('a press opens every option; a press on one chooses it and the focus stays in the field', async () => {
  const { screen, input, options, form } = await setup();
  await input.click();
  await expect.element(input).toHaveAttribute('aria-expanded', 'true');
  expect(options()).toHaveLength(7);
  await screen.getByRole('option', { name: 'Nantes' }).click();
  await expect.element(input).toHaveValue('Nantes');
  await expect.element(input).toHaveFocus();
  await expect.element(input).toHaveAttribute('aria-expanded', 'false');
  expect(formValue(form)).toBe('NAN');
});

test('options that change under the active one leave none active: down goes to the first again', async () => {
  const { screen, input, active, form } = await setup();
  await input.click();
  await userEvent.keyboard('l{ArrowDown}{ArrowDown}{ArrowDown}{ArrowDown}');
  expect(active()).toBe('Toulouse');
  // results from a server: two are left
  await screen.rerender({
    options: [
      { value: 'LYO', label: 'Lyon' },
      { value: 'LIL', label: 'Lille' },
    ],
  });
  expect(input.element().getAttribute('aria-activedescendant')).toBeNull();
  await userEvent.keyboard('{ArrowDown}');
  expect(active()).toBe('Lyon');
  await userEvent.keyboard('{Enter}');
  expect(formValue(form)).toBe('LYO');
});

test('Escape closes, then clears the text and the value', async () => {
  const { input, form } = await setup({ value: 'PAR' });
  await expect.element(input).toHaveValue('Paris');
  await input.click();
  await userEvent.keyboard('{End}x');
  await expect.element(input).toHaveAttribute('aria-expanded', 'true');
  await userEvent.keyboard('{Escape}');
  await expect.element(input).toHaveAttribute('aria-expanded', 'false');
  await expect.element(input).toHaveValue('Parisx');
  await userEvent.keyboard('{Escape}');
  await expect.element(input).toHaveValue('');
  expect(formValue(form)).toBe('');
});

test('strict: when focus leaves, a text that names an option chooses it, any other goes back', async () => {
  const { input, form } = await setup({ value: 'PAR' });
  await input.click();
  await userEvent.clear(input);
  await userEvent.keyboard('nowhere');
  await userEvent.tab();
  await expect.element(input).toHaveValue('Paris');
  expect(formValue(form)).toBe('PAR');
  await input.click();
  await userEvent.clear(input);
  await userEvent.keyboard('lille');
  await userEvent.tab();
  await expect.element(input).toHaveValue('Lille');
  expect(formValue(form)).toBe('LIL');
  await input.click();
  await userEvent.clear(input);
  await userEvent.tab();
  await expect.element(input).toHaveValue('');
  expect(formValue(form)).toBe('');
});

test('free text stays, and the form gets it while no option is chosen', async () => {
  const { input, form } = await setup({ freeText: true, value: 'PAR' });
  await input.click();
  await userEvent.clear(input);
  await userEvent.keyboard('Atlantis');
  await userEvent.tab();
  await expect.element(input).toHaveValue('Atlantis');
  expect(formValue(form)).toBe('Atlantis');
});

test('loading shows a spinner and the label; no match shows noResults; the count is announced', async () => {
  const { screen, input, options } = await setup();
  const live = () => document.querySelector('[data-tsuya-live="polite"]')?.textContent;
  await input.click();
  await userEvent.keyboard('l');
  await expect.poll(live, { timeout: TYPEAHEAD_TIMEOUT + 1000 }).toBe('4 results');
  await userEvent.keyboard('zz');
  await expect.element(screen.getByText('No results')).toBeVisible();
  expect(options()).toEqual([]);
  await expect.poll(live, { timeout: TYPEAHEAD_TIMEOUT + 1000 }).toBe('No results');
  await screen.rerender({ loading: true });
  await expect.element(screen.getByText('Loading')).toBeVisible();
  expect(screen.getByRole('listbox').element().querySelector('[role="option"]')).toBeNull();
  await expect.poll(live, { timeout: TYPEAHEAD_TIMEOUT + 1000 }).toBe('Loading');
});

test('options from a server, already filtered, keep the label of the value', async () => {
  const { screen, input, form } = await setup({ value: 'PAR', options: [{ value: 'PAR', label: 'Paris' }] });
  await expect.element(input).toHaveValue('Paris');
  await screen.rerender({ options: [{ value: 'LYO', label: 'Lyon' }] });
  await input.click();
  await userEvent.keyboard('{End}x');
  await userEvent.tab();
  await expect.element(input).toHaveValue('Paris');
  expect(formValue(form)).toBe('PAR');
});

test('disabled, it does not open; an error marks it invalid', async () => {
  const { input } = await setup({ disabled: true, error: 'Choose a city' });
  await expect.element(input).toBeDisabled();
  await expect.element(input).toHaveAttribute('aria-invalid', 'true');
  await expect.element(input).toHaveAccessibleDescription('Choose a city');
  await expect.element(input).toHaveAttribute('aria-expanded', 'false');
});
