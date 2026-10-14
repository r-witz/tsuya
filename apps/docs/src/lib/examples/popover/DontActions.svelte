<!-- Don't: a list of actions is a Menu, which has the arrows, the type-ahead and the roles for it. -->
<script lang="ts">
  import { Button, Popover } from '@tsuya/svelte';
</script>

<Popover.Root>
  <Popover.Trigger>Actions</Popover.Trigger>
  <Popover.Content>
    <Button variant="ghost" block>Rename</Button>
    <Button variant="ghost" block>Share</Button>
    <Button variant="ghost" block>Delete</Button>
  </Popover.Content>
</Popover.Root>
