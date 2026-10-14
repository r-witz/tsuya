<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import Forms from '#lib/examples/blocks/Forms.svelte';
</script>

<BlockPage block={getBlock('forms')}>
  <Forms />
</BlockPage>
