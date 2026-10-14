<!--
  A component page's main live preview: mode (the site's, until one is picked here), accent, direction and
  (optionally) size controls around the rendered example. `dir` flips logical CSS properties natively; `data-theme`
  forces the mode locally (DESIGN.md, Theme and mode); AccentRegion scopes the accent to the stage alone.
-->
<script lang="ts">
  import { accentFromColor } from '@tsuya/core';
  import { AccentRegion, SegmentedControl } from '@tsuya/svelte';
  import { untrack, type Snippet } from 'svelte';

  import CodeBlock from './CodeBlock.svelte';
  import { resolvedMode } from './site-mode.svelte.ts';

  interface Props {
    html: string;
    /** Offered in the size control, in this order; the slot gets the chosen one. */
    sizes?: ('sm' | 'md' | 'lg')[];
    children: Snippet<[{ size: 'sm' | 'md' | 'lg' }]>;
  }

  let { html, sizes, children }: Props = $props();

  const ACCENTS = [
    { value: 'neutral', label: 'Neutral' },
    { value: '#1FB8A6', label: 'Teal' },
    { value: '#B06BD9', label: 'Violet' },
    { value: '#F2722C', label: 'Ember' },
  ];

  // the stage starts in the site's own mode and follows it, until the reader picks one on the stage itself
  let picked = $state<string | null>(null);
  const mode = $derived(picked ?? resolvedMode());
  let accentValue = $state('neutral');
  let direction = $state('ltr');
  // the initial size only: `sizes` is a literal array each page passes once, never a value that changes after mount
  let size = $state<'sm' | 'md' | 'lg'>(untrack(() => sizes?.[0]) ?? 'md');

  const pair = $derived(accentValue === 'neutral' ? null : accentFromColor(accentValue));
</script>

<div class="controls">
  <SegmentedControl
    label="Mode"
    bind:value={
      () => mode,
      (v: string) => {
        picked = v;
      }
    }
    options={[
      { value: 'light', label: 'Light' },
      { value: 'dark', label: 'Dark' },
    ]}
  />
  <SegmentedControl label="Accent" bind:value={accentValue} options={ACCENTS} />
  <SegmentedControl
    label="Direction"
    bind:value={direction}
    options={[
      { value: 'ltr', label: 'LTR' },
      { value: 'rtl', label: 'RTL' },
    ]}
  />
  {#if sizes}
    <SegmentedControl
      label="Size"
      bind:value={() => size, (v) => (size = v as 'sm' | 'md' | 'lg')}
      options={sizes.map((s) => ({ value: s, label: s.toUpperCase() }))}
    />
  {/if}
</div>
<div class="preview">
  <AccentRegion {pair} data-theme={mode} dir={direction as 'ltr' | 'rtl'} class="stage">
    {@render children({ size })}
  </AccentRegion>
  <CodeBlock {html} />
</div>

<style>
  .controls {
    display: flex;
    flex-wrap: wrap;
    gap: var(--t-space-12);
    margin-bottom: var(--t-space-16);
  }
  .preview :global(.stage) {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: var(--t-space-16);
    padding: var(--t-space-48) var(--t-space-24);
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md) var(--t-radius-md) 0 0;
    background: var(--t-bg);
    color: var(--t-text);
  }
  .preview > :global(.shiki) {
    border-top: 0;
    border-radius: 0 0 var(--t-radius-md) var(--t-radius-md);
  }
</style>
