// Every check of the web side, the cheap ones first: `npm run verify` before a push, and CI after `npm ci`, the build
// and its check that no generated file is out of date. TSUYA_BROWSERS=chromium,firefox leaves out a browser that
// cannot launch. The Flutter side has its own commands (README.md, Development).
import { spawnSync } from 'node:child_process';

const STEPS = [
  'npm run build',
  'npm run format:check',
  // what the docs import and git does not keep: the props tables and the SvelteKit types
  'npm run -w docs sync',
  'npm run lint',
  'npm run typecheck',
  'npm run check',
  'npm test',
  'npm run test:web',
  // builds the docs first, which fails on a broken internal link or anchor
  'npm run test:docs',
  // the packages as the docs' build left them: every export points to a file of the package
  'npx publint packages/core && npx publint packages/svelte && npx publint packages/cli',
  // the published packages only: the docs app is a workspace with no version, which npm pack refuses
  'npm pack --dry-run --ignore-scripts -w @tsuya/core -w @tsuya/svelte',
  // the unscoped package of `npx tsuya init`, not a workspace: its bin would clash with the core's in node_modules/.bin
  'npm pack --dry-run ./packages/cli',
  // the web budgets, but the fonts' (https://github.com/r-witz/tsuya/issues/7)
  'node scripts/budgets.mjs --skip-fonts',
  // the packed packages type-check in an app that uses them, and init runs there
  'node scripts/consumer.mjs',
];

for (const step of STEPS) {
  console.log(`\n▶ ${step}`);
  const { status } = spawnSync(step, { shell: true, stdio: 'inherit' });
  if (status !== 0) {
    console.error(`\n✗ ${step}`);
    process.exit(status ?? 1);
  }
}
console.log('\n✓ every check passed');
