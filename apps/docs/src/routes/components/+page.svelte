<script lang="ts">
  import { List, ListItem, PageHeader } from '@tsuya/svelte';

  import { PAGES } from '#lib/content/nav.ts';

  const COMPONENTS = PAGES.filter((entry) => entry.slug.startsWith('components/'));
</script>

<svelte:head>
  <title>Components — tsuya</title>
</svelte:head>

<PageHeader title="Components" subtitle="Every component" />

<p class="t-body-l">
  Every page follows the same template: a live preview, Svelte usage and the HTML it renders, Flutter usage, the props
  of both, variants, keyboard and screen reader behaviour, and do and don't.
</p>

<List>
  {#each COMPONENTS as entry (entry.slug)}
    <ListItem title={entry.title} subtitle={entry.summary} href={`/${entry.slug}`} />
  {/each}
</List>
