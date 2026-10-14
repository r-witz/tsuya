// Syntax highlighting at build time: one shiki highlighter, reused by the loads of the component and block pages
// (prerendered, so this runs once per page while the site is built, never in the visitor's browser) and by mdsvex's
// `highlight` option in vite.config.ts. Light and dark themes both ship in the HTML; CodeBlock.svelte's CSS picks
// the one that matches the page's mode, the same way tokens.css does.
import { contrast } from '@tsuya/core/engine';
import { bundledThemes, createHighlighter, type Highlighter, type ThemeRegistrationRaw } from 'shiki';

const THEMES = { light: 'min-light', dark: 'min-dark' } as const;
const LANGS = ['svelte', 'ts', 'dart', 'bash', 'css', 'html', 'json', 'text'];

let highlighter: Highlighter | undefined;

/**
 * A bundled theme with every token colour moved toward black (light) or white (dark) until it reads at 4.5:1 on the
 * theme's background: min-light's comments are 1.8:1 on its white, min-dark's 3.4:1 on its grey.
 */
async function readable(name: (typeof THEMES)[keyof typeof THEMES]): Promise<ThemeRegistrationRaw> {
  const theme = (await bundledThemes[name]()).default as ThemeRegistrationRaw;
  const dark = theme.type === 'dark';
  const background = theme.colors?.['editor.background'] ?? (dark ? '#1f1f1f' : '#ffffff');
  const target = dark ? 255 : 0;
  const fix = (foreground: string): string => {
    if (!/^#[0-9a-f]{6}$/i.test(foreground)) return foreground;
    // 5 % steps toward the target, which is far past 4.5:1 on the background, so this ends
    for (let step = 0; step <= 20; step++) {
      const mixed = `#${[1, 3, 5]
        .map((at) => {
          const channel = parseInt(foreground.slice(at, at + 2), 16);
          return Math.round(channel + ((target - channel) * step) / 20)
            .toString(16)
            .padStart(2, '0');
        })
        .join('')}`;
      if (contrast(mixed, background) >= 4.5) return mixed;
    }
    return dark ? '#ffffff' : '#000000';
  };
  return {
    ...theme,
    tokenColors: theme.tokenColors?.map((rule) => ({
      ...rule,
      settings: { ...rule.settings, foreground: rule.settings.foreground && fix(rule.settings.foreground) },
    })),
  };
}

async function get(): Promise<Highlighter> {
  highlighter ??= await createHighlighter({
    themes: [await readable(THEMES.light), await readable(THEMES.dark)],
    langs: LANGS,
  });
  return highlighter;
}

/** `code` highlighted for both modes at once, as one HTML string. */
export async function highlightCode(code: string, lang: string): Promise<string> {
  const shiki = await get();
  const known = shiki.getLoadedLanguages().includes(lang) ? lang : 'text';
  return shiki.codeToHtml(code.replace(/\n$/, ''), { lang: known, themes: THEMES, defaultColor: 'light' });
}
