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

  import CheckboxBasic from '#lib/examples/checkbox/Basic.svelte';
  import CheckboxDisabled from '#lib/examples/checkbox/Disabled.svelte';
  import CheckboxDoForm from '#lib/examples/checkbox/DoForm.svelte';
  import CheckboxDontImmediate from '#lib/examples/checkbox/DontImmediate.svelte';
  import CheckboxMixed from '#lib/examples/checkbox/Mixed.svelte';

  import checkboxProps from '../../../../.generated/props/checkbox.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Checkbox — tsuya</title>
</svelte:head>

<PageHeader title="Checkbox" subtitle="Inputs" />

<p class="t-body-l">
  A native checkbox drawn as a 20 box: it fills with the accent and a tick when checked, and shows a dash when it is
  mixed. With its label, the whole row is pressable. Use it for a choice that is part of a form, submitted later, or to
  pick several items from a list; use Switch for a setting that applies at once, and RadioGroup for one choice among a
  few.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <CheckboxBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">The label is the checkbox's children; without one, give it an <code>aria-label</code>.</p>
<Example html={code('Basic')}><CheckboxBasic /></Example>
<p class="t-body t-muted">
  A mixed state is a dash, whatever <code>checked</code> says. It is a display state, so a parent checkbox sets it itself.
</p>
<Example html={code('Mixed')}><CheckboxMixed /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  Material also has a <code>Checkbox</code>: an app that imports it too imports tsuya with a prefix (<code
    >import 'package:tsuya/tsuya.dart' as t;</code
  >). <code>tristate</code> adds the mixed state, as a null value. As on the web, a press on a mixed checkbox checks it and
  no press sets mixed: the app does.
</p>
<CodeBlock html={code('FLUTTER_CHECKBOX')} />
<GalleryShot id="checkbox" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={checkboxProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Checkbox']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  Checked, unchecked and mixed; a disabled checkbox fades and ignores presses. The box is 20 across and the row is at
  least the target size tall, so a label makes a large press area.
</p>
<Example html={code('Disabled')}><CheckboxDisabled /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the checkbox.' },
    { keys: 'Space', action: 'Toggles it.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Remember me, checkbox, checked." A mixed checkbox reads "mixed" in place of "checked".</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="use a checkbox for a choice that a button submits later."
  dontCaption="use it for a setting that applies at once; that is a Switch."
>
  {#snippet doExample()}<CheckboxDoForm />{/snippet}
  {#snippet dontExample()}<CheckboxDontImmediate />{/snippet}
</DoDont>
