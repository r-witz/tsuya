# Changelog

`@tsuya/core`, `@tsuya/svelte` and `tsuya` (Flutter) are released together, with one version.

## 0.1.0 — unreleased

The first release.

### Foundations (`@tsuya/core`)

- Design tokens generated for CSS, TypeScript and Dart from one source: colours for light and dark, type, space,
  radius, shadows, motion, states, breakpoints and the material's values.
- The colour engine: an accent from a picture or a colour (`accentFromImage`, `accentFromColor`), the ambient opacity
  that keeps text readable, and `checkTheme`, with the same results to the bit in TypeScript and Dart.
- The CSS: tokens, base, material and every component's styles in cascade layers, and Inter and Geist Mono subsets.
- `npx tsuya` and `dart run tsuya:init` point an app's AI agents to `DESIGN.md`.
- `@tsuya/core/primitives`: the components' behaviours without a framework (anchored panels, roving focus, dismissal,
  focus scopes, the top layer, modals, swipe to dismiss, announcements).

### Material and app setup

- Accent regions, ambient, glow, grain, glass and their fallbacks (reduced transparency, high contrast, forced
  colours, reduced motion).
- Svelte: `TsuyaProvider`. Flutter: `TsuyaApp` and `TsuyaScope`, on the widgets layer, with no Material or Cupertino.
  `TsuyaApp` takes what a localized app needs (localizations delegates, supported locales and resolution callbacks,
  navigator observers, initial route, unknown-route and initial-routes factories, restoration scope, builder, shortcuts,
  actions), has a `TsuyaApp.router` constructor, follows the locale for its labels when none are given, and
  exposes its fade as `TsuyaPageRoute`.

### Components (Svelte and Flutter)

Button, IconButton, Field, TextInput (with Textarea and SearchInput), Checkbox, RadioGroup, Switch, SegmentedControl,
Slider, Select (a sheet on a phone), Combobox, Chip and ChipGroup, List, ListItem and Section, PageHeader and
SectionHeader, Thumbnail, Avatar, Badge, Progress, Spinner, Skeleton, Tabs, Accordion, TopBar, ScreenBar, TabBar,
Screen, Sidebar, Tooltip, Menu, Popover, Dialog, Sheet, CommandPalette, Toast, Banner.

### Docs and gallery

- The docs site: foundations, material, every component with live examples, both platforms' usage, the props and
  the Dart API, keyboard and screen reader tables; the blocks; `llms.txt`, and `DESIGN.md` as it is.
- The Flutter gallery, with every component and block, its switches, and its goldens.

### Known issues

See [the open issues](https://github.com/r-witz/tsuya/issues): among them the Inter subsets are over their 40 KB
budget and the docs home scores 0.85 on Lighthouse mobile against 95. The budgets on a real phone are not measured
yet.
