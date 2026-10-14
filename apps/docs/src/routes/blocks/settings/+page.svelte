<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import Settings from '#lib/examples/blocks/Settings.svelte';
</script>

<BlockPage block={getBlock('settings')}>
  <Settings />
</BlockPage>
