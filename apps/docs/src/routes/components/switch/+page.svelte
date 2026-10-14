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

  import SwitchBasic from '#lib/examples/switch/Basic.svelte';
  import SwitchDoApply from '#lib/examples/switch/DoApply.svelte';
  import SwitchDontSaveButton from '#lib/examples/switch/DontSaveButton.svelte';
  import SwitchSettingsRow from '#lib/examples/switch/SettingsRow.svelte';

  import switchProps from '../../../../.generated/props/switch.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Switch — tsuya</title>
</svelte:head>

<PageHeader title="Switch" subtitle="Inputs" />

<p class="t-body-l">
  A toggle that applies at once, with no save step. Use it for a setting that takes effect immediately; use Checkbox for
  a choice that is part of a form, submitted later.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <SwitchBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Basic')}><SwitchBasic /></Example>
<p class="t-body t-muted">
  The <code>label</code> is drawn beside the track and is the switch's name; the whole control presses. In a settings
  row, leave it out: the row's title names the switch (and its subtitle describes it). A switch anywhere else without a
  <code>label</code> needs an <code>aria-label</code>; in development it warns when it has no name.
</p>
<Example html={code('SettingsRow')}><SwitchSettingsRow /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_BASIC')} />
<GalleryShot id="switch" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={switchProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Switch']} />

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable rows={[{ keys: 'Space', action: 'Toggles it.' }]} />

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Wi-Fi, switch, on."</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont doCaption="apply the change the moment it is toggled." dontCaption="pair it with a separate Save button.">
  {#snippet doExample()}<SwitchDoApply />{/snippet}
  {#snippet dontExample()}<SwitchDontSaveButton />{/snippet}
</DoDont>
