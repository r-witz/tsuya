<script lang="ts">
  import { Checkbox, Popover } from '@tsuya/svelte';

  let unread = $state(true);
  let starred = $state(false);
</script>

<Popover.Root>
  <Popover.Trigger>Filters</Popover.Trigger>
  <Popover.Content>
    <Checkbox bind:checked={unread}>Unread</Checkbox>
    <Checkbox bind:checked={starred}>Starred</Checkbox>
  </Popover.Content>
</Popover.Root>
