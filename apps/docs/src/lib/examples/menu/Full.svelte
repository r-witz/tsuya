<!-- Checkbox and radio items, a label over a group of options, a shortcut shown at the end (DESIGN.md, Menu). -->
<script lang="ts">
  import { Menu } from '@tsuya/svelte';

  let open = $state(false);
  let shuffle = $state(true);
  let sort = $state('recent');
</script>

<Menu.Root bind:open>
  <Menu.Trigger>Sort</Menu.Trigger>
  <Menu.Content>
    <Menu.CheckboxItem bind:checked={shuffle}>Shuffle</Menu.CheckboxItem>
    <Menu.Separator />
    <Menu.Label>Sort by</Menu.Label>
    <Menu.RadioGroup label="Sort by" bind:value={sort}>
      <Menu.RadioItem value="recent" shortcut="⌘1">Recent</Menu.RadioItem>
      <Menu.RadioItem value="title" shortcut="⌘2">Title</Menu.RadioItem>
      <Menu.RadioItem value="name" shortcut="⌘3">Name</Menu.RadioItem>
    </Menu.RadioGroup>
  </Menu.Content>
</Menu.Root>
