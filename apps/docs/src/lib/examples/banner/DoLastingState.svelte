<script lang="ts">
  import { Banner, Button } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <Banner tone="warning" title="You are offline">
    Changes sync when you are back online.
    {#snippet actions()}<Button variant="secondary" size="sm">Retry</Button>{/snippet}
  </Banner>
</div>
