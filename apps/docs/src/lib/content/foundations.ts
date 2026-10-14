// Rows for the Foundations page, every one read from @tsuya/core/tokens or computed with contrast() from
// @tsuya/core: nothing here is hand-copied, so the page can't drift from the tokens it documents.
import { contrast } from '@tsuya/core';
import { dark, duration, easing, light, radius, size, space, state, type } from '@tsuya/core/tokens';

const toKebab = (key: string): string => key.replace(/[A-Z]/g, (c) => `-${c.toLowerCase()}`);

export interface ColorRow {
  name: string;
  cssVar: string;
  light: string;
  dark: string;
}

export const colorRows: ColorRow[] = Object.keys(light.color).map((key) => {
  const k = key as keyof typeof light.color;
  return { name: key, cssVar: `--t-${toKebab(key)}`, light: light.color[k], dark: dark.color[k] };
});

interface ContrastPair {
  label: string;
  fg: keyof typeof light.color;
  bg: keyof typeof light.color;
}

// A pairing of "this token" against the background it is normally read over, not every possible combination.
const CONTRAST_PAIRS: ContrastPair[] = [
  { label: 'text on bg', fg: 'text', bg: 'bg' },
  { label: 'textMuted on bg', fg: 'textMuted', bg: 'bg' },
  { label: 'borderStrong on bg', fg: 'borderStrong', bg: 'bg' },
  { label: 'onAccent on accent', fg: 'onAccent', bg: 'accent' },
  { label: 'danger on bg', fg: 'danger', bg: 'bg' },
  { label: 'warning on bg', fg: 'warning', bg: 'bg' },
  { label: 'success on bg', fg: 'success', bg: 'bg' },
  { label: 'info on bg', fg: 'info', bg: 'bg' },
  { label: 'onStatus on danger', fg: 'onStatus', bg: 'danger' },
  { label: 'onStatus on warning', fg: 'onStatus', bg: 'warning' },
  { label: 'onStatus on success', fg: 'onStatus', bg: 'success' },
  { label: 'onStatus on info', fg: 'onStatus', bg: 'info' },
];

export interface ContrastRow {
  label: string;
  light: number;
  dark: number;
}

export const contrastRows: ContrastRow[] = CONTRAST_PAIRS.map(({ label, fg, bg }) => ({
  label,
  light: contrast(light.color[fg], light.color[bg]),
  dark: contrast(dark.color[fg], dark.color[bg]),
}));

export interface TypeRow {
  name: string;
  cssVar: string;
  trackingVar: string;
  fontSize: number;
  fontWeight: number;
}

export const typeRows: TypeRow[] = Object.entries(type).map(([key, value]) => ({
  name: key,
  cssVar: `--t-type-${toKebab(key)}`,
  trackingVar: `--t-type-${toKebab(key)}-tracking`,
  fontSize: value.fontSize,
  fontWeight: value.fontWeight,
}));

export interface ScaleRow {
  name: string;
  cssVar: string;
  value: number;
}

const scaleRows = (group: string, values: Record<string, number>): ScaleRow[] =>
  Object.entries(values).map(([key, value]) => ({ name: key, cssVar: `--t-${group}-${toKebab(key)}`, value }));

export const spaceRows: ScaleRow[] = scaleRows('space', space);
export const radiusRows: ScaleRow[] = scaleRows('radius', radius);
export const sizeRows: ScaleRow[] = scaleRows('size', size);

// What each one is for (DESIGN.md, Motion), since that is documentation, not a number the tokens carry themselves.
const DURATION_USE: Record<string, string> = {
  fast: 'Press, hover, selection.',
  base: 'Dialogs, pages.',
  sheet: 'Sheets.',
  accent: 'The accent transition.',
  ambient: 'The ambient background.',
  tooltipDelay: 'The wait before a tooltip shows.',
  toast: 'How long a toast stays.',
};

const EASING_USE: Record<string, string> = {
  standard: 'Most transitions.',
  emphasized: 'Sheets rising, menus appearing.',
};

export interface DurationRow {
  name: string;
  cssVar: string;
  ms: number;
  use: string;
}

export const durationRows: DurationRow[] = Object.entries(duration).map(([key, value]) => ({
  name: key,
  cssVar: `--t-duration-${toKebab(key)}`,
  ms: value,
  use: DURATION_USE[key] ?? '',
}));

export interface EasingRow {
  name: string;
  cssVar: string;
  curve: string;
  use: string;
}

export const easingRows: EasingRow[] = Object.entries(easing).map(([key, value]) => ({
  name: key,
  cssVar: `--t-easing-${toKebab(key)}`,
  curve: `cubic-bezier(${value.join(', ')})`,
  use: EASING_USE[key] ?? '',
}));

export const stateRows: ScaleRow[] = scaleRows('state', state);
