// The Svelte material (DESIGN.md: Accent, Ambient background, Glass, Surface, Theme and mode, Labels): what each
// component renders and how the page's CSS reads it, in the browsers.
import { expect, test } from 'vitest';
import { render } from 'vitest-browser-svelte';

import { labelsEn, labelsFr } from '../../packages/core/src/labels.ts';
import { light } from '../../packages/core/src/tokens.ts';
import { announce } from '../../packages/core/src/primitives/announcer.ts';
import Labelled from './fixtures/Labelled.svelte';
import Material from './fixtures/Material.svelte';
import WithLabels from './fixtures/WithLabels.svelte';
import { hexOf } from './support.ts';

const PAIR = { seed: '#2A9D8F', light: '#03786C', dark: '#2FA193', ambient: { light: 0.3, dark: 0.45 } };
const OTHER = { seed: '#7A3FB0', light: '#7A3FB0', dark: '#B07BEA' };
const IMAGE = 'data:image/gif;base64,R0lGODlhAQABAIAAAP8AAP///yH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==';

test('an accent region gives its pair; the neutral pair untints glass; a new pair cross-fades to it', async () => {
  const screen = await render(Material, { labels: labelsEn, pair: PAIR });
  const probe = screen.getByTestId('probe').element();
  const region = screen.getByTestId('region').element();
  expect(region.classList.contains('t-accent')).toBe(true);
  expect(hexOf(probe)).toBe(PAIR.light);
  await screen.rerender({ pair: OTHER });
  await expect.poll(() => hexOf(probe), { timeout: 2000 }).toBe(OTHER.light);
  await screen.rerender({ pair: { seed: null, light: light.color.accent, dark: '#FFFFFF' } });
  expect(region.getAttribute('data-accent')).toBe('neutral');
  await screen.rerender({ pair: null });
  // it fades back to the accent around, then gives the class back
  expect(region.classList.contains('t-accent')).toBe(true);
  await expect.poll(() => region.classList.contains('t-accent'), { timeout: 2000 }).toBe(false);
});

test('a new pair cross-fades frame by frame from the colour shown, with no CSS animation', async () => {
  const screen = await render(Material, { labels: labelsEn, pair: PAIR });
  const region = screen.getByTestId('region').element() as HTMLElement;
  const inline = () => region.style.getPropertyValue('--t-accent-light');
  await screen.rerender({ pair: OTHER });
  expect(inline()).toMatch(/^color-mix\(in oklab, #7A3FB0 [\d.]+%, rgb\(3, 120, 108\)\)$/);
  expect(region.getAnimations()).toEqual([]);
  await new Promise((resolve) => setTimeout(resolve, 250));
  // a third pair in the middle of the fade starts from the colour shown, not from either pair
  await screen.rerender({ pair: PAIR });
  const from = /, (.+)\)$/.exec(inline())?.[1] ?? '';
  expect(from).not.toMatch(/^rgb\(3, 120, 108\)$|^#7A3FB0$|^rgb\(122, 63, 176\)$/i);
  await expect.poll(inline, { timeout: 2000 }).toBe(PAIR.light);
});

test('the ambient background shows its image at the pair opacity, a new image on the other layer', async () => {
  const screen = await render(Material, { labels: labelsEn, pair: PAIR, src: IMAGE });
  const layers = () => [...(screen.container.querySelector('.t-ambient')?.children ?? [])] as HTMLElement[];
  expect(screen.container.querySelector('.t-ambient')?.getAttribute('aria-hidden')).toBe('true');
  expect(layers().map((layer) => layer.hasAttribute('data-on'))).toEqual([true, false]);
  expect(layers()[0]?.style.getPropertyValue('--_t-ambient-light')).toBe('0.3');
  expect(layers()[0]?.style.backgroundImage).toContain('data:image/gif');
  await screen.rerender({ src: `${IMAGE}#2` });
  expect(layers().map((layer) => layer.hasAttribute('data-on'))).toEqual([false, true]);
  expect(layers()[1]?.style.backgroundImage).toContain('#2');
  await screen.rerender({ src: null });
  expect(layers().map((layer) => layer.hasAttribute('data-on'))).toEqual([false, false]);
});

test('the glow lights the top of its surface, hidden from assistive technology', async () => {
  const screen = await render(Material, { labels: labelsEn, pair: PAIR, glow: true });
  const glow = screen.container.querySelector('.t-glow') as HTMLElement;
  expect(glow.getAttribute('aria-hidden')).toBe('true');
  expect(glow.getBoundingClientRect().top).toBe(screen.getByTestId('surface').element().getBoundingClientRect().top);
  expect(getComputedStyle(glow.firstElementChild as Element).backgroundImage).toMatch(/^radial-gradient\(/);
  expect(screen.container.querySelector('.t-ambient')).toBeNull();
});

test('a glass scope makes glass neutral or opaque inside it', async () => {
  const screen = await render(Material, { labels: labelsEn, pair: PAIR, reduce: true });
  const glass = screen.getByTestId('glass').element();
  expect(getComputedStyle(glass).backdropFilter).toBe('none');
  await screen.rerender({ reduce: false, neutral: true });
  expect(hexOf(glass, 'background-color')).toBe(light.color.glass);
  expect(getComputedStyle(glass).backdropFilter).toBe('blur(24px)');
});

test('a surface carries the grain mode', async () => {
  const screen = await render(Material, { labels: labelsEn, pair: null, grain: 'off' });
  const surface = screen.getByTestId('surface').element();
  expect(surface.classList.contains('t-surface')).toBe(true);
  expect(surface.getAttribute('data-grain')).toBe('off');
  expect(getComputedStyle(surface, '::after').content).toBe('none');
});

test('a forced mode is set on the document too, and given back when the provider goes', async () => {
  const screen = await render(Material, { labels: labelsEn, pair: PAIR, mode: 'dark' });
  expect(document.documentElement.dataset['theme']).toBe('dark');
  expect(hexOf(screen.getByTestId('probe').element())).toBe(PAIR.dark);
  await screen.unmount();
  expect(document.documentElement.dataset['theme']).toBeUndefined();
});

test('a persisted mode set before hydration stays until the app chooses; the system mode then clears it', async () => {
  // what themeScript() leaves on <html> before the app runs
  document.documentElement.dataset['theme'] = 'dark';
  try {
    const screen = await render(Material, { labels: labelsEn, pair: PAIR });
    expect(document.documentElement.dataset['theme']).toBe('dark');
    await screen.rerender({ mode: 'light' });
    expect(document.documentElement.dataset['theme']).toBe('light');
    await screen.rerender({ mode: 'system' });
    expect(document.documentElement.dataset['theme']).toBeUndefined();
  } finally {
    delete document.documentElement.dataset['theme'];
  }
});

test('components read the labels of the provider, and fail loudly without one in development', async () => {
  const screen = await render(WithLabels, { labels: labelsFr });
  await expect.element(screen.getByRole('button')).toHaveTextContent('Fermer');
  await screen.rerender({ labels: labelsEn });
  await expect.element(screen.getByRole('button')).toHaveTextContent('Close');
  await expect(render(Labelled)).rejects.toThrow(/<Labelled> needs the "close" label/);
});

test('the announcer writes into the live regions of the provider', async () => {
  await render(Material, { labels: labelsEn, pair: null });
  const polite = document.querySelector('[data-tsuya-live="polite"]');
  const assertive = document.querySelector('[data-tsuya-live="assertive"]');
  expect(polite?.getAttribute('aria-live')).toBe('polite');
  announce('Saved');
  await expect.poll(() => polite?.textContent).toBe('Saved');
  announce('Connection lost', { assertive: true });
  await expect.poll(() => assertive?.textContent).toBe('Connection lost');
});
