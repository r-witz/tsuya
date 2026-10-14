<script lang="ts">
  import { List, ListItem, Switch } from '@tsuya/svelte';

  let notifications = $state(true);
  let autoUpdate = $state(false);
</script>

<List>
  <ListItem title="Notifications">
    {#snippet trailing()}<Switch bind:checked={notifications} />{/snippet}
  </ListItem>
  <ListItem title="Auto-update" subtitle="Install updates as soon as they are ready">
    {#snippet trailing()}<Switch bind:checked={autoUpdate} />{/snippet}
  </ListItem>
</List>
