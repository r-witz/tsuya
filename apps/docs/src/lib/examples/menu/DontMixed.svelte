<script lang="ts">
  import { Menu } from '@tsuya/svelte';
</script>

<Menu.Root open>
  <Menu.Trigger>Actions</Menu.Trigger>
  <Menu.Content>
    <Menu.Item onselect={() => {}}>Rename</Menu.Item>
    <Menu.Item destructive onselect={() => {}}>Delete</Menu.Item>
    <Menu.Item onselect={() => {}}>Share</Menu.Item>
  </Menu.Content>
</Menu.Root>
