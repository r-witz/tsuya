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

  import SegmentedControlBasic from '#lib/examples/segmented-control/Basic.svelte';
  import SegmentedControlDoFew from '#lib/examples/segmented-control/DoFew.svelte';
  import SegmentedControlDontMany from '#lib/examples/segmented-control/DontMany.svelte';
  import SegmentedControlExpand from '#lib/examples/segmented-control/Expand.svelte';
  import SegmentedControlIcons from '#lib/examples/segmented-control/Icons.svelte';

  import segmentedControlProps from '../../../../.generated/props/segmented-control.json' with { type: 'json' };
</script>

<svelte:head>
  <title>SegmentedControl — tsuya</title>
</svelte:head>

<PageHeader title="SegmentedControl" subtitle="Inputs" />

<p class="t-body-l">
  2 to 5 options seen together, one always selected: it switches a view or a mode, and the change shows at once. Built
  from native radios in a track. Use RadioGroup for a choice in a form, Tabs to switch between panels of content, and
  Select for more than five options.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <SegmentedControlBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  One segment is always selected: the first, while there is no value. <code>label</code> names the group.
</p>
<Example html={code('Basic')}><SegmentedControlBasic /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_SEGMENTED_CONTROL')} />
<GalleryShot id="segmented-control" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={segmentedControlProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['SegmentedControl', 'Segment']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  A segment with an <code>icon</code> shows the icon alone, named by its label. <code>expand</code> shares the width equally
  between the segments.
</p>
<Example html={code('Icons')}><SegmentedControlIcons /></Example>
<Example html={code('Expand')}><SegmentedControlExpand /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus into the control, on the selected segment; it is one tab stop.' },
    {
      keys: '→ / ↓',
      action: 'Moves to the next segment and selects it, wrapping at the end (mirrored right to left for →).',
    },
    { keys: '← / ↑', action: 'Moves to the previous segment and selects it, wrapping at the start.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"View, radio group. List, radio button, checked, 1 of 3."</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="keep to 2 to 5 short options that fit side by side."
  dontCaption="use it for a long list; a Select or Tabs scales better."
>
  {#snippet doExample()}<SegmentedControlDoFew />{/snippet}
  {#snippet dontExample()}<SegmentedControlDontMany />{/snippet}
</DoDont>
