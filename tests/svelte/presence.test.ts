// Presence (DESIGN.md, Motion): an element comes in and goes out over the duration token with the easing
// token, and at once under reduced motion.
import { afterEach, expect, test } from 'vitest';
import { commands } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { cubicBezier, easing } from '../../packages/svelte/src/lib/primitives/presence.ts';
import Presence from './fixtures/Presence.svelte';

afterEach(async () => {
  await commands.emulateMedia({ reducedMotion: null });
});

test('cubicBezier gives the curves of CSS', () => {
  const linear = cubicBezier(0, 0, 1, 1);
  const ease = cubicBezier(0.25, 0.1, 0.25, 1);
  expect(linear(0.3)).toBeCloseTo(0.3, 6);
  expect(ease(0.5)).toBeCloseTo(0.8024, 4);
  expect([ease(0), ease(1), ease(-1), ease(2)]).toEqual([0, 1, 0, 1]);
  const standard = easing(document.body, 'standard');
  const curve = cubicBezier(0.2, 0, 0, 1);
  for (const t of [0.1, 0.25, 0.5, 0.9]) expect(standard(t)).toBe(curve(t));
});

const timings = (element: Element) => element.getAnimations().map((a) => a.effect?.getTiming().duration);

// Svelte plays no intro when a component mounts: the panel comes after
test('comes in and goes out over the duration token', async () => {
  const screen = await render(Presence, { options: { scale: 0.96, y: 8 } });
  await screen.rerender({ show: true });
  const panel = screen.getByTestId('panel').element();
  // after Svelte's first animation, as long as a delay
  await expect.poll(() => timings(panel)).toEqual([280]);
  const frames = panel.getAnimations()[0]?.effect instanceof KeyframeEffect ? panel.getAnimations()[0]?.effect : null;
  const first = (frames as KeyframeEffect | null)?.getKeyframes()[0];
  expect(first?.['opacity']).toBe('0');
  expect(first?.['scale']).toBe('0.96');
  expect(first?.['translate']).toBe('0px 8px');
  // all the way in: an outro from part way takes only the part it undoes
  await Promise.all(panel.getAnimations().map((animation) => animation.finished));
  await screen.rerender({ show: false });
  await expect.poll(() => timings(panel)).toEqual([280]);
  await expect.poll(() => panel.isConnected, { timeout: 2000 }).toBe(false);
  await screen.rerender({ show: true, options: { duration: 'fast' } });
  await expect.poll(() => timings(screen.getByTestId('panel').element())).toEqual([150]);
});

test('under reduced motion it comes and goes at once', async () => {
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  const screen = await render(Presence, { options: { scale: 0.96 } });
  await screen.rerender({ show: true });
  const panel = screen.getByTestId('panel').element();
  expect(timings(panel).filter((duration) => duration !== 0)).toEqual([]);
  await screen.rerender({ show: false });
  await expect.poll(() => panel.isConnected).toBe(false);
});
