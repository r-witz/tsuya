<script lang="ts">
  import { Button, CommandPalette, type CommandGroup } from '@tsuya/svelte';

  let open = $state(false);

  const groups: CommandGroup[] = [
    { label: 'Recent', commands: [{ value: 'open', label: 'Open file…' }] },
    {
      label: 'Navigation',
      commands: [
        { value: 'settings', label: 'Go to settings' },
        { value: 'archive', label: 'Go to archive', disabled: true },
        { value: 'help', label: 'Go to help' },
      ],
    },
  ];
</script>

<Button variant="secondary" onclick={() => (open = true)}>Search commands</Button>

<CommandPalette bind:open {groups} onselect={() => {}} />
