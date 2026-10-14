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

  import ComboboxAsync from '#lib/examples/combobox/Async.svelte';
  import ComboboxBasic from '#lib/examples/combobox/Basic.svelte';
  import ComboboxDoLong from '#lib/examples/combobox/DoLong.svelte';
  import ComboboxDontFew from '#lib/examples/combobox/DontFew.svelte';
  import ComboboxFreeText from '#lib/examples/combobox/FreeText.svelte';

  import comboboxProps from '../../../../.generated/props/combobox.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Combobox — tsuya</title>
</svelte:head>

<PageHeader title="Combobox" subtitle="Inputs" />

<p class="t-body-l">
  A text input that filters a list: the user types, the options under it narrow, and the arrows and Enter choose one.
  The options can load, and the text can stay free. Use Select when the options are few enough to scroll through without
  typing, and TextInput when there is nothing to choose from.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <ComboboxBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  By default an option matches when its label contains the text, in any case. Escape closes the list, then clears the
  field.
</p>
<Example html={code('Basic')}><ComboboxBasic /></Example>
<p class="t-body t-muted">
  Options that load show a spinner and the <code>loading</code> label; pass a <code>filter</code> that keeps every
  option when a server already filtered them. No match shows <code>noResults</code>.
</p>
<Example html={code('Async')}><ComboboxAsync /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  The Flutter combobox reports an option through <code>onSelected</code>; it does not tell the app that the field was
  cleared.
</p>
<CodeBlock html={code('FLUTTER_COMBOBOX')} />
<GalleryShot id="combobox" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={comboboxProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Combobox', 'ListboxOption']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  With <code>freeText</code> any text may stay in the field, and the value stays undefined unless an option is chosen. Without
  it, when focus leaves, a text that names an option chooses it, and any other text goes back to the label of the value.
</p>
<Example html={code('FreeText')}><ComboboxFreeText /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Typing', action: 'Filters the options and opens the list, with no option active.' },
    { keys: '↓ / ↑ (closed)', action: 'Opens the list on its first or last option.' },
    { keys: '↓ / ↑', action: 'Moves the active option, from none to the first or the last, without wrapping.' },
    { keys: 'Enter', action: 'Chooses the active option; with none active, keeps the text.' },
    { keys: 'Escape', action: 'Closes the list; with it closed, clears the field.' },
    { keys: 'Tab', action: 'Leaves the field: a text that names an option chooses it.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "City, combo box, expanded, 4 results." The number of results is announced once typing pauses, and again when the
  options change; a list that loads says so.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="use a combobox for a long list that people filter by typing."
  dontCaption="use it for a few fixed options; use a Select or radios."
>
  {#snippet doExample()}<ComboboxDoLong />{/snippet}
  {#snippet dontExample()}<ComboboxDontFew />{/snippet}
</DoDont>
