<script lang="ts">
  import { Button, Sheet } from '@tsuya/svelte';

  let open = $state(false);
</script>

<Button variant="secondary" onclick={() => (open = true)}>Filters</Button>

<Sheet.Root bind:open side="end">
  <Sheet.Content>
    <Sheet.Title>Filters</Sheet.Title>
    <p>A panel from the end edge, for a desktop.</p>
    <Button variant="primary" onclick={() => (open = false)}>Apply</Button>
  </Sheet.Content>
</Sheet.Root>
