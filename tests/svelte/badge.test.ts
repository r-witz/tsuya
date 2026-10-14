// Badge (DESIGN.md, Badge; G5): the count pill, "99+" above 99, the dot, decorative, and pinned on the corner of an
// icon button and an avatar whose own label carries its meaning.
import { expect, test } from 'vitest';
import { render } from 'vitest-browser-svelte';

import Badges from './fixtures/Badges.svelte';

const box = (element: Element) => element.getBoundingClientRect();

test('a count pill, "99+" above 99, and a dot, all decorative', async () => {
  const screen = await render(Badges);
  const count = screen.getByTestId('standalone-count').element();
  const over = screen.getByTestId('standalone-over').element();
  const dot = screen.getByTestId('standalone-dot').element();
  expect(count.textContent).toBe('5');
  expect(over.textContent).toBe('99+');
  expect(box(count).height).toBe(18);
  expect(box(dot).width).toBe(8);
  expect(box(dot).height).toBe(8);
  for (const badge of [count, over, dot]) expect(badge.getAttribute('aria-hidden')).toBe('true');
});

test('pinned on the corner of an icon button, whose own label carries its meaning', async () => {
  const screen = await render(Badges);
  const button = screen.getByTestId('icon-button').element();
  const badge = screen.getByTestId('icon-button-badge').element();
  expect(button.getAttribute('aria-label')).toBe('Notifications, 3 unread');
  expect(badge.getAttribute('aria-hidden')).toBe('true');
  // pinned on the corner: it pokes past the button's top and trailing edges
  expect(box(badge).right).toBeGreaterThan(box(button).right);
  expect(box(badge).top).toBeLessThan(box(button).top);
});

test('pinned on the corner of an avatar, whose own label carries its meaning', async () => {
  const screen = await render(Badges);
  const avatar = screen.getByTestId('avatar').element();
  const badge = screen.getByTestId('avatar-badge').element();
  expect(avatar.getAttribute('aria-label')).toBe('Jamie Doe, online');
  expect(box(badge).right).toBeGreaterThan(box(avatar).right);
  expect(box(badge).top).toBeLessThan(box(avatar).top);
});

test('right to left, the pin sits on the top left corner', async () => {
  const screen = await render(Badges, { dir: 'rtl' });
  for (const [host, pin] of [
    ['icon-button', 'icon-button-badge'],
    ['avatar', 'avatar-badge'],
  ] as const) {
    const [hostBox, pinBox] = [box(screen.getByTestId(host).element()), box(screen.getByTestId(pin).element())];
    expect(pinBox.left).toBeLessThan(hostBox.left);
    expect(pinBox.top).toBeLessThan(hostBox.top);
  }
});
