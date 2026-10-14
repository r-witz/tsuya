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

  import SkeletonBasic from '#lib/examples/skeleton/Basic.svelte';
  import SkeletonDoBusyRegion from '#lib/examples/skeleton/DoBusyRegion.svelte';
  import SkeletonDontNoBusyRegion from '#lib/examples/skeleton/DontNoBusyRegion.svelte';
  import SkeletonLoading from '#lib/examples/skeleton/Loading.svelte';
  import SkeletonPreview from '#lib/examples/skeleton/Preview.svelte';
  import SkeletonShapes from '#lib/examples/skeleton/Shapes.svelte';

  import skeletonProps from '../../../../.generated/props/skeleton.json' with { type: 'json' };
  import skeletonTextProps from '../../../../.generated/props/skeleton-text.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Skeleton — tsuya</title>
</svelte:head>

<PageHeader title="Skeleton" subtitle="Content" />

<p class="t-body-l">
  Placeholders at the final size of what loads: blocks of <code>fill-strong</code> with the radius of the real element,
  pulsing slowly. They are hidden from screen readers; the region that loads, which holds them, is
  <code>aria-busy</code>. Use Progress for a task with a length, and Spinner for a wait with no shape.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <SkeletonPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Basic')}><SkeletonBasic /></Example>
<p class="t-body t-muted">
  The app sets <code>aria-busy</code> on the region while it loads, and swaps the blocks for the content.
</p>
<Example html={code('Loading')}><SkeletonLoading /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_BASIC')} />
<GalleryShot id="skeleton" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Skeleton</h3>
<PropsTable rows={skeletonProps} />
<h3 class="t-title-s">Skeleton.Text</h3>
<PropsTable rows={skeletonTextProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Skeleton']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  A block is 100 % wide and one line tall by default, with the <code>xs</code> radius; give it the <code>width</code>,
  <code>height</code>
  and <code>radius</code> of the element it stands in for. <code>Skeleton.Text</code> is 3 lines by default, the last at 60
  %, 8 px apart.
</p>
<Example html={code('Shapes')}><SkeletonShapes /></Example>

<h2 class="t-title-l">Keyboard</h2>
<p class="t-body">None: a skeleton is not interactive.</p>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  The blocks are skipped. The region that holds them is <code>aria-busy="true"</code> while it loads, so assistive technology
  waits for it instead of reading a half-loaded page.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="set aria-busy on the region that loads, and size the blocks like the content."
  dontCaption="show blocks with no busy region: nothing tells a screen reader that the page is loading."
>
  {#snippet doExample()}<SkeletonDoBusyRegion />{/snippet}
  {#snippet dontExample()}<SkeletonDontNoBusyRegion />{/snippet}
</DoDont>
