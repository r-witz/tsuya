// The components rendered on the server (G15): what their HTML holds before any script runs. A row per case: the
// fixture rendered with its props, and what its HTML must hold; then the cases that are not one render.
import { runInNewContext } from 'node:vm';

import { render } from 'svelte/server';
import { expect, test } from 'vitest';

import { labelsEn, labelsFr } from '../../../packages/core/src/labels.ts';
import { toastState } from '../../../packages/svelte/src/lib/components/toast/state.svelte.ts';
import { toast } from '../../../packages/svelte/src/lib/index.ts';
import Accordions from '../fixtures/Accordions.svelte';
import Avatars from '../fixtures/Avatars.svelte';
import Badges from '../fixtures/Badges.svelte';
import Banners from '../fixtures/Banners.svelte';
import Bars from '../fixtures/Bars.svelte';
import Buttons from '../fixtures/Buttons.svelte';
import Checkboxes from '../fixtures/Checkboxes.svelte';
import Chips from '../fixtures/Chips.svelte';
import Comboboxes from '../fixtures/Comboboxes.svelte';
import CommandPalettes from '../fixtures/CommandPalettes.svelte';
import Dialogs from '../fixtures/Dialogs.svelte';
import Form from '../fixtures/Form.svelte';
import Headers from '../fixtures/Headers.svelte';
import Labelled from '../fixtures/Labelled.svelte';
import Lists from '../fixtures/Lists.svelte';
import Material from '../fixtures/Material.svelte';
import Menus from '../fixtures/Menus.svelte';
import Popovers from '../fixtures/Popovers.svelte';
import Progresses from '../fixtures/Progresses.svelte';
import RadioGroups from '../fixtures/RadioGroups.svelte';
import SegmentedControls from '../fixtures/SegmentedControls.svelte';
import Selects from '../fixtures/Selects.svelte';
import Sheets from '../fixtures/Sheets.svelte';
import Sidebars from '../fixtures/Sidebars.svelte';
import Skeletons from '../fixtures/Skeletons.svelte';
import Sliders from '../fixtures/Sliders.svelte';
import Switches from '../fixtures/Switches.svelte';
import TabBars from '../fixtures/TabBars.svelte';
import Tabbed from '../fixtures/Tabbed.svelte';
import ThemeHead from '../fixtures/ThemeHead.svelte';
import Thumbnails from '../fixtures/Thumbnails.svelte';
import Toasts from '../fixtures/Toasts.svelte';
import Tooltips from '../fixtures/Tooltips.svelte';
import WithLabels from '../fixtures/WithLabels.svelte';

interface Case {
  name: string;
  /** The fixture rendered on the server with its props: its HTML. */
  html: () => string;
  /** What the HTML holds. */
  check: (body: string) => void;
}

const PAIR = { seed: '#2A9D8F', light: '#03786C', dark: '#2FA193', ambient: { light: 0.3, dark: 0.45 } };

const CASES: Case[] = [
  // The accordion rendered on the server (G15): the open item's region shows, the others are hidden, and every header
  // carries its state.
  {
    name: 'accordion: the open item shows its content and the others are hidden',
    html: () => render(Accordions, { props: { value: ['returns'] } }).body,
    check: (body) => {
      const buttons = [...body.matchAll(/<button[^>]*aria-expanded="(true|false)"[^>]*>/g)].map(([, state]) => state);
      expect(buttons).toEqual(['false', 'true', 'false']);
      const regions = [...body.matchAll(/<div[^>]*role="region"[^>]*>/g)].map(([tag]) => tag.includes('hidden'));
      expect(regions).toEqual([true, false, true]);
      expect(body).toMatch(/<h3[^>]*class="t-accordion-heading/);
    },
  },
  // Avatar rendered on the server (G15): the photo's alt, initials named through role=img, and the gradient contrast
  // check, computed in plain JavaScript, already resolved before any script runs.
  {
    name: 'avatar: the photo, initials and the gradient contrast check, server-rendered',
    html: () => render(Avatars).body,
    check: (body) => {
      expect(body).toMatch(/data-testid="photo"[^]*?<img[^>]*alt="Jamie Doe"/);
      expect(body).toMatch(
        /data-testid="plain-initials"[^]*?role="img" aria-label="Jamie Doe"[^]*?<span[^>]*aria-hidden="true">JD<\/span>/,
      );
      expect(body).toMatch(/data-testid="gradient-pass"[^]*?style="[^"]*background: linear-gradient/);
      const fail = /data-testid="gradient-fail"[^]*?(?=data-testid="broken-photo")/.exec(body)?.[0] ?? '';
      expect(fail).not.toContain('linear-gradient');
    },
  },
  // Badge rendered on the server (G15): the count and the dot, decorative, and pinned on the icon button and the
  // avatar, before any script runs.
  {
    name: 'badge: the count, the dot, and both pinned on their host',
    html: () => render(Badges).body,
    check: (body) => {
      expect(body).toMatch(/data-testid="standalone-count"[^>]*aria-hidden="true">5</);
      expect(body).toMatch(/data-testid="standalone-over"[^>]*aria-hidden="true">99\+/);
      expect(body).toMatch(/data-testid="standalone-dot"[^>]*t-badge-dot[^>]*aria-hidden="true">/);
      expect(body).toMatch(/data-testid="icon-button"[^]*?data-testid="icon-button-badge"/);
      expect(body).toMatch(/data-testid="avatar"[^]*?data-testid="avatar-badge"/);
    },
  },
  // A banner rendered on the server (G15): its role, its title read before any script runs, and no close button
  // without onclose.
  {
    name: 'banner: a group named by the title, the message and actions, no close button by default',
    html: () => render(Banners, { props: { tone: 'danger' } }).body,
    check: (body) => {
      expect(body).toMatch(/<div[^>]*role="group"[^>]*aria-labelledby="[^"]+"[^>]*class="t-banner t-banner-danger/);
      expect(body).toContain('Sync paused');
      expect(body).toContain('Your changes will upload once you are back online.');
      expect(body).toMatch(/class="t-button[^"]*t-button-secondary[^>]*>[\s\S]*?Retry/);
      expect(body).not.toContain('aria-label="Close"');
    },
  },
  {
    name: 'banner: onclose renders the close button',
    html: () => render(Banners, { props: { closable: true } }).body,
    check: (body) => {
      expect(body).toContain('aria-label="Close"');
    },
  },
  // Buttons rendered on the server (G15): native buttons and links, named, before any script runs.
  {
    name: 'buttons: native buttons and links with their names and states',
    html: () => render(Buttons, { props: { loading: true, pressed: true } }).body,
    check: (body) => {
      expect(body).toMatch(/<button[^>]*type="button"[^>]*class="t-button t-pressable t-button-primary/);
      expect(body).toMatch(/<a[^>]*href="\/settings"/);
      expect(body).toMatch(/aria-busy="true"/);
      expect(body).toMatch(/<button[^>]*aria-label="Shuffle"[^>]*aria-pressed="true"/);
      expect(body).toMatch(/role="progressbar" aria-label="Loading"/);
    },
  },
  // Checkbox rendered on the server (G15): a native input with its name, value and label before any script runs.
  {
    name: 'checkbox: a native checkbox with its name and value, inside a label with its text',
    html: () => render(Checkboxes, { props: { checked: true } }).body,
    check: (body) => {
      const input = /<input[^>]*>/.exec(body)?.[0] ?? '';
      expect(input).toContain('type="checkbox"');
      expect(input).toContain('name="remember"');
      expect(input).toContain('value="yes"');
      expect(input).toContain('checked');
      expect(body).toMatch(/<label class="t-checkbox t-pressable[^>]*>.*?Remember me/);
    },
  },
  // Chips rendered on the server (G15): native buttons with their roles, names and states before any script runs.
  {
    name: 'chips: a toggle button, a selected radio and an unselected one, before hydration',
    html: () => render(Chips).body,
    check: (body) => {
      expect(body).toMatch(/<button[^>]*class="t-chip t-pressable[^>]*aria-pressed="false"[^>]*>.*?Glass/);
      expect(body).toMatch(/<button[^>]*role="radio"[^>]*aria-checked="true"[^>]*>.*?Recent/);
      expect(body).toMatch(/<button[^>]*role="radio"[^>]*aria-checked="false"[^>]*>.*?Popular/);
    },
  },
  // The combobox rendered on the server (G15): the field shows the label of the value, and the hidden input carries
  // the value to the form, before any script runs.
  {
    name: 'combobox: the field shows the label of the value and the form gets the value',
    html: () => render(Comboboxes, { props: { value: 'LYO' } }).body,
    check: (body) => {
      const input = /<input[^>]*role="combobox"[^>]*>/.exec(body)?.[0] ?? '';
      expect(input).toContain('value="Lyon"');
      expect(input).toContain('aria-expanded="false"');
      expect(input).toContain('aria-autocomplete="list"');
      expect(input).not.toContain('name=');
      expect(body).toContain('<input type="hidden" name="city" value="LYO"/>');
      expect(body).toMatch(/popover="manual"[^>]*>[\s\S]*role="listbox"/);
    },
  },
  // A command palette rendered on the server (G15): a closed dialog, named by its hidden title, before any script runs.
  {
    name: 'command palette: a closed dialog named by its hidden title',
    html: () => render(CommandPalettes).body,
    check: (body) => {
      const [tag] = body.match(/<dialog[^>]*>/) ?? [];
      expect(tag).toBeDefined();
      expect(tag).not.toContain(' open');
      const labelledby = /aria-labelledby="([^"]+)"/.exec(tag ?? '')?.[1] ?? '';
      expect(body).toMatch(new RegExp(`id="${labelledby}"[^>]*>(<!---->)?Search<`));
    },
  },
  // A dialog rendered on the server (G15): closed, not modal, before any script runs; its title and description carry
  // their ids; the dialog is named by its title, and points at its description once mounted (never at one that is not
  // rendered).
  {
    name: 'dialog: a closed, plain dialog named by its title, its description in the server HTML and not yet pointed at',
    html: () => render(Dialogs).body,
    check: (body) => {
      const [tag] = body.match(/<dialog[^>]*>/) ?? [];
      expect(tag).toBeDefined();
      expect(tag).not.toContain(' open');
      const labelledby = /aria-labelledby="([^"]+)"/.exec(tag ?? '')?.[1] ?? '';
      expect(labelledby).not.toBe('');
      expect(body).toContain(`id="${labelledby}"`);
      expect(tag).not.toContain('aria-describedby');
      expect(body).toMatch(/<h2[^>]*id="[^"]+-title"/);
      expect(body).toMatch(/<p[^>]*id="[^"]+-description"/);
      expect(body).toContain('Delete this photo?');
    },
  },
  {
    name: 'dialog: alert renders role="alertdialog"',
    html: () => render(Dialogs, { props: { alert: true } }).body,
    check: (body) => {
      expect(body).toMatch(/<dialog[^>]*role="alertdialog"/);
    },
  },
  // PageHeader and SectionHeader rendered on the server (G15): the title, the count line and the ghost action, before
  // any script runs.
  {
    name: 'headers: the page title, its count line, and a section header with a count and an action',
    html: () => render(Headers).body,
    check: (body) => {
      expect(body).toMatch(/<h1 class="t-page-header-title[^"]*">Recently Added<\/h1>/);
      expect(body).toMatch(/<p class="t-page-header-subtitle[^"]*">412 albums · 3 208 tracks<\/p>/);
      expect(body).toMatch(
        /<h2 class="t-section-header-title[^"]*">Albums<\/h2>\s*<!--\[0--><span class="t-section-header-count[^"]*">24<\/span>/,
      );
      expect(body).toMatch(/<button[^>]*class="t-button t-pressable t-button-ghost t-button-sm[ "]/);
      expect(body).toMatch(/>See all</);
      const playlists = /data-testid="playlists-header"[^]*?<\/div>/.exec(body)?.[0] ?? '';
      expect(playlists).not.toContain('class="t-section-header-count');
      expect(playlists).not.toContain('<button');
    },
  },
  // The fields rendered on the server (G15): native inputs with their label, hint and error wired before any script
  // runs.
  {
    name: 'inputs: the label points to the input and the hint or error describes it',
    html: () => render(Form, { props: { error: 'Enter an email address', required: true } }).body,
    check: (body) => {
      const input = /<input[^>]*type="email"[^>]*>/.exec(body)?.[0] ?? '';
      const id = /\sid="([^"]+)"/.exec(input)?.[1];
      expect(id).toBeTruthy();
      expect(body).toContain(`<label class="t-field-label"`);
      expect(body).toMatch(new RegExp(`for="${String(id)}"`));
      const message = /aria-describedby="([^"]+)"/.exec(input)?.[1];
      expect(input).toContain('aria-invalid="true"');
      expect(input).toContain(`aria-errormessage="${String(message)}"`);
      expect(input).toContain('required');
      expect(body).toMatch(new RegExp(`id="${String(message)}"[^>]*>.*Enter an email address`));
      expect(body).toContain('type="search"');
      expect(body).toContain('aria-label="Search"');
    },
  },
  // List, ListItem and Section rendered on the server (G15): the tag that varies with href/onclick, their states and
  // the section grouping, before any script runs.
  {
    name: 'list: the row tag, its states, and the section grouping',
    html: () => render(Lists).body,
    check: (body) => {
      expect(body).toMatch(
        /<a[^>]*data-testid="account"[^>]*href="\/account"[^>]*class="t-list-item t-pressable t-list-item-tall"/,
      );
      expect(body).toMatch(/<a[^>]*data-testid="wifi"[^>]*href="\/wifi"[^>]*aria-current="true"/);
      expect(body).toMatch(/<button[^>]*data-testid="bluetooth"[^>]*type="button"[^>]*class="t-list-item t-pressable"/);
      expect(body).toMatch(/<div[^>]*data-testid="storage"[^>]*class="t-list-item"/);
      expect(body).toMatch(
        /<button[^>]*data-testid="sign-out"[^>]*class="t-list-item t-pressable t-list-item-destructive"/,
      );
      expect(body).toMatch(/role="group" aria-labelledby="[^"]+"\s+class="t-section"/);
    },
  },
  // The Svelte material rendered on the server (G15): the HTML has the mode, the accent, the ambient image, the
  // surface and the live regions before any script runs, and labels fail loudly in development there too.
  {
    name: 'material: the material renders on the server with everything the CSS needs',
    html: () => render(Material, { props: { labels: labelsEn, pair: PAIR, src: '/cover.jpg', mode: 'dark' } }).body,
    check: (body) => {
      expect(body).toContain('data-theme="dark"');
      expect(body).toMatch(/class="t-surface"/);
      expect(body).toMatch(/class="t-accent"[^>]*style="--t-accent-light: #03786C; --t-accent-dark: #2FA193;"/);
      expect(body).toMatch(
        /<i data-on="" style="background-image: url\(&quot;\/cover\.jpg&quot;\); --_t-ambient-light: 0\.3; --_t-ambient-dark: 0\.45;"/,
      );
      expect(body).toContain('data-tsuya-live="polite" aria-live="polite"');
      expect(body).toContain('data-tsuya-live="assertive" aria-live="assertive"');
    },
  },
  // A menu rendered on the server (G15): its opener says what it opens, and the menu is in the page, hidden until it
  // opens, with its items.
  {
    name: 'menu: the opener and the hidden menu with its items',
    html: () => render(Menus).body,
    check: (body) => {
      const opener =
        /<button[^>]*id="([^"]+)"[^>]*aria-haspopup="menu" aria-expanded="false" aria-controls="([^"]+)"/.exec(body);
      expect(opener).not.toBeNull();
      const [, trigger = '', menu = ''] = opener ?? [];
      expect(body).toMatch(new RegExp(`<div id="${menu}" role="menu" aria-labelledby="${trigger}" popover="manual"`));
      expect(body).toMatch(/<button[^>]*role="menuitem"[^>]*tabindex="-1"[^>]*>[\s\S]*?Rename/);
      expect(body).toMatch(/role="menuitemcheckbox"[^>]*aria-checked="true"/);
      expect(body).toMatch(/<div[^>]*role="group" aria-label="Sort by"/);
    },
  },
  // A popover rendered on the server (G15): its opener says it opens a dialog, which is in the page, hidden until it
  // opens, named by the opener.
  {
    name: 'popover: the opener and the hidden dialog it names',
    html: () => render(Popovers).body,
    check: (body) => {
      const opener =
        /<button[^>]*id="([^"]+)"[^>]*aria-haspopup="dialog" aria-expanded="false" aria-controls="([^"]+)"/.exec(body);
      expect(opener).not.toBeNull();
      const [, trigger = '', panel = ''] = opener ?? [];
      expect(body).toMatch(
        new RegExp(`<div aria-labelledby="${trigger}" id="${panel}" role="dialog" tabindex="-1" popover="manual"`),
      );
    },
  },
  // Progress rendered on the server (G15): a native progress with its value and name, and no value attribute at all
  // when indeterminate, before any script runs.
  {
    name: 'progress: a determinate value, and no value attribute when indeterminate',
    html: () => render(Progresses).body,
    check: (body) => {
      expect(body).toMatch(
        /<progress[^>]*data-testid="determinate"[^>]*value="0\.42"[^>]*max="1"[^>]*aria-label="Uploading photo\.jpg"/,
      );
      const indeterminate = /<progress[^>]*data-testid="indeterminate"[^>]*>/.exec(body)?.[0] ?? '';
      expect(indeterminate).not.toContain('value=');
      expect(indeterminate).toContain('aria-label="Loading your library"');
    },
  },
  // RadioGroup rendered on the server (G15): a fieldset with its legend and native radios, checked state before any
  // script runs.
  {
    name: 'radio group: a fieldset and legend, native radios sharing a name, the bound one checked',
    html: () => render(RadioGroups).body,
    check: (body) => {
      expect(body).toMatch(/<fieldset[^>]*class="t-radio-group[^>]*>/);
      expect(body).toMatch(/<legend class="t-radio-group-legend[^>]*>Size/);
      const inputs = [...body.matchAll(/<input[^>]*>/g)].map((m) => m[0]);
      expect(inputs).toHaveLength(3);
      expect(inputs.every((input) => input.includes('type="radio"') && input.includes('name="size"'))).toBe(true);
      expect(inputs.find((input) => input.includes('value="md"'))).toContain('checked');
      expect(inputs.find((input) => input.includes('value="sm"'))).not.toContain('checked');
    },
  },
  // SegmentedControl rendered on the server (G15): a radiogroup of native radios, named, one checked.
  {
    name: 'segmented control: a radiogroup of native radios sharing a name, the bound one checked',
    html: () => render(SegmentedControls).body,
    check: (body) => {
      expect(body).toMatch(/<div[^>]*role="radiogroup"[^>]*aria-label="View"/);
      const inputs = [...body.matchAll(/<input[^>]*>/g)].map((m) => m[0]);
      expect(inputs).toHaveLength(3);
      expect(inputs.every((input) => input.includes('type="radio"'))).toBe(true);
      const names = new Set(inputs.map((input) => /name="([^"]+)"/.exec(input)?.[1]));
      expect(names.size).toBe(1);
      expect(inputs.find((input) => input.includes('value="list"'))).toContain('checked');
      expect(inputs.find((input) => input.includes('value="grid"'))).not.toContain('checked');
    },
  },
  // The select rendered on the server (G15): the trigger shows the label of the value, and the native select out of
  // sight carries it to the form, before any script runs.
  {
    name: 'select: the trigger shows the label of the value and the form gets the value',
    html: () => render(Selects, { props: { country: 'GR' } }).body,
    check: (body) => {
      const triggers = [...body.matchAll(/<button[^>]*role="combobox"[^>]*>[\s\S]*?<\/button>/g)].map(([html]) => html);
      expect(triggers).toHaveLength(2);
      expect(triggers[0]).toContain('aria-expanded="false"');
      expect(triggers[0]).toMatch(/>\s*Greece\s*</);
      // the composed select names its value from `items`, before its items have rendered
      expect(triggers[1]).toMatch(/>\s*Medium\s*</);
      expect(body).toMatch(
        /<select name="country"[^>]*>(?:<option value=""><\/option>)(?:<!--[^>]*-->)*<option value="GR" selected="">/,
      );
      // the listboxes are there, hidden until they open
      expect(body.match(/role="listbox"[^>]*popover="manual"/g)).toHaveLength(2);
    },
  },
  // A sheet rendered on the server (G15): closed, not modal, before any script runs; aria-labelledby points at a real id.
  {
    name: 'sheet: a closed, plain sheet, its title in the server HTML',
    html: () => render(Sheets).body,
    check: (body) => {
      const [tag] = body.match(/<dialog[^>]*>/) ?? [];
      expect(tag).toBeDefined();
      expect(tag).not.toContain(' open');
      const labelledby = /aria-labelledby="([^"]+)"/.exec(tag ?? '')?.[1] ?? '';
      expect(labelledby).not.toBe('');
      expect(body).toContain(`id="${labelledby}"`);
      expect(body).toContain('Share album');
    },
  },
  // Skeleton and Skeleton.Text rendered on the server (G15): hidden from screen readers, in their busy region, and the
  // lines of Skeleton.Text, before any script runs.
  {
    name: 'skeleton: hidden in a busy region, at their size, and the lines of Skeleton.Text',
    html: () => render(Skeletons).body,
    check: (body) => {
      expect(body).toMatch(/data-testid="region" aria-busy="true"/);
      expect(body).toMatch(
        /data-testid="avatar-skeleton" class="t-skeleton[^"]*" aria-hidden="true" style="width: 40px; height: 40px; border-radius: var\(--t-radius-full\);"/,
      );
      const paragraph = /data-testid="paragraph"[^]*?(?=data-testid="single-line")/.exec(body)?.[0] ?? '';
      expect([...paragraph.matchAll(/class="t-skeleton"/g)]).toHaveLength(4);
    },
  },
  // Slider rendered on the server (G15): a native range input, named, with its value and announced text.
  {
    name: 'slider: a native range input, named, with its value and announced percentage',
    html: () => render(Sliders, { props: { value: 25 } }).body,
    check: (body) => {
      const input = /<input[^>]*>/.exec(body)?.[0] ?? '';
      expect(input).toContain('type="range"');
      expect(input).toContain('min="0"');
      expect(input).toContain('max="100"');
      expect(input).toContain('value="25"');
      expect(input).toContain('aria-label="Volume"');
      expect(input).toContain('aria-valuetext="25 %"');
    },
  },
  {
    name: 'slider: the default range is 0 to 1',
    html: () => render(Sliders, { props: { bare: true, value: 0.25 } }).body,
    check: (body) => {
      const input = /<input[^>]*>/.exec(body)?.[0] ?? '';
      expect(input).toContain('min="0"');
      expect(input).toContain('max="1"');
      expect(input).toContain('aria-valuetext="25 %"');
    },
  },
  // Switch rendered on the server (G15): a native checkbox with role=switch and its name, before any script runs.
  {
    name: 'switch: a native checkbox, role switch, inside its label, with its state',
    html: () => render(Switches, { props: { checked: true } }).body,
    check: (body) => {
      const input = /<input[^>]*>/.exec(body)?.[0] ?? '';
      expect(input).toContain('type="checkbox"');
      expect(input).toContain('role="switch"');
      expect(input).toContain('name="wifi"');
      expect(input).toContain('checked');
      expect(body).toMatch(/<label[^>]*>.*<input.*<span class="t-switch-text">Wi-Fi<\/span>.*<\/label>/s);
    },
  },
  {
    name: 'switch: in a row, named by the title and described by the subtitle, whose ids exist',
    html: () => render(Switches, { props: { variant: 'row' } }).body,
    check: (body) => {
      const input = /<input[^>]*>/.exec(body)?.[0] ?? '';
      const named = /aria-labelledby="([^"]+)"/.exec(input)?.[1] ?? '';
      const described = /aria-describedby="([^"]+)"/.exec(input)?.[1] ?? '';
      expect(body).toMatch(new RegExp(`id="${named}"[^>]*>Wi-Fi<`));
      expect(body).toMatch(new RegExp(`id="${described}"[^>]*>Connected<`));
    },
  },
  // A tab bar rendered on the server (G15): a tab list whose first tab is current until a value comes, its badge read
  // after its label.
  {
    name: 'tab bar: the tabs, the first one current, and a badge read after its label',
    html: () => render(TabBars).body,
    check: (body) => {
      expect(body).toMatch(/<div aria-label="Sections" role="tablist" class="t-tab-bar t-glass/);
      expect(body).toMatch(/<button[^>]*role="tab" aria-selected="true"[^>]*>[\s\S]*?Home/);
      expect(body).toMatch(/<button[^>]*role="tab" aria-selected="false"[^>]*>[\s\S]*?Library/);
      expect(body).toMatch(/Inbox<!--\[0--><span style="[^"]*">, 3 new<\/span>/);
    },
  },
  // Tabs rendered on the server (G15): the first tab selected and the only tab stop, its panel the only one shown.
  {
    name: 'tabs: the selected tab is the tab stop and only its panel shows',
    html: () => render(Tabbed, { props: { value: 'Reviews' } }).body,
    check: (body) => {
      const tabs = [...body.matchAll(/<button[^>]*role="tab"[^>]*>/g)].map(([tag]) => tag);
      expect(tabs).toHaveLength(3);
      expect(tabs.filter((tag) => tag.includes('aria-selected="true"'))).toHaveLength(1);
      expect(tabs[1]).toContain('aria-selected="true"');
      expect(tabs[1]).toContain('tabindex="0"');
      expect(tabs[0]).toContain('tabindex="-1"');
      const panels = [...body.matchAll(/<div[^>]*role="tabpanel"[^>]*>/g)].map(([tag]) => tag);
      expect(panels.filter((tag) => !tag.includes('hidden'))).toHaveLength(1);
      expect(body).toContain('The reviews of the product.');
      expect(body).not.toContain('The overview of the product.');
    },
  },
  // Thumbnail rendered on the server (G15): the img with its alt and its decode size, and the placeholder without one.
  {
    name: 'thumbnail: the img with its alt and size, and the placeholder without an image',
    html: () => render(Thumbnails).body,
    check: (body) => {
      expect(body).toMatch(
        /data-testid="loaded"[^]*?<img[^>]*alt="Album cover"[^>]*width="48"[^>]*height="48"[^>]*decoding="async"/,
      );
      const empty = /data-testid="empty"[^]*?(?=data-testid="broken")/.exec(body)?.[0] ?? '';
      expect(empty).not.toContain('<img');
    },
  },
  // Toast on the server (G15): nothing is shown before toast() is ever called, so the region renders nothing.
  {
    name: 'toast: renders no toast and no popover before any script runs',
    html: () => render(Toasts).body,
    check: (body) => {
      expect(body).not.toContain('role="status"');
      expect(body).not.toContain('popover=');
      expect(body).toContain('Notify');
    },
  },
  // Tooltips rendered on the server (G15): the tooltip is in the page, hidden until it shows, and describes its trigger;
  // an icon button's repeats its label out of the accessibility tree.
  {
    name: 'tooltip: a hidden tooltip that describes its trigger, and the label of an icon button',
    html: () => render(Tooltips).body,
    check: (body) => {
      const id = /<button[^>]*aria-describedby="([^"]+)"[^>]*>[\s\S]*?Copy link/.exec(body)?.[1];
      expect(id).toBeDefined();
      expect(body).toMatch(
        new RegExp(`<div id="${String(id)}" role="tooltip" popover="manual"[^>]*>\\s*Copies the address of this page`),
      );
      // what follows each icon button's own element, without reaching into the next button
      expect(body).toMatch(
        /<button[^>]*aria-label="Share"[^>]*>(?:(?!<button)[\s\S])*?<\/button>(?:\s|<!--[^>]*-->)*<div[^>]*role="tooltip"[^>]*aria-hidden="true"/,
      );
      expect(body).not.toMatch(
        /aria-label="Shuffle"[^>]*>(?:(?!<button)[\s\S])*?<\/button>(?:\s|<!--[^>]*-->)*<div[^>]*role="tooltip"/,
      );
    },
  },

  // The bars and the sidebar rendered on the server (G15): links and buttons work before any script runs.
  {
    name: 'shells: the bars render their links and their state',
    html: () => render(Bars).body,
    check: (bars) => {
      expect(bars).toMatch(/<header[^>]*class="t-top-bar t-glass/);
      expect(bars).toContain('aria-current="page"');
      expect(bars).toMatch(/<h1 class="t-screen-bar-title[^"]*">Order 1042<\/h1>/);
      expect(bars).toContain('aria-label="Back"');
    },
  },
  {
    name: 'shells: the sidebar renders its links and their state',
    html: () => render(Sidebars).body,
    check: (sidebar) => {
      expect(sidebar).toMatch(/<nav[^>]*aria-label="Library"/);
      expect(sidebar).toMatch(/<a[^>]*href="#home"[^>]*aria-current="page"/);
      expect(sidebar).toMatch(/role="group" aria-labelledby="[^"]+"/);
    },
  },
];

test.each(CASES)('$name', ({ html, check }) => {
  check(html());
});

test('material: labels come from the provider; without one, rendering fails in development', () => {
  expect(render(WithLabels, { props: { labels: labelsFr } }).body).toContain('Fermer');
  // the server renders when the body is read
  expect(() => render(Labelled).body).toThrow(/<Labelled> needs the "close" label/);
});

test('material: the theme script is in the server-rendered head and sets the persisted mode before anything else runs', () => {
  const { head } = render(ThemeHead, { props: { labels: labelsEn, storageKey: 'my-app-mode' } });
  const source = /<script>([\s\S]*?)<\/script>/.exec(head)?.[1] ?? '';
  expect(source).toContain('"my-app-mode"');
  const run = (stored: string | null): string | undefined => {
    const document = { documentElement: { dataset: {} as Record<string, string> } };
    runInNewContext(source, { document, localStorage: { getItem: () => stored } });
    return document.documentElement.dataset['theme'];
  };
  expect(run('dark')).toBe('dark');
  expect(run('light')).toBe('light');
  // the system's mode, or anything else: nothing is set
  expect(run('system')).toBeUndefined();
  expect(run(null)).toBeUndefined();
  // storage that throws (blocked): the page still loads
  expect(() => {
    runInNewContext(source, { document: {}, localStorage: null });
  }).not.toThrow();
});

test('toast: toast() called on the server (a load function, an SSR render) does not throw and keeps no message between requests', () => {
  expect(() => {
    toast('Saved');
  }).not.toThrow();
  expect(toastState.current).toBeNull();
});
