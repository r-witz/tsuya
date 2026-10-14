# Contributing

Thank you for helping. Bug reports, fixes, docs and examples are all welcome.

## Before you start

- **A bug**: open an issue with the smallest example that shows it (the bug form asks for what helps).
- **A small fix** (a typo, a wrong value, a missing test): open a pull request directly.
- **Anything else** (a new component, a new prop, a change of behaviour): open an issue first. tsuya is a design
  system: what a component does is written in [`DESIGN.md`](DESIGN.md) and holds on both platforms, so a change is a
  decision before it is code.

## Setup

You need Node 22.18 or later and Flutter 3.44 or later. Then:

```sh
git clone https://github.com/r-witz/tsuya.git && cd tsuya
npm ci
npm run build
```

The [Development](README.md#development) section of the README lists every command: tests, the docs site, the checks.

## The rules of the repository

1. **Both platforms.** A component behaves the same in Svelte and in Flutter: a change to one lands on the other in
   the same pull request, with tests on both. If a platform cannot do it, say why in the pull request.
2. **`DESIGN.md` is the contract.** A change of behaviour or of a value changes `DESIGN.md` in the same pull request.
   The build copies it into each package.
3. **A fix comes with a test** that fails without it. Web: Vitest in the browsers (`tests/svelte`), or Playwright
   (`tests/web`) for what needs a whole page; Flutter: `packages/flutter/test`.
4. **Generated files are never edited by hand.** Change `tokens/`, `DESIGN.md` or the engine, then run
   `npm run build`; the generated files are committed, and CI fails when one is out of date.
5. **Accessibility is not optional**: contrast, keyboard, focus, touch targets, screen readers, reduced motion and
   right-to-left are checked by tests. Keep them passing; add to them when you add a control.
6. **Style.** Prettier, ESLint and `dart format --line-length 120` decide the formatting. A source file has at most 500
   lines; tests have no limit. Component styles (`packages/core/src/css/components`) use tokens, not raw lengths: a
   value that must stay raw says why on its line, `/* raw: <reason> */` (`npm run check`). Comments and docs are in
   English.
7. **Commits** have a [conventional](https://www.conventionalcommits.org) title: `feat:`, `fix:`, `docs:`, `test:`,
   `chore:`… One change per commit.

## Pull requests

Run the checks that cover what you changed before you push. CI has two workflows, each run only when its files
change: Web (`npm run verify`: build, lint, types, the tests in Chromium, Firefox and WebKit, the docs site, the
packages) and Flutter (the package on the current and the oldest supported SDK, its example and the gallery on the
current one). A draft pull request runs neither until it is marked ready for review, so open one as a draft while you
are still pushing.

Locally:

```sh
npm run verify                                  # what CI's web job runs
TSUYA_BROWSERS=chromium npm run verify          # the same, in one browser
cd packages/flutter && flutter analyze && flutter test
```

The pull request template has a short checklist. A maintainer reviews every pull request; small, focused ones are
reviewed faster.

## Conduct and security

Everyone taking part follows the [code of conduct](CODE_OF_CONDUCT.md). Report a vulnerability privately, as
[`SECURITY.md`](SECURITY.md) explains, never in a public issue.

## Licence

By contributing, you agree that your contribution is licensed under the MIT licence of the project.
