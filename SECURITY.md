# Security

## Supported versions

Only the latest release of `@tsuya/core`, `@tsuya/svelte` and `tsuya` (pub.dev) receives fixes.

## Reporting a vulnerability

Please do not open a public issue. Report it privately on GitHub: [Report a
vulnerability](https://github.com/r-witz/tsuya/security/advisories/new) (the repository's **Security** tab). Include
what is affected (package and version), how to reproduce it, and what an attacker could do.

We will acknowledge the report, keep you informed while we work on a fix, and credit you in the release notes unless
you prefer otherwise.

## Scope

The published packages: the components, the CSS, the colour engine, and the `init` commands (`npx tsuya init`,
`dart run tsuya:init`), which write `AGENTS.md`, `CLAUDE.md` and, for Flutter, `DESIGN.md` in the current directory.
The docs site and the gallery are examples, not products, but reports about them are welcome too.
