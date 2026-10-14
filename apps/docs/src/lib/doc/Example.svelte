<!--
  A live example next to its code: the code is highlighted at build time (#lib/server/highlight.ts) and
  passed in as `html`.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  import CodeBlock from './CodeBlock.svelte';

  interface Props {
    title?: string;
    html: string;
    children: Snippet;
  }

  let { title, html, children }: Props = $props();
</script>

<figure class="example">
  {#if title}<figcaption class="t-control t-muted">{title}</figcaption>{/if}
  <div class="stage">{@render children()}</div>
  <CodeBlock {html} />
</figure>

<style>
  .example {
    margin: var(--t-space-16) 0;
  }
  figcaption {
    margin-bottom: var(--t-space-8);
  }
  .stage {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: var(--t-space-12);
    min-height: var(--t-size-control-lg);
    padding: var(--t-space-16);
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md) var(--t-radius-md) 0 0;
    background: var(--t-fill);
  }
  /* attaches the code block to the stage above it (not the HTML folded under it) */
  .example > :global(.shiki) {
    border-top: 0;
    border-radius: 0 0 var(--t-radius-md) var(--t-radius-md);
  }
</style>
