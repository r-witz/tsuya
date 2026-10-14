<script lang="ts">
  import { Button, CommandPalette, type CommandGroup } from '@tsuya/svelte';

  let open = $state(false);

  // the first group is "Recent": the command used most is the one Enter runs
  const groups: CommandGroup[] = [
    { label: 'Recent', commands: [{ value: 'export', label: 'Export album' }] },
    {
      label: 'All commands',
      commands: [
        { value: 'import', label: 'Import photos' },
        { value: 'settings', label: 'Open settings' },
      ],
    },
  ];
</script>

<Button variant="secondary" onclick={() => (open = true)}>Search commands</Button>

<CommandPalette bind:open {groups} onselect={() => {}} />
