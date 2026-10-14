// System settings (G9): under reduced motion a panel opens at once; in forced colours, where fills disappear, the
// active option, focused fields, a tooltip and the current item of a navigation keep an outline.
import { afterEach, expect, test } from 'vitest';
import { commands, page, server, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { toastState } from '../../packages/svelte/src/lib/components/toast/state.svelte.ts';
import Bars from './fixtures/Bars.svelte';
import Comboboxes from './fixtures/Comboboxes.svelte';
import Dialogs from './fixtures/Dialogs.svelte';
import Selects from './fixtures/Selects.svelte';
import Sidebars from './fixtures/Sidebars.svelte';
import TabBars from './fixtures/TabBars.svelte';
import Sheets from './fixtures/Sheets.svelte';
import Toasts from './fixtures/Toasts.svelte';
import Tooltips from './fixtures/Tooltips.svelte';

const outline = (element: Element) => getComputedStyle(element).outlineStyle;

afterEach(async () => {
  // a singleton outside any component: a toast would outlive the test that showed it
  toastState.current = null;
  await commands.emulateMedia({ reducedMotion: null, forcedColors: null });
});

test('reduced motion: a panel opens at once', async () => {
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  await page.viewport(800, 600);
  const screen = await render(Selects);
  await screen.getByRole('combobox', { name: 'Country' }).click();
  const panel = screen.getByRole('listbox', { name: 'Country' }).element();
  expect(panel.getAnimations()).toEqual([]);
  expect(getComputedStyle(panel).opacity).toBe('1');
});

test('reduced motion: a dialog opens at once', async () => {
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  await page.viewport(800, 600);
  const screen = await render(Dialogs);
  await screen.getByRole('button', { name: 'Delete photo' }).click();
  const dialog = screen.getByRole('dialog').element();
  expect(dialog.getAnimations()).toEqual([]);
  expect(getComputedStyle(dialog).opacity).toBe('1');
});

test('reduced motion: a sheet opens at once', async () => {
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  await page.viewport(800, 600);
  const screen = await render(Sheets);
  await screen.getByRole('button', { name: 'Share' }).click();
  const sheet = screen.getByRole('dialog').element();
  expect(sheet.getAnimations()).toEqual([]);
  expect(getComputedStyle(sheet).translate).toBe('none');
});

test('reduced motion: a toast appears at once', async () => {
  await commands.emulateMedia({ reducedMotion: 'reduce' });
  await page.viewport(800, 600);
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Notify' }).click();
  const toast = screen.getByRole('status').element();
  expect(toast.getAnimations()).toEqual([]);
  expect(getComputedStyle(toast).opacity).toBe('1');
});

// Firefox does not emulate forced colours (tests/web/base.spec.ts skips it too)
test.skipIf(server.browser === 'firefox')(
  'forced colours: the active option, a focused field and a focused trigger keep an outline',
  async () => {
    await page.viewport(800, 600);
    const screen = await render(Comboboxes);
    const input = screen.getByRole('combobox', { name: 'City' });
    await input.click();
    await userEvent.keyboard('{ArrowDown}');
    const active = () => document.getElementById(input.element().getAttribute('aria-activedescendant') ?? '');
    const field = input.element().closest('.t-text-input') as Element;
    // without forced colours, the fill marks them
    expect(outline(active() as Element)).toBe('none');
    expect(outline(field)).toBe('none');
    await commands.emulateMedia({ forcedColors: 'active' });
    expect(outline(active() as Element)).toBe('solid');
    expect(outline(field)).toBe('solid');
    await screen.unmount();
    const selects = await render(Selects);
    selects.getByRole('button', { name: 'After' }).element().focus();
    await userEvent.tab({ shift: true });
    await expect.element(selects.getByRole('combobox', { name: 'Country' })).toHaveFocus();
    expect(outline(selects.getByRole('combobox', { name: 'Country' }).element())).toBe('solid');
  },
);

test.skipIf(server.browser === 'firefox')('forced colours: a tooltip keeps an edge', async () => {
  const screen = await render(Tooltips);
  (screen.getByRole('button', { name: 'Before' }).element() as HTMLElement).focus();
  await userEvent.tab();
  const tip = screen.getByRole('tooltip').element();
  expect(outline(tip)).toBe('none');
  await commands.emulateMedia({ forcedColors: 'active' });
  expect(outline(tip)).toBe('solid');
});

test.skipIf(server.browser === 'firefox')(
  'forced colours: a toast keeps an edge (a transparent border, which they paint)',
  async () => {
    await page.viewport(800, 600);
    const screen = await render(Toasts);
    await screen.getByRole('button', { name: 'Notify' }).click();
    const toast = screen.getByRole('status').element();
    await commands.emulateMedia({ forcedColors: 'active' });
    const style = getComputedStyle(toast);
    expect(style.borderTopStyle).toBe('solid');
    expect(parseFloat(style.borderTopWidth)).toBeGreaterThan(0);
    // WebKit's emulation leaves the computed colour as written
    if (server.browser === 'chromium') expect(style.borderTopColor).not.toBe('rgba(0, 0, 0, 0)');
  },
);

test.skipIf(server.browser === 'firefox')('forced colours: the current tab of a tab bar keeps an edge', async () => {
  const screen = await render(TabBars);
  const home = screen.getByRole('tab', { name: 'Home' }).element();
  expect(outline(home)).toBe('none');
  await commands.emulateMedia({ forcedColors: 'active' });
  expect(outline(home)).toBe('solid');
});

test.skipIf(server.browser === 'firefox')(
  'forced colours: the current item of a sidebar and the current link of a top bar keep an edge',
  async () => {
    await page.viewport(1024, 800);
    const sidebar = await render(Sidebars);
    const home = sidebar.getByRole('link', { name: 'Home' }).element();
    const albums = sidebar.getByRole('link', { name: 'Albums 12' }).element();
    const bars = await render(Bars);
    const current = bars.container.querySelector('.t-top-bar a[aria-current="page"]') as Element;
    const other = bars.container.querySelector('.t-top-bar .t-top-bar-links a:not([aria-current])') as Element;
    expect([home, current].map(outline)).toEqual(['none', 'none']);
    await commands.emulateMedia({ forcedColors: 'active' });
    expect([home, albums, current, other].map(outline)).toEqual(['solid', 'none', 'solid', 'none']);
  },
);
