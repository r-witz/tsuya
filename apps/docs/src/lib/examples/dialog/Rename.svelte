<script lang="ts">
  import { Button, Dialog, Field, TextInput } from '@tsuya/svelte';

  let open = $state(false);
  let name = $state('Holiday');
</script>

<Dialog.Root bind:open>
  <Dialog.Trigger>
    {#snippet children(props)}<Button variant="secondary" {...props}>Rename album</Button>{/snippet}
  </Dialog.Trigger>
  <Dialog.Content>
    <Dialog.Title>Rename album</Dialog.Title>
    <Field label="Name">
      {#snippet control(props)}<TextInput {...props} bind:value={name} />{/snippet}
    </Field>
    <Dialog.Actions>
      <Dialog.Close>
        {#snippet children(props)}<Button variant="secondary" {...props}>Cancel</Button>{/snippet}
      </Dialog.Close>
      <Button variant="primary" onclick={() => (open = false)}>Save</Button>
    </Dialog.Actions>
  </Dialog.Content>
</Dialog.Root>
