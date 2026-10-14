// Select (DESIGN.md, Select; G5, G6, G8): the trigger, the listbox panel anchored under it, the keyboard of a
// select-only combobox, groups, the form value, the composed parts, glass.
import { beforeEach, expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light, radius } from '../../packages/core/src/tokens.ts';
import Selects from './fixtures/Selects.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

beforeEach(async () => {
  await page.viewport(800, 600);
});

async function open() {
  const screen = await render(Selects);
  const trigger = screen.getByRole('combobox', { name: 'Country' });
  return { screen, trigger };
}

test('the trigger: a field box named by its label, with the placeholder, collapsed', async () => {
  const { trigger } = await open();
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
  await expect.element(trigger).toHaveTextContent('Choose a country');
  const element = trigger.element();
  expect(box(element).height).toBe(44);
  expect(style(element, 'border-top-left-radius')).toBe('12px');
  expect(hexOf(element, 'border-top-color')).toBe(light.color.borderStrong.slice(0, 7));
  expect(rgbaOf(element.querySelector('.t-select-trigger-value') as Element)).toEqual(rgbaOfHex(light.color.textMuted));
});

test('a press opens the listbox under the trigger, at least 220 wide and as wide as it, in groups', async () => {
  const { screen, trigger } = await open();
  await trigger.click();
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'true');
  const listbox = screen.getByRole('listbox', { name: 'Country' });
  await expect.element(listbox).toBeVisible();
  const panel = listbox.element();
  expect(box(panel).top).toBe(box(trigger.element()).bottom + 4);
  expect(box(panel).left).toBe(box(trigger.element()).left);
  expect(box(panel).width).toBe(320);
  expect(style(panel, 'border-top-left-radius')).toBe(`${String(radius.md)}px`);
  expect(style(panel, 'padding-top')).toBe('4px');
  expect(hexOf(panel, 'background-color')).toBe(light.color.surface);
  expect(style(panel, 'box-shadow')).not.toBe('none');
  await expect.element(screen.getByRole('group', { name: 'Europe' })).toBeVisible();
  expect(screen.getByRole('option').elements()).toHaveLength(30);
  // the focus stays on the trigger
  await expect.element(trigger).toHaveFocus();
});

test('near the bottom of the screen, it opens over the trigger from its first frame', async () => {
  await page.viewport(800, 170);
  const { screen, trigger } = await open();
  (trigger.element() as HTMLElement).click();
  // what the first frame paints: a placement that waits for a resize to be measured comes a frame late
  await new Promise(requestAnimationFrame);
  const panel = screen.getByRole('listbox', { name: 'Country' }).element() as HTMLElement;
  expect(panel.dataset['side']).toBe('top');
  expect(parseFloat(panel.style.top) + panel.offsetHeight).toBeCloseTo(box(trigger.element()).top - 4, 0);
});

test('keyboard: arrows open and move, Enter chooses and closes, the trigger shows the label', async () => {
  const { screen, trigger } = await open();
  trigger.element().focus();
  await userEvent.keyboard('{ArrowDown}');
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'true');
  const active = () => document.getElementById(trigger.element().getAttribute('aria-activedescendant') ?? '');
  expect(active()?.textContent.trim()).toBe('France');
  await userEvent.keyboard('{ArrowDown}{ArrowDown}');
  expect(active()?.textContent.trim()).toBe('Greece');
  expect(active()?.classList.contains('t-option-active')).toBe(true);
  await userEvent.keyboard('{Enter}');
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
  await expect.element(trigger).toHaveTextContent('Greece');
  await expect.element(trigger).toHaveFocus();
  expect(new FormData(screen.getByTestId('form').element() as HTMLFormElement).get('country')).toBe('GR');
});

test('reopened, the selected option is active, ticked and in view; End, Home and letters move', async () => {
  const { screen, trigger } = await open();
  await trigger.click();
  await screen.getByRole('option', { name: 'Asia 20' }).click();
  await expect.element(trigger).toHaveTextContent('Asia 20');
  // a press on an option leaves the focus on the trigger
  await expect.element(trigger).toHaveFocus();
  await userEvent.keyboard(' ');
  const listbox = screen.getByRole('listbox', { name: 'Country' }).element();
  const selected = screen.getByRole('option', { name: 'Asia 20' });
  await expect.element(selected).toHaveAttribute('aria-selected', 'true');
  expect(selected.element().querySelector('svg')).not.toBeNull();
  expect(trigger.element().getAttribute('aria-activedescendant')).toBe(selected.element().id);
  await expect.poll(() => listbox.scrollTop).toBeGreaterThan(0);
  const active = () => document.getElementById(trigger.element().getAttribute('aria-activedescendant') ?? '');
  await userEvent.keyboard('{Home}');
  expect(active()?.textContent.trim()).toBe('France');
  await userEvent.keyboard('{End}');
  expect(active()?.textContent.trim()).toBe('Asia 25');
  await userEvent.keyboard('s');
  expect(active()?.textContent.trim()).toBe('Spain');
});

test('Escape, a press outside and Tab close it without choosing', async () => {
  const { screen, trigger } = await open();
  await trigger.click();
  await userEvent.keyboard('{ArrowDown}{Escape}');
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
  await expect.element(trigger).toHaveTextContent('Choose a country');
  await trigger.click();
  await screen.getByRole('button', { name: 'After' }).click();
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
  trigger.element().focus();
  await userEvent.keyboard('{ArrowDown}');
  await userEvent.tab();
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
});

test('disabled, it does not open; an error marks it invalid', async () => {
  const screen = await render(Selects, { disabled: true, error: 'Choose a country to ship to' });
  const trigger = screen.getByRole('combobox', { name: 'Country' });
  await expect.element(trigger).toBeDisabled();
  await expect.element(trigger).toHaveAttribute('aria-invalid', 'true');
  await expect.element(trigger).toHaveAccessibleDescription('Choose a country to ship to');
  expect(hexOf(trigger.element(), 'border-top-color')).toBe(light.color.danger);
});

test('composed: the label of the value before the items render, a separator, disabled options skipped', async () => {
  const screen = await render(Selects);
  const trigger = screen.getByRole('combobox', { name: 'Size' });
  await expect.element(trigger).toHaveTextContent('Medium');
  trigger.element().focus();
  await userEvent.keyboard('{ArrowDown}');
  const active = () => document.getElementById(trigger.element().getAttribute('aria-activedescendant') ?? '');
  expect(active()?.textContent.trim()).toBe('Medium');
  await userEvent.keyboard('{ArrowDown}');
  expect(active()?.textContent.trim()).toBe('Extra large');
  const listbox = screen.getByRole('listbox', { name: 'Size' }).element();
  expect(listbox.querySelector('.t-select-separator')?.getAttribute('aria-hidden')).toBe('true');
  await screen.getByRole('option', { name: 'Large' }).click({ force: true });
  await expect.element(trigger).toHaveTextContent('Medium');
  await userEvent.keyboard('{Enter}');
  await expect.element(trigger).toHaveTextContent('Extra large');
});

test('opened from glass, the panel is glass', async () => {
  const screen = await render(Selects, { glass: true });
  await screen.getByRole('combobox', { name: 'Country' }).click();
  const panel = screen.getByRole('listbox', { name: 'Country' }).element();
  expect(panel.classList.contains('t-glass')).toBe(true);
  expect(style(panel, 'backdrop-filter')).toMatch(/blur/);
});

test('required: announced as required; a form does not submit without a value, and the focus goes to the trigger', async () => {
  const screen = await render(Selects, { required: true });
  const trigger = screen.getByRole('combobox', { name: 'Country' });
  await expect.element(trigger).toHaveAttribute('aria-required', 'true');
  expect(trigger.element().hasAttribute('required')).toBe(false);
  const form = screen.getByTestId('form').element() as HTMLFormElement;
  let submitted = 0;
  form.addEventListener('submit', (event) => {
    event.preventDefault();
    submitted += 1;
  });
  expect(form.checkValidity()).toBe(false);
  form.requestSubmit();
  expect(submitted).toBe(0);
  await expect.element(trigger).toHaveFocus();
  await userEvent.keyboard('{ArrowDown}{Enter}');
  expect(form.checkValidity()).toBe(true);
  form.requestSubmit();
  expect(submitted).toBe(1);
  expect(new FormData(form).get('country')).toBe('FR');
});

test('not required, a form submits without a value, which it sends empty', async () => {
  const screen = await render(Selects);
  const trigger = screen.getByRole('combobox', { name: 'Country' });
  expect(trigger.element().hasAttribute('aria-required')).toBe(false);
  const form = screen.getByTestId('form').element() as HTMLFormElement;
  expect(form.checkValidity()).toBe(true);
  expect(new FormData(form).get('country')).toBe('');
});
