# tsuya

A design system for Svelte 5 and Flutter: neutral surfaces, an accent computed from the content on screen, the
content lighting the background, glass above content, film grain. Version 0.1.

[`DESIGN.md`](DESIGN.md) is the contract: the rules, the material, every component and the tokens. It is also a
Claude Code skill, and each package ships a copy.

## Use it

```sh
npm install @tsuya/svelte @tsuya/core   # Svelte 5 / SvelteKit: components, and the CSS, fonts and labels they need
npm install @tsuya/core                 # any other web stack, or none: CSS, primitives, fonts, labels, colour engine
npx tsuya init                          # optional: points your AI agents at DESIGN.md
flutter pub add tsuya                   # Flutter
```

Start with [`packages/svelte/README.md`](packages/svelte/README.md) (a SvelteKit quick start with the app bar, dark mode
and an accent from an image), [`packages/core/README.md`](packages/core/README.md) (every entry point: `tsuya.css`,
`tokens.css`, `base.css`, `material.css`, `fonts.css`, the engine, the labels, the primitives) or the Flutter package's
README. The docs site in `apps/docs` has a Getting started for Svelte, for a site without a framework and for Flutter.

## Packages

| Path               | Package               | Contents                                                                                                                |
| ------------------ | --------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `packages/core`    | `@tsuya/core` (npm)   | Tokens (CSS and TypeScript), colour engine, all the CSS, primitives, fonts, labels, `npx tsuya init`. No dependencies.  |
| `packages/svelte`  | `@tsuya/svelte` (npm) | Svelte 5 components. Peer dependencies: `svelte` and `@tsuya/core`, which holds the CSS, fonts and labels they rely on. |
| `packages/flutter` | `tsuya` (pub.dev)     | Flutter widgets on the widgets layer, without Material or Cupertino.                                                    |
| `packages/cli`     | `tsuya` (npm)         | Only `npx tsuya init` where `@tsuya/core` is not installed: it says what to install. No dependencies.                   |

The rest of the repository:

- `tokens/`: every token, in the DTCG format. `core.json` holds what does not change with the mode; `light.json` and
  `dark.json` hold the same tokens with each mode's values.
- `scripts/`: the build and the static checks, in Node with no dependencies.
- `tests/`: Vitest (`core`, `scripts`; `svelte`, the components in the browsers, and `svelte/ssr`, on the server)
  and Playwright (`web`, and `docs` on the built docs site). The Flutter tests are in `packages/flutter/test`.

## Development

Needs Node 22.18 or later and Flutter 3.44 or later; the build formats the Dart it generates with `dart format`.

```sh
npm ci
npm run build          # checks the tokens, then writes every generated file
npm run verify         # every check of CI's web job, the cheap ones first (scripts/verify.mjs)
npm test               # Vitest alone; the Svelte tests in Chromium, Firefox and WebKit
npm run test:web       # Playwright alone: Chromium, Firefox, WebKit
npm run test:docs      # Playwright on the docs site, which it builds first (a broken link fails): Chromium
npm run test:docs -- visual --update-snapshots   # after a reviewed visual change: new screenshot baselines
npm run -w docs dev    # the docs site (apps/docs)

cd packages/flutter    # the package; then the same in packages/flutter/example and apps/gallery
flutter pub get && dart format --set-exit-if-changed . && flutter analyze && flutter test
node scripts/flutter-snippets.mjs   # the docs' Flutter snippets compile against the package

cd scripts/dart_api    # after a change to the Flutter API or to a page's <DartApi types>: the docs' tables
dart pub get && dart run bin/dart_api.dart
```

`TSUYA_BROWSERS=chromium,firefox` runs the browser tests (`npm test`, `npm run test:web`, `npm run verify`) in some of
the browsers only, where one cannot start.

The generated files are committed: `packages/core/src/tokens.ts`, `packages/core/src/css/tokens.css` and `grain.png`,
`packages/flutter/lib/src/foundation/tokens.g.dart`, the Tokens section of `DESIGN.md`, `spec/cases.json` (the
results of the TS colour engine, which the Dart engine must reproduce) and the docs' Dart API tables. Change
`tokens/`, `DESIGN.md` or the engine, then run the build. The build writes nothing when a check fails, a contrast
guarantee for instance, and CI fails when a generated file is out of date. The build also copies `DESIGN.md` and
`CHANGELOG.md` into each package, which ships them; git ignores these copies.

To contribute, read [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Licence

MIT. The fonts, Inter and Geist Mono, are under the SIL Open Font License; see `packages/core/fonts/README.md`.
