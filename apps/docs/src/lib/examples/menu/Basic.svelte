<script lang="ts">
  import { Menu } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';

  let open = $state(false);
</script>

<Menu.Root bind:open>
  <Menu.Trigger>Actions</Menu.Trigger>
  <Menu.Content>
    <Menu.Item onselect={() => {}}>
      {#snippet icon()}<Icon name="pencil" />{/snippet}
      Rename
    </Menu.Item>
    <Menu.Item onselect={() => {}}>
      {#snippet icon()}<Icon name="share" />{/snippet}
      Share
    </Menu.Item>
    <Menu.Separator />
    <Menu.Item destructive onselect={() => {}}>
      {#snippet icon()}<Icon name="trash" />{/snippet}
      Delete
    </Menu.Item>
  </Menu.Content>
</Menu.Root>
