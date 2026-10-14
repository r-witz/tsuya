<!-- Don't: nothing is asked here, so the dialog only gets in the way; this is a toast (DESIGN.md, Dialog: "a decision that needs an answer"). -->
<script lang="ts">
  import { Button, Dialog } from '@tsuya/svelte';
</script>

<Dialog.Root>
  <Dialog.Trigger>
    {#snippet children(props)}<Button variant="secondary" {...props}>Save</Button>{/snippet}
  </Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Title>Saved</Dialog.Title>
    <Dialog.Description>Your changes were saved.</Dialog.Description>
    <Dialog.Actions>
      <Dialog.Close>
        {#snippet children(props)}<Button variant="primary" {...props}>OK</Button>{/snippet}
      </Dialog.Close>
    </Dialog.Actions>
  </Dialog.Content>
</Dialog.Root>
