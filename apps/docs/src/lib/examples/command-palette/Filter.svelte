<script lang="ts">
  import { Button, CommandPalette, type CommandGroup } from '@tsuya/svelte';

  let open = $state(false);

  const groups: CommandGroup[] = [
    {
      label: 'Actions',
      commands: [
        { value: 'new-album', label: 'New album' },
        { value: 'new-playlist', label: 'New playlist' },
        { value: 'import', label: 'Import photos' },
      ],
    },
  ];
</script>

<Button variant="secondary" onclick={() => (open = true)}>Search commands</Button>

<!-- a command matches when every word of the query is in its label -->
<CommandPalette
  bind:open
  {groups}
  filter={(command, query) =>
    query
      .toLowerCase()
      .split(/\s+/)
      .filter(Boolean)
      .every((word) => command.label.toLowerCase().includes(word))}
  onselect={() => {}}
/>
