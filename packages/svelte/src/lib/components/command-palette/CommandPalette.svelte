<!--
  @component
  A command palette (DESIGN.md, CommandPalette): a dialog at most 560 wide near the top, a search field without a
  visible label (named by the `search` label) over the commands in their groups, in the order given (put "Recent"
  first). Typing filters; the first command found is active, so that Enter runs it; the arrows move; a press runs one.
  Running closes it, then calls `onselect`. Escape and a press on the scrim close; focus returns to the opener. No match
  shows `noResults`, and the number of results is announced when typing pauses. The app opens it, usually with Ctrl
  or Cmd+K: tsuya binds no shortcut.
-->
<script lang="ts">
  import { announce, HIDDEN, TYPEAHEAD_TIMEOUT } from '@tsuya/core/primitives';
  import { tick, untrack } from 'svelte';

  import Glyph from '../../internal/Glyph.svelte';
  import Option from '../../internal/Option.svelte';
  import { getLabels } from '../../primitives/labels.ts';
  import { Listbox } from '../../primitives/listbox.svelte.ts';
  import { Dialog } from '../dialog/index.ts';
  import TextInput from '../text-input/TextInput.svelte';
  import type { Command, CommandGroup } from './types.ts';

  interface Props {
    /** Whether it is open. */
    open?: boolean;
    /** The commands, in groups, in the order shown. */
    groups: readonly CommandGroup[];
    /** Whether a command matches the text. By default its label contains it, ignoring case. */
    filter?: (command: Command, query: string) => boolean;
    /** Runs a command, once the palette has closed and focus is back on the opener. */
    onselect: (command: Command) => void;
  }

  let {
    open = $bindable(false),
    groups,
    filter = (command, query) => command.label.toLowerCase().includes(query.trim().toLowerCase()),
    onselect,
  }: Props = $props();

  const labels = getLabels('CommandPalette');
  const id = $props.id();
  const listId = `${id}-list`;
  let query = $state('');

  const found = $derived(
    groups.flatMap((group) =>
      group.commands.filter((command) => filter(command, query)).map((command) => ({ ...command, group: group.label })),
    ),
  );

  const listbox = new Listbox<string>({
    id,
    options: () => found,
    value: () => [],
    onchange: ([value]) => {
      const command = found.find((each) => each.value === value);
      if (!command) return;
      open = false;
      // once closed and focus is back on the opener, so that a command can move it
      void tick().then(() => {
        onselect({ value: command.value, label: command.label, disabled: command.disabled });
      });
    },
    field: true,
  });

  // a new search starts empty
  $effect.pre(() => {
    if (open) query = '';
  });

  // the first command found is active, so that Enter runs it: on each search, and each time it opens
  $effect.pre(() => {
    const commands = found;
    if (!open) return;
    untrack(() => {
      listbox.active = -1;
      if (commands.length > 0) listbox.move('first');
    });
  });

  $effect(() => {
    const active = listbox.activeId;
    if (open && active) document.getElementById(active)?.scrollIntoView({ block: 'nearest' });
  });

  // the number of results, once typing pauses
  $effect(() => {
    if (!open) return;
    const message = found.length === 0 ? labels.noResults : labels.results(found.length);
    const timer = setTimeout(() => {
      announce(message);
    }, TYPEAHEAD_TIMEOUT);
    return () => {
      clearTimeout(timer);
    };
  });
</script>

{#snippet search()}<Glyph name="search" />{/snippet}

<Dialog.Root bind:open>
  <Dialog.Content size="lg" class="t-command-palette">
    <Dialog.Title style={HIDDEN}>{labels.search}</Dialog.Title>
    <TextInput
      bind:value={query}
      leading={search}
      aria-label={labels.search}
      role="combobox"
      aria-autocomplete="list"
      aria-expanded="true"
      aria-controls={listId}
      aria-activedescendant={listbox.activeId}
      autocomplete="off"
      autofocus
      onkeydown={(event: KeyboardEvent) => {
        listbox.keydown(event);
      }}
    />
    {#if found.length === 0}
      <div class="t-command-palette-status">{labels.noResults}</div>
    {/if}
    <div role="listbox" id={listId} aria-label={labels.search} class="t-command-palette-list">
      {#each listbox.groups as group (group.label)}
        <div role="group" aria-labelledby="{id}-group-{group.options[0]?.index}" class="t-command-palette-group">
          <div id="{id}-group-{group.options[0]?.index}" class="t-command-palette-heading" role="presentation">
            {group.label}
          </div>
          {#each group.options as { option, index } (option.value)}
            <Option
              id={listbox.idOf(index)}
              selected={false}
              active={listbox.active === index}
              disabled={option.disabled}
              onpointermove={() => {
                if (!option.disabled) listbox.move(index);
              }}
              onmousedown={(event: MouseEvent) => {
                // a press keeps the focus in the field
                event.preventDefault();
              }}
              onclick={() => {
                listbox.select(index);
              }}>{option.label}</Option
            >
          {/each}
        </div>
      {/each}
    </div>
  </Dialog.Content>
</Dialog.Root>
