# @tsuya/core

The tsuya tokens, CSS, primitives, fonts, labels and colour engine, for any web stack or none. No dependencies. The
components for Svelte are in `@tsuya/svelte`, which needs this package for its CSS, primitives and labels.

`DESIGN.md`, next to this file, is the contract: the rules, the material, every component's spec and the tokens.

```sh
npm install @tsuya/core
npx tsuya init   # optional: points your AI agents at DESIGN.md (see below)
```

## Entry points

| Import                                         | Contents                                                                                                                                                                                                                                                                                                          |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `@tsuya/core/tsuya.css`                        | The one stylesheet to import: tokens, base, material and every component's styles, in the cascade layers `tsuya.tokens`, `tsuya.base`, `tsuya.material` and `tsuya.components`, so your unlayered CSS wins.                                                                                                       |
| `@tsuya/core/tokens.css`                       | The tokens as `--t-` custom properties, light and dark (light by default, dark under `prefers-color-scheme` and `[data-theme=dark]`).                                                                                                                                                                             |
| `@tsuya/core/base.css`                         | The page (background, text, type), the type helpers `t-body`, `t-title-m`…, the focus ring, the pressable primitive and the field box `t-field-box` (in `tsuya.components`).                                                                                                                                      |
| `@tsuya/core/material.css`                     | Accent regions, ambient background, glow, grain, glass and their fallbacks.                                                                                                                                                                                                                                       |
| `@tsuya/core/fonts.css`, `@tsuya/core/fonts/*` | Inter and Geist Mono, subset, as WOFF2, with their `@font-face` rules.                                                                                                                                                                                                                                            |
| `@tsuya/core`                                  | `labelsEn`, `labelsFr`, `TsuyaLabels`; the colour engine (`accentFromColor`, `accentFromPixels`, `contrast`, `checkTheme`); `accentFromImage`; the DOM helpers `setAccent`, `clearAccent`, `setAmbient`, and `fadeAccent` and `shownAccent` that they and `AccentRegion` share; `themeScript`.                    |
| `@tsuya/core/engine`                           | The colour engine alone, for browsers, workers, Node and server rendering.                                                                                                                                                                                                                                        |
| `@tsuya/core/primitives`                       | The components' behaviours, without a framework: `anchored` (a panel beside its anchor), `rovingFocus` (one tab stop, arrows inside), `dismissable` (Escape, a press outside), `focusScope` (trap and restore), `topLayer`, `modal`, `swipeDown`, `announce`. Each takes an element and returns what detaches it. |
| `@tsuya/core/tokens`                           | Every token as a typed value: `light`, `dark`, `space`, `type`…                                                                                                                                                                                                                                                   |
| `@tsuya/core/DESIGN.md`                        | The contract.                                                                                                                                                                                                                                                                                                     |
| `npx tsuya init`                               | The command (`bin`): see AI agents below.                                                                                                                                                                                                                                                                         |

```js
import '@tsuya/core/tsuya.css';
import '@tsuya/core/fonts.css';
import { labelsEn } from '@tsuya/core';
```

`tsuya.css` is `tokens.css`, `base.css`, `material.css` and the components' styles; import the first three alone when
no tsuya component is on the page. `labelsEn` and `labelsFr` are every system string a component shows (close,
loading, copy…); copy one and translate it for another language.

Without a framework, a component is its markup, which the docs show under every example, and its behaviour, which the
page builds with `@tsuya/core/primitives`: the docs' Getting started has the setup and an example.

## Mode before the first paint

`themeScript(storageKey = 'tsuya-mode')` returns a few dozen bytes of JavaScript for the `<head>`: it sets `data-theme`
on `<html>` to the `light` or `dark` saved in `localStorage[storageKey]`, so that a persisted choice does not flash the
system's mode while the app loads. For a mode that is always the same, write `<html data-theme="dark">` instead. See the
`@tsuya/svelte` README for the whole setup.

## The colour engine

```js
import { accentFromColor, accentFromPixels } from '@tsuya/core/engine';

accentFromColor('#2A9D8F'); // { seed: '#2A9D8F', light: '#03786C', dark: '#2FA193' }

// at upload time: decode a thumbnail to straight RGBA bytes, then store the result with the content
const { seed, light, dark, ambient } = accentFromPixels(rgba, width, height);
```

The same pixels give the same hex digits in every browser, in Node and in Flutter: both engines reproduce
`spec/cases.json` exactly. Image decoders differ between platforms, so compute the pair once from the pixels and store
it with the content. In a browser, `accentFromImage(image)` reads a loaded image, canvas or bitmap (a cross-origin
image needs CORS headers).

`contrast(foreground, background)` is the WCAG ratio, a translucent foreground seen over the background.
`checkTheme({ light, dark, glass })` runs the contrast checks of the build on a theme whose colours you changed and
returns the checks it fails, each with its worst case.

## Without a bundler

The built modules load in a browser as they are, served over HTTP:

```html
<script type="module">
  import { accentFromColor } from './node_modules/@tsuya/core/dist/index.js';

  const pair = accentFromColor('#2A9D8F');
</script>
```

## AI agents

`npx tsuya init`, in a project where `@tsuya/core` is installed, adds a line to `AGENTS.md` and `CLAUDE.md` (made
when missing) that tells the project's agents to read and follow `node_modules/@tsuya/core/DESIGN.md`. In a
workspace it finds the package in a parent's `node_modules`. Run again, it changes nothing.
