# @tsuya/svelte

The tsuya components for Svelte 5 and SvelteKit: neutral surfaces, an accent computed from the content on screen, the
content lighting the background, glass above content, film grain. Light and dark follow the system or are forced.

## Install

```sh
npm install @tsuya/svelte @tsuya/core
```

The two go together. `@tsuya/svelte` holds the components. `@tsuya/core` holds what they style and read: the CSS
(tokens, base, material and the components' own styles), the fonts, the system strings (`labelsEn`, `labelsFr`), the
colour engine that computes an accent from an image, and the primitives the components are built on. The components
import neither the CSS nor the labels, so that you load the CSS once and the labels are yours to choose; that is why
`@tsuya/core` is a peer dependency.

Needs Svelte 5.57 or later.

## Quick start (SvelteKit)

An app bar, a screen, a dark-mode switch that is remembered and does not flash, and a page. Four files.

`src/app.html` is the stock one. For an app that is only ever dark (or only light), write the mode on the tag, so that
the page is dark before any script runs, and give `TsuyaProvider` the same `mode`:

```html
<html lang="en" data-theme="dark"></html>
```

`src/routes/+layout.svelte`: the CSS, the provider, the screen and its bar.

```svelte
<script lang="ts">
  import '@tsuya/core/tsuya.css';
  import '@tsuya/core/fonts.css';
  import { labelsEn, themeScript } from '@tsuya/core';
  import { Screen, SegmentedControl, TsuyaProvider, TopBar } from '@tsuya/svelte';
  import { onMount, type Snippet } from 'svelte';
  import { lit } from '../lib/lit.svelte';

  type Mode = 'system' | 'light' | 'dark';

  let { children }: { children: Snippet } = $props();

  // the user's choice, kept in localStorage; themeScript() reads the same key before the first paint
  let mode = $state('system');
  onMount(() => {
    const saved = localStorage.getItem('tsuya-mode');
    if (saved === 'light' || saved === 'dark') mode = saved;
  });
</script>

<svelte:head>
  <!-- eslint-disable-next-line svelte/no-at-html-tags -- a constant string from @tsuya/core -->
  {@html `<script>${themeScript('tsuya-mode')}<\/script>`}
</svelte:head>

<TsuyaProvider mode={mode as Mode} labels={labelsEn}>
  <Screen ambient={lit.src} ambientOpacity={lit.opacity}>
    <TopBar links={[{ href: '/', label: 'Library', current: true }]}>
      {#snippet start()}<strong>My app</strong>{/snippet}
      {#snippet end()}
        <SegmentedControl
          label="Mode"
          bind:value={mode}
          onchange={() => localStorage.setItem('tsuya-mode', mode)}
          options={[
            { value: 'system', label: 'System' },
            { value: 'light', label: 'Light' },
            { value: 'dark', label: 'Dark' },
          ]}
        />
      {/snippet}
    </TopBar>
    <main>{@render children()}</main>
  </Screen>
</TsuyaProvider>

<style>
  main {
    padding-block-start: var(--t-space-24);
  }
</style>
```

`src/lib/lit.svelte.ts`: the image that lights the screen, shared by the layout and the pages (used below).

```ts
export const lit = $state<{ src: string | null; opacity?: { light: number; dark: number } }>({ src: null });
```

`src/routes/+page.svelte`: a page.

```svelte
<script lang="ts">
  import { Button, PageHeader } from '@tsuya/svelte';
</script>

<PageHeader title="Library" subtitle="4 albums" />
<Button variant="primary">Create</Button>
```

### What each part does

- **`@tsuya/core/tsuya.css`** is the whole of the CSS: the tokens (`--t-*`, light and dark), the base (the page's
  background and text, the type, the focus ring), the material and the components' styles. **`fonts.css`** serves Inter
  and Geist Mono.
- **`TsuyaProvider`** is the root. It gives every component its system strings (`labels`: close, loading, copy… no
  component holds text of its own: pass `labelsEn`, `labelsFr` or your own `TsuyaLabels`), the live regions that
  announce and the toasts, and applies `mode` (`'system'`, `'light'` or `'dark'`). Without it, components throw in
  development.
- **`Screen`** is the shell of a page: a surface (`--t-bg`), the ambient background that the image in `ambient` lights
  (or a soft glow without one), the film grain, and the content within the side margins and the safe areas. The
  content scrolls; an optional `dock` snippet holds a tab bar at the bottom.
- **`TopBar`** is a glass bar floating 12 px from the top, sticky. Put it first inside `Screen`, so that the ambient
  light runs under it and the page does not gain a bar's height of scroll. DESIGN.md does not say where the content
  starts below a floating bar, so that is the layout's: a title straight after the bar touches it. The quick start
  gives `main` `padding-block-start: var(--t-space-24)`.
- Everything is styled with tokens and component props. Add your own CSS with `var(--t-space-16)` and the like; its
  names are prefixed `--t-` and `t-`, and the library's rules sit in cascade layers, so unlayered CSS of yours wins.

## Dark mode

The tokens follow `prefers-color-scheme` by default. `TsuyaProvider mode` forces a mode, and `data-theme="light"` or
`"dark"` on any element forces a region.

A page's background is painted by `<html>`, which a component cannot reach before JavaScript runs, so the first
paint needs help when the mode is not the system's:

- **A fixed mode:** `<html data-theme="dark">` in `app.html`, as above.
- **A choice the user makes and you remember:** `themeScript(key)` of `@tsuya/core` returns a script, a few dozen
  bytes, that sets `data-theme` from `localStorage[key]` (`'light'` or `'dark'`; anything else is the system's). Put it
  in the `<head>` as in the layout above and write the same key when the user chooses. The provider takes over the
  attribute once the app runs, and back to `'system'` removes it.

The script is plain JavaScript in a string: with a content security policy, give it your nonce, or copy it into
`app.html` and hash it.

## An accent from an image

An accent is a pair of colours, one per mode, computed from the content: `accentFromImage` of `@tsuya/core` reads a
loaded image. Compute it once, in the browser as below or at upload time with `accentFromPixels`, and store it with the
content. `AccentRegion` gives its pair to everything inside; `Screen` lights its top with the image, at the opacity the
pair computed (`pair.ambient`), so that text on it stays readable.

`src/routes/+page.svelte`, with an image at `static/cover.jpg`:

```svelte
<script lang="ts">
  import { accentFromImage, type ImageAccent } from '@tsuya/core';
  import { AccentRegion, Button, PageHeader } from '@tsuya/svelte';
  import { onMount } from 'svelte';
  import { lit } from '../lib/lit.svelte';

  const cover = '/cover.jpg';
  let pair = $state<ImageAccent | null>(null);

  onMount(() => {
    const image = new Image();
    image.src = cover;
    image.decode().then(() => {
      pair = accentFromImage(image);
      lit.src = cover;
      lit.opacity = pair.ambient;
    });
    return () => {
      lit.src = null;
    };
  });
</script>

<PageHeader title="Library" subtitle="4 albums" />
<AccentRegion {pair}>
  <Button variant="primary">Create</Button>
</AccentRegion>
```

Without a shared layout, a page can also write `<Screen ambient={cover} ambientOpacity={pair?.ambient}>` itself. A
page without an image needs nothing: the accent is neutral.

## Components

About forty, all imported from `@tsuya/svelte`: buttons, fields and controls, lists and headers, menus, dialogs, sheets,
popovers, tabs, bars, toasts, and the material (`AccentRegion`, `Ambient`, `GlassScope`, `Glow`, `Surface`). The docs
site lists each with its props and examples.

## More

- [`DESIGN.md`](./DESIGN.md) in this package: the contract, with the rules, the material, every component's spec,
  its keyboard and screen reader behaviour, and the tokens. It is also a Claude Code skill: `npx tsuya init` (after
  installing `@tsuya/core`) points your AI agents at it.
- The docs site: every component with its props, live examples, and a Getting started that follows this page. It lives
  in the repository's `apps/docs`; there is no public URL yet.
- [`CHANGELOG.md`](./CHANGELOG.md).

MIT.
