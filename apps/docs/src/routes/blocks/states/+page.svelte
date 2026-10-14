<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import States from '#lib/examples/blocks/States.svelte';
</script>

<BlockPage block={getBlock('states')}>
  <States />
</BlockPage>
