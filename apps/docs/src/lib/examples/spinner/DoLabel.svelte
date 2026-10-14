<script lang="ts">
  import { Spinner } from '@tsuya/svelte';
</script>

<div class="row">
  <Spinner size="sm" aria-hidden="true" />
  <span class="t-body">Syncing your library…</span>
</div>

<style>
  .row {
    display: flex;
    align-items: center;
    gap: var(--t-space-8);
  }
</style>
