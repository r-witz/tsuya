# tsuya

The command of the tsuya design system, nothing else: the design system itself is
[`@tsuya/core`](https://www.npmjs.com/package/@tsuya/core) (tokens, CSS, fonts, colour engine) and
[`@tsuya/svelte`](https://www.npmjs.com/package/@tsuya/svelte) (the Svelte 5 components).

```sh
npm install @tsuya/core   # or @tsuya/core @tsuya/svelte
npx tsuya init
```

`npx tsuya init` adds a line to `AGENTS.md` and `CLAUDE.md` (made when missing) that points your AI agents at the
`DESIGN.md` of the installed `@tsuya/core`. Where `@tsuya/core` is installed, npx runs its own command; this package
only answers where it is not, and then says what to install. It has no dependencies and installs nothing.

See the [repository](https://github.com/r-witz/tsuya) for everything else.
