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

  import ButtonDoOnePrimary from '#lib/examples/button/DoOnePrimary.svelte';
  import ButtonDontTwoPrimary from '#lib/examples/button/DontTwoPrimary.svelte';
  import ButtonGlassOverArt from '#lib/examples/button/GlassOverArt.svelte';
  import ButtonLoading from '#lib/examples/button/Loading.svelte';
  import ButtonPrimary from '#lib/examples/button/Primary.svelte';
  import ButtonVariants from '#lib/examples/button/Variants.svelte';

  import buttonProps from '../../../../.generated/props/button.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Button — tsuya</title>
</svelte:head>

<PageHeader title="Button" subtitle="Actions" />

<p class="t-body-l">
  A labelled action: the pill button of the system. <code>primary</code> is the one accent action of a screen;
  <code>secondary</code>, <code>ghost</code> and <code>danger</code> cover the rest; <code>glass</code> is for a button over
  artwork. Use IconButton instead for an icon-only action, and Chip for a filter or a sort option.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Primary')} sizes={['sm', 'md', 'lg']}>
  {#snippet children({ size })}
    <ButtonPrimary {size} />
  {/snippet}
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Variants')}><ButtonVariants /></Example>
<p class="t-body t-muted">
  Loading swaps the icon for a spinner, keeps the width, and ignores presses; disabled fades and ignores presses too.
</p>
<Example html={code('Loading')}><ButtonLoading /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_PRIMARY')} />
<GalleryShot id="button" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={buttonProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Button', 'ButtonKind', 'ButtonSize']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  Sizes <code>sm</code>, <code>md</code> and <code>lg</code> change the height, the side padding and the icon size.
  <code>glass</code> is control glass: it only reads over artwork, never a flat background (DESIGN.md, rule 3).
</p>
<Example html={code('GlassOverArt')}><ButtonGlassOverArt /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the button.' },
    { keys: 'Enter / Space', action: 'Presses the button.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Create, button." While loading, it is also announced as busy.</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="one accent-filled action per screen; the rest are secondary or ghost."
  dontCaption="put two accent-filled actions side by side."
>
  {#snippet doExample()}<ButtonDoOnePrimary />{/snippet}
  {#snippet dontExample()}<ButtonDontTwoPrimary />{/snippet}
</DoDont>
