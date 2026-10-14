// The unscoped package of `npx tsuya init` (packages/cli): where the project has the core package, it runs that
// package's init; where it has not, it says what to install and writes nothing.
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, symlinkSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { afterAll, expect, test } from 'vitest';

const npmScope = '@tsuya';
const cli = new URL('../../packages/cli/', import.meta.url);
const { bin } = JSON.parse(readFileSync(new URL('package.json', cli), 'utf8')) as { bin: Record<string, string> };
const entry = fileURLToPath(new URL(Object.values(bin)[0] ?? '', cli));
const work = mkdtempSync(join(tmpdir(), 'tsuya-cli-'));
afterAll(() => {
  rmSync(work, { recursive: true, force: true });
});

const run = (cwd: string, ...args: string[]) =>
  spawnSync(process.execPath, [entry, ...args], { cwd, encoding: 'utf8' });

test('in a project with the core package, in it or in a parent, runs its init', () => {
  const root = join(work, 'installed');
  mkdirSync(join(root, 'node_modules', npmScope), { recursive: true });
  symlinkSync(
    fileURLToPath(new URL('../../packages/core', import.meta.url)),
    join(root, 'node_modules', npmScope, 'core'),
  );
  const app = join(root, 'apps', 'web');
  mkdirSync(app, { recursive: true });
  const result = run(app, 'init');
  expect(result.status).toBe(0);
  expect(readFileSync(join(app, 'AGENTS.md'), 'utf8')).toContain(`read ../../node_modules/${npmScope}/core/DESIGN.md`);
});

test('without the core package, says to install it and writes nothing', () => {
  const dir = join(work, 'empty');
  mkdirSync(dir);
  const result = run(dir, 'init');
  expect(result.status).toBe(1);
  expect(result.stderr).toContain(`npm install ${npmScope}/core`);
  expect(existsSync(join(dir, 'AGENTS.md'))).toBe(false);
  expect(run(dir).status).toBe(0);
  expect(run(dir).stdout).toContain('init');
  expect(run(dir, 'nonsense').status).toBe(1);
});

test('has no dependencies and ships only its command', () => {
  const manifest = JSON.parse(readFileSync(new URL('package.json', cli), 'utf8')) as Record<string, unknown>;
  expect(manifest['dependencies']).toBeUndefined();
  expect(manifest['files']).toEqual(['bin']);
});
