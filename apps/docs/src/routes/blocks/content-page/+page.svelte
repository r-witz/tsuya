<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import ContentPage from '#lib/examples/blocks/ContentPage.svelte';
</script>

<BlockPage block={getBlock('content-page')}>
  {#snippet children(covers)}<ContentPage {covers} />{/snippet}
</BlockPage>
