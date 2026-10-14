<!-- Don't: two commands do not need a search; this is a menu, anchored to its button (DESIGN.md, CommandPalette: a list of commands to search). -->
<script lang="ts">
  import { Button, CommandPalette, type CommandGroup } from '@tsuya/svelte';

  let open = $state(false);

  const groups: CommandGroup[] = [
    {
      label: 'Actions',
      commands: [
        { value: 'rename', label: 'Rename' },
        { value: 'delete', label: 'Delete' },
      ],
    },
  ];
</script>

<Button variant="secondary" onclick={() => (open = true)}>Actions</Button>

<CommandPalette bind:open {groups} onselect={() => {}} />
