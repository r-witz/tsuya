<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import Auth from '#lib/examples/blocks/Auth.svelte';
</script>

<BlockPage block={getBlock('auth')}>
  <Auth />
</BlockPage>
