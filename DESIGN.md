---
name: tsuya
description: The tsuya design system for Svelte and Flutter. Use whenever you design, build, restyle or review a user interface in a project that uses tsuya (neutral surfaces, an accent computed from the content on screen, the content lighting the background, glass above content, film grain). Gives the rules, the material, the foundations, every component's spec, the guarantees and the tokens.
---

# tsuya

Familiar layouts, neutral surfaces, and one material that comes from the content on screen. Light and dark are
designed with equal care.

This file is the contract: both platforms implement it and their tests check it. Every value is a token, named here by
its CSS custom property (`--t-space-16`), or a constant of its component, written here. The Tokens section at the end
is generated from `tokens/` and gives every value; the Flutter name follows the same path (`--t-space-16` is
`TsuyaSpace.s16`, `--t-text-muted` is `TsuyaColors.of(context).textMuted`).

## Using tsuya

**Svelte 5.** Install `@tsuya/core` and `@tsuya/svelte`. Import `@tsuya/core/tsuya.css` and `@tsuya/core/fonts.css`
once, wrap the app in `<TsuyaProvider labels={labelsEn}>`, and take components from `@tsuya/svelte`.

**Flutter.** Add `tsuya` and use `TsuyaApp` (a `WidgetsApp` with the theme, the labels and fade routes), or keep your
`MaterialApp`, `CupertinoApp` or `WidgetsApp` and put `TsuyaScope` in its `builder`. Import
`package:tsuya/tsuya.dart`; where Material is imported too, use `import 'package:tsuya/tsuya.dart' as t;` because
`Switch`, `Slider`, `Tooltip`, `Dialog`, `Chip`, `Checkbox`, `Radio` and `Badge` exist in both.

**Rules for code that uses tsuya.**

- Use tokens and component props, never raw values: `var(--t-space-16)`, `TsuyaSpace.s16`.
- Components hold no text of their own: every system string (Close, Loading, Copy…) comes from the labels given once
  at the root (`labelsEn`, `labelsFr`, or your own `TsuyaLabels`); every visible label is passed by the app.
- Customise through tokens, props and your own CSS. Never copy a component's code to change it.
- Global CSS names are prefixed: `--t-` custom properties, `t-` classes. Component styles sit in the cascade layer
  `tsuya.components`, so any unlayered CSS of the app wins.

## The four rules

1. **Content gives the colour.** The accent is computed from the content in view (a cover, a poster, a photo, an
   avatar). Its hue is kept; its lightness moves into a readable band for each mode.
2. **Content lights the background.** The leading content itself, scaled, blurred and saturated, lights the top of
   the screen, at an opacity computed from the image so that text on it stays readable.
3. **Glass only above content.** Surfaces that float above content (bars, menus, sheets, toasts) are glass, tinted by
   the accent. Never glass on a flat background: nothing passes under it, so it is invisible and still costs a blur.
4. **Grain on backgrounds.** A film grain under the content, never on text or glass.

Everything else is neutral: greys for surfaces, text and lines; full-width rows instead of cards; one primary action
per screen.

## The material

### Accent

An accent is a **pair**: one colour for light mode, one for dark. Any region can take a pair; inside it `--t-accent`
resolves to the pair's colour for the nearest mode, including inside a nested region of the other mode. A change of
pair cross-fades over `--t-duration-accent` (instant with reduced motion), from script: `setAccent` and `AccentRegion`
run it; a pair written straight into `--t-accent-light` and `--t-accent-dark` comes at once.

- Where it comes from, in order: the content that leads the screen; the brand colour when no content is in view; the
  neutral accent when there is neither. The neutral accent is the text colour: near-black in light, white in dark.
- In a grid no item leads: controls keep the brand or neutral accent, each item keeps its own region, the ambient
  background follows the hovered or focused item (on touch, the item at the top of the viewport), and that item gets
  a focus-like ring in its own accent.
- The engine computes pairs (section "The engine" below). `--t-on-accent` is the colour of text and icons on the
  accent; it keeps 5.3:1 on every accent of the band.
- Svelte: `<AccentRegion pair={pair}>…</AccentRegion>`; any other page: `setAccent(element, pair)`. CSS: the region
  sets `--t-accent-light` and `--t-accent-dark` (registered `<color>` properties) and the class `t-accent`;
  `--t-accent` mixes them with `--t-mode-dark`, which every mode block sets to 0 or 1.
- Flutter: `Accent(pair:, child:)`, `Accent.of(context)` (the colour for the current mode), `Accent.pairOf(context)`.

### The engine

The same engine on both platforms, bit-identical: the same input gives the same hex everywhere.

- `accentFromColor(seed)` → `{ seed, light, dark }`: the seed's lightness is clamped into each mode's band
  (`--t-accent-tone-min` to `--t-accent-tone-max`), its hue kept, its chroma reduced until it fits sRGB, then turned
  away from the four statuses until it is at least `--t-accent-status-distance` (ΔE76) from each.
- `accentFromPixels(rgba, width, height)` → `{ seed, light, dark, ambient: { light, dark } }`: the seed of an image
  (the dominant hue of its colourful cells) and the ambient opacity of each mode. `seed` is null for an image without
  colour; the pair is then the neutral accent.
- `accentFromImage(image, size = 256)` (browser; the image must be CORS-readable), `contrast(foreground, background)`,
  `checkTheme(theme)`. Dart: `accentFromColor`, `accentFromPixels`, `accentFromImage(ImageProvider)` on an isolate,
  `contrast`, and `AccentPair` (seed, light, dark, ambientLight, ambientDark, `of(Brightness)`).
- Decoding differs between browsers and Flutter. For the same accent everywhere, compute it once from the pixels
  (`accentFromPixels` in Node at upload time) and store the pair with the content.

### Ambient background

The leading content's image (a 64–128 px thumbnail is enough), scaled `--t-ambient-scale`, blurred
`--t-ambient-blur`, saturated `--t-ambient-saturate`, covers the top `--t-ambient-height` of its region and fades out
from `--t-ambient-fade` of that height to the bottom. Its opacity comes from the pair (`ambient.light`,
`ambient.dark`, never above `--t-ambient-max-opacity`) so that the background keeps its luminance within
`--t-ambient-cap`; without a computed value it is `--t-ambient-safe-opacity`. A new image cross-fades over
`--t-duration-ambient`. It scrolls with the region's main scroll view.

- Svelte: `<Ambient src={thumb} opacity={pair.ambient} />` inside a `<Surface>`. Flutter: `Ambient(image:)` inside
  `TsuyaSurface` or `Screen`.

### Glow

When no content leads, a faint neutral radial glow takes the ambient's place: `--t-text` at `--t-glow-opacity`,
centred at the top, radius `--t-glow-radius` of the width, the same fade. Svelte `<Glow />`, Flutter `Glow()`.

### Grain

A greyscale noise tile of `--t-grain-size` px (generated by the build: LCG seed 64, each texel the mean of two draws)
laid in overlay blend at `--t-grain-opacity`, one texel per device pixel, over the background and the ambient, under
the content. Region modes: `bg` (default), `all` (poster-like pages: over content too, never over text inputs),
`off`. Svelte `data-grain="bg|all|off"` on the surface; Flutter `TsuyaSurface(grain:)`.

### Glass

Recipe: backdrop blur `--t-glass-blur`; fill = `--t-glass` mixed with the accent at `--t-glass-tint` (0 for neutral
glass), at `--t-glass-opacity`; a 1 px `--t-glass-shade` bottom edge, and no lit top edge; `--t-shadow-md` when it
floats (bars, toasts), `--t-shadow-lg` for menus and sheets. The shadow is drawn outside the shape only.

- **Tinted** (the default) when one content leads; **neutral** for settings, forms, grids and brand screens. A neutral
  pair gives neutral glass. Choose per family of surfaces; menus, sheets, popovers and toasts follow the surface that
  opens them. Scope: Svelte `<GlassScope neutral>` or `data-glass="neutral"`; Flutter `GlassScope(neutral:, reduce:)`.
- **Control glass** for small controls over artwork: blur `--t-glass-control-blur`, fill `--t-glass-control`. A veil,
  not a surface: over the ambient background or mid-to-dark artwork, not straight on very light images.
- At most three glass layers on screen; never one per row or card; never on a flat background; never animate a blur.
- `--t-text` and `--t-text-muted` keep 4.5:1 on any glass over any content: there is no special text colour on glass.

### Status colours and the material

Status text (`--t-danger`, `--t-warning`, `--t-success`, `--t-info` used as text) sits only on opaque grounds:
`--t-bg`, `--t-surface`, `--t-fill`. It is never set on glass or over the ambient background, where it cannot keep
4.5:1. A layer that holds status text (a menu with a destructive item, a sheet with an error) uses `--t-surface` even
when it opens from glass. Status colours as marks (icons, dots, banner fills) follow the 3:1 rule of marks.

### Surface

The screen shell, back to front: `--t-bg`, the ambient background (or the glow), the grain, the content. Svelte
`<Surface>` (a positioned, isolated region); Flutter `TsuyaSurface(ambient:, child:)`, and `Screen` for the phone
shell.

### Fallbacks

- **Reduced transparency** (system setting, `data-transparency="reduce"`, `GlassScope(reduce: true)`), **high
  contrast**, **forced colours**, **print**, and browsers without `backdrop-filter`: glass is opaque (its fill without
  opacity) and does not blur; control glass becomes `--t-surface`; the ambient background and the glow are removed.
- High contrast, forced colours and print also remove the grain.
- Forced colours: every custom-drawn control (switch, slider, checkbox, radio, segmented control, progress) is drawn
  with system colours.

## Foundations

### Theme and mode

Light and dark follow the system by default and can be forced per app or per region.

- Svelte: `<TsuyaProvider mode="system|light|dark" labels={…}>` at the root sets `data-theme`, provides the labels and
  holds the toast region; `data-theme="light|dark"` on any element forces a region. The tokens CSS is light by
  default, dark under `prefers-color-scheme: dark` unless `[data-theme=light]`, and dark under `[data-theme=dark]`;
  each mode sets `color-scheme`.
- Flutter: `TsuyaTheme(mode:, child:)` with `TsuyaTheme.of(context)` (colours, shadows, material values); `TsuyaApp` and
  `TsuyaScope` as above.

### Layout

- **Titles**: large, left-aligned page titles (`--t-type-display-s` on phone, `--t-type-display-m` on desktop) with a
  count line `--t-space-8` below in `--t-type-small` `--t-text-muted` ("412 albums · 3 208 tracks"). They scroll away;
  no collapsing bar.
- **Lists**: full-width rows at least `--t-size-row` tall, separated by `--t-border` hairlines, no card around them,
  grouped under a section label.
- **Actions**: one accent-filled action per screen; its neighbours are icon buttons; the rest goes into "more".
  Action rows wrap rather than overflow.
- **Phone shell**: side margins `--t-space-20`, a floating glass tab bar, sheets from the bottom.
- **Desktop shell**: a sidebar instead of the tab bar from `--t-breakpoint-desktop` wide; content column at most
  `--t-container-max-width`.
- **Website**: a glass app bar floating 12 from the top; a hero lit by the product's own imagery.
- Breakpoints are minimum widths of the container, not of the device: below `--t-breakpoint-tablet` is phone. Gutters:
  `--t-container-gutter-phone`, `--t-container-gutter-tablet`, `--t-container-gutter-desktop`.

### Type

Inter (400 to 800) and Geist Mono (400), subset to Latin, Latin Extended, punctuation and symbols, with `tnum`,
`case` and `zero` kept. Each style is a `font` shorthand and a tracking: `font: var(--t-type-body);
letter-spacing: var(--t-type-body-tracking)`; Flutter `TsuyaType.body`.

- Display (`--t-type-display-xl` to `--t-type-display-s`): page titles. Titles (`--t-type-title-l`, `-m`, `-s`):
  sections, dialogs, rich rows. `--t-type-body-l` for descriptions, `--t-type-body` for text and menu rows,
  `--t-type-body-strong` for row titles, `--t-type-button` for button labels, `--t-type-control` for small controls,
  `--t-type-small` for subtitles and hints, `--t-type-caption` for metadata, `--t-type-label` for section labels (in
  capitals: the component sets `text-transform: uppercase`), `--t-type-micro` for tab labels and badges,
  `--t-type-mono` for codes and shortcuts.
- Tabular figures (`font-variant-numeric: tabular-nums`, `FontFeature.tabularFigures()`) for durations, counts in
  columns and prices.
- One-line labels end with an ellipsis; everything else wraps.

### Space, radius, size

- Space: `--t-space-4` to `--t-space-96`. Radius: `--t-radius-xs` (small boxes, thumbnails up to 40), `--t-radius-sm`
  (fields, chips, menu items), `--t-radius-md` (panels, banners), `--t-radius-lg` (dialogs, sheets, the tab bar, large
  pictures), `--t-radius-full` (pills).
- Sizes: `--t-size-control-sm`, `--t-size-control-md`, `--t-size-control-lg` for controls; `--t-size-row` and
  `--t-size-row-tall` for rows; `--t-size-bar` for bars, `--t-size-dock` for the tab bar; `--t-size-icon-sm`,
  `--t-size-icon`, `--t-size-icon-lg` for icons.

### Motion

Motion accompanies a change; nothing decorative loops. Animate opacity and transforms only.
`--t-duration-fast` (press, hover, selection), `--t-duration-base` (dialogs, pages), `--t-duration-sheet`,
`--t-duration-accent`, `--t-duration-ambient`; `--t-easing-standard`, and `--t-easing-emphasized` for sheets rising
and menus appearing. Reduced motion: every change is instant, nothing slides, scales or springs; only loading
indicators keep moving, because their motion is the information.

### States

- **Pressed**: buttons, icon buttons and chips scale to `--t-state-pressed-scale` over `--t-duration-fast`; rows, menu
  items, tabs and segments answer with `--t-fill-strong` or their own change. Web: the `t-pressable` class, with
  `data-press="highlight"` for the fill or `data-press="none"`.
- **Hover** (fine pointers only): `--t-fill` behind rows, menu items and quiet controls.
- **Focus** (keyboard only: `:focus-visible`, Flutter's focus highlight mode): a ring of `--t-state-focus-width` in
  `--t-accent`, `--t-state-focus-offset` away, the gap filled with `--t-bg` so the ring keeps 3:1 anywhere. Fields show
  focus by their boundary turning `--t-state-focus-width` `--t-accent`.
- **Disabled**: `--t-state-disabled-opacity`, no answer, not focusable, except menu items that WAI-ARIA keeps
  focusable and announces as disabled.
- **Current and selected** always have a second signal besides colour: weight, fill, tick or marker.
- **Targets**: every control answers on at least `--t-size-target` square on touch and `--t-size-target-pointer` with
  a mouse, whatever its drawing (web: an invisible pseudo-element; Flutter: a box of at least 44 on touch platforms,
  the drawing centred).

### Icons

No icon set ships. Components take icons as snippets (Svelte) or widgets (Flutter) and size them:
`--t-size-icon` by default, `--t-size-icon-sm` small, `--t-size-icon-lg` large, coloured by the component. Docs and
examples use Lucide (stroke 1.8, round caps and joins). tsuya draws a few glyphs itself: check, minus
(indeterminate), chevron (down, right), back (a screen bar), close, menu (the links of a narrow top bar), search, alert
(a field's error), eye and eye off (showing a password).
Directional glyphs (chevron right, back) mirror in right-to-left layouts.

### Accessibility

Roles, names and states for every control; icon-only controls need a label; decorative pictures and icons are
hidden. Overlays move focus in and back and close on Escape. Text up to 200 % clips nothing except the one-line
labels named below (they end with an ellipsis); up to 300 % (Flutter) and 400 % zoom at 320 px (web) nothing
overflows. Reduced motion, reduced transparency, high contrast and forced colours are followed. Layouts mirror in
right-to-left: logical CSS properties, `Directionality` on Flutter; arrow keys follow the visual order.

### Writing

Labels are short verbs. Counts go in subtitles. An error says what to do next, not a code. An empty state says what
is missing and offers one action. Write in the product's language with its typography (French: a non-breaking space
before `:` `;` `?` `!`).

### Labels

Components hold no text. One object holds every system string, passed once at the root: `close`, `dismiss`,
`loading`, `more`, `clear`, `search`, `noResults`, `copy`, `cut`, `paste`, `selectAll`, `showPassword`,
`hidePassword`, `required`, `optional`, `selected`, and `results`, a function of the count ("4 results") that the
combobox announces. `@tsuya/core` exports `labelsEn` and `labelsFr`;
Dart has `TsuyaLabels.en` and `TsuyaLabels.fr`. Without a provider, a component that needs a label throws a clear
error in development and shows the key name in production.

### Don't

- Don't mark a state with a coloured stripe on one edge of a row, card or nav item.
- Don't use decorative gradients, glass on flat backgrounds, or the accent for text: a link is `--t-text` with an
  accent underline.
- Don't put two accent-filled actions side by side, or the accent on a destructive action.
- Don't copy Apple or Material: no ripples, no floating action button, no blue text back buttons.
- Don't put grain on text; don't loop decorative animation; don't animate blur.
- Don't put status text on glass or over the ambient background.
- Don't invent values.

## Components

Each component exists on Svelte and Flutter with the same values and behaviour. Svelte components spread extra
attributes onto their root, merge a `class` prop, expose their root through `bind:ref`, render meaningful HTML on the
server and use native elements where they meet the spec. Flutter components work under `TsuyaApp` or `TsuyaScope` and
use Flutter's semantics roles where they exist.

### Actions

#### Button

- **For**: a labelled action. Variants `primary` (the one accent action of a screen), `secondary`, `ghost`, `danger`,
  `glass` (control glass, over artwork). Sizes `sm` (`--t-size-control-sm`), `md` (`--t-size-control-md`, default),
  `lg` (`--t-size-control-lg`). Options `block` (full width) and `loading`.
- **Values**: a pill (radius half the height); side padding 12 / 20 / 32 (sm / md / lg); type `--t-type-control` (sm)
  or `--t-type-button`; icon 16 / 20 / 24, `--t-space-8` from the label. Primary: `--t-accent` with `--t-on-accent`;
  secondary: `--t-fill`, a `--t-border` hairline, `--t-text`; ghost: no fill until hover (`--t-fill`); danger:
  `--t-danger` with `--t-on-status`; glass: control glass with `--t-text`.
- **Behaviour**: loading puts a spinner in place of the icon (or before the label), keeps the width, sets busy and
  ignores presses. The label is one line and ends with an ellipsis; at 200 % text the button grows taller.
- **Keyboard**: Tab focuses; Enter and Space press. **Screen reader**: "Save, button" (busy while loading).
- Svelte: `<Button variant size block loading disabled href type onclick>{label}{#snippet icon()}…{/snippet}
  </Button>` (renders `<a>` with `href`). Flutter: `Button(label:, onPressed:, icon:, kind:, size:, block:, loading:,
  focusNode:, autofocus:)`.

#### IconButton

- **For**: an icon-only action or a toggle. Variants `filled` (fill and hairline, default), `plain` (no fill,
  `--t-text-muted`, `--t-fill` on hover), `accent` (the icon-only primary action), `glass`. Sizes sm / md / lg
  (32 / 44 / 56) plus a `size` number for the large primary action (40 to 72). Round.
- **Values**: icon 16 / 20 / 24, or 38 % of a custom size and at least 18.
- **Behaviour**: as a toggle, `pressed` sets the pressed state; on, it is accent-filled with an `--t-on-accent` icon.
  It always has a label, its accessible name, shown as a tooltip on fine pointers after `--t-duration-tooltip-delay`
  (unless `tooltip={false}`).
- **Keyboard**: Enter and Space. **Screen reader**: "Share, button"; a toggle reads "Shuffle, toggle button, pressed".
- Svelte: `<IconButton label variant size pressed onclick>{#snippet icon()}…{/snippet}</IconButton>`. Flutter:
  `IconButton(icon:, label:, onPressed:, kind:, size:, toggled:)`.

#### Chip

- **For**: a filter or a sort option. `--t-size-control-sm` tall, `--t-radius-sm`, side padding 12, type
  `--t-type-control`, icon 16 in `--t-text-muted`; `--t-fill` with a hairline; selected: accent fill with
  `--t-on-accent`. A glass variant over content.
- **ChipGroup**: a row that scrolls sideways, single or multiple selection, one tab stop with roving focus.
- **Keyboard**: in a group, arrows move, Space and Enter select. **Screen reader**: "Recent, toggle button, pressed"
  (multiple) or "Recent, radio button, selected, 2 of 4" (single).
- Svelte: `<Chip selected onclick>`, `<ChipGroup bind:value multiple label>`. Flutter: `Chip(label:, selected:,
  onPressed:, icon:, glass:)`, `ChipGroup<T>(label:, value:, onChanged:, chips:, multiple:)`.

### Inputs

#### Field

- **For**: the frame of every form control: the label above (`--t-type-control`, `--t-text-muted`, `--t-space-8`
  away), the control, then the hint (`--t-type-small`, `--t-text-muted`) or the error (`--t-type-small`, `--t-danger`,
  with an alert icon; it replaces the hint and is read with the control). An optional field shows the `optional`
  label after its label (`optional`); a required one is not marked, it is announced as required. It wires ids and
  ARIA (`aria-describedby`, `aria-invalid`, `aria-errormessage`, `required`).
- Svelte: `<Field label hint error required>{#snippet control(props)}<TextInput {...props} />{/snippet}</Field>`;
  Flutter: built into each input (`label:`, `hint:`, `error:`) and `Field(label:, hint:, error:, child:)` for custom
  controls.

#### TextField, Textarea, Search

- **Values**: the field box is `--t-size-control-md` tall (it grows with the text scale), `--t-radius-sm`, `--t-fill`,
  a 1 px `--t-border-strong` boundary, type `--t-type-body`, padding `--t-space-12`; placeholder in
  `--t-text-muted`; focus turns the boundary `--t-state-focus-width` `--t-accent`; an error turns it `--t-danger`,
  focused too. Leading and trailing slots: an icon, a unit, a clear button, show password (names from the labels).
  Web: the class `t-field-box` of base.css, the one box of TextInput, Textarea and Select's trigger.
- **Textarea**: at least twice `--t-size-control-md`, grows with its content up to `maxRows`, then scrolls.
- **Search**: a pill (`--t-radius-full`) with a leading search glyph in `--t-text-muted`, no visible label (a label is
  still required), an optional clear button, a glass variant over content and a `sm` size (`--t-size-control-sm`).
  The default size is `md` (`--t-size-control-md`) on both platforms.
- Flutter's field is built on `EditableText`: own selection handles (accent teardrops), own context menu (Cut, Copy,
  Paste, Select all, from the labels) drawn as a tsuya menu, and the system context menu on iOS where supported.
- **Keyboard**: the platform's text editing. **Screen reader**: "Email, edit text, required, Enter your work email".
- Svelte: `<TextInput bind:value type name placeholder …>`, `<Textarea>`, `<SearchInput>` (native inputs). Flutter:
  `TextField(label:, controller:, placeholder:, hint:, error:, leading:, trailing:, obscureText:, maxLines:, …)`,
  `TextField.search(…)`.

#### Checkbox

- **Values**: a 20 box, `--t-radius-xs`, a 1.5 px `--t-border-strong` boundary; checked: accent fill with an
  `--t-on-accent` tick (2 px stroke); indeterminate (mixed): a dash. With its label (`--t-type-body`, `--t-space-12` after the
  box) the whole row is pressable and at least `--t-size-target` tall.
- **Mixed**: a state the app sets (a parent of a partly checked group), on both platforms: a press on a mixed checkbox
  checks it, and no press sets mixed. With Flutter's `tristate` a press goes unchecked to checked, checked to
  unchecked, mixed to checked.
- **Keyboard**: Space toggles. **Screen reader**: "Remember me, checkbox, checked" (or "mixed").
- Svelte: `<Checkbox bind:checked indeterminate name value>{label}</Checkbox>` (native input). Flutter:
  `Checkbox(value:, onChanged:, label:, tristate:)`.

#### RadioGroup

- **Values**: radios are 20 circles with a 1.5 px `--t-border-strong` boundary; selected: accent fill with an 8 px
  `--t-on-accent` dot. The group is named by a legend or label.
- **Keyboard**: one tab stop; arrows move and select. **Screen reader**: "Medium, radio button, checked, 2 of 3".
- Svelte: `<RadioGroup bind:value name label>{#each …}<Radio value>{label}</Radio>{/each}</RadioGroup>` (native
  radios). Flutter: `RadioGroup<T>(label:, value:, onChanged:, options: [RadioOption(value:, label:)])`.

#### Switch

- **Values**: a 48 × 28 track (`--t-space-48` by `--t-space-32` minus `--t-space-4`), a 24 thumb 2 from the edge.
  Off: `--t-border-strong` track, `--t-thumb`; on: `--t-accent` track, `--t-on-accent` thumb; slides over
  `--t-duration-fast`. Forced colours: drawn with system colours.
- **Behaviour**: applies at once, with no save step. The optional `label` is drawn beside the track (`--t-space-12`
  away, in `--t-type-body`) on both platforms, and the whole control is pressable. Without a label the switch is named
  by its row: in a plain `ListItem`, its title names it and its subtitle describes it (Svelte wires `aria-labelledby`
  and `aria-describedby`; Flutter merges the row into one node). Anywhere else a label-less switch needs a name:
  Svelte's `aria-label` (in development, a switch with no name warns in the console); Flutter's `Semantics`. In a row,
  leave the label out, or the text shows twice.
- **Keyboard**: Space toggles. **Screen reader**: "Wi-Fi, switch, on".
- Svelte: `<Switch bind:checked name label>` (native `input type=checkbox role=switch`). Flutter: `Switch(value:,
  onChanged:, label:)`.

#### SegmentedControl

- **For**: 2 to 5 options seen together, one always selected.
- **Values**: track `--t-fill` with a hairline, `--t-space-4` inside, radius `--t-radius-sm` plus `--t-space-4`;
  segments `--t-size-control-md` minus twice `--t-space-4` tall, `--t-radius-sm`, side padding 16, type
  `--t-type-control` in `--t-text-muted`; selected: `--t-fill-selected`, `--t-shadow-sm`, `--t-text`. Icon-only
  segments are allowed (a label is still required). `expand` shares the width. When the segments do not fit (large text, a narrow screen) they share the width in
  proportion to their content and their labels wrap, so the segments grow taller. Each segment has a 44 target on touch.
- **Keyboard**: one tab stop; arrows move and select. **Screen reader**: "List, radio button, checked, 1 of 2".
- Svelte: `<SegmentedControl bind:value label options={[{ value, label, icon }]} expand>` (native radios). Flutter:
  `SegmentedControl<T>(label:, segments:, selected:, onChanged:, expand:)`.

#### Slider

- **Values**: `--t-size-target` tall; track `--t-space-4` in `--t-track`, filled with `--t-accent` from the start
  (from the end in right-to-left); a 20 thumb in `--t-thumb` with `--t-shadow-sm` and a 1 px `--t-border-strong`
  ring, which keeps the thumb 3:1 on its track; the focus ring goes around the thumb.
- **Behaviour**: the range is `min` 0 to `max` 1 by default, on both platforms; arrows move by `step` (default a
  twentieth of the range), PageUp and PageDown by a tenth, Home and End to the ends. The value is announced as a percentage unless `valueLabel` is given. Show the value next to it when it
  matters.
- **Screen reader**: "Volume, slider, 40 %".
- Svelte: `<Slider bind:value min max step label valueLabel>` (native range input). Flutter: `Slider(value:,
  onChanged:, onChangeEnd:, label:, min:, max:, step:, valueLabel:)`.

#### Select

- **For**: a choice among more than five options, or options not all seen together.
- **Values**: the trigger looks like a text field with a chevron and the selected label (or the placeholder); it opens
  a listbox panel (menu panel styling) anchored under it, the selected option ticked and scrolled into view; groups
  and separators. Below the tablet width the options open in a sheet titled by the label instead (`sheetOnPhone`,
  default true), the listbox taking the focus until it closes. A native select out of
  sight carries the value in forms; required, the trigger is announced as required, a form does not submit without a
  value, and its focus goes to the trigger.
- **Keyboard**: Enter, Space and arrows open; arrows move; type-ahead; Enter selects; Escape closes; Home and End.
  **Screen reader**: "Country, France, combo box, collapsed".
- Svelte: `<Select bind:value name label placeholder options sheetOnPhone>` or composed (`Select.Root`,
  `Select.Trigger`, `Select.Content`, `Select.Item`, `Select.Group`). Flutter: `Select<T>(label:, value:, onChanged:,
  options:, placeholder:, sheetOnPhone:)`.

#### Combobox

- **For**: a text input that filters a list (`role=combobox` with `aria-activedescendant`).
- **Behaviour**: arrows move the active option, Enter selects, Escape closes then clears; async options show a loading
  state (spinner and the `loading` label) and an empty state (`noResults`); free text allowed or not; single
  selection. The number of results is announced, and again when the options change. Typing filters with no option
  active until an arrow moves (down to the first, up to the last, no wrap); a press on the field or an arrow opens
  every option, the chosen one active. With no active option, Enter keeps the text, as focus leaving does: a text
  that names an option, in any case, chooses it; other text stays with free text, or goes back to the chosen label.
  An active option that the options changed under is none. Escape passes on once there is nothing to close or clear.
- **Screen reader**: "City, combo box, expanded, 4 results".
- Svelte: `<Combobox bind:value bind:inputValue label options filter loading>`. Flutter: `Combobox<T>(label:,
  options:, onSelected:, filter:, loading:)`.

### Content

#### List, ListItem, Section

- **Values**: a row is at least `--t-size-row` tall (`--t-size-row-tall` for an account row), `--t-space-8` above and
  below, `--t-space-12` between parts. Leading: an icon 20 in `--t-text-muted`, an avatar 40 or a thumbnail 40 to 48.
  Title `--t-type-body-strong`, subtitle `--t-type-small` `--t-text-muted` (one line each, ellipsis). Trailing: a
  value (`--t-type-small`, tabular, `--t-text-muted`, at most half the row), a control, or a 16 chevron.
- **Behaviour**: pressable rows show `--t-fill` on hover and `--t-fill-strong` when pressed. The current item has a
  800 weight title and a marker (`aria-current`). A destructive row has its title in `--t-danger` and stands alone in
  the last group. In a selectable list the selected row has a tick at the end. Rows are separated by hairlines; a
  `Section` has a label (`--t-type-label`, `--t-space-24` above, `--t-space-8` below) and its rows. The selected row
  of a selectable list is a pressed button, or for a link or a plain row the tick and the `selected` label read out.
- Svelte: `<List>`, `<ListItem title subtitle href onclick current tall destructive selected>{#snippet
  leading()}…{/snippet}{#snippet trailing()}…{/snippet}</ListItem>`, `<Section label>`. Flutter: `ListItem(…)`, `Section(label:, children:)`.

#### PageHeader, SectionHeader

- Page header: the title (`--t-type-display-s` on phone, `--t-type-display-m` from desktop, `--t-type-display-l`
  optionally), a count line `--t-space-8` below (`--t-type-small`, `--t-text-muted`), actions at the end that wrap
  under the title when narrow. Section header: title `--t-type-title-l`, a count (`--t-type-control`,
  `--t-text-muted`), a ghost "see all" button at the end, wrapping under the title when narrow; `--t-space-32` above,
  `--t-space-12` below.
- Svelte: `<PageHeader title subtitle large>{#snippet actions()}…{/snippet}</PageHeader>` (`large`: `display-l` from
  desktop), `<SectionHeader title count action>`. Flutter: `PageHeader(…)`, `SectionHeader(…)`.

#### Thumbnail

- The picture of a content: square, portrait 2:3 or wide 16:9. Radius from the width: `--t-radius-xs` up to 40,
  `--t-radius-sm` up to 64, `--t-radius-md` up to 160, `--t-radius-lg` above. A 1 px `--t-border` hairline over the
  picture. A `--t-fill` placeholder with an optional icon while it loads or without an image. Decorative unless it has
  a label. Decoded at its display size.
- Svelte: `<Thumbnail src alt size ratio>`. Flutter: `Thumbnail(image:, size:, ratio:, label:, placeholder:)`.

#### Avatar

- Round, 40 by default: the photo, or initials (weight 600, 36 % of the size) on `--t-fill` in `--t-text-muted`, or on
  a gradient of the person's colours (`colors`, from the top start corner at 135°) in white when white keeps 4.5:1 on
  the darker colour (checked; falls back to `--t-fill`).
- Svelte: `<Avatar src initials size colors label>`. Flutter: `Avatar(image:, initials:, size:, colors:, label:)`.

#### Badge

- Count: 18 tall, `--t-radius-full`, side padding 5, `--t-accent` fill, `--t-type-micro` at weight 700 in
  `--t-on-accent`; "99+" above 99. Dot: an 8 accent circle. Pinned on the corner of an icon button, a tab or an
  avatar (its top end corner, 30 % of its own size past it); its meaning is part of the host's label.
- Svelte: `<Badge count dot>`. Flutter: `Badge.count(n)`, `Badge.dot()`, and `badge:` on hosts.

#### Progress

- A bar `--t-space-4` tall, `--t-radius-full`, `--t-track`, filled with `--t-accent`; a thin variant (2) along an
  edge. Without a value, a third of the bar crosses the track every 1.2 s, in the reading direction, and keeps moving
  under reduced motion (it is the information). Named, with its value (progress bar role).
- Svelte: `<Progress value max label thin>` (native `<progress>`). Flutter: `Progress(value:, label:, thin:)`.

#### Spinner

- A 20 ring (16, 24), stroke `--t-state-focus-width`, a quarter arc in `--t-accent` (in the content colour inside a
  button) on `--t-track`, one turn every 0.8 s. Alone, it has a label; inside a labelled button it is hidden from
  screen readers.
- Svelte: `<Spinner size label>`. Flutter: `Spinner(size:, label:, color:)`.

#### Skeleton

- Placeholders at the final size of what loads: blocks of `--t-fill-strong` with the radius of the real element; a
  slow opacity pulse (0.5 to 1, 1.6 s) that stops under reduced motion. Hidden from screen readers; the region that
  loads, which holds them, is `aria-busy` (the app sets it on its container while it loads). A block is 100 % wide and a line tall by default, `--t-radius-xs`; text is 3 lines, the last at 60 %,
  `--t-space-8` apart.
- Svelte: `<Skeleton width height radius>`, `<Skeleton.Text lines>`. Flutter: `Skeleton(…)`, `Skeleton.text(lines:)`.

### Disclosure and navigation

#### Tabs

- A row of text tabs, `--t-size-control-md` tall, type `--t-type-body-strong` in `--t-text-muted`; selected:
  `--t-text` and a 2 px `--t-accent` bar under it, sliding over `--t-duration-fast`; scrolls sideways when there are
  too many. Panels are tab panels.
- **Keyboard**: one tab stop; arrows move (right-to-left aware) and activate, unless `manual`; Home and End.
  **Screen reader**: "Reviews, tab, selected, 2 of 3".
- Svelte: `Tabs.Root bind:value`, `Tabs.List`, `Tabs.Trigger value`, `Tabs.Content value`. Flutter: `Tabs(tabs:
  [TabItem(label:)], selected:, onChanged:)`, `TabView(…)`.

#### Accordion

- Rows in ListItem styling with a chevron that turns 180°; content below with `--t-space-16` padding; one or several
  open; the height animates (instant with reduced motion). The header is a button with its expanded state, inside a
  heading.
- **Keyboard**: Enter and Space toggle. **Screen reader**: "Shipping, button, collapsed".
- Svelte: `Accordion.Root type="single|multiple"`, `Accordion.Item`, `Accordion.Trigger`, `Accordion.Content`.
  Flutter: `Accordion(items:, multiple:)`.

#### TopBar, ScreenBar

- App bar (website, desktop app): glass, `--t-size-bar` tall, `--t-radius-md`, floating 12 from the top and sides,
  sticky, `--t-shadow-md`; brand or back, navigation links (current: `--t-fill-strong`, `--t-text`), search, icon
  buttons; the links move into a menu below `--t-breakpoint-tablet` (a popover from a plain icon button at the end,
  named by the `more` label, the links in rows as a menu's; a choice closes it). When the start and the end do not fit side by side (a labelled
  button at a large text size on a narrow screen), the bar grows a row for the end instead of overflowing. Links (and
  the centre) too wide for the room between the start and the end scroll sideways inside it, centred when they fit,
  and never run over either (as on Flutter).
- Screen bar (a pushed screen): at least `--t-size-bar` tall, a round back button, a centred `--t-type-title-m` title
  (one line, ellipsis) with an optional `--t-type-caption` line, at most one action.
- Svelte: `<TopBar links>` (`{ href, label, current }`) with snippets `start`, `center` (a search), `end`;
  `<ScreenBar title subtitle onBack backLabel>`. Flutter:
  `TopBar(…)`, `ScreenBar(…)`.

#### TabBar, Screen

- Tab bar: glass, at least `--t-size-dock` tall, `--t-radius-lg`, floating 12 from the edges and above the home
  indicator; 3 to 5 items sharing the width, icon 24 and a `--t-type-micro` label in `--t-text-muted` (one line,
  ellipsis); current: icon in `--t-accent`, label `--t-text` at weight 700, a `--t-fill-strong` capsule behind the
  item; badges pinned to icons. Content scrolls under it and fades into `--t-bg`. Tapping the current tab scrolls to
  the top.
- `Screen`: the phone shell: surface, ambient, grain, a scroll view padded for the safe areas, the margins and the
  dock (on Flutter also the keyboard: the focused field stays visible).
- **Keyboard**: one tab stop; arrows move, Enter and Space choose (choosing a tab changes the screen, so moving does
  not). A press on the current tab scrolls the page to the top (at once under reduced motion). While there is no
  value the first tab is current. **Screen reader**: "Library, tab, selected, 1 of 4"; a badge's meaning is read
  after the label ("Inbox, 3 new").
- Svelte: `<TabBar bind:value items>` with items `{ value, label, icon, badge?: { count?, dot?, label } }`,
  `<Screen>`. Flutter: `TabBar(items:, current:, onSelect:)`, `Screen(ambient:,
  builder:, dock:)`.

#### Sidebar

- 240 wide, padding `--t-space-12`; items `--t-size-control-sm` tall (`--t-size-target` on touch), `--t-radius-sm`,
  icon 20 and a `--t-type-control` label in `--t-text-muted`, a count at the end; current: `--t-fill-strong`,
  `--t-text`; group labels in `--t-type-label`. Replaces the tab bar from `--t-breakpoint-desktop` wide. Collapsible
  to icons (72 wide), each label then a tooltip at its item's end.
- Svelte: `<Sidebar>`, `<SidebarItem href icon count current>`, `<SidebarGroup label>`. Flutter: `Sidebar(…)`.

### Overlays and feedback

Overlays sit above every bar, follow the accent and glass scope of what opened them, and dismiss in order when
nested.

#### Tooltip

- A short label for a control on fine pointers and keyboard focus, never on touch, never essential information:
  `--t-text` background with `--t-bg` text, `--t-radius-xs`, padding 4 8, type `--t-type-caption`, at most 240 wide;
  after `--t-duration-tooltip-delay` on hover, at once on focus; Escape hides it, and stops there only when its
  control has the focus (an open panel or dialog gets the key otherwise). It describes its trigger, or is the label
  itself for icon buttons.
- Svelte: `<Tooltip text>{#snippet trigger(props)}…{/snippet}</Tooltip>`. Flutter: `Tooltip(message:, child:)`.

#### Menu

- **Values**: actions anchored to the control that opens them. Panel at least 220 wide, `--t-radius-md`, padding
  `--t-space-4`, `--t-surface` with a hairline and `--t-shadow-lg`, or glass when opened from glass (unless it holds a
  destructive item). Items `--t-size-control-md` tall, `--t-radius-sm`, padding 12, type `--t-type-body`, icon 20 in
  `--t-text-muted`, a tick at the end when checked, a shortcut in `--t-type-mono` `--t-text-muted`; a destructive item
  in `--t-danger`, last, after a separator.
- **Behaviour**: opens under the opener aligned to its end edge, above when there is no room; closes on choice and
  on an outside press.
- **Keyboard**: the first item is focused (the last when the up arrow opens it); arrows (wrapping), Home and End,
  type-ahead; Enter and Space choose; Escape and Tab close; focus returns to the opener on Escape and on a choice,
  before the action runs. A disabled item takes focus but no choice. **Screen reader**: "Rename, menu item, 1 of 5";
  the shortcut is seen, not read (give the item `aria-keyshortcuts` to announce it).
- A label over a few items is `--t-type-caption` in `--t-text-muted`; checkbox and radio items close the menu too.
- Svelte: `Menu.Root`, `Menu.Trigger`, `Menu.Content`, `Menu.Item onselect`, `Menu.CheckboxItem`, `Menu.RadioGroup`,
  `Menu.RadioItem`, `Menu.Separator`, `Menu.Label` (popover top layer). `Menu.Trigger` is a secondary button, or your
  own opener through `{#snippet child(props)}<IconButton {...props} … />{/snippet}`. Flutter: `Menu.show(anchor, items:,
  barrierLabel:)`, `MenuButton(icon:, label:, items:)`, `MenuItem(…)`, `MenuItem.radio(label:, checked:, onSelect:)` (announced as a
  radio menu item, ticked when checked), `MenuItem.label(…)` (a heading, in caption: not focusable, not chosen),
  `MenuItem.separator()`.

#### Popover

- A non-modal panel anchored to a trigger for small interactive content (filters, a colour picker, details): the menu
  panel with padding `--t-space-16`, no arrow, under its opener at its start edge by default, named by its opener.
  Focus moves in when it was opened by the keyboard (to its first control, or to the panel without one); Escape and
  an outside press close it, and so does focus leaving it; focus returns to the opener after Escape.
- Svelte: `Popover.Root bind:open`, `Popover.Trigger` (a secondary button, or your own opener through `child`, as
  for a menu), `Popover.Content side align`. Flutter: `Popover(…)`,
  `Popover.show(anchor, builder:)`.

#### Dialog

- **For**: a decision that needs an answer, or a short focused task.
- **Values**: at most 420 wide (`size="lg"`: 560), `--t-space-16` from the screen edges, `--t-radius-lg`, padding
  `--t-space-24`, `--t-surface`, a hairline, `--t-shadow-lg`, over `--t-scrim`; title `--t-type-title-m`, body in
  `--t-text-muted`, actions at the end wrapping when needed, the main one last. Fades and grows from 0.98 over
  `--t-duration-base`.
- **Behaviour**: modal; focus is trapped; initial focus on the least destructive action; Escape and a scrim tap close
  unless the decision is required (`dismissible={false}`, see below for how the web keeps this stack-aware). An alert
  dialog when it interrupts.
- **Screen reader**: "Delete photo?, dialog" with its description.
- Svelte: `Dialog.Root bind:open dismissible`, `Dialog.Trigger`, `Dialog.Content`, `Dialog.Title`,
  `Dialog.Description`, `Dialog.Actions`, `Dialog.Close` (native `<dialog>`). Flutter: `Dialog.show(context, builder:,
  dismissible:, barrierLabel:)`, `Dialog(title:, body:, content:, actions:)`.
- `Dialog.Trigger` and `Dialog.Close` take a snippet, like Tooltip's `trigger`, so any element opens or closes the
  dialog (a `Button` of any variant, a plain link) without nesting a button inside one:
  `{#snippet children(props)}<Button {...props}>Cancel</Button>{/snippet}`. Initial focus: the first `[autofocus]`
  inside `Dialog.Content`, or `Dialog.Close` when nothing is marked (document which action is least destructive by
  marking it, or leave the default).
- Escape and the scrim go through the dismissable layer, not `closedby`/`cancel`: a native dialog's own
  Escape handling does not know about a non-modal layer (a menu, a combobox) opened from inside it, so two separate
  mechanisms would race (`tests/svelte/dismissable.test.ts`, "in a modal dialog, Escape closes the layer first, then
  the dialog", already exercises this for the primitives). `dismissible={false}` only blocks the dismissable layer's
  own close, never a `Dialog.Close` the consumer placed: an explicit action is always honoured. A press on the scrim
  is found by geometry on the dialog's own box, not by its event target: clicking the `::backdrop` of a native dialog
  still targets the dialog element itself, so an "outside" test like the dismissable layer's would never fire. The
  focus scope primitive gives the trap and the restore to the opener: `showModal()` alone focuses something
  inside the dialog, but Chromium and Firefox do not reliably wrap Tab at the edges or restore focus on `close()`
  (`tests/svelte/dialog.test.ts` caught both).

#### Sheet

- **Values**: content that rises from the bottom, at most `--t-breakpoint-tablet` wide, top corners `--t-radius-lg`,
  padding `--t-space-24` (and `--t-space-12` above a `--t-space-32` by `--t-space-4` handle in `--t-border-strong`),
  `--t-space-32` plus the safe area below; `--t-surface` or glass; at most the viewport height minus `--t-space-48`.
  Slides over `--t-duration-sheet` with `--t-easing-emphasized`.
- **Behaviour**: drag down to close on touch (a third of its height, or a fling); Escape and a scrim tap close; focus
  is trapped and restored. A `side` variant comes from the end edge, 400 wide (`--t-space-16` short of the screen's start edge
  on a narrower one), for desktop panels.
- Svelte: `Sheet.Root bind:open side`, `Sheet.Content`, `Sheet.Title`. Flutter: `Sheet.show(context, builder:,
  barrierLabel:)`, `Sheet(label:, child:, glass:)`.
- Built like Dialog: a native `<dialog>`, the dismissable layer for Escape and a geometry-found scrim press, the focus
  scope for the trap and the restore. Always dismissible: unlike a dialog, nothing requires a sheet (no `dismissible`
  prop, no `Sheet.Close`; the consumer's own content sets `open = false`).
- Glass follows the surface it opens from (`.closest('.t-glass, .t-glass-control')`), as the Glass section says for
  sheets; `--t-surface` otherwise, with a hairline and `--t-shadow-lg` (material.css already names "menus and sheets"
  under that shadow). The `side` variant spans the full height, flush with the screen (no radius, no safe area, a
  plain `--t-space-24` all round): it is a desktop panel, not a floating sheet.
  The handle itself is `--t-space-12` above and below, not only above: space only above it
  leaves the gap after it open, and a handle flush against the content it is about to push down would read as a
  mistake. Dragging only answers from the handle (not the whole sheet, which would fight scrolling its own content),
  and only to a touch or a pen, never a mouse.

#### CommandPalette

- A search-driven list of commands: a dialog at most 560 wide near the top, a search field without a visible label and
  a grouped listbox; type to filter, arrows to move, Enter to run, Escape to close; recent items first; an empty state.
  The app opens it, usually with Ctrl or Cmd+K (documented, not bound by tsuya).
- Svelte: `<CommandPalette bind:open groups filter onselect>`. Flutter: `CommandPalette.show(context, groups:,
  onSelected:)`.
- A group is `{ label, commands: [{ value, label, disabled }] }`. The first command found is active, so that Enter
  runs it: unlike a combobox, the palette's text is a search, never a value. Running closes the palette, then calls
  `onselect`, so that a command can move the focus. The dialog and the field are named by the `search` label.

#### Toast

- **Values**: a short message about something that just happened: glass, at least 48 tall, `--t-radius-full`, padding
  0 20 0 14, type `--t-type-body-strong`, icon 20 in `--t-accent`; bottom centre, above the tab bar.
- **Behaviour**: one at a time (a new one replaces the current one); a status, announced politely. Without an action
  it leaves after `--t-duration-toast` (paused while hovered or focused); with an action (a small ghost button) it also
  has a close button and stays until used, Escape, or replaced. Opened by a keyboard action, focus can reach it (F6)
  and returns. Swipe down to dismiss on touch.
- Svelte: `toast(message, { icon, action: { label, onclick } })`, with `<TsuyaProvider>` holding the region. Flutter:
  `Toast.show(context, message:, icon:, actionLabel:, onAction:)`.
- F6 moves focus to the toast; it is the shortcut 11.32 leaves tsuya to name.
- The message is announced politely through the live announcer, whose region exists before it: an element added with
  its text already in it is not read reliably. The toast itself is `role="status"` with `aria-live="off"`, so it is
  not read twice.
- An outside press and focus leaving do not dismiss it: 11.32 names Escape, besides used, replaced and a swipe.
- Escape dismisses it wherever the focus is, as long as no layer opened after it (a dialog, a menu) takes the key
  first.
- It shows above an open dialog or sheet, since a toast fired from inside one (a save, an undo) must stay in sight.
- `--t-duration-toast` stays at 4 s under reduced motion: it is reading time, not an animation.

#### Banner

- A lasting state (offline, sync error, trial ending): `--t-radius-md`, padding 12 16, fill the status colour at 13 %
  with a 1 px ring at 32 %, the status icon, title `--t-type-body-strong`, text `--t-type-small` `--t-text-muted`,
  actions at the end (under the text when narrow), an optional close button. Tones `info`, `success`, `warning`,
  `danger`. Never a coloured side stripe.
- The status icon follows the tone, not a prop: `info` (its own glyph), `success` (`check`), `warning` and `danger`
  (`alert`, the same glyph as a field's error) — colour and the title's wording still tell warning and danger apart.
  "Under the text when narrow" is a container query on the banner's text column (480 px); plain wrapping would drop
  the actions flush under the icon instead of under the text.
- Svelte: `<Banner tone title onclose>{text}{#snippet actions()}…{/snippet}</Banner>` (`onclose` shows the close
  button; omit it for a banner with no dismissal). Flutter: `Banner(tone:, title:, message:, actions:, onClose:)`.

## Patterns and blocks

Blocks are examples to copy, in light and dark, phone and desktop widths, not packaged components.

- **Content page** (album, film, person, place): the content large (a cover with `--t-shadow-lg`, centred on phone,
  on the left on desktop with the text aligned to its bottom), a kind label, the title, a key facts line, a
  description (`--t-type-body-l`, at most 60 characters a line), actions (one primary, then icon buttons), sections of
  rows or grids. The page's accent and ambient come from its picture.
- **Library or grid**: a page header with counts, chips (sort, filters) and a grid or list segmented control; grid
  columns at least 148 wide with gaps of `--t-space-16` or `--t-space-24`; grid items keep their own accent region;
  hover and focus light the ambient. Empty, no-result and loading (skeleton) states.
- **Settings**: neutral glass; the account row first; sections of 2 to 6 rows; switches apply at once; a destructive
  row alone at the end; search beyond about 20 settings; on desktop a column at most 560 wide with a sidebar.
- **Forms**: one column, labels always visible, `--t-space-16` between fields, validation on blur and then on input
  once in error, focus on the first error on submit, actions at the end (a full-width primary at the bottom on phone).
- **Auth**: sign in, sign up and reset with the brand accent and the glow.
- **Shells**: phone, desktop and website (see Layout), with a player-style screen as the showcase of the ambient and
  control glass.
- **Dashboard-lite**: a page header, rows of tabular figures, a list.
- **Empty, error and offline states**: a short title, one sentence, one action; a banner for lasting states.

## Theming

- **Brand**: `accentFromColor(brand)` gives the pair; set it on the root region. It replaces the neutral accent where
  no content leads.
- **Fonts** may be overridden: `--t-font-sans`; Flutter `TsuyaTheme(typeface:)`. **Radii** too, on the web only:
  `--t-radius-xs` to `--t-radius-lg`.
- **Neutral colours** may be overridden, but then the app owns its contrast: `checkTheme(theme)` (core) and
  `TsuyaThemeData.check()` (Dart) run every check of the build on a theme and return the failures.

## Guarantees

Each guarantee has tests on both platforms, and each test names the guarantees it checks (`G6`).

- **G1** Text (`--t-text`, `--t-text-muted`, statuses on opaque grounds) reaches 4.5:1 on its surface: background,
  surface, fill, glass over white, black and the reference images, the ambient background of every reference image.
  Checked on the tokens by the build (the ambient at its cap) and on rendered pixels.
- **G2** Marks reach 3:1: the focus ring with its gap, `--t-border-strong` boundaries, the switch thumb on its track,
  the slider thumb on its track, the accent on the background, the surface and the capped ambient.
- **G3** Targets: at least 44 square on touch and 24 with a mouse for every interactive element, on every platform:
  Android's 48 dp is a platform recommendation, not a WCAG rule, and the target stays `--t-size-target`.
- **G4** The accent: both platforms give `spec/cases.json` exactly; for 4000 random seeds the pair stays in its band,
  away from the four statuses, with `--t-on-accent` at 5.3:1, and the ambient opacity at most its maximum.
- **G5** Every control has a role, a name and its state, and its actions work from assistive technology.
- **G6** Keyboard: every control works with the keyboard alone, focus is always visible, composite widgets follow
  their WAI-ARIA pattern, overlays move focus in and back and close on Escape, modals trap focus.
- **G7** Text scale and reflow: nothing clipped up to 200 % except the named one-line labels; nothing overflows up to
  300 % (Flutter) and 400 % zoom at 320 px (web).
- **G8** Overlays sit above every bar and follow the accent and glass scope of what opened them; the toast sits above
  the tab bar; nested overlays dismiss in order.
- **G9** Reduced motion, reduced transparency, high contrast and forced colours are followed.
- **G10** Flutter: the focused field of a screen, a dialog or a sheet stays above the keyboard.
- **G11** Flutter: each glass reads its own backdrop under Impeller (no `BackdropGroup`); content passing under a bar
  shows through it.
- **G12** Build: generated files are up to date; packages contain what they publish; types compile for a strict
  consumer; the Svelte package passes `svelte-check` and `publint`; Flutter analyses on the minimum and current SDK;
  no Material or Cupertino import.
- **G13** Specified values: every component's sizes, radii, colours and behaviours named above are the same on both
  platforms.
- **G14** Right-to-left: layouts mirror and arrow keys follow the visual order.
- **G15** Server rendering (web): every component renders on the server without errors and hydrates without mismatch;
  native controls work before hydration.

<!-- tokens:start -->
Generated by scripts/build.mjs from tokens/. Do not edit this section.

Colours, per mode:

| token | light | dark | role |
| --- | --- | --- | --- |
| `--t-bg` | #F6F6F8 | #0A0A0C | Screen background, under the ambient background. |
| `--t-surface` | #FFFFFF | #15151B | Opaque raised surface: dialogs, menus without glass, placeholders. |
| `--t-text` | #0A0A0C | #FFFFFF | Primary text and icons. |
| `--t-text-muted` | #0A0A0CA3 | #FFFFFFA0 | Secondary text. At least 4.5:1 on bg, surface, any glass, the ambient at its cap, and fill. |
| `--t-border` | #0A0A0C14 | #FFFFFF13 | Hairline, row separator. Decorative only. |
| `--t-border-strong` | #0A0A0C78 | #FFFFFF6B | Boundary that must be seen: field, checkbox, switch track. At least 3:1. |
| `--t-fill` | #0A0A0C0D | #FFFFFF11 | Control background (chip, field, segmented track); hover of rows and quiet controls. |
| `--t-fill-strong` | #0A0A0C17 | #FFFFFF1A | Pressed rows, the current navigation item, skeletons. |
| `--t-fill-selected` | #FFFFFF | #FFFFFF21 | Selected segment. |
| `--t-track` | #0A0A0C24 | #FFFFFF24 | Unfilled part of a slider or progress bar. |
| `--t-thumb` | #FFFFFF | #FFFFFF | Switch thumb (off), slider thumb. At least 3:1 on border-strong over bg and surface. |
| `--t-accent` | #0A0A0C | #FFFFFF | Neutral accent (monochrome). Replaced by the content's pair in an accent region. |
| `--t-on-accent` | #FFFFFF | #0A0A0C | Text and icons on the accent. |
| `--t-danger` | #C62828 | #FF6B6B | Errors, destructive actions. |
| `--t-warning` | #8A5A00 | #F5B942 | Warnings. |
| `--t-success` | #0B7040 | #3DD68C | Success. |
| `--t-info` | #1F5FBF | #6AA8FF | Information. |
| `--t-on-status` | #FFFFFF | #0A0A0C | Text and icons on a status colour. |
| `--t-scrim` | #0A0A0C2E | #0000004D | Behind a dialog or sheet. |
| `--t-glass` | #FCFCFD | #101014 | Glass colour before tint and opacity. |
| `--t-glass-shade` | #0000001A | #0000003D | Bottom edge of glass. |
| `--t-glass-control` | #0A0A0C14 | #FFFFFF14 | Control glass veil. |

Shadows (offset x, offset y, blur, spread, colour), per mode:

| token | light | dark | use |
| --- | --- | --- | --- |
| `--t-shadow-sm` | 0 4 12 0 #0000001C | 0 4 12 0 #00000052 | Raised segment, slider thumb. |
| `--t-shadow-md` | 0 12 32 0 #00000026 | 0 12 32 0 #00000073 | Floating bars, toasts. |
| `--t-shadow-lg` | 0 24 64 0 #00000033 | 0 24 64 0 #00000099 | Menus, dialogs, sheets, hero covers. |

Material values, per mode:

| token | light | dark | use |
| --- | --- | --- | --- |
| `--t-accent-tone-min` | 32 | 60 | Lowest CIE L* of the accent in this mode. |
| `--t-accent-tone-max` | 45 | 74 | Highest CIE L* of the accent in this mode. |
| `--t-ambient-max-opacity` | 0.42 | 0.55 | Highest opacity of the ambient background. |
| `--t-ambient-cap` | 0.55 | 0.055 | Luminance limit of the ambient over bg, so text stays readable: at least this in light mode, at most this in dark mode. |
| `--t-glow-opacity` | 0.04 | 0.06 | Opacity of the text colour at the centre of the neutral glow. |

Type:

| style | font | size | line height | weight | tracking | use |
| --- | --- | --- | --- | --- | --- | --- |
| `--t-type-display-xl` | Inter | 76 px | 0.96 | 800 | -0.045 em | Content page title on wide screens. |
| `--t-type-display-l` | Inter | 56 px | 1 | 800 | -0.045 em | Home or profile title on desktop. |
| `--t-type-display-m` | Inter | 44 px | 1 | 800 | -0.04 em | Page title on desktop. |
| `--t-type-display-s` | Inter | 34 px | 1.06 | 800 | -0.035 em | Page title on phone. |
| `--t-type-title-l` | Inter | 24 px | 1.15 | 800 | -0.03 em | Section title. |
| `--t-type-title-m` | Inter | 22 px | 1.18 | 700 | -0.02 em | Dialog title, centred bar title. |
| `--t-type-title-s` | Inter | 17 px | 1.3 | 700 | -0.01 em | Title of a rich row or card-like block. |
| `--t-type-body-l` | Inter | 17 px | 1.5 | 500 | 0 em | Intro text, description. |
| `--t-type-body` | Inter | 15 px | 1.33 | 500 | 0 em | Body text, row titles in menus. |
| `--t-type-body-strong` | Inter | 15 px | 1.27 | 600 | -0.012 em | Row titles. |
| `--t-type-button` | Inter | 15 px | 1.27 | 700 | -0.01 em | Button labels. |
| `--t-type-control` | Inter | 13 px | 1.23 | 600 | 0 em | Small controls: chips, segments, field labels, small buttons. |
| `--t-type-small` | Inter | 13 px | 1.31 | 400 | 0 em | Subtitles, hints. |
| `--t-type-caption` | Inter | 12 px | 1.33 | 400 | 0 em | Metadata, timestamps. |
| `--t-type-label` | Inter | 12 px | 1.17 | 700 | 0.14 em | Section labels, in capitals. |
| `--t-type-micro` | Inter | 11 px | 1.2 | 600 | 0 em | Tab bar labels, badges. |
| `--t-type-mono` | Geist Mono | 13 px | 1.4 | 400 | 0 em | Codes, keyboard shortcuts. |

- **font**: `--t-font-sans` Inter, system-ui, sans-serif (every text but code) · `--t-font-mono` "Geist Mono", ui-monospace, monospace (codes, keyboard shortcuts)
- **space**: `--t-space-4` 4 px · `--t-space-8` 8 px · `--t-space-12` 12 px · `--t-space-16` 16 px · `--t-space-20` 20 px (side margins of the phone shell) · `--t-space-24` 24 px · `--t-space-32` 32 px · `--t-space-48` 48 px · `--t-space-64` 64 px · `--t-space-96` 96 px
- **radius**: `--t-radius-xs` 6 px (checkbox, tooltip, thumbnails up to 40 wide) · `--t-radius-sm` 12 px (field, chip, segment, menu item, thumbnails up to 64 wide) · `--t-radius-md` 18 px (menu, banner, top bar, thumbnails up to 160 wide) · `--t-radius-lg` 28 px (dialog, sheet, tab bar, larger thumbnails) · `--t-radius-full` 999 px (pill, round button, avatar)
- **size**: `--t-size-control-sm` 32 px (chip, small button, small search field) · `--t-size-control-md` 44 px (button, field, segmented control, menu item, tabs) · `--t-size-control-lg` 56 px (large button) · `--t-size-row` 56 px (minimum height of a list row) · `--t-size-row-tall` 72 px (minimum height of an account row) · `--t-size-bar` 56 px (height of the top bar and the screen bar) · `--t-size-dock` 66 px (minimum height of the tab bar) · `--t-size-target` 44 px (minimum target on touch screens, whatever the drawing) · `--t-size-target-pointer` 24 px (minimum target with a mouse) · `--t-size-icon-sm` 16 px (small icon) · `--t-size-icon` 20 px (icon) · `--t-size-icon-lg` 24 px (large icon)
- **breakpoint**: `--t-breakpoint-tablet` 600 px (minimum container width of the tablet layout; below it is the phone layout) · `--t-breakpoint-desktop` 1024 px (minimum container width of the desktop layout) · `--t-breakpoint-wide` 1440 px (minimum container width of the wide layout)
- **container**: `--t-container-max-width` 1200 px (widest content column) · `--t-container-gutter-phone` `--t-space-16` (side gutter of the content column on phone) · `--t-container-gutter-tablet` `--t-space-24` (side gutter of the content column on tablet) · `--t-container-gutter-desktop` `--t-space-48` (side gutter of the content column on desktop)
- **duration**: `--t-duration-fast` 150 ms (press, hover, selection) · `--t-duration-base` 280 ms (dialog, page) · `--t-duration-sheet` 450 ms (a sheet rising or leaving) · `--t-duration-accent` 600 ms (cross-fade of the accent when the content changes) · `--t-duration-ambient` 900 ms (cross-fade of the ambient background) · `--t-duration-tooltip-delay` 500 ms (hover time before a tooltip shows) · `--t-duration-toast` 4000 ms (time a toast without an action stays)
- **easing**: `--t-easing-standard` cubic-bezier(0.2, 0, 0, 1) (most changes) · `--t-easing-emphasized` cubic-bezier(0.22, 1, 0.36, 1) (sheets rising, menus appearing)
- **state**: `--t-state-disabled-opacity` 0.38 (opacity of a disabled control) · `--t-state-pressed-scale` 0.96 (scale of a button, icon button or chip while pressed) · `--t-state-focus-width` 2 px (width of the focus ring, and of a focused field's boundary) · `--t-state-focus-offset` 2 px (gap between a control and its focus ring, filled with bg)
- **accent**: `--t-accent-sample` 48 (an image is box-averaged into sample × sample cells) · `--t-accent-bins` 24 (number of hue bins, 15° each) · `--t-accent-min-chroma` 12 (cells under this CIE chroma are skipped) · `--t-accent-min-tone` 8 (cells under this CIE L* are skipped) · `--t-accent-max-tone` 97 (cells over this CIE L* are skipped) · `--t-accent-status-distance` 20 (minimum CIE76 distance between the accent and each status colour of its mode)
- **ambient**: `--t-ambient-scale` 1.28 (the leading content is scaled up behind the screen) · `--t-ambient-blur` 64 px (blur radius) · `--t-ambient-saturate` 1.5 (saturation boost) · `--t-ambient-height` 720 px (height of the lit area at the top of its region) · `--t-ambient-fade` 0.4 (the light fades out from this share of the height to the bottom) · `--t-ambient-safe-opacity` 0.2 (opacity when the image's own opacity is not computed: safe for any image)
- **glass**: `--t-glass-opacity` 0.82 (opacity of the glass fill) · `--t-glass-blur` 24 px (backdrop blur) · `--t-glass-tint` 0.12 (share of the accent mixed into the glass colour; 0 for neutral glass) · `--t-glass-control-blur` 13 px (backdrop blur of control glass)
- **grain**: `--t-grain-opacity` 0.09 (opacity of the grain, in overlay blend mode) · `--t-grain-size` 64 px (side of the generated noise tile, in texels)
- **glow**: `--t-glow-radius` 0.6 (radius of the neutral glow, as a share of its region's width)
<!-- tokens:end -->
