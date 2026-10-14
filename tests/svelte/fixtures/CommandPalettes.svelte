<!-- A command palette opened by a button, with recent commands first, a disabled one and a field a command focuses. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import {
    Button,
    CommandPalette,
    TextInput,
    TsuyaProvider,
    type Command,
    type CommandGroup,
  } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    open?: boolean;
    dir?: 'ltr' | 'rtl';
    onselect?: (command: Command) => void;
  }

  let { open = $bindable(false), dir = 'ltr', onselect = () => {} }: Props = $props();

  let note = $state<HTMLInputElement | null>(null);

  const groups: CommandGroup[] = [
    { label: 'Recent', commands: [{ value: 'open', label: 'Open file' }] },
    {
      label: 'Files',
      commands: [
        { value: 'new', label: 'New file' },
        { value: 'save', label: 'Save', disabled: true },
        { value: 'open', label: 'Open file' },
        { value: 'note', label: 'Write a note' },
      ],
    },
    { label: 'Settings', commands: [{ value: 'theme', label: 'Change theme' }] },
  ];
</script>

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="padding: var(--t-space-16)">
    <Button
      onclick={() => {
        open = true;
      }}>Commands</Button
    >
    <TextInput bind:ref={note} aria-label="Note" />
    <CommandPalette
      bind:open
      {groups}
      onselect={(command: Command) => {
        onselect(command);
        if (command.value === 'note') note?.focus();
      }}
    />
  </div>
</TsuyaProvider>
