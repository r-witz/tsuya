<!-- Don't: Escape or a press outside would close this sheet and leave the question unanswered; a required decision is a dialog (DESIGN.md, Sheet). -->
<script lang="ts">
  import { Button, Sheet } from '@tsuya/svelte';

  let open = $state(false);
</script>

<Button variant="secondary" onclick={() => (open = true)}>Leave</Button>

<Sheet.Root bind:open>
  <Sheet.Content>
    <Sheet.Title>Discard your changes?</Sheet.Title>
    <Button variant="danger" onclick={() => (open = false)}>Discard</Button>
    <Button variant="secondary" onclick={() => (open = false)}>Keep editing</Button>
  </Sheet.Content>
</Sheet.Root>
