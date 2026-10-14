// tokens.css in the three engines: light by default, dark from the system unless the root says light,
// regions forced either way, and the accent following the nearest mode from the pair it inherits.
import { readFileSync } from 'node:fs';

import { expect, test, type Page } from '@playwright/test';

const css = readFileSync(new URL('../../packages/core/src/css/tokens.css', import.meta.url), 'utf8');

const html = `<style>${css} .probe { background: var(--t-bg); color: var(--t-accent); }</style>
<div id="root" class="probe"></div>
<div id="dark" data-theme="dark" class="probe"><div id="light-in-dark" data-theme="light" class="probe"></div></div>
<div style="--t-accent-light: #FF0000; --t-accent-dark: #00FF00">
  <div id="pair-dark" data-theme="dark" class="probe"></div>
  <div id="pair-light" data-theme="light" class="probe"></div>
</div>`;

const LIGHT = { bg: '#F6F6F8', accent: '#0A0A0C' };
const DARK = { bg: '#0A0A0C', accent: '#FFFFFF' };

// the computed background and text colours as #RRGGBB, whatever the engine writes: rgb(…) or color(srgb …)
function colours(page: Page, id: string) {
  return page.evaluate((id) => {
    const style = getComputedStyle(document.getElementById(id) as HTMLElement);
    const hex = (value: string) => {
      const numbers = (value.match(/[\d.]+/g) ?? []).map(Number).slice(0, 3);
      const bytes = value.startsWith('color(') ? numbers.map((v) => v * 255) : numbers;
      return '#' + bytes.map((v) => Math.round(v).toString(16).padStart(2, '0').toUpperCase()).join('');
    };
    return { bg: hex(style.backgroundColor), accent: hex(style.color), scheme: style.colorScheme };
  }, id);
}

test.describe('system in light mode', () => {
  test.use({ colorScheme: 'light' });

  test('light by default, dark and light regions, the accent from the inherited pair', async ({ page }) => {
    await page.setContent(html);
    expect(await colours(page, 'root')).toEqual({ ...LIGHT, scheme: 'light' });
    expect(await colours(page, 'dark')).toEqual({ ...DARK, scheme: 'dark' });
    expect(await colours(page, 'light-in-dark')).toEqual({ ...LIGHT, scheme: 'light' });
    expect((await colours(page, 'pair-dark')).accent).toBe('#00FF00');
    expect((await colours(page, 'pair-light')).accent).toBe('#FF0000');
  });
});

test.describe('system in dark mode', () => {
  test.use({ colorScheme: 'dark' });

  test('dark by default, a light region stays light, the root can be forced light', async ({ page }) => {
    await page.setContent(html);
    expect(await colours(page, 'root')).toEqual({ ...DARK, scheme: 'dark' });
    expect(await colours(page, 'light-in-dark')).toEqual({ ...LIGHT, scheme: 'light' });
    await page.evaluate(() => (document.documentElement.dataset['theme'] = 'light'));
    expect(await colours(page, 'root')).toEqual({ ...LIGHT, scheme: 'light' });
    expect(await colours(page, 'dark')).toEqual({ ...DARK, scheme: 'dark' });
  });
});
