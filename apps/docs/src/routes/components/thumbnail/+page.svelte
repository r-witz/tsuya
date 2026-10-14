<script lang="ts">
  import { PageHeader } from '@tsuya/svelte';

  import { code } from '#lib/doc/code.ts';
  import CodeBlock from '#lib/doc/CodeBlock.svelte';
  import GalleryShot from '#lib/doc/GalleryShot.svelte';
  import DartApi from '#lib/doc/DartApi.svelte';
  import DoDont from '#lib/doc/DoDont.svelte';
  import Example from '#lib/doc/Example.svelte';
  import PreviewStage from '#lib/doc/PreviewStage.svelte';
  import PropsTable from '#lib/doc/PropsTable.svelte';

  import ThumbnailBasic from '#lib/examples/thumbnail/Basic.svelte';
  import ThumbnailDoDecorative from '#lib/examples/thumbnail/DoDecorative.svelte';
  import ThumbnailDontRepeatTitle from '#lib/examples/thumbnail/DontRepeatTitle.svelte';
  import ThumbnailPlaceholder from '#lib/examples/thumbnail/Placeholder.svelte';
  import ThumbnailPreview from '#lib/examples/thumbnail/Preview.svelte';
  import ThumbnailRatios from '#lib/examples/thumbnail/Ratios.svelte';
  import ThumbnailSizes from '#lib/examples/thumbnail/Sizes.svelte';

  import thumbnailProps from '../../../../.generated/props/thumbnail.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Thumbnail — tsuya</title>
</svelte:head>

<PageHeader title="Thumbnail" subtitle="Content" />

<p class="t-body-l">
  The picture of a content (an album, a poster, a photo): square by default, portrait (2:3) or wide (16:9), with a
  radius that grows with its width. A placeholder shows while it loads, or without an image. Use Avatar instead for a
  person, which is round.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')} sizes={['sm', 'md', 'lg']}>
  {#snippet children({ size })}
    <ThumbnailPreview {size} />
  {/snippet}
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Basic')}><ThumbnailBasic /></Example>
<p class="t-body t-muted">Without an image, or while it loads, a fill with an optional icon stands in.</p>
<Example html={code('Placeholder')}><ThumbnailPlaceholder /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_BASIC')} />
<GalleryShot id="thumbnail" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={thumbnailProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Thumbnail', 'ThumbnailRatio']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  The ratio is <code>square</code>, <code>portrait</code> (2:3) or <code>wide</code> (16:9); <code>size</code> is the
  width in px and the height follows. The radius comes from the width: <code>xs</code> up to 40, <code>sm</code> up to
  64, <code>md</code> up to 160, <code>lg</code> above.
</p>
<Example html={code('Ratios')}><ThumbnailRatios /></Example>
<Example html={code('Sizes')}><ThumbnailSizes /></Example>

<h2 class="t-title-l">Keyboard</h2>
<p class="t-body">
  None: a thumbnail is not interactive. Put it in a button or a link when pressing it should do something.
</p>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Cover of Kind of Blue, image." Without <code>alt</code>, a thumbnail is decorative: screen readers skip it.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="leave it decorative when the row beside it already names the content."
  dontCaption="repeat the title as alt text: a screen reader reads it twice."
>
  {#snippet doExample()}<ThumbnailDoDecorative />{/snippet}
  {#snippet dontExample()}<ThumbnailDontRepeatTitle />{/snippet}
</DoDont>
