<script lang="ts">
  import { PageHeader } from '@tsuya/svelte';

  import { code } from '#lib/doc/code.ts';
  import CodeBlock from '#lib/doc/CodeBlock.svelte';
  import GalleryShot from '#lib/doc/GalleryShot.svelte';
  import DartApi from '#lib/doc/DartApi.svelte';
  import DoDont from '#lib/doc/DoDont.svelte';
  import Example from '#lib/doc/Example.svelte';
  import KeyboardTable from '#lib/doc/KeyboardTable.svelte';
  import PreviewStage from '#lib/doc/PreviewStage.svelte';
  import PropsTable from '#lib/doc/PropsTable.svelte';

  import CommandPaletteBasic from '#lib/examples/command-palette/Basic.svelte';
  import CommandPaletteDoRecentFirst from '#lib/examples/command-palette/DoRecentFirst.svelte';
  import CommandPaletteDontFewCommands from '#lib/examples/command-palette/DontFewCommands.svelte';
  import CommandPaletteFilter from '#lib/examples/command-palette/Filter.svelte';
  import CommandPalettePreview from '#lib/examples/command-palette/Preview.svelte';

  import commandPaletteProps from '../../../../.generated/props/command-palette.json' with { type: 'json' };
</script>

<svelte:head>
  <title>CommandPalette — tsuya</title>
</svelte:head>

<PageHeader title="CommandPalette" subtitle="Overlays and feedback" />

<p class="t-body-l">
  A search-driven list of commands: a dialog at most 560 wide near the top, with a search field and the commands in
  groups. Type to filter, press Enter to run the first match, Escape to close. The app opens it, usually on Ctrl or
  Cmd+K: tsuya binds no shortcut. Use Menu for a few actions next to the control that owns them, and Combobox to choose
  a value.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <CommandPalettePreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  Bind <code>open</code>, give it <code>groups</code> and handle <code>onselect</code>. A group is
  <code>&#123; label, commands: [&#123; value, label, disabled &#125;] &#125;</code>. Groups show in the order given:
  put the recent commands in the first one. Running a command closes the palette first, then calls
  <code>onselect</code>, so that a command can move the focus.
</p>
<Example html={code('Basic')}><CommandPaletteBasic /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  <code>CommandPalette.show</code> opens it above everything. A group is a <code>CommandGroup</code> of
  <code>Command</code>s; <code>onSelected</code> gets the command's <code>value</code>, once the palette has closed and
  the focus is back where it was.
</p>
<CodeBlock html={code('FLUTTER_COMMAND_PALETTE')} />
<GalleryShot id="command-palette" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={commandPaletteProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['CommandPalette', 'CommandGroup', 'Command']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  By default a command matches when its label contains the text, ignoring case. <code>filter</code> (Flutter:
  <code>filter:</code>) replaces that rule. With no match, the list says "No results". A disabled command is shown and
  never active. Its words, "Search", "No results" and the result count, come from the labels, so they follow the
  language of the app.
</p>
<Example html={code('Filter')}><CommandPaletteFilter /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Ctrl or Cmd + K', action: 'Opens the palette, when the app binds it: tsuya binds no shortcut.' },
    {
      keys: 'Type',
      action: 'Filters the commands. The first one found is active, so that Enter runs it.',
    },
    {
      keys: '↑ / ↓',
      action:
        'Moves the active command, skipping the disabled ones and stopping at the ends. Focus stays in the field.',
    },
    { keys: 'Enter', action: 'Runs the active command: the palette closes, then the command runs.' },
    { keys: 'Escape', action: 'Closes the palette, and focus returns to what opened it.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Search, dialog": the dialog and its field are named by the search label. The field is a combobox, with the active
  command as its active descendant, announced with its group. Once typing pauses, the number of results is announced: "4
  results", or "No results".
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="put the recent commands in the first group: the command used most is the one Enter runs."
  dontCaption="search two commands; a few actions are a Menu, anchored to their button."
>
  {#snippet doExample()}<CommandPaletteDoRecentFirst />{/snippet}
  {#snippet dontExample()}<CommandPaletteDontFewCommands />{/snippet}
</DoDont>
