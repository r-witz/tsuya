# Releasing

`@tsuya/core`, `@tsuya/svelte` and `tsuya` (pub.dev) are released together, by hand, with one version (CHANGELOG.md).
Nothing below runs in CI: CI only checks that a release would build (`npm pack` of both npm packages,
`flutter pub publish --dry-run`, the Dart API tables, the docs' Flutter snippets).

## Once, before the first release

1. **Registries.** npm: the `tsuya` organisation owns the `@tsuya` scope; publish with two-factor authentication on.
   The unscoped `tsuya` package (`packages/cli`) holds the name `npx tsuya init` reaches where `@tsuya/core` is not
   installed, so that it never runs someone else's code. pub.dev: `flutter pub publish` publishes a new package from
   the Google account only, shown as an unverified uploader; right after, transfer it to the verified publisher from
   the package's admin page (you must be an admin of the publisher; a package moved to a publisher never goes back to
   an account, but it can move to another publisher later). Two-factor authentication on that Google account.
2. **Repository.** [github.com/r-witz/tsuya](https://github.com/r-witz/tsuya): the npm manifests and the pubspec link
   to it, and the Flutter README installs from it by git until the first release.

## Each release

1. Bump the version in `packages/core/package.json`, `packages/svelte/package.json`, `packages/cli/package.json` and
   `packages/flutter/pubspec.yaml` (the same one), and give the release its date in `CHANGELOG.md` (the build copies it
   into each package). Remove "nothing is published yet" from the READMEs on the first release.
2. On a clean checkout of `main`: `npm ci`, `npm run verify`, and `node scripts/budgets.mjs` with the fonts this
   time; then the Flutter commands of the README's Development section, the package's on both supported SDKs.
3. npm, core first (the Svelte package is used with it):
   `npm publish -w @tsuya/core --access public`, then `npm publish -w @tsuya/svelte --access public`, then
   `npm publish ./packages/cli` (not a workspace). `prepack` builds each package. Check the tarballs first with
   `npm pack --dry-run -w <package>` (`npm pack --dry-run ./packages/cli`).
4. pub.dev: in `packages/flutter`, `flutter pub publish --dry-run`, which must end without a warning, then
   `flutter pub publish`. It asks for a confirmation, then, the first time, prints a link to sign in with the Google
   account; the upload starts once signed in. A publication cannot be undone: a version can only be retracted within
   7 days, and a package marked discontinued. `.pubignore` keeps `test/` out of the archive.
5. Tag the commit `v<version>` and push the tag.
6. The docs site (`apps/docs`) is a static build (`npm run -w docs build`, output in `apps/docs/build`): publish it
   where it is hosted, once the docs go public.
