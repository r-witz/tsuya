<script lang="ts">
  import { List, ListItem, PageHeader } from '@tsuya/svelte';

  import { BLOCKS } from '#lib/content/blocks.ts';
</script>

<svelte:head>
  <title>Blocks — tsuya</title>
</svelte:head>

<PageHeader title="Blocks" subtitle={`${String(BLOCKS.length)} patterns`} />

<p class="t-body-l">
  Blocks are examples, not packaged components: the patterns of the system, built only from its public API, live, in
  light and dark, at a phone and at a desktop width. Each page has the example's code to copy and the rules it shows.
</p>

<List>
  {#each BLOCKS as block (block.slug)}
    <ListItem title={block.title} subtitle={block.summary} href={`/blocks/${block.slug}`} />
  {/each}
</List>
