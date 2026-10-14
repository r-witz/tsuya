<script lang="ts">
  import { Banner, Button } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <Banner tone="danger" title="Sync failed">
    The last 12 changes were not sent.
    {#snippet actions()}
      <Button variant="ghost" size="sm">Details</Button>
      <Button variant="secondary" size="sm">Try again</Button>
    {/snippet}
  </Banner>
</div>
