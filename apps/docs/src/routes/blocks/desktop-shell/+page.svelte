<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import DesktopShell from '#lib/examples/blocks/DesktopShell.svelte';
</script>

<BlockPage block={getBlock('desktop-shell')}>
  {#snippet children(covers)}<DesktopShell {covers} />{/snippet}
</BlockPage>
