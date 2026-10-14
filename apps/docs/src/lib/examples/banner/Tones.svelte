<script lang="ts">
  import { Banner } from '@tsuya/svelte';
</script>

<div style="display: grid; gap: 12px; width: 100%">
  <Banner tone="info" title="New version available">Reload to get it.</Banner>
  <Banner tone="success" title="Backup complete">Your library is safe.</Banner>
  <Banner tone="warning" title="Trial ends in 3 days">Pick a plan to keep your playlists.</Banner>
  <Banner tone="danger" title="Sync failed">The last 12 changes were not sent.</Banner>
</div>
