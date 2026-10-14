<script lang="ts">
  import { Button, Dialog } from '@tsuya/svelte';

  let open = $state(false);
</script>

<Dialog.Root bind:open>
  <Dialog.Trigger>
    {#snippet children(props)}<Button variant="secondary" {...props}>Delete photo</Button>{/snippet}
  </Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Title>Delete photo?</Dialog.Title>
    <Dialog.Description>This cannot be undone.</Dialog.Description>
    <Dialog.Actions>
      <Dialog.Close>
        {#snippet children(props)}<Button variant="secondary" {...props}>Cancel</Button>{/snippet}
      </Dialog.Close>
      <Button variant="danger" onclick={() => (open = false)}>Delete</Button>
    </Dialog.Actions>
  </Dialog.Content>
</Dialog.Root>
