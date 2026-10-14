<script lang="ts">
  import { Button, CommandPalette, type CommandGroup } from '@tsuya/svelte';

  let open = $state(false);
  let last = $state('');

  const groups: CommandGroup[] = [
    { label: 'Recent', commands: [{ value: 'open', label: 'Open file…' }] },
    {
      label: 'Navigation',
      commands: [
        { value: 'settings', label: 'Go to settings' },
        { value: 'archive', label: 'Go to archive', disabled: true },
      ],
    },
  ];
</script>

<!-- tsuya binds no shortcut: the app opens the palette, here on Ctrl or Cmd+K -->
<svelte:window
  onkeydown={(event: KeyboardEvent) => {
    if (event.key === 'k' && (event.ctrlKey || event.metaKey)) {
      event.preventDefault();
      open = true;
    }
  }}
/>

<Button variant="secondary" onclick={() => (open = true)}>Search commands</Button>
{#if last}<p>Ran: {last}</p>{/if}

<CommandPalette bind:open {groups} onselect={(command) => (last = command.label)} />
