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

  import SelectBasic from '#lib/examples/select/Basic.svelte';
  import SelectComposed from '#lib/examples/select/Composed.svelte';
  import SelectDoMany from '#lib/examples/select/DoMany.svelte';
  import SelectDontFew from '#lib/examples/select/DontFew.svelte';
  import SelectGrouped from '#lib/examples/select/Grouped.svelte';
  import SelectStates from '#lib/examples/select/States.svelte';

  import selectProps from '../../../../.generated/props/select.json' with { type: 'json' };
  import selectRootProps from '../../../../.generated/props/select-root.json' with { type: 'json' };
  import selectTriggerProps from '../../../../.generated/props/select-trigger.json' with { type: 'json' };
  import selectContentProps from '../../../../.generated/props/select-content.json' with { type: 'json' };
  import selectItemProps from '../../../../.generated/props/select-item.json' with { type: 'json' };
  import selectGroupProps from '../../../../.generated/props/select-group.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Select — tsuya</title>
</svelte:head>

<PageHeader title="Select" subtitle="Inputs" />

<p class="t-body-l">
  A choice among more than five options, or options not all seen together. The trigger looks like a text field, with the
  selected label (or the placeholder) and a chevron; it opens a listbox panel under it, with the selected option ticked.
  It builds in its Field, and carries the value in a form. Use RadioGroup or SegmentedControl for a few options seen
  together, and Combobox when the user types to filter the list.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <SelectBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  Pass the <code>options</code> and a <code>label</code>; a <code>name</code> sends the value with a form, and
  <code>required</code> makes the form refuse to submit without one.
</p>
<Example html={code('Basic')}><SelectBasic /></Example>
<p class="t-body t-muted">
  Options in groups, one of them disabled. For full control, compose it from <code>Select.Root</code>,
  <code>Select.Trigger</code>, <code>Select.Content</code>, <code>Select.Item</code>, <code>Select.Group</code> and
  <code>Select.Separator</code>:
</p>
<Example html={code('Grouped')}><SelectGrouped /></Example>
<Example html={code('Composed')}><SelectComposed /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  The label, the options and the value are named as on the web; groups come from <code>ListboxOption.group</code>.
  <code>sheetOnPhone</code> is true by default: below the tablet width the options open in a <code>Sheet</code>.
</p>
<CodeBlock html={code('FLUTTER_SELECT')} />
<GalleryShot id="select" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Select</h3>
<PropsTable rows={selectProps} />
<h3 class="t-title-s">Select.Root</h3>
<PropsTable rows={selectRootProps} />
<h3 class="t-title-s">Select.Trigger</h3>
<PropsTable rows={selectTriggerProps} />
<h3 class="t-title-s">Select.Content</h3>
<PropsTable rows={selectContentProps} />
<h3 class="t-title-s">Select.Item</h3>
<PropsTable rows={selectItemProps} />
<h3 class="t-title-s">Select.Group</h3>
<PropsTable rows={selectGroupProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Select', 'ListboxOption']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  A hint, an error (which marks the trigger invalid), <code>required</code>, <code>optional</code> and
  <code>disabled</code> come from the Field it builds in.
</p>
<Example html={code('States')}><SelectStates /></Example>
<p class="t-body t-muted">
  Below 600 px wide (the tablet width) the options open in a sheet titled by the label instead of a panel under the
  trigger, and the listbox takes the focus until the sheet closes. The width is read as it opens: a resize does not swap
  a panel that is open. Set <code>sheetOnPhone=&#123;false&#125;</code> (Flutter: <code>sheetOnPhone: false</code>) to
  keep the panel on every width.
</p>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the trigger. On an open list, it closes it and moves on.' },
    { keys: 'Enter / Space / ↓ / ↑ (closed)', action: 'Opens the list, on the selected option.' },
    { keys: 'Home / End (closed)', action: 'Opens the list on its first or last option.' },
    { keys: 'A letter', action: 'Opens the list on the next option that starts with it, or moves to it when open.' },
    { keys: '↑ / ↓', action: 'Moves the active option; focus stays on the trigger.' },
    { keys: 'Home / End', action: 'Moves to the first or last option.' },
    { keys: 'Enter / Space', action: 'Chooses the active option and closes the list.' },
    { keys: 'Escape', action: 'Closes the list; focus stays on the trigger.' },
  ]}
/>
<p class="t-body t-muted">
  In the sheet (below 600 px) the focus is on the listbox itself, not on the trigger. The same keys move, choose and
  close; a drag down on touch closes it too. Focus goes back to the trigger when the sheet closes.
</p>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Country, France, combo box, collapsed." Open, it reads the active option, for example "Germany, option, 2 of 7". A
  required select is announced as required. In the sheet, it is a dialog named by the label, "Country, dialog", holding
  the listbox.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="use a select for more than five options, or ones that are not all seen together."
  dontCaption="hide two or three options behind one; use a SegmentedControl, RadioGroup or Switch."
>
  {#snippet doExample()}<SelectDoMany />{/snippet}
  {#snippet dontExample()}<SelectDontFew />{/snippet}
</DoDont>
