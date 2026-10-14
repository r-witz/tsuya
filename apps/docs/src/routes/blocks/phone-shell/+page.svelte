<script lang="ts">
  import { getBlock } from '#lib/content/blocks.ts';
  import BlockPage from '#lib/doc/BlockPage.svelte';
  import PhoneShell from '#lib/examples/blocks/PhoneShell.svelte';
</script>

<BlockPage block={getBlock('phone-shell')}>
  {#snippet children(covers)}<PhoneShell {covers} />{/snippet}
</BlockPage>
