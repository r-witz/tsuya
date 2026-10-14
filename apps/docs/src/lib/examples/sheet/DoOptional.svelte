<script lang="ts">
  import { Button, List, ListItem, Sheet } from '@tsuya/svelte';

  let open = $state(false);
</script>

<Button variant="secondary" onclick={() => (open = true)}>Sort</Button>

<Sheet.Root bind:open>
  <Sheet.Content>
    <Sheet.Title>Sort by</Sheet.Title>
    <List>
      <ListItem title="Name" onclick={() => (open = false)} />
      <ListItem title="Date added" onclick={() => (open = false)} />
    </List>
  </Sheet.Content>
</Sheet.Root>
