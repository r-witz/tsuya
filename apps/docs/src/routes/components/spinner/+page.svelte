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

  import SpinnerBasic from '#lib/examples/spinner/Basic.svelte';
  import SpinnerDoLabel from '#lib/examples/spinner/DoLabel.svelte';
  import SpinnerDontPanel from '#lib/examples/spinner/DontPanel.svelte';
  import SpinnerInButton from '#lib/examples/spinner/InButton.svelte';
  import SpinnerLabelled from '#lib/examples/spinner/Labelled.svelte';

  import spinnerProps from '../../../../.generated/props/spinner.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Spinner — tsuya</title>
</svelte:head>

<PageHeader title="Spinner" subtitle="Content" />

<p class="t-body-l">
  A ring with a quarter arc turning once every 0.8 s: progress that cannot be estimated. Alone it is an indeterminate
  progress bar with a label; inside a labelled button it is only drawn. Use Progress when the amount is known, and
  Skeleton for content that is loading in its place.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')} sizes={['sm', 'md', 'lg']}>
  {#snippet children({ size })}
    <SpinnerBasic {size} />
  {/snippet}
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Basic')}><SpinnerBasic /></Example>
<p class="t-body t-muted">Alone, it needs a name: <code>label</code> says what is loading.</p>
<Example html={code('Labelled')}><SpinnerLabelled /></Example>
<p class="t-body t-muted">
  In a button, use the button's own <code>loading</code>: it puts the spinner in place of the icon.
</p>
<Example html={code('InButton')}><SpinnerInButton /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_SPINNER')} />
<GalleryShot id="spinner" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={spinnerProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Spinner', 'SpinnerSize']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  Sizes are <code>sm</code>, <code>md</code> and <code>lg</code> (16, 20 and 24). It turns at the same speed under reduced
  motion: its motion is the information.
</p>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable rows={[{ keys: '—', action: 'None: a spinner is not interactive and takes no focus.' }]} />

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Loading, progress bar." With <code>label</code> it reads that instead, for example "Loading messages". Inside a labelled
  button it is hidden from screen readers, and the button is announced as busy.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="say what is loading, next to a small spinner."
  dontCaption="leave a whole panel to a spinner; use a Skeleton."
>
  {#snippet doExample()}<SpinnerDoLabel />{/snippet}
  {#snippet dontExample()}<SpinnerDontPanel />{/snippet}
</DoDont>
