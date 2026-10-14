<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import Library from '#lib/examples/blocks/Library.svelte';
</script>

<BlockPage block={getBlock('library')}>
  {#snippet children(covers)}<Library {covers} />{/snippet}
</BlockPage>
