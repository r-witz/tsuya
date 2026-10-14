<script lang="ts">
  import { Button, Dialog } from '@tsuya/svelte';

  let { size = 'md' }: { size?: 'sm' | 'md' | 'lg' } = $props();
  let open = $state(false);
</script>

<Dialog.Root bind:open>
  <Dialog.Trigger>
    {#snippet children(props)}<Button {...props}>Delete photo</Button>{/snippet}
  </Dialog.Trigger>
  <Dialog.Content size={size === 'lg' ? 'lg' : 'md'}>
    <Dialog.Title>Delete photo?</Dialog.Title>
    <Dialog.Description>It leaves every album it is in. This cannot be undone.</Dialog.Description>
    <Dialog.Actions>
      <Dialog.Close>
        {#snippet children(props)}<Button variant="secondary" {...props}>Cancel</Button>{/snippet}
      </Dialog.Close>
      <Button variant="danger" onclick={() => (open = false)}>Delete</Button>
    </Dialog.Actions>
  </Dialog.Content>
</Dialog.Root>
