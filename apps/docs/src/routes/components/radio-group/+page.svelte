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

  import RadioGroupBasic from '#lib/examples/radio-group/Basic.svelte';
  import RadioGroupDoFew from '#lib/examples/radio-group/DoFew.svelte';
  import RadioGroupDontMany from '#lib/examples/radio-group/DontMany.svelte';
  import RadioGroupPlan from '#lib/examples/radio-group/Plan.svelte';

  import radioGroupProps from '../../../../.generated/props/radio-group.json' with { type: 'json' };
  import radioProps from '../../../../.generated/props/radio.json' with { type: 'json' };
</script>

<svelte:head>
  <title>RadioGroup — tsuya</title>
</svelte:head>

<PageHeader title="RadioGroup" subtitle="Inputs" />

<p class="t-body-l">
  One choice among a few, all seen together: a fieldset of native radios that share a name and are named by a legend.
  Each radio is a 20 circle that fills with the accent and an on-accent dot. Use SegmentedControl to switch a view or a
  mode, Select for more than five options or options not all seen together, and Checkbox when several can be chosen.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <RadioGroupBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  The group needs a <code>name</code>, shared by its radios and sent with a form, and a <code>label</code>, which is its
  legend. A radio can be disabled alone: it fades, and the arrows skip it.
</p>
<Example html={code('Plan')}><RadioGroupPlan /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  Flutter's <code>RadioGroup</code> has the name of a widget of <code>package:flutter/widgets.dart</code>, which every
  Flutter app imports: import tsuya with a prefix, or hide the SDK's.
</p>
<CodeBlock html={code('FLUTTER_RADIO_GROUP')} />
<GalleryShot id="radio-group" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">RadioGroup</h3>
<PropsTable rows={radioGroupProps} />
<h3 class="t-title-s">Radio</h3>
<PropsTable rows={radioProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['RadioGroup', 'RadioOption']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  The row of a radio and its label is at least the target size tall, so the label is part of the press area. Selected, a
  radio is filled with the accent.
</p>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    {
      keys: 'Tab',
      action: 'Moves focus into the group, on the selected radio, or the first one; the group is one tab stop.',
    },
    {
      keys: '↓ / →',
      action: 'Moves to the next radio and selects it, wrapping at the end (mirrored right to left for →).',
    },
    { keys: '↑ / ←', action: 'Moves to the previous radio and selects it, wrapping at the start.' },
    { keys: 'Space', action: 'Selects the focused radio.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Size, radio group. Medium, radio button, checked, 2 of 3."</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="use radios for a few options that are worth seeing together."
  dontCaption="list more than five options as radios; use a Select."
>
  {#snippet doExample()}<RadioGroupDoFew />{/snippet}
  {#snippet dontExample()}<RadioGroupDontMany />{/snippet}
</DoDont>
