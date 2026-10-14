// Focus scope (G6): focus goes in when a modal opens, Tab stays inside, and focus goes back when it closes;
// the topmost scope keeps Tab.
import { expect, test } from 'vitest';
import { userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { tabbables } from '../../packages/core/src/primitives/focus.ts';
import Scope from './fixtures/Scope.svelte';

const name = () => {
  const active = document.activeElement;
  return active?.getAttribute('aria-label') ?? active?.textContent;
};

test('Tab reaches what is enabled, visible and focusable, and one radio of a group', async () => {
  const screen = await render(Scope);
  await screen.getByRole('button', { name: 'Open' }).click();
  const names = tabbables(screen.getByTestId('scope').element()).map(
    (element) => element.getAttribute('aria-label') ?? element.textContent,
  );
  expect(names).toEqual(['Name', 'Large', 'Inner', 'Close']);
});

test('focus goes to the first element, Tab cycles inside, and focus returns to the opener', async () => {
  const screen = await render(Scope);
  await screen.getByRole('button', { name: 'Open' }).click();
  await expect.poll(name).toBe('Name');
  await userEvent.tab({ shift: true });
  expect(name()).toBe('Close');
  await userEvent.tab();
  expect(name()).toBe('Name');
  await userEvent.keyboard('{Tab}{Tab}{Tab}');
  expect(name()).toBe('Close');
  await userEvent.keyboard('{Enter}');
  await expect.poll(name).toBe('Open');
});

test('a marked element takes focus first', async () => {
  const screen = await render(Scope, { mark: true });
  await screen.getByRole('button', { name: 'Open' }).click();
  await expect.poll(name).toBe('Inner');
});

test('an empty scope takes focus itself', async () => {
  const screen = await render(Scope, { empty: true });
  await screen.getByRole('button', { name: 'Open' }).click();
  await expect.poll(() => document.activeElement?.getAttribute('data-testid')).toBe('scope');
});

test('a scope over another keeps Tab, and gives focus back to it', async () => {
  const screen = await render(Scope);
  await screen.getByRole('button', { name: 'Open' }).click();
  await expect.poll(name).toBe('Name');
  await screen.getByRole('button', { name: 'Inner' }).click();
  await expect.poll(name).toBe('Back');
  await userEvent.keyboard('{Tab}{Tab}');
  expect(name()).toBe('Back');
  await userEvent.keyboard('{Enter}');
  await expect.poll(name).toBe('Inner');
});

test('without a trap, Tab leaves; without restore, focus stays where it went', async () => {
  const screen = await render(Scope, { options: { trap: false, restore: false } });
  await screen.getByRole('button', { name: 'Open' }).click();
  await expect.poll(name).toBe('Name');
  await screen.getByRole('button', { name: 'Close' }).click();
  await expect.poll(() => screen.container.querySelector('[data-testid="scope"]')).toBeNull();
  expect(name()).not.toBe('Open');
  await screen.getByRole('button', { name: 'Open' }).click();
  await expect.poll(name).toBe('Name');
  await userEvent.keyboard('{Tab}{Tab}{Tab}{Tab}');
  expect(name()).toBe('Page');
});
