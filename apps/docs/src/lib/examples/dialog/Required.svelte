<script lang="ts">
  import { Button, Dialog } from '@tsuya/svelte';

  let open = $state(false);
</script>

<Dialog.Root bind:open dismissible={false} alert>
  <Dialog.Trigger>
    {#snippet children(props)}<Button variant="secondary" {...props}>Sign out</Button>{/snippet}
  </Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Title>Your session has expired</Dialog.Title>
    <Dialog.Description>Sign in again to keep your changes.</Dialog.Description>
    <Dialog.Actions>
      <Button variant="primary" onclick={() => (open = false)}>Sign in</Button>
    </Dialog.Actions>
  </Dialog.Content>
</Dialog.Root>
