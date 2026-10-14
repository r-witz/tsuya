<script lang="ts">
  import { Button, Dialog } from '@tsuya/svelte';
</script>

<Dialog.Root>
  <Dialog.Trigger>
    {#snippet children(props)}<Button variant="secondary" {...props}>Terms</Button>{/snippet}
  </Dialog.Trigger>
  <Dialog.Content size="lg">
    <Dialog.Title>Terms of use</Dialog.Title>
    <Dialog.Description>A wider box, 560 at most, for a longer text or a small form.</Dialog.Description>
    <Dialog.Actions>
      <Dialog.Close>
        {#snippet children(props)}<Button variant="primary" {...props}>Done</Button>{/snippet}
      </Dialog.Close>
    </Dialog.Actions>
  </Dialog.Content>
</Dialog.Root>
