// Reflow (G7): at 320 px wide, as at 400 % zoom of a 1280 px window, the scenarios (scenarios.ts) fit without a
// horizontal scroll, and what opens stays inside the window (--t-space-16 for panels and dialogs); anchored panels stay
// --t-space-16 inside a narrow window whatever the width of their trigger (G8).
import { beforeEach, expect, test } from 'vitest';
import { page, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import Anchoring from './fixtures/Anchoring.svelte';
import Bars from './fixtures/Bars.svelte';
import Headers from './fixtures/Headers.svelte';
import LongMenu from './fixtures/LongMenu.svelte';
import LongTip from './fixtures/LongTip.svelte';
import SegmentedControls from './fixtures/SegmentedControls.svelte';
import TabBars from './fixtures/TabBars.svelte';
import { SCENARIOS } from './scenarios.ts';

const WIDTH = 320;
const scrolls = () => document.documentElement.scrollWidth > document.documentElement.clientWidth;

beforeEach(async () => {
  await page.viewport(WIDTH, 640);
});

test.each(SCENARIOS.filter((scenario) => !scenario.skip?.reflow))(
  '$name',
  async ({ fixture, props, fit, open, inset }) => {
    const screen = await render(fixture, props);
    expect(scrolls()).toBe(false);
    for (const element of fit === undefined ? [] : screen.container.querySelectorAll(fit)) {
      expect(element.getBoundingClientRect().right).toBeLessThanOrEqual(WIDTH);
    }
    if (!open) return;
    const box = (await open(screen)).getBoundingClientRect();
    if (inset !== undefined) {
      expect(box.left).toBeGreaterThanOrEqual(inset);
      expect(box.right).toBeLessThanOrEqual(WIDTH - inset);
    }
    expect(scrolls()).toBe(false);
  },
);

test('a section header with a count and an action wraps them under the title at the width of 300 % text', async () => {
  // a 320 px screen at 300 % text leaves a title the room of 1x text in about 100 px
  await page.viewport(140, 640);
  const screen = await render(Headers);
  const header = screen.container.querySelector('[data-testid="albums-header"]') as HTMLElement;
  for (const part of header.children) {
    expect(part.getBoundingClientRect().right).toBeLessThanOrEqual(140);
  }
});

test('a top bar whose brand and labelled button do not fit side by side grows a row', async () => {
  // the room of a 320 px screen at 300 % text, for a brand and a button
  await page.viewport(200, 640);
  const screen = await render(Bars, { labelled: true });
  const bar = screen.getByTestId('top-bar').element().getBoundingClientRect();
  expect(bar.height).toBeGreaterThan(56);
  for (const part of screen.container.querySelectorAll(
    '[data-testid="top-bar"] .t-top-bar-start, .t-top-bar-end, .t-top-bar-compact',
  )) {
    const rect = part.getBoundingClientRect();
    expect(rect.left, part.className).toBeGreaterThanOrEqual(bar.left);
    expect(rect.right, part.className).toBeLessThanOrEqual(bar.right);
  }
});

test('a segmented control that does not fit shrinks its segments and wraps their labels', async () => {
  const screen = await render(SegmentedControls, { long: true });
  expect(scrolls()).toBe(false);
  const track = screen.getByRole('radiogroup').element().getBoundingClientRect();
  expect(track.right).toBeLessThanOrEqual(WIDTH);
  for (const segment of screen.container.querySelectorAll('.t-segmented-segment')) {
    // no label is clipped by its segment, which stays inside the track
    expect(segment.scrollWidth).toBeLessThanOrEqual(segment.clientWidth);
    expect(segment.getBoundingClientRect().right).toBeLessThanOrEqual(track.right);
  }
});

test('a tab bar of five long labels fits, its labels cut with an ellipsis', async () => {
  const screen = await render(TabBars, { crowded: true });
  expect(scrolls()).toBe(false);
  const bar = screen.getByRole('tablist').element().getBoundingClientRect();
  expect(bar.right).toBeLessThanOrEqual(WIDTH);
  const label = screen
    .getByRole('tab', { name: 'Your music library' })
    .element()
    .querySelector('.t-tab-bar-label') as HTMLElement;
  expect(label.scrollWidth).toBeGreaterThan(label.clientWidth);
});

test('G7: panels with a long label stay --t-space-16 inside the window, a menu item ellipsized', async () => {
  const screen = await render(LongMenu);
  const inside = (box: DOMRect) => {
    expect(box.left).toBeGreaterThanOrEqual(16);
    expect(box.right).toBeLessThanOrEqual(WIDTH - 16);
  };
  await screen.getByRole('button', { name: 'Actions' }).click();
  const menu = screen.getByRole('menu').element();
  inside(menu.getBoundingClientRect());
  const label = menu.querySelector('.t-menu-item-label') as HTMLElement;
  expect(label.scrollWidth).toBeGreaterThan(label.clientWidth);
  await userEvent.keyboard('{Escape}');
  await screen.getByRole('button', { name: 'Info' }).click();
  inside(screen.getByRole('dialog').element().getBoundingClientRect());
  await userEvent.keyboard('{Escape}');
  await screen.getByRole('combobox', { name: 'Pick' }).click();
  inside(screen.getByRole('listbox', { name: 'Pick' }).element().getBoundingClientRect());
  await userEvent.keyboard('{Escape}');
  await screen.getByRole('combobox', { name: 'Search' }).click();
  await userEvent.keyboard('{ArrowDown}');
  inside(
    screen.getByRole('listbox', { name: 'Search' }).element().closest('.t-panel')?.getBoundingClientRect() as DOMRect,
  );
  expect(scrolls()).toBe(false);
});

test('G7: a long tooltip near the edge stays --t-space-16 inside the window', async () => {
  const screen = await render(LongTip);
  await userEvent.tab();
  await expect.element(screen.getByRole('tooltip')).toBeVisible();
  const box = screen.getByRole('tooltip').element().getBoundingClientRect();
  expect(box.left).toBeGreaterThanOrEqual(16);
  expect(box.right).toBeLessThanOrEqual(WIDTH - 16);
});

for (const dir of ['ltr', 'rtl'] as const) {
  for (const width of [304, 320]) {
    test(`G7: a select and a combobox ${String(width)} wide have their panel --t-space-16 inside the window, ${dir}`, async () => {
      const inside = (box: DOMRect) => {
        expect(box.left).toBeGreaterThanOrEqual(16 - 0.01);
        expect(box.right).toBeLessThanOrEqual(WIDTH - 16 + 0.01);
      };
      const select = await render(Anchoring, { kind: 'select', width, dir });
      await select.getByRole('combobox', { name: 'Pick' }).click();
      inside(
        select.getByRole('listbox', { name: 'Pick' }).element().closest('.t-panel')?.getBoundingClientRect() as DOMRect,
      );
      await select.unmount();
      const combobox = await render(Anchoring, { kind: 'combobox', width, dir });
      await combobox.getByRole('combobox', { name: 'Search' }).click();
      await userEvent.keyboard('{ArrowDown}');
      inside(
        combobox
          .getByRole('listbox', { name: 'Search' })
          .element()
          .closest('.t-panel')
          ?.getBoundingClientRect() as DOMRect,
      );
    });
  }
}

test('G7: a menu in a window narrower than 252 px stays --t-space-16 inside it', async () => {
  await page.viewport(240, 640);
  const screen = await render(Anchoring, { kind: 'menu', pad: 16 });
  await screen.getByRole('button', { name: 'Actions' }).click();
  const box = screen.getByRole('menu').element().getBoundingClientRect();
  expect(box.left).toBeGreaterThanOrEqual(16 - 0.01);
  expect(box.right).toBeLessThanOrEqual(240 - 16 + 0.01);
});

for (const dir of ['ltr', 'rtl'] as const) {
  test(`G7: a long tooltip on the start side of a centred trigger takes the room there is, ${dir}`, async () => {
    const screen = await render(Anchoring, { kind: 'tooltip', align: 'center', dir });
    await userEvent.tab();
    await expect.element(screen.getByRole('tooltip')).toBeVisible();
    const box = screen.getByRole('tooltip').element().getBoundingClientRect();
    expect(box.left).toBeGreaterThanOrEqual(16 - 0.01);
    expect(box.right).toBeLessThanOrEqual(WIDTH - 16 + 0.01);
    expect(scrolls()).toBe(false);
  });
}
