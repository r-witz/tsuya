<!--
  A block's page: its summary, the live example in a frame (mode and width switches), the
  example's code with a copy button, and the rules it shows. The code is highlighted at build time, by
  routes/blocks/+layout.server.ts, which also gives it as text, for the copy button.
-->
<script lang="ts">
  import { Button, PageHeader } from '@tsuya/svelte';
  import { onMount, type Snippet } from 'svelte';

  import { page } from '$app/state';
  import type { Block } from '#lib/content/blocks.ts';
  import { sampleCovers, type SampleCover } from '#lib/material/sample-covers.svelte.ts';

  import BlockFrame from './BlockFrame.svelte';
  import CodeBlock from './CodeBlock.svelte';

  interface Props {
    block: Block;
    /** The live example; it gets the sample covers when the block shows them (`block.covers`), once they are drawn. */
    children: Snippet<[SampleCover[]]>;
  }

  let { block, children }: Props = $props();

  const example = $derived.by(() => {
    if (!page.data.example) throw new Error(`${page.url.pathname} has no example code`);
    return page.data.example;
  });

  let copied = $state(false);

  onMount(() => {
    if (block.covers) sampleCovers.load();
  });

  async function copy(): Promise<void> {
    await navigator.clipboard.writeText(example.source);
    copied = true;
    setTimeout(() => (copied = false), 2000);
  }
</script>

<svelte:head>
  <title>{block.title} — tsuya</title>
</svelte:head>

<PageHeader title={block.title} subtitle="Blocks" />

<p class="t-body-l">{block.summary}</p>

<h2 class="t-title-l">Live example</h2>
<BlockFrame width={block.width} label={`${block.title}, live example`}>
  {#if block.covers && sampleCovers.list.length === 0}
    <p class="t-small t-muted waiting" aria-busy="true">Drawing the sample covers…</p>
  {:else}
    {@render children(sampleCovers.list)}
  {/if}
</BlockFrame>

<h2 class="t-title-l">Code</h2>
<p class="t-body t-muted">
  The whole example, to copy: it is one component of the public API. Only the sample covers (the picture and its accent
  pair, computed once by <code class="t-mono">accentFromImage</code>) come from the docs.
</p>
<div class="copy"><Button variant="secondary" size="sm" onclick={copy}>{copied ? 'Copied' : 'Copy code'}</Button></div>
<CodeBlock html={example.html} />

<h2 class="t-title-l">Rules it shows</h2>
<ul class="rules t-body">
  {#each block.rules as rule (rule)}<li>{rule}</li>{/each}
</ul>

<style>
  .copy {
    margin-block: var(--t-space-12);
  }
  .waiting {
    padding: var(--t-space-24);
  }
  .rules {
    max-width: 70ch;
    margin: var(--t-space-16) 0 0;
    padding-inline-start: var(--t-space-24);
  }
  .rules li + li {
    margin-top: var(--t-space-8);
  }
</style>
