// The packages as an app gets them (G12): each one packed with npm pack, unpacked into the node_modules of an app in
// a temporary directory next to svelte, and the app's TypeScript and Svelte files type-checked. They import every
// export and use the components: a declaration that was not written, an export that points nowhere or a type that
// does not reach the app fails the check. Then the init command of the packed core runs in the app.
import { execFileSync } from 'node:child_process';
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';

const ROOT = resolve(import.meta.dirname, '..');

const TSCONFIG = {
  compilerOptions: {
    target: 'es2022',
    module: 'esnext',
    moduleResolution: 'bundler',
    lib: ['es2022', 'dom', 'dom.iterable'],
    types: [],
    strict: true,
    verbatimModuleSyntax: true,
    skipLibCheck: false,
    noEmit: true,
  },
  include: ['src/**/*.ts', 'src/**/*.svelte'],
};

// any where a type should be: the export lost its declaration
const CHECK_TS = `import * as core from '@tsuya/core';
import * as engine from '@tsuya/core/engine';
import * as tokens from '@tsuya/core/tokens';
import * as tsuya from '@tsuya/svelte';

type IsAny<T> = 0 extends 1 & T ? true : false;
type Typed<M> = [{ [K in keyof M]: IsAny<M[K]> extends true ? K : never }[keyof M]] extends [never] ? true : false;
type Assert<T extends true> = T;

export type Checks = [
  Assert<Typed<typeof core>>,
  Assert<Typed<typeof engine>>,
  Assert<Typed<typeof tokens>>,
  Assert<Typed<typeof tsuya>>,
  Assert<Typed<Pick<typeof tsuya.Select, 'Root' | 'Trigger' | 'Content' | 'Item' | 'Group' | 'Separator'>>>,
  Assert<Typed<typeof tsuya.Tabs>>,
  Assert<Typed<typeof tsuya.Accordion>>,
  Assert<Typed<typeof tsuya.Menu>>,
  Assert<Typed<typeof tsuya.Popover>>,
];
`;

const APP_SVELTE = `<script lang="ts">
  import { labelsEn } from '@tsuya/core';
  import { Button, Combobox, Field, IconButton, Menu, Select, TsuyaProvider, TextInput } from '@tsuya/svelte';

  let country = $state<string>();
  let size = $state('m');
  let city = $state<string>();
  let wrap = $state(false);
</script>

<TsuyaProvider labels={labelsEn}>
  <Select label="Country" bind:value={country} options={[{ value: 'FR', label: 'France' }]} />
  <Select.Root bind:value={size} label="Size">
    <Select.Trigger />
    <Select.Content>
      <Select.Item value="s" label="Small" />
      <Select.Separator />
      <Select.Group label="Larger"><Select.Item value="m" label="Medium" /></Select.Group>
    </Select.Content>
  </Select.Root>
  <Combobox label="City" bind:value={city} options={[{ value: 'PAR', label: 'Paris' }]} />
  <Field label="Name">
    {#snippet control(props)}<TextInput {...props} />{/snippet}
  </Field>
  <Button variant="primary">Save</Button>
  <Menu.Root>
    <Menu.Trigger>
      {#snippet child(props)}<IconButton {...props} label="More" icon={dots} />{/snippet}
    </Menu.Trigger>
    <Menu.Content>
      <Menu.Item shortcut="⌘ R" onselect={() => {}}>Rename</Menu.Item>
      <Menu.CheckboxItem bind:checked={wrap}>Wrap lines</Menu.CheckboxItem>
      <Menu.Separator />
      <Menu.Item destructive>Delete</Menu.Item>
    </Menu.Content>
  </Menu.Root>
</TsuyaProvider>

{#snippet dots()}<svg viewBox="0 0 24 24"></svg>{/snippet}
`;

const app = mkdtempSync(join(tmpdir(), 'tsuya-consumer-'));
try {
  const modules = join(app, 'node_modules');
  mkdirSync(join(modules, '@tsuya'), { recursive: true });
  // the builds of prepack, whose output would mix with the JSON of npm pack
  execFileSync('npm', ['run', 'build', '--workspace', 'packages/core', '--workspace', 'packages/svelte'], {
    cwd: ROOT,
    stdio: 'inherit',
  });
  for (const name of ['core', 'svelte']) {
    const [packed] = JSON.parse(
      execFileSync('npm', ['pack', '--json', '--ignore-scripts', '--pack-destination', app], {
        cwd: join(ROOT, 'packages', name),
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'inherit'],
      }),
    );
    const target = join(modules, '@tsuya', name);
    mkdirSync(target);
    execFileSync('tar', ['-xzf', join(app, packed.filename), '-C', target, '--strip-components=1']);
  }
  symlinkSync(join(ROOT, 'node_modules', 'svelte'), join(modules, 'svelte'), 'dir');
  mkdirSync(join(app, 'src'));
  writeFileSync(join(app, 'tsconfig.json'), JSON.stringify(TSCONFIG, null, 2));
  writeFileSync(join(app, 'src', 'check.ts'), CHECK_TS);
  writeFileSync(join(app, 'src', 'App.svelte'), APP_SVELTE);
  execFileSync(
    join(ROOT, 'node_modules', '.bin', 'svelte-check'),
    ['--workspace', app, '--tsconfig', join(app, 'tsconfig.json'), '--fail-on-warnings'],
    { stdio: 'inherit' },
  );
  console.log('✓ the packed packages type-check in an app');
  // a bundler follows every relative import of the built files: each must name a file of the package
  const broken = [];
  for (const name of ['core', 'svelte']) {
    const root = join(modules, '@tsuya', name);
    for (const file of readdirSync(root, { recursive: true })) {
      if (!/\.(js|svelte)$/.test(file)) continue;
      const source = readFileSync(join(root, file), 'utf8');
      for (const [, path] of source.matchAll(/(?:from|import)\s*\(?\s*['"](\.{1,2}\/[^'"]+)['"]/g)) {
        if (!existsSync(join(root, dirname(file), path))) broken.push(`@tsuya/${name}/${file}: ${path}`);
      }
    }
  }
  if (broken.length > 0) throw new Error(`relative imports to no file:\n${broken.join('\n')}`);
  console.log('✓ every relative import of the packed packages names a file');
  // the init command, as npx runs it from the packed package
  const core = join(modules, '@tsuya', 'core');
  const { bin } = JSON.parse(readFileSync(join(core, 'package.json'), 'utf8'));
  execFileSync(process.execPath, [join(core, bin.tsuya), 'init'], { cwd: app, stdio: 'inherit' });
  if (!readFileSync(join(app, 'AGENTS.md'), 'utf8').includes('node_modules/@tsuya/core/DESIGN.md')) {
    throw new Error('init did not point AGENTS.md to the DESIGN.md of the packed package');
  }
  console.log('✓ init points the agents of the app to DESIGN.md');
} finally {
  rmSync(app, { recursive: true, force: true });
}
