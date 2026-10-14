// material.css and the DOM helpers (DESIGN.md: Accent, Glass, Fallbacks): accent regions, the glass tint and its
// scopes, glass shadows, and the fallbacks of reduced transparency, high contrast, forced colours and print (G9).
import { expect, test, type Page } from '@playwright/test';

import { glass, light } from '../../packages/core/src/tokens.ts';
import { hex, open, rgba, style } from './support.ts';

const PAIR = { seed: '#2A9D8F', light: '#03786C', dark: '#2FA193' };
const OTHER = { seed: '#7A3FB0', light: '#7A3FB0', dark: '#B07BEA' };
const region = (pair: { light: string; dark: string }) =>
  `class="t-accent" style="--t-accent-light: ${pair.light}; --t-accent-dark: ${pair.dark}"`;

// the glass fill of DESIGN.md: glass mixed with the accent in sRGB at `share`, at the glass opacity
function glassFill(accent: string, share: number): number[] {
  const g = hex(light.color.glass);
  const a = hex(accent);
  return [...[0, 1, 2].map((i) => Math.round((g[i] ?? 0) * (1 - share) + (a[i] ?? 0) * share)), glass.opacity];
}

function setAccent(page: Page, id: string, pair: { seed: string | null; light: string; dark: string } | null) {
  return page.evaluate(
    ({ id, pair }) => {
      const { tsuya } = window as unknown as { tsuya: typeof import('../../packages/core/src/index.ts') };
      const element = document.getElementById(id);
      if (!element) throw new Error(`no #${id}`);
      if (pair) tsuya.setAccent(element, pair);
      else tsuya.clearAccent(element);
    },
    { id, pair },
  );
}

test.describe('accent regions', () => {
  test.use({ reducedMotion: 'reduce' });

  test('a region gives its pair for the nearest mode, and the neutral accent around it', async ({ page }) => {
    const probe = (id: string) => `<p id="${id}" style="color: var(--t-accent)">Aa</p>`;
    await open(
      page,
      `<div id="region">${probe('in')}<div data-theme="dark">${probe('in-dark')}<div id="inner">${probe('in-inner')}</div></div></div>${probe('out')}`,
    );
    await setAccent(page, 'region', PAIR);
    await setAccent(page, 'inner', OTHER);
    expect(await rgba(page, '#in', 'color')).toEqual(hex(PAIR.light));
    expect(await rgba(page, '#in-dark', 'color')).toEqual(hex(PAIR.dark));
    expect(await rgba(page, '#in-inner', 'color')).toEqual(hex(OTHER.dark));
    expect(await rgba(page, '#out', 'color')).toEqual(hex(light.color.accent));
    await setAccent(page, 'region', null);
    expect(await rgba(page, '#in', 'color')).toEqual(hex(light.color.accent));
  });

  test('with reduced motion a new pair comes at once', async ({ page }) => {
    await open(page, `<div id="region" ${region(PAIR)}></div>`);
    await setAccent(page, 'region', OTHER);
    expect(await page.evaluate(() => document.getElementById('region')?.getAnimations().length)).toBe(0);
  });
});

test('a new pair cross-fades over --t-duration-accent, frame by frame, with no CSS animation', async ({ page }) => {
  await open(page, `<div id="region" ${region(PAIR)}></div>`);
  // setAccent, then what the region says each frame until the fade ends, in one go in the page
  const fade = await page.evaluate(
    (pair) =>
      new Promise<{ first: string; animations: number; changed: boolean; ms: number }>((resolve) => {
        const { tsuya } = window as unknown as { tsuya: typeof import('../../packages/core/src/index.ts') };
        const region = document.getElementById('region');
        if (!region) throw new Error('no #region');
        const start = performance.now();
        tsuya.setAccent(region, pair);
        const first = region.style.getPropertyValue('--t-accent-light');
        const animations = region.getAnimations().length;
        const before = getComputedStyle(region).getPropertyValue('--t-accent-light');
        let changed = false;
        const frame = () => {
          changed ||= getComputedStyle(region).getPropertyValue('--t-accent-light') !== before;
          if (region.style.getPropertyValue('--t-accent-light').startsWith('color-mix')) requestAnimationFrame(frame);
          else resolve({ first, animations, changed, ms: performance.now() - start });
        };
        requestAnimationFrame(frame);
      }),
    OTHER,
  );
  expect(fade.first).toMatch(/^color-mix\(in oklab, #7A3FB0 [\d.]+%, /);
  expect(fade.animations).toBe(0);
  expect(fade.changed).toBe(true);
  expect(fade.ms).toBeGreaterThanOrEqual(590);
  expect(await page.evaluate(() => document.getElementById('region')?.style.getPropertyValue('--t-accent-light'))).toBe(
    OTHER.light,
  );
  expect(await style(page, '#region', '--t-accent-light')).toMatch(/122, 63, 176|0\.478/);
});

test('clearAccent cross-fades back to the accent around, then gives the element back', async ({ page }) => {
  await open(page, `<div id="region" ${region(PAIR)}><p id="probe" style="color: var(--t-accent)">Aa</p></div>`);
  await setAccent(page, 'region', null);
  expect(await page.evaluate(() => document.getElementById('region')?.classList.contains('t-accent'))).toBe(true);
  await expect
    .poll(() => page.evaluate(() => document.getElementById('region')?.classList.contains('t-accent')), {
      timeout: 3000,
    })
    .toBe(false);
  expect(await rgba(page, '#probe', 'color')).toEqual(hex(light.color.accent));
});

test('glass takes the tint of a content pair, never of the neutral pair or in a neutral scope', async ({ page }) => {
  await open(
    page,
    `<div ${region(PAIR)}><div id="tinted" class="t-glass">a</div></div>
     <div ${region(PAIR)} data-accent="neutral"><div id="neutral-pair" class="t-glass">b</div></div>
     <div id="outside" class="t-glass">c</div>
     <div data-glass="neutral"><div ${region(PAIR)}><div id="scope" class="t-glass">d</div>
       <div data-glass="tinted"><div id="rescoped" class="t-glass">e</div></div></div></div>`,
  );
  const tinted = glassFill(PAIR.light, glass.tint);
  const neutral = glassFill(PAIR.light, 0);
  expect(await rgba(page, '#tinted', 'background-color')).toEqual(tinted);
  expect(await rgba(page, '#neutral-pair', 'background-color')).toEqual(neutral);
  expect(await rgba(page, '#outside', 'background-color')).toEqual(neutral);
  expect(await rgba(page, '#scope', 'background-color')).toEqual(neutral);
  expect(await rgba(page, '#rescoped', 'background-color')).toEqual(tinted);
  expect(await style(page, '#tinted', 'backdrop-filter')).toBe('blur(24px)');
});

test('glass has its shaded bottom edge and no lit top edge, and the shadow of what it is', async ({ page }) => {
  await open(page, '<div id="plain" class="t-glass">a</div><div id="bar" class="t-glass" data-shadow="md">b</div>');
  const plain = await style(page, '#plain', 'box-shadow');
  expect(plain.match(/inset/g)).toHaveLength(1);
  expect(plain).toMatch(/0px -1px 0px 0px inset|inset 0px -1px 0px/);
  const bar = await style(page, '#bar', 'box-shadow');
  expect(bar).toMatch(/0px 12px 32px 0px/);
  expect(bar.match(/inset/g)).toHaveLength(1);
});

const FALLBACK_BODY = `<div class="t-surface" style="height: 200px"><div class="t-ambient"></div>
  <div ${region(PAIR)}><div id="glass" class="t-glass">a</div><div id="control" class="t-glass-control">b</div></div></div>`;

async function expectOpaque(page: Page, grain: boolean) {
  expect((await rgba(page, '#glass', 'background-color'))[3]).toBe(1);
  expect(await style(page, '#glass', 'backdrop-filter')).toBe('none');
  expect(await style(page, '#control', 'backdrop-filter')).toBe('none');
  expect(await style(page, '.t-ambient', 'display')).toBe('none');
  expect(await style(page, '.t-surface', 'content', '::after')).toBe(grain ? '""' : 'none');
}

test('data-transparency="reduce": opaque glass, control glass as a surface, no ambient background', async ({
  page,
}) => {
  await open(page, `<div data-transparency="reduce">${FALLBACK_BODY}</div>`);
  await expectOpaque(page, true);
  expect(await rgba(page, '#glass', 'background-color')).toEqual([...glassFill(PAIR.light, glass.tint).slice(0, 3), 1]);
  expect(await rgba(page, '#control', 'background-color')).toEqual(hex(light.color.surface));
});

test('print: opaque glass, no ambient background, no grain', async ({ page }) => {
  await open(page, FALLBACK_BODY);
  await page.emulateMedia({ media: 'print' });
  await expectOpaque(page, false);
});

test('the system setting for reduced transparency', async ({ page, browserName }) => {
  test.skip(browserName !== 'chromium', 'only Chromium emulates prefers-reduced-transparency');
  const cdp = await page.context().newCDPSession(page);
  await cdp.send('Emulation.setEmulatedMedia', {
    features: [{ name: 'prefers-reduced-transparency', value: 'reduce' }],
  });
  await open(page, FALLBACK_BODY);
  await expectOpaque(page, true);
});

test.describe('high contrast', () => {
  test.use({ contrast: 'more' });

  test('opaque glass, no ambient background, no grain', async ({ page }) => {
    await open(page, FALLBACK_BODY);
    await expectOpaque(page, false);
  });
});

test.describe('forced colours', () => {
  test.use({ forcedColors: 'active' });

  test('no blur, no ambient background, no grain', async ({ page, browserName }) => {
    test.skip(browserName === 'firefox', 'Firefox does not emulate forced colours');
    await open(page, FALLBACK_BODY);
    expect(await style(page, '#glass', 'backdrop-filter')).toBe('none');
    expect(await style(page, '.t-ambient', 'display')).toBe('none');
    expect(await style(page, '.t-surface', 'content', '::after')).toBe('none');
  });
});
