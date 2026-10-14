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

  import ChipBasic from '#lib/examples/chip/Basic.svelte';
  import ChipDoFilter from '#lib/examples/chip/DoFilter.svelte';
  import ChipDontAction from '#lib/examples/chip/DontAction.svelte';
  import ChipGlass from '#lib/examples/chip/Glass.svelte';
  import ChipMultiple from '#lib/examples/chip/Multiple.svelte';
  import ChipStandalone from '#lib/examples/chip/Standalone.svelte';

  import chipProps from '../../../../.generated/props/chip.json' with { type: 'json' };
  import chipGroupProps from '../../../../.generated/props/chip-group.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Chip — tsuya</title>
</svelte:head>

<PageHeader title="Chip" subtitle="Actions" />

<p class="t-body-l">
  A filter or a sort option: a small token that turns accent-filled when it is selected. <code>ChipGroup</code> is a row
  of chips that scrolls sideways, with single selection or <code>multiple</code>, and one tab stop. Use Button for an
  action, SegmentedControl for 2 to 5 modes that switch a view, and Checkbox for a choice in a form.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <ChipBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  In a group, a chip takes its <code>value</code> and the group drives the selection: one value, or an array when
  <code>multiple</code>.
</p>
<Example html={code('Basic')}><ChipBasic /></Example>
<Example html={code('Multiple')}><ChipMultiple /></Example>
<p class="t-body t-muted">Alone, a chip is a toggle button: <code>selected</code> and <code>onclick</code>.</p>
<Example html={code('Standalone')}><ChipStandalone /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  Material also has a <code>Chip</code>: an app that imports it too imports tsuya with a prefix (<code
    >import 'package:tsuya/tsuya.dart' as t;</code
  >). The group holds its selection as a set, so a single selection is a set of one.
</p>
<CodeBlock html={code('FLUTTER_CHIP')} />
<p class="t-body t-muted">A chip on its own, and a group with several chips selected:</p>
<CodeBlock html={code('FLUTTER_CHIP_ALONE')} />
<GalleryShot id="chip" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Chip</h3>
<PropsTable rows={chipProps} />
<h3 class="t-title-s">ChipGroup</h3>
<PropsTable rows={chipGroupProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Chip', 'ChipGroup', 'ChipOption']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  A single selection reads as radios, <code>multiple</code> as toggle buttons. <code>glass</code> is control glass: it only
  reads over artwork, never a flat background (DESIGN.md, rule 3).
</p>
<Example html={code('Glass')}><ChipGlass /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the chip. A group is one tab stop, on the selected chip or the first.' },
    { keys: '→ / ← (in a group)', action: 'Moves to the next or previous chip, wrapping (mirrored right to left).' },
    { keys: 'Home / End (in a group)', action: 'Moves to the first or last chip.' },
    { keys: 'Space / Enter', action: 'Selects the chip, or toggles it.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  A single selection reads "Recent, radio button, checked, 1 of 4" in a group named "Sort by"; with <code>multiple</code
  >, "Jazz, toggle button, pressed". A chip on its own reads as a toggle button.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="use chips to filter or sort what is on screen."
  dontCaption="use a chip for an action such as Save or Delete; use a Button."
>
  {#snippet doExample()}<ChipDoFilter />{/snippet}
  {#snippet dontExample()}<ChipDontAction />{/snippet}
</DoDont>
