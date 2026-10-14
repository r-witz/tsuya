<script lang="ts">
  import { Avatar, List, ListItem } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <List>
    <ListItem title="Ada Lovelace" subtitle="ada@example.com" tall onclick={() => {}}>
      {#snippet leading()}<Avatar initials="AL" colors={['#1F7A6E', '#0C2B3A']} />{/snippet}
    </ListItem>
  </List>
</div>
