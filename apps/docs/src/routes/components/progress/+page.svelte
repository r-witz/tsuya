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

  import ProgressBasic from '#lib/examples/progress/Basic.svelte';
  import ProgressDoNamed from '#lib/examples/progress/DoNamed.svelte';
  import ProgressDontUnnamed from '#lib/examples/progress/DontUnnamed.svelte';
  import ProgressIndeterminate from '#lib/examples/progress/Indeterminate.svelte';
  import ProgressPreview from '#lib/examples/progress/Preview.svelte';
  import ProgressThin from '#lib/examples/progress/Thin.svelte';

  import progressProps from '../../../../.generated/props/progress.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Progress — tsuya</title>
</svelte:head>

<PageHeader title="Progress" subtitle="Content" />

<p class="t-body-l">
  A bar that fills with the accent while something loads: determinate with a <code>value</code>, or a third of the bar
  sweeping across when the amount is unknown. Use Spinner for a wait with no length at all, inside a button or beside a
  line; use Skeleton for content that is about to appear.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <ProgressPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Basic')}><ProgressBasic /></Example>
<p class="t-body t-muted">Without a value, a third of the bar sweeps across every 1.2 s, in the reading direction.</p>
<Example html={code('Indeterminate')}><ProgressIndeterminate /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_BASIC')} />
<GalleryShot id="progress" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={progressProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Progress']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  <code>thin</code> is 2 tall, for along an edge (the top of a screen, the bottom of a card). The indeterminate sweep
  keeps moving under reduced motion: it is the information. <code>max</code> defaults to 1, so <code>value</code> runs from
  0 to 1.
</p>
<Example html={code('Thin')}><ProgressThin /></Example>

<h2 class="t-title-l">Keyboard</h2>
<p class="t-body">None: a progress bar is not interactive.</p>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Uploading photo, progress bar, 60 percent." Indeterminate, no value is read.</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="name what loads, so each bar is told apart."
  dontCaption="leave several bars on the default label: each one reads as just loading."
>
  {#snippet doExample()}<ProgressDoNamed />{/snippet}
  {#snippet dontExample()}<ProgressDontUnnamed />{/snippet}
</DoDont>
