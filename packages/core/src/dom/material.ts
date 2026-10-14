// The material on any page (DESIGN.md, The material): accent regions and the ambient background, for pages that do
// not use the Svelte components; AccentRegion cross-fades with fadeAccent too.
import type { AccentPair } from '../engine/color.ts';

/** What a region needs of a pair: its colours, and its seed when it has one (null for the neutral pair). */
export type RegionPair = Pick<AccentPair, 'light' | 'dark'> & { seed?: string | null };

type Colours = Pick<AccentPair, 'light' | 'dark'>;

/**
 * Colours an element and everything inside it with an accent pair, the colour of the nearest mode; a change of pair
 * cross-fades. The pair of a content tints the glass inside; the neutral pair (seed null) does not.
 */
export function setAccent(element: HTMLElement, pair: RegionPair): void {
  element.classList.add('t-accent');
  if (pair.seed === null) element.dataset['accent'] = 'neutral';
  else delete element.dataset['accent'];
  fadeAccent(element, shownAccent(element), pair, () => {
    element.style.setProperty('--t-accent-light', pair.light);
    element.style.setProperty('--t-accent-dark', pair.dark);
  });
}

/** Back to the accent of the enclosing region, or the neutral one, cross-fading to it. */
export function clearAccent(element: HTMLElement): void {
  const around = element.parentElement && shownAccent(element.parentElement);
  fadeAccent(element, shownAccent(element), around, () => {
    element.classList.remove('t-accent');
    element.style.removeProperty('--t-accent-light');
    element.style.removeProperty('--t-accent-dark');
    delete element.dataset['accent'];
  });
}

/** The pair an element shows now, in the middle of a cross-fade too: its accent colours, computed. */
export function shownAccent(element: HTMLElement): Colours | null {
  const style = getComputedStyle(element);
  const light = style.getPropertyValue('--t-accent-light').trim();
  const dark = style.getPropertyValue('--t-accent-dark').trim();
  return light && dark ? { light, dark } : null;
}

// The cross-fade runs from script, a colour-mix a frame: Firefox paints a CSS transition of the registered accent
// colours apart from the transitions of the elements inside (a pressable's background flashes back towards the old
// pair), and runs none on an element with display: contents.
const fades = new WeakMap<HTMLElement, number>();

/**
 * Cross-fades the accent of `element` from `from` to `to` over --t-duration-accent with --t-easing-standard, then
 * calls `done`, which sets the final state; `done` at once with reduced motion, or without a pair to fade from or to.
 * A new fade of the element stops the one running; so does the function it returns, leaving the colour shown.
 */
export function fadeAccent(
  element: HTMLElement,
  from: Colours | null,
  to: Colours | null,
  done: () => void,
): () => void {
  const stop = () => {
    cancelAnimationFrame(fades.get(element) ?? 0);
    fades.delete(element);
  };
  stop();
  const style = getComputedStyle(element);
  const time = style.getPropertyValue('--t-duration-accent').trim();
  const duration = parseFloat(time) * (time.endsWith('ms') ? 1 : 1000) || 0;
  const curve = (style.getPropertyValue('--t-easing-standard').match(/-?[\d.]+/g) ?? []).map(Number);
  const still = !from || !to || (from.light === to.light && from.dark === to.dark);
  if (still || !duration || matchMedia('(prefers-reduced-motion: reduce)').matches) {
    done();
    return stop;
  }
  const start = performance.now();
  const frame = (now: number): void => {
    // a frame's time can be just before the start
    const t = Math.min(1, Math.max(0, (now - start) / duration));
    if (t === 1) {
      fades.delete(element);
      done();
      return;
    }
    const share = `${(ease(curve, t) * 100).toFixed(2)}%`;
    for (const mode of ['light', 'dark'] as const) {
      element.style.setProperty(`--t-accent-${mode}`, `color-mix(in oklab, ${to[mode]} ${share}, ${from[mode]})`);
    }
    fades.set(element, requestAnimationFrame(frame));
  };
  frame(start);
  return stop;
}

// cubic-bezier(x1, y1, x2, y2) at x, its parameter found by bisection
function ease([x1 = 0, y1 = 0, x2 = 1, y2 = 1]: number[], x: number): number {
  const at = (a: number, b: number, s: number) => 3 * (1 - s) ** 2 * s * a + 3 * (1 - s) * s ** 2 * b + s ** 3;
  let [low, high] = [0, 1];
  for (let i = 0; i < 24; i++) {
    const mid = (low + high) / 2;
    if (at(x1, x2, mid) < x) low = mid;
    else high = mid;
  }
  return at(y1, y2, (low + high) / 2);
}

/**
 * Shows an image in a `.t-ambient` element, cross-fading from the one it showed; null shows none. `opacity` is the
 * `ambient` of the image's pair (accentFromPixels, accentFromImage); without it, the safe opacity. A 64 to 128 px
 * thumbnail is enough.
 */
export function setAmbient(element: HTMLElement, src: string | null, opacity?: { light: number; dark: number }): void {
  element.setAttribute('aria-hidden', 'true');
  while (element.children.length < 2) element.append(document.createElement('i'));
  const [first, second] = [...element.children] as HTMLElement[];
  if (!first || !second) return;
  const shown = first.hasAttribute('data-on') ? first : second;
  const next = shown === first ? second : first;
  next.style.backgroundImage = src ? `url(${JSON.stringify(src)})` : '';
  for (const mode of ['light', 'dark'] as const) {
    if (opacity) next.style.setProperty(`--_t-ambient-${mode}`, String(opacity[mode]));
    else next.style.removeProperty(`--_t-ambient-${mode}`);
  }
  // the new layer is laid out hidden first, so that its opacity transition runs
  next.getBoundingClientRect();
  next.toggleAttribute('data-on', src !== null);
  shown.removeAttribute('data-on');
}
