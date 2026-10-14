<!-- A root layout that keeps the first paint in the persisted mode: the theme script in the head, then the provider. -->
<script lang="ts">
  import { themeScript } from '../../../packages/core/src/dom/theme.ts';
  import { TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  let { labels, storageKey }: { labels: TsuyaLabels; storageKey?: string } = $props();
  // not written whole: a closing script tag in a script block ends it
  const script = $derived(`<script>${themeScript(storageKey)}</` + 'script>');
</script>

<svelte:head>
  <!-- eslint-disable-next-line svelte/no-at-html-tags -- the script is a constant of the package -->
  {@html script}
</svelte:head>

<TsuyaProvider {labels}><p>page</p></TsuyaProvider>
