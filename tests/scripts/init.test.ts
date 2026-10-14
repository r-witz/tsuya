// `npx tsuya init`: a line in AGENTS.md and CLAUDE.md that points the project's agents to the
// DESIGN.md of the installed package, found in the project's node_modules or a parent's, and written once.
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { afterAll, expect, test } from 'vitest';

const npmScope = '@tsuya';
const bin = new URL('../../packages/core/bin/init.mjs', import.meta.url).pathname;
const work = mkdtempSync(join(tmpdir(), 'tsuya-init-'));
afterAll(() => {
  rmSync(work, { recursive: true, force: true });
});

// a project, with the packages installed in its node_modules
function project(name: string, packages: string[] = ['core']) {
  const dir = join(work, name);
  for (const pkg of packages) {
    mkdirSync(join(dir, 'node_modules', npmScope, pkg), { recursive: true });
    writeFileSync(join(dir, 'node_modules', npmScope, pkg, 'DESIGN.md'), '---\nname: design\n---\n');
    writeFileSync(join(dir, 'node_modules', npmScope, pkg, 'package.json'), '{}');
  }
  return dir;
}

const run = (cwd: string, ...args: string[]) => spawnSync(process.execPath, [bin, ...args], { cwd, encoding: 'utf8' });
const read = (dir: string, file: string) => readFileSync(join(dir, file), 'utf8');

test('writes AGENTS.md and CLAUDE.md, each one line that points to DESIGN.md', () => {
  const dir = project('fresh');
  const result = run(dir, 'init');
  expect(result.status).toBe(0);
  for (const file of ['AGENTS.md', 'CLAUDE.md']) {
    const text = read(dir, file);
    expect(text.split('\n')).toHaveLength(2);
    expect(text).toContain(`read node_modules/${npmScope}/core/DESIGN.md`);
    expect(text).toContain(`${npmScope}/core for the tokens`);
    expect(text).not.toContain(`${npmScope}/svelte`);
  }
  expect(result.stdout).toContain('AGENTS.md: created');
});

test('a second run changes nothing', () => {
  const dir = project('twice');
  run(dir, 'init');
  const before = read(dir, 'AGENTS.md');
  const result = run(dir, 'init');
  expect(result.status).toBe(0);
  expect(read(dir, 'AGENTS.md')).toBe(before);
  expect(result.stdout).toContain('AGENTS.md: already points to');
});

test("keeps a file's own text, the line after a blank one", () => {
  const dir = project('kept');
  writeFileSync(join(dir, 'AGENTS.md'), '# Agents\n\nUse pnpm.');
  run(dir, 'init');
  const text = read(dir, 'AGENTS.md');
  expect(text.startsWith('# Agents\n\nUse pnpm.\n\nThis project uses')).toBe(true);
  expect(text.endsWith('\n')).toBe(true);
});

test("in a workspace, finds the package in a parent's node_modules, and names the Svelte package when installed", () => {
  const root = project('workspace', ['core', 'svelte']);
  const app = join(root, 'apps', 'web');
  mkdirSync(app, { recursive: true });
  expect(run(app, 'init').status).toBe(0);
  const text = read(app, 'AGENTS.md');
  expect(text).toContain(`read ../../node_modules/${npmScope}/core/DESIGN.md`);
  expect(text).toContain(`${npmScope}/svelte for the components`);
});

test('without the package, says to install it and writes nothing', () => {
  const dir = join(work, 'empty');
  mkdirSync(dir);
  const result = run(dir, 'init');
  expect(result.status).toBe(1);
  expect(result.stderr).toContain(`npm install ${npmScope}/core`);
  expect(existsSync(join(dir, 'AGENTS.md'))).toBe(false);
});

test('without a command it prints its usage; an unknown command fails', () => {
  const dir = project('usage');
  const bare = run(dir);
  expect(bare.status).toBe(0);
  expect(bare.stdout).toContain('init');
  expect(run(dir, 'nonsense').status).toBe(1);
  expect(existsSync(join(dir, 'AGENTS.md'))).toBe(false);
});
