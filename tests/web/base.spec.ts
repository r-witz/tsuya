// base.css (DESIGN.md: Type, States, TextField): the page, the type helpers, the keyboard focus ring, the field box,
// and the pressable primitive's target, press feedback and disabled state (G2, G3, G6, G9).
import { expect, test } from '@playwright/test';

import { light, type } from '../../packages/core/src/tokens.ts';
import { hex, open, rgba, style } from './support.ts';

const kebab = (name: string) => name.replace(/[A-Z]/g, (c) => `-${c.toLowerCase()}`);

test('the page takes the background, the text colour and the body style', async ({ page }) => {
  await open(page, '<p id="text">tsuya</p>');
  expect(await rgba(page, 'html', 'background-color')).toEqual(hex(light.color.bg));
  expect(await rgba(page, '#text', 'color')).toEqual(hex(light.color.text));
  expect(await style(page, '#text', 'font-size')).toBe(`${String(type.body.fontSize)}px`);
});

test('every type style has its helper class, with its size, weight and tracking', async ({ page }) => {
  const names = Object.keys(type);
  await open(page, names.map((name) => `<p class="t-${kebab(name)}">Aa</p>`).join(''));
  for (const [name, value] of Object.entries(type)) {
    const selector = `.t-${kebab(name)}`;
    expect(await style(page, selector, 'font-size'), name).toBe(`${String(value.fontSize)}px`);
    expect(await style(page, selector, 'font-weight'), name).toBe(String(value.fontWeight));
    const tracking = await style(page, selector, 'letter-spacing');
    expect(tracking === 'normal' ? 0 : parseFloat(tracking), name).toBeCloseTo(value.letterSpacing, 2);
  }
  expect(await style(page, '.t-label', 'text-transform')).toBe('uppercase');
});

// .t-button is also the root of a Button, whose styles are in tsuya.css too: a helper alone takes none of them
test("a type helper gives any text its type style only, never a component's", async ({ page }) => {
  const names = Object.keys(type);
  await open(page, `<p id="plain">Aa</p>${names.map((name) => `<p class="t-${kebab(name)}">Aa</p>`).join('')}`);
  for (const property of ['display', 'min-height', 'padding-left', 'border-top-width', 'border-top-left-radius']) {
    const plain = await style(page, '#plain', property);
    for (const name of names)
      expect(await style(page, `.t-${kebab(name)}`, property), `${name}: ${property}`).toBe(plain);
  }
});

test('keyboard focus draws the ring in the accent, its gap in bg; a click does not', async ({ page }) => {
  // controls drawn by the page, as tsuya's are: WebKit draws no box-shadow on a button of native appearance
  await open(
    page,
    '<button id="first" style="appearance: none">One</button> <button id="second" style="appearance: none">Two</button>',
  );
  await page.keyboard.press('Tab');
  expect(await style(page, '#first', 'outline-style')).toBe('solid');
  expect(await style(page, '#first', 'outline-width')).toBe('2px');
  expect(await style(page, '#first', 'outline-offset')).toBe('2px');
  expect(await rgba(page, '#first', 'outline-color')).toEqual(hex(light.color.accent));
  // the gap: a box-shadow of focus-offset in bg
  const shadow = await style(page, '#first', 'box-shadow');
  expect(shadow).toMatch(/0px 0px 0px 2px/);
  await page.click('#second');
  expect(await style(page, '#second', 'outline-style')).toBe('none');
});

test('the field box: its boundary, accent when focused, danger with an error, focused too', async ({ page }) => {
  await open(
    page,
    '<input id="name" class="t-field-box" aria-label="Name"> <textarea id="notes" class="t-field-box" aria-label="Notes" aria-invalid="true"></textarea>',
  );
  // the colours without their alpha, which engines round differently
  const rgb = async (selector: string, property: string) => (await rgba(page, selector, property)).slice(0, 3);
  expect(await rgb('#name', 'border-top-color')).toEqual(hex(light.color.borderStrong).slice(0, 3));
  expect(await rgb('#notes', 'border-top-color')).toEqual(hex(light.color.danger).slice(0, 3));
  for (const [selector, colour] of [
    ['#name', light.color.accent],
    ['#notes', light.color.danger],
  ] as const) {
    await page.keyboard.press('Tab');
    expect(await rgb(selector, 'border-top-color')).toEqual(hex(colour).slice(0, 3));
    // focus-width thick inside the box, instead of the ring outside it
    expect(await rgb(selector, 'box-shadow')).toEqual(hex(colour).slice(0, 3));
    expect(await style(page, selector, 'box-shadow')).toMatch(/ 0px 0px 0px 1px inset$/);
    expect(await style(page, selector, 'outline-style')).toBe('none');
  }
});

test.describe('pressable', () => {
  const body = `<button id="small" class="t-pressable" style="width: 16px; height: 16px; padding: 0"></button>
    <button id="large" class="t-pressable" style="width: 80px; height: 40px">Save</button>
    <button id="row" class="t-pressable" data-press="highlight" style="width: 200px; height: 40px">Row</button>
    <button id="off" class="t-pressable" disabled>Off</button>`;

  test('the target is at least --t-size-target-pointer with a mouse, never smaller than the drawing', async ({
    page,
  }) => {
    await open(page, body);
    expect(await style(page, '#small', 'width', '::after')).toBe('24px');
    expect(await style(page, '#small', 'height', '::after')).toBe('24px');
    // a larger control keeps its own box: the target takes its padding box, the control answers on its border
    expect(parseFloat(await style(page, '#large', 'width', '::after'))).toBeGreaterThan(24);
    // the target answers: a press inside it but outside the drawing lands on the control
    const box = await page.locator('#small').boundingBox();
    if (!box) throw new Error('no box');
    const hit = await page.evaluate(({ x, y }) => document.elementFromPoint(x, y)?.id, {
      x: box.x + box.width + 3,
      y: box.y + box.height / 2,
    });
    expect(hit).toBe('small');
  });

  test('the target is under the drawing: a pressable label lets its input take presses, and takes those around it', async ({
    page,
  }) => {
    await open(
      page,
      `<label id="label" class="t-pressable" data-press="none" style="display: inline-block; margin: 20px">
        <input id="input" type="checkbox" style="display: block; width: 16px; height: 16px; margin: 0"></label>`,
    );
    const box = await page.locator('#input').boundingBox();
    if (!box) throw new Error('no box');
    const at = (x: number, y: number) =>
      page.evaluate(([px, py]) => document.elementFromPoint(px, py)?.id, [x, y] as const);
    expect(await at(box.x + 8, box.y + 8)).toBe('input');
    expect(await at(box.x + box.width + 3, box.y + 8)).toBe('label');
    await page.mouse.click(box.x + box.width + 3, box.y + 8);
    expect(await page.isChecked('#input')).toBe(true);
  });

  test('a pressed control shrinks, a pressed row takes fill-strong, a disabled one fades', async ({ page }) => {
    await open(page, body);
    await page.hover('#large');
    await page.mouse.down();
    await expect.poll(() => style(page, '#large', 'scale')).toBe('0.96');
    await page.mouse.up();
    await page.hover('#row');
    await page.mouse.down();
    // after the fast transition from the hover fill
    await expect.poll(() => rgba(page, '#row', 'background-color')).toEqual(hex(light.color.fillStrong));
    await page.mouse.up();
    expect(await style(page, '#off', 'opacity')).toBe('0.38');
  });
});

test.describe('pressable with reduced motion', () => {
  test.use({ reducedMotion: 'reduce' });

  test('nothing scales', async ({ page }) => {
    await open(page, '<button id="b" class="t-pressable">Save</button>');
    await page.hover('#b');
    await page.mouse.down();
    expect(await style(page, '#b', 'scale')).toBe('none');
    expect(await style(page, '#b', 'transition-duration')).toBe('0s');
  });
});

test.describe('pressable on touch', () => {
  test.use({ hasTouch: true, isMobile: true, viewport: { width: 390, height: 844 } });

  test('the target is at least --t-size-target', async ({ page, browserName }) => {
    test.skip(browserName === 'firefox', 'Firefox does not emulate a mobile device');
    await open(page, '<button id="small" class="t-pressable" style="width: 16px; height: 16px; padding: 0"></button>');
    expect(await style(page, '#small', 'width', '::after')).toBe('44px');
  });
});
