// The bars (DESIGN.md, TopBar, ScreenBar; G5, G13, G14): the screen bar's back button, centred title on one line and
// caption, and the floating, sticky glass top bar with its navigation links.
import { beforeEach, expect, test } from 'vitest';
import { page } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light, radius } from '../../packages/core/src/tokens.ts';
import Bars from './fixtures/Bars.svelte';
import { hexOf, rgbaOf, rgbaOfHex } from './support.ts';

const box = (element: Element) => element.getBoundingClientRect();
const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);

beforeEach(async () => {
  await page.viewport(800, 600);
});

test('the screen bar: a round back button, the title centred on one line, a caption, one action', async () => {
  let backs = 0;
  const screen = await render(Bars, { subtitle: 'Shipped', onback: () => (backs += 1) });
  const bar = screen.getByTestId('screen-bar').element();
  expect(box(bar).height).toBe(56);
  const back = screen.getByRole('button', { name: 'Back' });
  // measured before a press, which scales it for a moment
  expect(box(back.element()).width).toBe(44);
  expect(style(back.element(), 'border-top-left-radius')).toBe(`${String(radius.full)}px`);
  await back.click();
  expect(backs).toBe(1);
  const title = screen.getByRole('heading', { level: 1, name: 'Order 1042' }).element();
  expect(style(title, 'font-size')).toBe('22px');
  expect(style(title, 'font-weight')).toBe('700');
  const [titleBox, barBox] = [box(title), box(bar)];
  expect(titleBox.left + titleBox.width / 2).toBeCloseTo(barBox.left + barBox.width / 2, 0);
  const caption = screen.getByText('Shipped').element();
  expect(style(caption, 'font-size')).toBe('12px');
  expect(rgbaOf(caption)).toEqual(rgbaOfHex(light.color.textMuted));
  await expect.element(screen.getByRole('button', { name: 'Share' })).toBeVisible();
});

test('a long title stays on one line, ends with an ellipsis and leaves the buttons their room', async () => {
  await page.viewport(390, 700);
  const screen = await render(Bars, { title: 'The order of a customer who bought far too many things at once' });
  const title = screen.getByRole('heading', { level: 1 }).element();
  expect(style(title, 'text-overflow')).toBe('ellipsis');
  expect(title.scrollWidth).toBeGreaterThan(title.clientWidth);
  expect(box(title).height).toBeLessThan(30);
  const share = box(screen.getByRole('button', { name: 'Share' }).element());
  expect(box(title).right).toBeLessThanOrEqual(share.left);
});

test('right to left, the back button is at the right and its arrow points right', async () => {
  const screen = await render(Bars, { dir: 'rtl' });
  const back = screen.getByRole('button', { name: 'Back' }).element();
  const bar = box(screen.getByTestId('screen-bar').element());
  expect(box(back).right).toBeCloseTo(bar.right, 0);
  expect(style(back.querySelector('svg') as Element, 'scale')).toBe('-1 1');
});

test('without onBack there is no back button', async () => {
  const screen = await render(Bars, { back: false });
  expect(screen.container.querySelector('.t-screen-bar button')).toBeNull();
});

test('the top bar: glass, floating 12 from the top and sides, sticky, bar tall; the current link stands out', async () => {
  const screen = await render(Bars);
  const bar = screen.getByTestId('top-bar').element();
  expect(bar.classList.contains('t-glass')).toBe(true);
  expect(style(bar, 'box-shadow')).not.toBe('none');
  expect(style(bar, 'border-top-left-radius')).toBe(`${String(radius.md)}px`);
  expect(box(bar).height).toBe(56);
  expect([box(bar).top, box(bar).left, innerWidth - box(bar).right]).toEqual([12, 12, 12]);
  scrollTo(0, 400);
  await expect.poll(() => box(bar).top).toBe(12);
  scrollTo(0, 0);
  const current = screen.getByRole('link', { name: 'Catalog' }).element();
  const other = screen.getByRole('link', { name: 'Help' }).element();
  expect(hexOf(current, 'background-color')).toBe(light.color.fillStrong.slice(0, 7));
  expect(rgbaOf(current)).toEqual(rgbaOfHex(light.color.text));
  expect(rgbaOf(other)).toEqual(rgbaOfHex(light.color.textMuted));
});

test('below the tablet width, the links move into a menu at the end, which a choice closes', async () => {
  await page.viewport(390, 700);
  const screen = await render(Bars);
  const bar = screen.getByTestId('top-bar').element();
  expect(bar.querySelector('.t-top-bar-links')?.checkVisibility()).toBe(false);
  const more = screen.getByRole('button', { name: 'More' });
  await more.click();
  const menu = screen.getByRole('dialog', { name: 'More' });
  await expect.element(menu).toBeVisible();
  // hidden, they leave the accessibility tree: kept by their elements
  const [button, panel] = [more.element(), menu.element()];
  const current = menu.getByRole('link', { name: 'Catalog' }).element();
  expect(current.getAttribute('aria-current')).toBe('page');
  expect(hexOf(current, 'background-color')).toBe(light.color.fillStrong.slice(0, 7));
  expect(box(current).height).toBe(44);
  await menu.getByRole('link', { name: 'Help' }).click();
  await expect.poll(() => panel.matches(':popover-open')).toBe(false);
  await page.viewport(800, 700);
  expect(bar.querySelector('.t-top-bar-links')?.checkVisibility()).toBe(true);
  expect(button.checkVisibility()).toBe(false);
});

test("the links fold into the menu by the bar's container, not the window", async () => {
  await page.viewport(1280, 700);
  // WebKit resolves a container query at the next rendering update, not on a synchronous read: poll
  const screen = await render(Bars);
  const bar = screen.getByTestId('top-bar').element();
  const more = bar.querySelector('.t-top-bar-compact') as HTMLElement;
  screen.container.style.width = '390px';
  await expect.poll(() => bar.querySelector('.t-top-bar-links')?.checkVisibility()).toBe(false);
  await expect.poll(() => more.checkVisibility()).toBe(true);
  screen.container.style.width = '1000px';
  await expect.poll(() => bar.querySelector('.t-top-bar-links')?.checkVisibility()).toBe(true);
  await expect.poll(() => more.checkVisibility()).toBe(false);
  // a narrow window around a wide container: the container decides
  await page.viewport(390, 700);
  await expect.poll(() => bar.querySelector('.t-top-bar-links')?.checkVisibility()).toBe(true);
  await expect.poll(() => more.checkVisibility()).toBe(false);
});

test("the links fold below the tablet width of the bar's container, its margins included", async () => {
  const screen = await render(Bars);
  const bar = screen.getByTestId('top-bar').element();
  screen.container.style.width = '600px';
  await expect.poll(() => bar.querySelector('.t-top-bar-links')?.checkVisibility()).toBe(true);
  screen.container.style.width = '599px';
  await expect.poll(() => bar.querySelector('.t-top-bar-links')?.checkVisibility()).toBe(false);
});

test('a top bar whose links do not fit between its start and end scrolls them, and never overlaps either', async () => {
  // above the tablet width, so the links are not in the menu, but ten of them are wider than the room left
  await page.viewport(700, 640);
  const screen = await render(Bars, { extraLinks: 10 });
  const bar = screen.getByTestId('top-bar').element();
  const [start, centre, end] = ['.t-top-bar-start', '.t-top-bar-center', '.t-top-bar-end'].map(
    (s) => bar.querySelector(s) as HTMLElement,
  ) as [HTMLElement, HTMLElement, HTMLElement];
  const [startBox, centreBox, endBox] = [start, centre, end].map((el) => el.getBoundingClientRect()) as [
    DOMRect,
    DOMRect,
    DOMRect,
  ];
  expect(startBox.right).toBeLessThanOrEqual(centreBox.left);
  expect(centreBox.right).toBeLessThanOrEqual(endBox.left);
  expect(getComputedStyle(centre).overflowX).toBe('auto');
  expect(centre.scrollWidth).toBeGreaterThan(centre.clientWidth);
  // the last link is reached by the keyboard: focusing it scrolls it into the middle
  const last = screen.getByRole('link', { name: 'Section 10' }).element() as HTMLElement;
  last.focus();
  await expect.poll(() => centre.scrollLeft).toBeGreaterThan(0);
  const [lastBox, nowBox] = [last.getBoundingClientRect(), centre.getBoundingClientRect()];
  expect(lastBox.right).toBeLessThanOrEqual(nowBox.right + 1);
  expect(lastBox.left).toBeGreaterThanOrEqual(nowBox.left - 1);
});

test('a top bar whose links fit keeps them centred between its start and end', async () => {
  await page.viewport(800, 640);
  const screen = await render(Bars);
  const bar = screen.getByTestId('top-bar').element();
  const centre = bar.querySelector('.t-top-bar-center') as HTMLElement;
  expect(centre.scrollWidth).toBeLessThanOrEqual(centre.clientWidth);
  const links = bar.querySelector('.t-top-bar-links') as HTMLElement;
  const [linksBox, centreBox] = [links.getBoundingClientRect(), centre.getBoundingClientRect()];
  expect(linksBox.left + linksBox.width / 2).toBeCloseTo(centreBox.left + centreBox.width / 2, 0);
});
