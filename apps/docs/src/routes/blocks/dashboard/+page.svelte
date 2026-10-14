<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import Dashboard from '#lib/examples/blocks/Dashboard.svelte';
</script>

<BlockPage block={getBlock('dashboard')}>
  <Dashboard />
</BlockPage>
