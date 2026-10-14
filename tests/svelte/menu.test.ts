// Menu (DESIGN.md, Menu; G5, G6, G8, G13): the opener, the panel under it at its end edge, the values of the items,
// the keyboard of a menu, choosing, checkbox and radio items, closing and focus going back, glass.
import { beforeEach, expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light, radius } from '../../packages/core/src/tokens.ts';
import Menus from './fixtures/Menus.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();
const focused = () => document.activeElement?.querySelector('.t-menu-item-label')?.textContent.trim();
const output = (name: string) => document.querySelector(`[data-testid="${name}"]`)?.textContent;

beforeEach(async () => {
  await page.viewport(800, 600);
});

test('a press opens the menu under its opener at its end edge, named by it, on its first item', async () => {
  const screen = await render(Menus);
  const trigger = screen.getByRole('button', { name: 'Actions' });
  await expect.element(trigger).toHaveAttribute('aria-haspopup', 'menu');
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
  await trigger.click();
  const menu = screen.getByRole('menu', { name: 'Actions' });
  await expect.element(menu).toBeVisible();
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'true');
  await expect.poll(focused).toBe('Rename');
  const [panel, opener] = [box(menu.element()), box(trigger.element())];
  expect(panel.right).toBeCloseTo(Math.max(opener.right, 16 + panel.width), 0);
  expect(panel.top).toBeCloseTo(opener.bottom + 4, 0);
});

test('values: the panel, the items, an icon, a shortcut, a tick, a separator and a destructive item', async () => {
  const screen = await render(Menus, { open: true });
  const menu = screen.getByRole('menu', { name: 'Actions' }).element();
  await expect.poll(() => menu.matches(':popover-open')).toBe(true);
  expect(box(menu).width).toBeGreaterThanOrEqual(220);
  expect(style(menu, 'border-top-left-radius')).toBe(`${String(radius.md)}px`);
  expect(style(menu, 'padding-top')).toBe('4px');
  expect(hexOf(menu, 'background-color')).toBe(light.color.surface);
  const rename = screen.getByRole('menuitem', { name: 'Rename' }).element();
  expect(box(rename).height).toBe(44);
  expect(style(rename, 'border-top-left-radius')).toBe(`${String(radius.sm)}px`);
  expect(style(rename, 'padding-left')).toBe('12px');
  expect(style(rename, 'font-size')).toBe('15px');
  const icon = rename.querySelector('[data-testid="icon"]') as Element;
  expect(box(icon).width).toBe(20);
  expect(rgbaOf(icon)).toEqual(rgbaOfHex(light.color.textMuted));
  const shortcut = rename.querySelector('kbd') as Element;
  expect(style(shortcut, 'font-family')).toMatch(/mono/i);
  expect(rgbaOf(shortcut)).toEqual(rgbaOfHex(light.color.textMuted));
  const wrap = screen.getByRole('menuitemcheckbox', { name: 'Wrap lines' }).element();
  expect(wrap.getAttribute('aria-checked')).toBe('true');
  expect(wrap.querySelector('svg:last-child')).not.toBeNull();
  expect(box(wrap.querySelector('svg:last-child') as Element).right).toBeCloseTo(box(wrap).right - 12, 0);
  const separator = menu.querySelector('[role="separator"]') as Element;
  expect(box(separator).height).toBe(1);
  expect(rgbaOf(separator, 'background-color')).toEqual(rgbaOfHex(light.color.border));
  const remove = screen.getByRole('menuitem', { name: 'Delete' }).element();
  expect(hexOf(remove)).toBe(light.color.danger);
});

test('keyboard: arrows wrap, Home and End, letters; a disabled item takes focus but no choice', async () => {
  const screen = await render(Menus);
  (screen.getByRole('button', { name: 'Actions' }).element() as HTMLElement).focus();
  await userEvent.keyboard('{ArrowDown}');
  await expect.poll(focused).toBe('Rename');
  await userEvent.keyboard('{ArrowUp}');
  expect(focused()).toBe('Delete');
  await userEvent.keyboard('{ArrowDown}');
  expect(focused()).toBe('Rename');
  await userEvent.keyboard('{End}');
  expect(focused()).toBe('Delete');
  await userEvent.keyboard('{Home}');
  await userEvent.keyboard('d');
  expect(focused()).toBe('Duplicate');
  await userEvent.keyboard('{ArrowDown}');
  expect(focused()).toBe('Move');
  await userEvent.keyboard('{Enter}');
  expect(output('chosen')).toBe('');
  await expect.element(screen.getByRole('menu', { name: 'Actions' })).toBeVisible();
});

test('the up arrow on the opener opens it on its last item', async () => {
  const screen = await render(Menus);
  (screen.getByRole('button', { name: 'Actions' }).element() as HTMLElement).focus();
  await userEvent.keyboard('{ArrowUp}');
  await expect.poll(focused).toBe('Delete');
});

test('Enter or a press chooses: the menu closes, focus goes back to the opener, then the action runs', async () => {
  const screen = await render(Menus);
  const trigger = screen.getByRole('button', { name: 'Actions' });
  (trigger.element() as HTMLElement).focus();
  await userEvent.keyboard('{Enter}');
  await expect.poll(focused).toBe('Rename');
  await userEvent.keyboard('{Enter}');
  expect(output('chosen')).toBe('rename');
  await expect.element(trigger).toHaveFocus();
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
  await trigger.click();
  await screen.getByRole('menuitem', { name: 'Duplicate' }).click();
  expect(output('chosen')).toBe('rename,duplicate');
  await expect.element(trigger).toHaveFocus();
});

test('a checkbox item toggles and a radio item selects, and both close the menu', async () => {
  const screen = await render(Menus);
  const trigger = screen.getByRole('button', { name: 'Actions' });
  await trigger.click();
  await screen.getByRole('menuitemcheckbox', { name: 'Wrap lines' }).click();
  expect(output('wrap')).toBe('false');
  await expect.element(trigger).toHaveAttribute('aria-expanded', 'false');
  await trigger.click();
  await expect
    .element(screen.getByRole('menuitemcheckbox', { name: 'Wrap lines' }))
    .toHaveAttribute('aria-checked', 'false');
  const group = screen.getByRole('group', { name: 'Sort by' });
  await expect.element(group.getByRole('menuitemradio', { name: 'Name' })).toHaveAttribute('aria-checked', 'true');
  await group.getByRole('menuitemradio', { name: 'Date' }).click();
  expect(output('sort')).toBe('date');
  await trigger.click();
  await expect.element(group.getByRole('menuitemradio', { name: 'Date' })).toHaveAttribute('aria-checked', 'true');
  await expect.element(group.getByRole('menuitemradio', { name: 'Name' })).toHaveAttribute('aria-checked', 'false');
});

test('Escape closes it and focus goes back; Tab and a press outside close it', async () => {
  const screen = await render(Menus);
  const trigger = screen.getByRole('button', { name: 'Actions' });
  // hidden, it leaves the accessibility tree: watched by its element
  const menu = document.getElementById(trigger.element().getAttribute('aria-controls') ?? '') as HTMLElement;
  const shown = () => menu.matches(':popover-open');
  await trigger.click();
  await expect.poll(focused).toBe('Rename');
  await userEvent.keyboard('{Escape}');
  await expect.poll(shown).toBe(false);
  await expect.element(trigger).toHaveFocus();
  await trigger.click();
  await expect.poll(focused).toBe('Rename');
  await userEvent.tab();
  await expect.poll(shown).toBe(false);
  await expect.element(screen.getByRole('button', { name: 'More' })).toHaveFocus();
  await trigger.click();
  await expect.poll(shown).toBe(true);
  await screen.getByRole('button', { name: 'After' }).click();
  await expect.poll(shown).toBe(false);
});

test('from an icon button on glass the panel is glass, unless it holds a destructive item', async () => {
  const screen = await render(Menus);
  const more = screen.getByRole('button', { name: 'More' });
  await more.click();
  const menu = screen.getByRole('menu', { name: 'More' });
  await expect.element(menu).toBeVisible();
  expect(menu.element().classList.contains('t-glass')).toBe(true);
  await userEvent.keyboard('{Escape}');
  await screen.rerender({ danger: true });
  await more.click();
  await expect.element(menu).toBeVisible();
  expect(menu.element().classList.contains('t-glass')).toBe(false);
  expect(hexOf(menu.element(), 'background-color')).toBe(light.color.surface);
});
