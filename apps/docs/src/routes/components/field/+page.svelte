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

  import FieldBasic from '#lib/examples/field/Basic.svelte';
  import FieldCustom from '#lib/examples/field/Custom.svelte';
  import FieldDoOptional from '#lib/examples/field/DoOptional.svelte';
  import FieldDontAsterisk from '#lib/examples/field/DontAsterisk.svelte';
  import FieldStates from '#lib/examples/field/States.svelte';

  import fieldProps from '../../../../.generated/props/field.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Field — tsuya</title>
</svelte:head>

<PageHeader title="Field" subtitle="Inputs" />

<p class="t-body-l">
  The frame of every form control: the label above, the control, then the hint, or the error in its place. It wires the
  ids and the ARIA between them, so that the label names the control and the hint or error is read with it. Use it
  around TextInput, Textarea or a native control of your own; Select and Combobox already build it in, so do not wrap
  them again.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <FieldBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  The <code>control</code> snippet gets the id and the ARIA props: spread them on the control, and the label, hint and error
  are wired to it.
</p>
<Example html={code('Basic')}><FieldBasic /></Example>
<p class="t-body t-muted">Any native control works, since the props are plain attributes.</p>
<Example html={code('Custom')}><FieldCustom /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  Every tsuya input builds the frame in (<code>label:</code>, <code>hint:</code>, <code>error:</code>,
  <code>optional:</code>, <code>required:</code>). Wrap a custom control in <code>Field</code> directly.
</p>
<CodeBlock html={code('FLUTTER_FIELD')} />
<GalleryShot id="field" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={fieldProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Field', 'FieldLabel', 'FieldMessage']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  An <code>error</code> takes the place of the hint, with an alert icon, and marks the control invalid.
  <code>optional</code>
  adds the optional label after the label; <code>required</code> adds nothing visible, only the announcement.
</p>
<Example html={code('States')}><FieldStates /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the control; the label and the message are not tab stops.' },
    { keys: 'Click or tap on the label', action: 'Focuses the control, as a native label does.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Invite code, edit text, invalid entry, Codes have 6 characters. This one has 3." The label names the control; the
  hint, or the error, is read with it, and an error also marks it invalid.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="mark the optional fields; a required one is only announced as required."
  dontCaption="mark the required ones with an asterisk."
>
  {#snippet doExample()}<FieldDoOptional />{/snippet}
  {#snippet dontExample()}<FieldDontAsterisk />{/snippet}
</DoDont>
