<script lang="ts">
  import { IconButton, Popover } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<!-- Your own opener, through child: spread the props it receives on its element. -->
<Popover.Root>
  <Popover.Trigger>
    {#snippet child(props)}
      <IconButton label="Details" variant="plain" {...props}>
        {#snippet icon()}<Icon name="pencil" />{/snippet}
      </IconButton>
    {/snippet}
  </Popover.Trigger>
  <Popover.Content side="bottom" align="end">
    <p class="t-body">Edited by Ada, 2 minutes ago.</p>
  </Popover.Content>
</Popover.Root>
