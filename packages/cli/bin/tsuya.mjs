#!/usr/bin/env node
// The unscoped `tsuya` package, so that `npx tsuya init` never runs someone else's code: npx runs a project's own
// bin first, so it lands here only where @tsuya/core is not installed in the project. Then it runs the init of the
// project's @tsuya/core if it finds one after all, and otherwise says what to install. No dependencies: it never
// installs anything itself.
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { pathToFileURL } from 'node:url';

const core = '@tsuya/core';

let manifest;
try {
  // resolved from the project, as an import of its own would be: its node_modules, then its parents'
  manifest = createRequire(join(process.cwd(), 'index.js')).resolve(`${core}/package.json`);
} catch {
  manifest = undefined;
}

if (manifest !== undefined) {
  const { bin } = JSON.parse(readFileSync(manifest, 'utf8'));
  await import(pathToFileURL(join(dirname(manifest), bin.tsuya)).href);
} else if (process.argv[2] !== 'init') {
  console.log(`Usage: npx tsuya init   (in your project, after npm install ${core})`);
  process.exit(process.argv[2] === undefined ? 0 : 1);
} else {
  console.error(`${core} is not installed here: run npm install ${core} in your project first, then npx tsuya init.`);
  process.exit(1);
}
