// Presence (DESIGN.md Motion): an element comes in and goes out with the duration and easing tokens, then
// leaves the document; instant under reduced motion. `transition:presence` with Svelte's {#if}; the toast uses it.
import type { TransitionConfig } from 'svelte/transition';

import { duration } from './motion.svelte.ts';

export interface PresenceOptions {
  /** `--t-duration-<name>`. Default 'base'. */
  duration?: 'fast' | 'base' | 'sheet';
  /** `--t-easing-<name>`: emphasized for sheets rising and menus appearing. Default 'standard'. */
  easing?: 'standard' | 'emphasized';
  /** The scale it comes in from, such as 0.96. Default 1. */
  scale?: number;
  /** How far below it comes in from, in pixels (negative: above). Default 0. */
  y?: number;
}

/** The easing of CSS `cubic-bezier(x1, y1, x2, y2)`: x is solved for t, by Newton's method then by halves. */
export function cubicBezier(x1: number, y1: number, x2: number, y2: number): (x: number) => number {
  const cx = 3 * x1;
  const bx = 3 * (x2 - x1) - cx;
  const ax = 1 - cx - bx;
  const cy = 3 * y1;
  const by = 3 * (y2 - y1) - cy;
  const ay = 1 - cy - by;
  const xAt = (t: number) => ((ax * t + bx) * t + cx) * t;
  const yAt = (t: number) => ((ay * t + by) * t + cy) * t;
  const slope = (t: number) => (3 * ax * t + 2 * bx) * t + cx;
  return (x) => {
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    let t = x;
    for (let i = 0; i < 8; i++) {
      const error = xAt(t) - x;
      if (Math.abs(error) < 1e-7) return yAt(t);
      const d = slope(t);
      if (Math.abs(d) < 1e-6) break;
      t -= error / d;
    }
    let low = 0;
    let high = 1;
    t = x;
    while (high - low > 1e-7) {
      if (xAt(t) < x) low = t;
      else high = t;
      t = (low + high) / 2;
    }
    return yAt(t);
  };
}

/** An easing token as `node` resolves it; linear if it is not a cubic-bezier(). */
export function easing(node: Element, name: 'standard' | 'emphasized'): (t: number) => number {
  const value = getComputedStyle(node).getPropertyValue(`--t-easing-${name}`);
  const numbers = /cubic-bezier\(([^)]*)\)/.exec(value)?.[1]?.split(',').map(Number);
  if (numbers?.length !== 4 || numbers.some((n) => !Number.isFinite(n))) return (t) => t;
  const [x1 = 0, y1 = 0, x2 = 1, y2 = 1] = numbers;
  return cubicBezier(x1, y1, x2, y2);
}

/** `transition:presence={{ scale: 0.96 }}`: opacity, and the scale and offset it comes in from. */
export function presence(node: Element, options: PresenceOptions = {}): TransitionConfig {
  const { scale = 1, y = 0 } = options;
  const moves = scale !== 1 || y !== 0;
  return {
    duration: duration(node, options.duration ?? 'base'),
    easing: easing(node, options.easing ?? 'standard'),
    css: (t, u) =>
      `opacity: ${String(t)};` +
      (moves ? ` translate: 0 ${String(u * y)}px; scale: ${String(1 - u * (1 - scale))};` : ''),
  };
}
