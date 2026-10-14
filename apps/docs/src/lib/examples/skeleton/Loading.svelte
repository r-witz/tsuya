<script lang="ts">
  import { Button, Skeleton } from '@tsuya/svelte';

  let loading = $state(true);
</script>

<div style="display: grid; gap: 12px; width: 100%">
  <div aria-busy={loading} style="display: grid; gap: 8px">
    {#if loading}
      <Skeleton height={20} width="40%" />
      <Skeleton.Text lines={2} />
    {:else}
      <strong>Release notes</strong>
      <p style="margin: 0">Faster start-up, and a new accent for every cover.</p>
    {/if}
  </div>
  <div>
    <Button variant="secondary" onclick={() => (loading = !loading)}>
      {loading ? 'Finish loading' : 'Load again'}
    </Button>
  </div>
</div>
