// The contrast guarantees a theme must hold in one mode, checked at their worst: any accent of the
// mode's tone band, glass tinted by any of them over white or black content, the ambient background at its cap.
// The build runs this on the tokens before writing anything; checkTheme runs it on an app's own theme. The Dart port,
// packages/flutter/lib/src/engine/check.dart, follows this file line by line.
import { bandAccents, bandCorners, bandExtremes } from './band.ts';
import { contrastOf, gam, luminance, over, parseColor, toHex, toLab, type Rgb } from './colorspace.ts';

/** The colours, tone band and ambient cap of one mode, as in the generated tokens (`light`, `dark`). */
export interface ModeTheme {
  color: {
    bg: string;
    surface: string;
    text: string;
    textMuted: string;
    borderStrong: string;
    fill: string;
    fillStrong: string;
    fillSelected: string;
    thumb: string;
    accent: string;
    onAccent: string;
    danger: string;
    warning: string;
    success: string;
    info: string;
    onStatus: string;
    glass: string;
    glassControl: string;
  };
  accent: { toneMin: number; toneMax: number };
  ambient: { cap: number };
}

/** The glass constants the checks depend on. */
export interface GlassTheme {
  opacity: number;
  tint: number;
}

/** Both modes and the glass constants, as in `@tsuya/core/tokens` (`{ light, dark, glass }`). */
export interface Theme {
  light: ModeTheme;
  dark: ModeTheme;
  glass: GlassTheme;
}

/** The worst case found for one check. */
export interface ContrastResult {
  check: string;
  ratio: number;
  min: number;
  worst: string;
}

/** A check a theme fails, with the mode and the worst case. */
export interface ContrastFailure extends ContrastResult {
  mode: 'light' | 'dark';
}

const TEXT = 4.5;
const MARK = 3;
// on-accent on the accent has to reach more than text elsewhere
const ON_ACCENT = 5.3;
const STATUSES = ['danger', 'warning', 'success', 'info'] as const;
const WHITE: Rgb = { r: 1, g: 1, b: 1, a: 1 };
const BLACK: Rgb = { r: 0, g: 0, b: 0, a: 1 };

const mix = (p: Rgb, q: Rgb, share: number): Rgb => ({
  r: p.r * (1 - share) + q.r * share,
  g: p.g * (1 - share) + q.g * share,
  b: p.b * (1 - share) + q.b * share,
  a: 1,
});

const describe = (rgb: Rgb) => `${toHex(rgb)} (L* ${toLab(rgb).L.toFixed(1)})`;

/** Every check for one mode, each with its worst case. */
export function checkMode(theme: ModeTheme, glass: GlassTheme): ContrastResult[] {
  const color = Object.fromEntries(Object.entries(theme.color).map(([k, v]) => [k, parseColor(v)])) as Record<
    keyof ModeTheme['color'],
    Rgb
  >;
  const results = new Map<string, ContrastResult>();
  const need = (check: string, fg: Rgb, back: Rgb, min: number, worst = '') => {
    const ratio = contrastOf(over(fg, back), back);
    const known = results.get(check);
    if (!known || ratio < known.ratio) results.set(check, { check, ratio, min, worst });
  };
  const grounds = { bg: color.bg, surface: over(color.surface, color.bg) };
  const cap = gam(theme.ambient.cap);
  const ambient: Rgb = { r: cap, g: cap, b: cap, a: 1 }; // a grey whose luminance is the cap
  const band = bandAccents(theme.accent.toneMin, theme.accent.toneMax).map(parseColor);
  const tints = [...band, ...bandCorners(theme.accent.toneMin, theme.accent.toneMax).map(parseColor)];
  // the neutral accent fills controls like any accent, but never tints glass: a neutral pair gives neutral glass
  const accents = [
    parseColor(theme.color.accent),
    ...band,
    ...bandExtremes(theme.accent.toneMin, theme.accent.toneMax).map(parseColor),
  ];

  for (const fg of ['text', 'textMuted'] as const) {
    for (const [name, ground] of Object.entries(grounds)) {
      const fill = over(color.fill, ground);
      need(`${fg} on ${name}`, color[fg], ground, TEXT);
      need(`${fg} on fill`, color[fg], fill, TEXT, `over ${name}`);
      need(`${fg} on fill-strong`, color[fg], over(color.fillStrong, ground), TEXT, `over ${name}`);
      need(`${fg} on fill-selected over fill`, color[fg], over(color.fillSelected, fill), TEXT, `over ${name}`);
    }
    for (const tint of [null, ...tints]) {
      const fill = tint ? mix(color.glass, tint, glass.tint) : color.glass;
      for (const [content, under] of [
        ['white', WHITE],
        ['black', BLACK],
      ] as const) {
        const tinted = tint ? `tinted by ${describe(tint)}` : 'neutral';
        need(
          `${fg} on any glass`,
          color[fg],
          over({ ...fill, a: glass.opacity }, under),
          TEXT,
          `${tinted}, over ${content}`,
        );
      }
    }
    need(`${fg} on the ambient at its cap`, color[fg], ambient, TEXT);
  }

  for (const status of STATUSES) {
    for (const [name, ground] of Object.entries(grounds)) need(`${status} on ${name}`, color[status], ground, TEXT);
    need(`on-status on ${status}`, color.onStatus, color[status], TEXT);
  }

  for (const [name, ground] of Object.entries(grounds)) {
    const fill = over(color.fill, ground);
    need(`border-strong on ${name}`, color.borderStrong, ground, MARK);
    need('border-strong over fill', color.borderStrong, fill, MARK, `over ${name}`);
    need('thumb on border-strong', color.thumb, over(color.borderStrong, ground), MARK, `over ${name}`);
  }
  for (const accent of accents) {
    const worst = describe(accent);
    need('on-accent on any accent', color.onAccent, accent, ON_ACCENT, worst);
    need('on-accent thumb on any accent', color.onAccent, accent, MARK, worst);
    for (const [name, ground] of Object.entries(grounds)) need(`any accent on ${name}`, accent, ground, MARK, worst);
    need('any accent on the ambient at its cap', accent, ambient, MARK, worst);
  }
  need(
    'text (icons) on control glass over the ambient at its cap',
    color.text,
    over(color.glassControl, ambient),
    MARK,
  );

  return [...results.values()];
}

/** Whether bg looks like the mode it is given for: a light mode needs a light background. */
export const looksLike = (theme: ModeTheme, mode: 'light' | 'dark'): boolean =>
  luminance(parseColor(theme.color.bg)) > 0.5 === (mode === 'light');

/**
 * Every check on a theme, as the build runs them on the tokens, and the ones it fails. An app that
 * overrides neutral colours owns their contrast: `checkTheme({ light: { ...light, color: { ...light.color, … } },
 * dark, glass })` with the values of `@tsuya/core/tokens`.
 */
export function checkTheme(theme: Theme): ContrastFailure[] {
  return (['light', 'dark'] as const).flatMap((mode) =>
    checkMode(theme[mode], theme.glass)
      .filter((result) => result.ratio < result.min)
      .map((result) => ({ mode, ...result })),
  );
}
