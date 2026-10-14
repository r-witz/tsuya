// PageHeader and SectionHeader (DESIGN.md, PageHeader, SectionHeader; G5, G6, G7): type sizes, the count line, the
// responsive title, the ghost "see all" action, and wrapping when narrow.
import { expect, test } from 'vitest';
import { page } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { light } from '../../packages/core/src/tokens.ts';
import Headers from './fixtures/Headers.svelte';
import { rgbaOf, rgbaOfHex } from './support.ts';

const style = (element: Element, property: string) => getComputedStyle(element).getPropertyValue(property);
const box = (element: Element) => element.getBoundingClientRect();

test('the page title is an h1, the count line 8 below it, muted', async () => {
  await page.viewport(390, 800);
  const screen = await render(Headers);
  const header = screen.getByTestId('page-header').element();
  const title = header.querySelector('h1.t-page-header-title') as HTMLElement;
  const subtitle = header.querySelector('.t-page-header-subtitle') as HTMLElement;
  expect(title.textContent).toBe('Recently Added');
  expect(subtitle.textContent).toBe('412 albums · 3 208 tracks');
  expect(style(subtitle, 'margin-top')).toBe('8px');
  expect(rgbaOf(subtitle, 'color')).toEqual(rgbaOfHex(light.color.textMuted));
});

test('the title is display-s in a phone-wide container and display-m from the desktop breakpoint, whatever the window', async () => {
  await page.viewport(1280, 800);
  const screen = await render(Headers, { maxWidth: 'none' });
  const title = screen.getByTestId('page-header').element().querySelector('.t-page-header-title') as HTMLElement;
  // the header is the container the title asks: its own width, the page's padding included
  screen.container.style.width = '390px';
  expect(style(title, 'font-size')).toBe('34px');
  screen.container.style.width = '1100px';
  expect(style(title, 'font-size')).toBe('44px');
  // a narrow window around a wide container: the container decides
  await page.viewport(390, 800);
  expect(style(title, 'font-size')).toBe('44px');
});

test('large, the title is display-l from the desktop breakpoint', async () => {
  await page.viewport(1280, 800);
  const screen = await render(Headers, { large: true, maxWidth: 'none' });
  const title = screen.getByTestId('page-header').element().querySelector('.t-page-header-title') as HTMLElement;
  screen.container.style.width = '390px';
  expect(style(title, 'font-size')).toBe('34px');
  screen.container.style.width = '1100px';
  expect(style(title, 'font-size')).toBe('56px');
});

test('actions wrap under the title when the header is narrow, sit beside it when wide', async () => {
  await page.viewport(320, 800);
  const screen = await render(Headers);
  const header = screen.getByTestId('page-header').element();
  const heading = header.querySelector('.t-page-header-heading') as HTMLElement;
  const actions = header.querySelector('.t-page-header-actions') as HTMLElement;
  expect(box(actions).top).toBeGreaterThanOrEqual(box(heading).bottom);
  await page.viewport(900, 800);
  expect(box(actions).top).toBeLessThan(box(heading).bottom);
});

test('a section header: title-l title, a muted control count, and a ghost action at the end', async () => {
  const screen = await render(Headers);
  const header = screen.getByTestId('albums-header').element();
  const title = header.querySelector('h2.t-section-header-title') as HTMLElement;
  const count = header.querySelector('.t-section-header-count') as HTMLElement;
  expect(title.textContent).toBe('Albums');
  expect(style(title, 'font-size')).toBe('24px');
  expect(count.textContent).toBe('24');
  expect(style(count, 'font-size')).toBe('13px');
  expect(rgbaOf(count, 'color')).toEqual(rgbaOfHex(light.color.textMuted));
  const action = screen.getByRole('button', { name: 'See all' }).element();
  expect(action.classList.contains('t-button-ghost')).toBe(true);
  expect(action.classList.contains('t-button-sm')).toBe(true);
  // margin-inline-start: auto pushes it to the end of the row
  expect(box(action).right).toBeCloseTo(box(header).right, 0);
});

test('its margins: space-32 above, space-12 below', async () => {
  const screen = await render(Headers);
  const header = screen.getByTestId('albums-header').element();
  expect(style(header, 'margin-top')).toBe('32px');
  expect(style(header, 'margin-bottom')).toBe('12px');
});

test('a section header without a count or an action shows neither', async () => {
  const screen = await render(Headers);
  const header = screen.getByTestId('playlists-header').element();
  expect(header.querySelector('.t-section-header-count')).toBeNull();
  expect(header.querySelector('button')).toBeNull();
});

test('a press on the ghost action calls onclick', async () => {
  const pressed: string[] = [];
  const screen = await render(Headers, { onaction: (name: string) => pressed.push(name) });
  await screen.getByRole('button', { name: 'See all' }).click();
  expect(pressed).toEqual(['see-all']);
});
