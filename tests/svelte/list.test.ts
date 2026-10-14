// List, ListItem and Section (DESIGN.md, List, ListItem, Section; G5, G6, G14): row metrics, hairlines, leading and
// trailing content, current and destructive rows, the tag that varies with href/onclick, and section grouping.
import { expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Lists from './fixtures/Lists.svelte';
import { rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('row heights: the regular size and the tall account row', async () => {
  const screen = await render(Lists);
  expect(box(screen.getByTestId('account').element()).height).toBe(72);
  expect(box(screen.getByTestId('wifi').element()).height).toBe(56);
  expect(box(screen.getByTestId('storage').element()).height).toBe(56);
});

test('hairlines separate a row from the one before it, not from a section label', async () => {
  const screen = await render(Lists);
  const borderOf = (name: string) => style(screen.getByTestId(name).element(), 'border-top-width');
  expect(borderOf('account')).toBe('0px');
  expect(borderOf('wifi')).toBe('0px');
  expect(borderOf('bluetooth')).toBe('1px');
  expect(borderOf('storage')).toBe('1px');
  expect(borderOf('sign-out')).toBe('0px');
  expect(rgbaOf(screen.getByTestId('bluetooth').element(), 'border-top-color')).toEqual(rgbaOfHex(light.color.border));
});

test('leading, title and subtitle, one line each with an ellipsis', async () => {
  const screen = await render(Lists);
  expect(screen.getByTestId('wifi-icon').element().getBoundingClientRect().width).toBe(20);
  // a row that is not the current item: the regular body-strong weight
  const account = screen.getByTestId('account').element();
  expect(style(account.querySelector('.t-list-item-title') as Element, 'font-weight')).toBe('600');
  const subtitle = screen.getByTestId('wifi').element().querySelector('.t-list-item-subtitle') as HTMLElement;
  expect(rgbaOf(subtitle, 'color')).toEqual(rgbaOfHex(light.color.textMuted));
  expect(style(subtitle, 'text-overflow')).toBe('ellipsis');
  expect(subtitle.scrollWidth).toBeGreaterThan(subtitle.clientWidth);
});

test('a trailing value is muted, tabular, and capped at half the row', async () => {
  const screen = await render(Lists);
  const storage = screen.getByTestId('storage').element();
  const trailing = storage.querySelector('.t-list-item-trailing') as HTMLElement;
  expect(rgbaOf(trailing, 'color')).toEqual(rgbaOfHex(light.color.textMuted));
  expect(style(trailing, 'font-variant-numeric')).toBe('tabular-nums');
  expect(style(trailing, 'max-width')).toBe('50%');
  expect(screen.getByTestId('storage-value').element().textContent).toBe('128 GB');
});

test('a row with href renders a link and a trailing chevron when nothing else trails it', async () => {
  const screen = await render(Lists);
  const account = screen.getByTestId('account').element();
  expect(account.tagName).toBe('A');
  expect(account.getAttribute('href')).toBe('/account');
  const chevron = account.querySelector('.t-list-item-chevron svg') as SVGElement;
  expect(box(chevron).width).toBe(16);
  // a row with its own trailing content keeps it instead of a chevron
  expect(screen.getByTestId('storage').element().querySelector('.t-list-item-chevron')).toBeNull();
});

test('a row with onclick renders a button and ignores no href', async () => {
  const pressed: string[] = [];
  const screen = await render(Lists, { onpress: (name: string) => pressed.push(name) });
  const bluetooth = screen.getByTestId('bluetooth').element();
  expect(bluetooth.tagName).toBe('BUTTON');
  expect(bluetooth.getAttribute('type')).toBe('button');
  await screen.getByTestId('bluetooth').click();
  bluetooth.focus();
  await userEvent.keyboard('{Enter}');
  expect(pressed).toEqual(['bluetooth', 'bluetooth']);
});

test('a plain row with neither href nor onclick is not interactive', async () => {
  const screen = await render(Lists);
  const storage = screen.getByTestId('storage').element();
  expect(storage.tagName).toBe('DIV');
  expect(storage.classList.contains('t-pressable')).toBe(false);
  expect(storage.hasAttribute('data-press')).toBe(false);
  expect(storage.getAttribute('tabindex')).toBeNull();
});

test('interactive rows are pressable: fill on hover, fill-strong on press', async () => {
  const screen = await render(Lists);
  const account = screen.getByTestId('account').element();
  expect(account.classList.contains('t-pressable')).toBe(true);
  expect(account.getAttribute('data-press')).toBe('highlight');
});

test('the current item has a bold title and aria-current; it moves when the prop changes', async () => {
  const screen = await render(Lists);
  const wifi = screen.getByTestId('wifi').element();
  const bluetooth = screen.getByTestId('bluetooth').element();
  expect(wifi.getAttribute('aria-current')).toBe('true');
  expect(style(wifi.querySelector('.t-list-item-title') as Element, 'font-weight')).toBe('800');
  expect(bluetooth.hasAttribute('aria-current')).toBe(false);
  await screen.rerender({ current: 'bluetooth' });
  expect(screen.getByTestId('wifi').element().hasAttribute('aria-current')).toBe(false);
  expect(screen.getByTestId('bluetooth').element().getAttribute('aria-current')).toBe('true');
});

test('a destructive row has its title in danger', async () => {
  const screen = await render(Lists);
  const title = screen.getByTestId('sign-out').element().querySelector('.t-list-item-title') as Element;
  expect(rgbaOf(title, 'color')).toEqual(rgbaOfHex(light.color.danger));
});

test('a Section groups its rows under its label, announced to assistive technology', async () => {
  const screen = await render(Lists);
  const network = screen.getByRole('group', { name: 'Network' });
  await expect.element(network).toBeInTheDocument();
  expect(network.element().contains(screen.getByTestId('wifi').element())).toBe(true);
  const label = network.element().querySelector('.t-section-label') as HTMLElement;
  expect(style(label, 'margin-top')).toBe('24px');
  expect(style(label, 'margin-bottom')).toBe('8px');
  expect(style(label, 'text-transform')).toBe('uppercase');
});

test('right to left: the chevron mirrors', async () => {
  await page.viewport(800, 600);
  const screen = await render(Lists, { dir: 'rtl' });
  const chevron = screen.getByTestId('account').element().querySelector('.t-list-item-chevron svg') as SVGElement;
  expect(style(chevron, 'scale')).toBe('-1 1');
});

test('in a selectable list, the selected row has a tick at the end, and says so', async () => {
  const screen = await render(Lists);
  const english = screen.getByTestId('english').element();
  const french = screen.getByTestId('french').element();
  // the tick, the row's last part, and a pressed button
  expect(english.lastElementChild?.matches('svg')).toBe(true);
  expect(english.getAttribute('aria-pressed')).toBe('true');
  expect(french.querySelector('svg')?.closest('.t-list-item-chevron')).not.toBeNull();
  expect(french.hasAttribute('aria-pressed')).toBe(false);
  await screen.rerender({ language: 'fr' });
  expect(english.getAttribute('aria-pressed')).toBe('false');
  expect(english.querySelector('svg')).toBeNull();
  // a link cannot be pressed: the tick and a hidden word, instead of the chevron
  expect(french.querySelector('.t-list-item-chevron')).toBeNull();
  expect(french.textContent).toContain('Selected');
  await expect.element(screen.getByRole('link', { name: 'Français Selected' })).toBeInTheDocument();
});
