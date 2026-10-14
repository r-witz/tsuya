// Motion (DESIGN.md Motion): durations that are zero under reduced motion (never on the server), read from the
// page's tokens.
import { prefersReducedMotion } from 'svelte/motion';

/** `ms`, or 0 under reduced motion. */
export function motion(ms: number): number {
  return prefersReducedMotion.current ? 0 : ms;
}

/** A duration token (`--t-duration-<name>`) as `node` resolves it, in milliseconds; `fallback` without one. */
export function durationOf(node: Element, name: string, fallback = 0): number {
  const value = getComputedStyle(node).getPropertyValue(`--t-duration-${name}`).trim();
  const ms = parseFloat(value) * (value.endsWith('ms') ? 1 : 1000);
  return Number.isFinite(ms) ? ms : fallback;
}

/** A motion duration token as `node` resolves it, in milliseconds, or 0 under reduced motion. */
export function duration(node: Element, name: 'fast' | 'base' | 'sheet' | 'accent' | 'ambient'): number {
  return motion(durationOf(node, name));
}
