// The scenarios the checks across components run on (a11y.test.ts, targets.test.ts, reflow.test.ts): a fixture, its
// props, and how to open what it opens. Each check renders every scenario, checks it, then opens it and checks what
// opened.
import type { Component } from 'svelte';
import { expect } from 'vitest';
import { page, userEvent, type Locator } from 'vitest/browser';
import type { RenderResult } from 'vitest-browser-svelte';

import Accordions from './fixtures/Accordions.svelte';
import Avatars from './fixtures/Avatars.svelte';
import Badges from './fixtures/Badges.svelte';
import Banners from './fixtures/Banners.svelte';
import Bars from './fixtures/Bars.svelte';
import Buttons from './fixtures/Buttons.svelte';
import Checkboxes from './fixtures/Checkboxes.svelte';
import Chips from './fixtures/Chips.svelte';
import Comboboxes from './fixtures/Comboboxes.svelte';
import CommandPalettes from './fixtures/CommandPalettes.svelte';
import Dialogs from './fixtures/Dialogs.svelte';
import Form from './fixtures/Form.svelte';
import Headers from './fixtures/Headers.svelte';
import Lists from './fixtures/Lists.svelte';
import Menus from './fixtures/Menus.svelte';
import Popovers from './fixtures/Popovers.svelte';
import Progresses from './fixtures/Progresses.svelte';
import RadioGroups from './fixtures/RadioGroups.svelte';
import Screens from './fixtures/Screens.svelte';
import SegmentedControls from './fixtures/SegmentedControls.svelte';
import Selects from './fixtures/Selects.svelte';
import Sheets from './fixtures/Sheets.svelte';
import Sidebars from './fixtures/Sidebars.svelte';
import Skeletons from './fixtures/Skeletons.svelte';
import Sliders from './fixtures/Sliders.svelte';
import Switches from './fixtures/Switches.svelte';
import TabBars from './fixtures/TabBars.svelte';
import Tabbed from './fixtures/Tabbed.svelte';
import Thumbnails from './fixtures/Thumbnails.svelte';
import Toasts from './fixtures/Toasts.svelte';
import Tooltips from './fixtures/Tooltips.svelte';

export interface Scenario {
  name: string;
  fixture: Component;
  props?: Record<string, unknown>;
  /** The window it needs, a phone or a desktop; reflow.test.ts always takes a narrow one. */
  viewport?: [number, number];
  /** Opens what it opens and gives it (a panel, a dialog, a sheet, a toast), once it has come in. */
  open?: (screen: RenderResult<Component>) => Promise<HTMLElement>;
  /** For reflow.test.ts: the elements that end inside a narrow window, besides the page not scrolling. */
  fit?: string;
  /** For reflow.test.ts: how far inside a narrow window what opens stays. */
  inset?: number;
  /** The checks that leave it out, and why. */
  skip?: Partial<Record<'a11y' | 'targets' | 'reflow', string>>;
}

// what opened, once it is shown and every entrance has ended (its own, and that of a sheet it rises in): measured where
// it stays, audited at its final contrast
async function shown(opened: Locator | Element): Promise<HTMLElement> {
  const locator = opened instanceof Element ? page.elementLocator(opened) : opened;
  await expect.element(locator).toBeVisible();
  const ending = document
    .getAnimations()
    .filter((animation) => animation.effect?.getComputedTiming().endTime !== Infinity);
  await Promise.allSettled(ending.map((animation) => animation.finished));
  return locator.element() as HTMLElement;
}

const press =
  (name: string, role: 'button' | 'combobox' = 'button') =>
  async (screen: RenderResult<Component>) => {
    await screen.getByRole(role, { name }).click();
  };

const openSelect = async (screen: RenderResult<Component>) => {
  await press('Country', 'combobox')(screen);
  await userEvent.keyboard('{ArrowDown}');
  return shown(screen.getByRole('listbox', { name: 'Country' }));
};

// the panel, which holds the listbox, or the status when nothing is found
const openCombobox = (typed: string) => async (screen: RenderResult<Component>) => {
  await press('City', 'combobox')(screen);
  await userEvent.keyboard(`{ArrowDown}${typed}`);
  return shown(screen.getByRole('listbox', { name: 'City' }).element().closest('.t-panel') as Element);
};

const opening =
  (trigger: string, role: 'dialog' | 'alertdialog' | 'menu' | 'status', name?: string, typed = '') =>
  async (screen: RenderResult<Component>) => {
    await press(trigger)(screen);
    if (typed) await userEvent.keyboard(typed);
    return shown(screen.getByRole(role, name === undefined ? {} : { name }));
  };

export const SCENARIOS: Scenario[] = [
  { name: 'avatars: a photo, initials, a passing and a failing gradient, a broken photo', fixture: Avatars },
  { name: 'badges, standalone and pinned on an icon button and an avatar', fixture: Badges },
  {
    name: 'fields with an error and a clear button, and a search field',
    fixture: Form,
    props: { error: 'Enter an email address, such as name@company.com', clearable: true, email: 'a@b.c' },
    fit: '.t-field-box',
  },
  { name: 'buttons of every variant and size', fixture: Buttons },
  { name: 'buttons, loading and pressed', fixture: Buttons, props: { loading: true, pressed: true } },
  { name: 'a list of rows, sections, a current and a destructive row', fixture: Lists, fit: '.t-list-item' },
  { name: 'a page header with actions, and section headers', fixture: Headers, fit: '.t-page-header' },
  { name: 'thumbnails: loaded, empty and broken, every ratio and radius tier', fixture: Thumbnails },
  { name: 'progress bars: determinate, thin, indeterminate, and a toggling one', fixture: Progresses },
  { name: 'skeletons: a row placeholder and paragraphs of skeleton text', fixture: Skeletons },
  {
    name: 'an accordion, an item open and one disabled',
    fixture: Accordions,
    props: { type: 'multiple', value: ['returns'], disabled: 'warranty' },
  },
  {
    name: 'an accordion, every item open',
    fixture: Accordions,
    props: { type: 'multiple', value: ['shipping', 'returns', 'warranty'] },
  },
  { name: 'a top bar and a screen bar', fixture: Bars, props: { subtitle: 'Shipped' } },
  { name: 'a top bar with its links in a menu, on a phone', fixture: Bars, viewport: [390, 700] },
  { name: 'a sidebar', fixture: Sidebars },
  { name: 'a sidebar, collapsed', fixture: Sidebars, props: { collapsed: true } },
  { name: 'a phone screen', fixture: Screens, props: { rows: 3 } },
  { name: 'tabs, one disabled', fixture: Tabbed, props: { disabled: 'Details' } },
  { name: 'a row of tabs too long for the window', fixture: Tabbed, props: { many: true } },
  { name: 'chips', fixture: Chips },
  { name: 'chips, one on, disabled', fixture: Chips, props: { filters: ['sale'], disabled: true } },
  { name: 'checkboxes, checked', fixture: Checkboxes, props: { checked: true } },
  { name: 'radios', fixture: RadioGroups },
  { name: 'radios, disabled', fixture: RadioGroups, props: { disabled: true } },
  { name: 'a switch, on', fixture: Switches, props: { checked: true } },
  {
    name: 'a switch in a row',
    fixture: Switches,
    props: { variant: 'row' },
    skip: { targets: 'on touch, the row clips its 44 target (https://github.com/r-witz/tsuya/issues/5)' },
  },
  { name: 'a segmented control of icons', fixture: SegmentedControls, props: { icons: true } },
  {
    name: 'a segmented control as wide as it can be',
    fixture: SegmentedControls,
    props: { expand: true },
    fit: '[role="radiogroup"]',
  },
  { name: 'sliders', fixture: Sliders, props: { withLabel: true } },
  {
    name: 'a banner, its actions wrapped, with its close button',
    fixture: Banners,
    props: { closable: true, narrow: true },
  },
  { name: 'a tab bar in the dock of a screen', fixture: TabBars, viewport: [390, 700] },
  {
    name: 'a tab bar of five long labels',
    fixture: TabBars,
    props: { crowded: true },
    viewport: [390, 700],
    fit: '[role="tablist"]',
  },
  {
    name: 'a select, open',
    fixture: Selects,
    props: { error: 'Choose a country' },
    viewport: [800, 600],
    open: openSelect,
    inset: 16,
  },
  { name: 'a select, open in a sheet on a phone', fixture: Selects, viewport: [390, 700], open: openSelect, inset: 16 },
  {
    name: 'a combobox, open with results',
    fixture: Comboboxes,
    props: { value: 'PAR' },
    viewport: [800, 600],
    open: openCombobox(''),
    inset: 16,
  },
  {
    name: 'a combobox, open with none',
    fixture: Comboboxes,
    props: { value: 'PAR' },
    viewport: [800, 600],
    open: openCombobox('zz'),
    inset: 16,
  },
  {
    name: 'a menu, open',
    fixture: Menus,
    viewport: [800, 600],
    open: opening('Actions', 'menu', 'Actions'),
    inset: 16,
  },
  {
    name: 'a menu on glass, open',
    fixture: Menus,
    viewport: [800, 600],
    open: opening('More', 'menu', 'More'),
    inset: 16,
  },
  {
    name: 'a popover, open',
    fixture: Popovers,
    viewport: [800, 600],
    open: opening('Filters', 'dialog', 'Filters'),
    inset: 16,
  },
  {
    name: 'a popover at the end of a row, open',
    fixture: Popovers,
    viewport: [800, 600],
    open: opening('Details', 'dialog', 'Details'),
    inset: 16,
  },
  {
    name: 'a tooltip, shown',
    fixture: Tooltips,
    skip: { reflow: 'the fixture is laid out for a wide window; LongTip is the narrow one' },
    open: async (screen) => {
      (screen.getByRole('button', { name: 'Before' }).element() as HTMLElement).focus();
      await userEvent.tab();
      return shown(screen.getByRole('tooltip'));
    },
  },
  { name: 'a dialog, open', fixture: Dialogs, open: opening('Delete photo', 'dialog'), inset: 16 },
  {
    name: 'an alertdialog, open',
    fixture: Dialogs,
    props: { alert: true },
    open: opening('Delete photo', 'alertdialog'),
    inset: 16,
  },
  { name: 'a command palette, open', fixture: CommandPalettes, open: opening('Commands', 'dialog'), inset: 16 },
  {
    name: 'a command palette with no match',
    fixture: CommandPalettes,
    open: opening('Commands', 'dialog', undefined, 'zz'),
    inset: 16,
  },
  { name: 'a sheet, open', fixture: Sheets, open: opening('Share', 'dialog'), inset: 0 },
  {
    name: 'a toast with an icon, an action and a long message',
    fixture: Toasts,
    props: {
      withAction: true,
      icon: 'check',
      message: 'Your changes were saved to the album and shared with everyone',
    },
    // portalled out of the container (top-layer.ts of @tsuya/core/primitives, portal in ToastRegion.svelte)
    open: opening('Notify', 'status'),
    inset: 0,
  },
];
