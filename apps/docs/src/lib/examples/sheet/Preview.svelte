<script lang="ts">
  import { Button, List, ListItem, Sheet } from '@tsuya/svelte';

  let open = $state(false);
</script>

<Button variant="secondary" onclick={() => (open = true)}>Share</Button>

<Sheet.Root bind:open>
  <Sheet.Content>
    <Sheet.Title>Share</Sheet.Title>
    <List>
      <ListItem title="Copy link" onclick={() => (open = false)} />
      <ListItem title="Send by message" onclick={() => (open = false)} />
      <ListItem title="Save to files" onclick={() => (open = false)} />
    </List>
  </Sheet.Content>
</Sheet.Root>
