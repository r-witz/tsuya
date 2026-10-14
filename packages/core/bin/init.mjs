#!/usr/bin/env node
// `npx tsuya init`: points the project's AI agents to DESIGN.md, the contract this package ships, with
// a line in AGENTS.md and CLAUDE.md (made when missing). Run it in the project once the package is installed; run
// again, it changes nothing.
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, relative } from 'node:path';

const { name } = JSON.parse(readFileSync(new URL('../package.json', import.meta.url), 'utf8'));

if (process.argv[2] !== 'init') {
  console.log(`Usage: npx tsuya init   (in your project, after npm install ${name})`);
  process.exit(process.argv[2] === undefined ? 0 : 1);
}

// DESIGN.md where the project reaches it: in its node_modules or, in a workspace, a parent's
function find(dir) {
  const path = join(dir, 'node_modules', name, 'DESIGN.md');
  if (existsSync(path)) return path;
  return dirname(dir) === dir ? undefined : find(dirname(dir));
}

const design = find(process.cwd());
if (design === undefined) {
  console.error(`${name} is not installed here: run npm install ${name} in this folder first.`);
  process.exit(1);
}
const path = relative(process.cwd(), design).replaceAll('\\', '/');
const svelte = join(dirname(dirname(design)), 'svelte', 'package.json');
const packages = `${existsSync(svelte) ? `${dirname(name)}/svelte for the components and ` : ''}${name} for the tokens, CSS and colour engine`;
const line = `This project uses the tsuya design system. Before building or changing any user interface, read ${path} (the rules, the material, every component's spec and the tokens) and follow it; use ${packages}.`;

for (const file of ['AGENTS.md', 'CLAUDE.md']) {
  const text = existsSync(file) ? readFileSync(file, 'utf8') : '';
  if (text.includes(path)) {
    console.log(`${file}: already points to ${path}`);
    continue;
  }
  writeFileSync(file, `${text}${text && !text.endsWith('\n') ? '\n' : ''}${text ? '\n' : ''}${line}\n`);
  console.log(`${file}: ${text ? 'added the line' : 'created'}`);
}
