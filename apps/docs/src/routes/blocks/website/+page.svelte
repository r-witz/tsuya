<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import Website from '#lib/examples/blocks/Website.svelte';
</script>

<BlockPage block={getBlock('website')}>
  {#snippet children(covers)}<Website {covers} />{/snippet}
</BlockPage>
