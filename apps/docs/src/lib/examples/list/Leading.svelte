<script lang="ts">
  import { Avatar, List, ListItem, Switch, Thumbnail } from '@tsuya/svelte';

  import { COVER } from '#lib/examples/art.ts';
  import NavIcon from '#lib/icons/NavIcon.svelte';

  let wifi = $state(true);
</script>

<div style="width: 100%">
  <List>
    <ListItem title="Settings" onclick={() => {}}>
      {#snippet leading()}<span style="display: flex; width: 20px; height: 20px; color: var(--t-text-muted)">
          <NavIcon name="settings" />
        </span>{/snippet}
    </ListItem>
    <ListItem title="Ada Lovelace" subtitle="Online" onclick={() => {}}>
      {#snippet leading()}<Avatar initials="AL" />{/snippet}
    </ListItem>
    <ListItem title="Kind of Blue" subtitle="Miles Davis" onclick={() => {}}>
      {#snippet leading()}<Thumbnail src={COVER.teal} size={48} />{/snippet}
      {#snippet trailing()}<span>9:22</span>{/snippet}
    </ListItem>
    <ListItem title="Wi-Fi">
      {#snippet trailing()}<Switch bind:checked={wifi} />{/snippet}
    </ListItem>
  </List>
</div>
