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

  import PageHeaderDoOnePageHeader from '#lib/examples/page-header/DoOnePageHeader.svelte';
  import PageHeaderDontTwoPageHeaders from '#lib/examples/page-header/DontTwoPageHeaders.svelte';
  import PageHeaderLarge from '#lib/examples/page-header/Large.svelte';
  import PageHeaderPageBasic from '#lib/examples/page-header/PageBasic.svelte';
  import PageHeaderPreview from '#lib/examples/page-header/Preview.svelte';
  import PageHeaderSectionBasic from '#lib/examples/page-header/SectionBasic.svelte';

  import pageHeaderProps from '../../../../.generated/props/page-header.json' with { type: 'json' };
  import sectionHeaderProps from '../../../../.generated/props/section-header.json' with { type: 'json' };
</script>

<svelte:head>
  <title>PageHeader — tsuya</title>
</svelte:head>

<PageHeader title="PageHeader and SectionHeader" subtitle="Content" />

<p class="t-body-l">
  <code>PageHeader</code> is a page's title, a count line and its actions; <code>SectionHeader</code> is a section's
  title, a count and a ghost "see all" button. A page has one <code>PageHeader</code> (it is the page's
  <code>h1</code>); each section below it has a <code>SectionHeader</code> (an <code>h2</code>). Use ScreenBar for the
  bar of a pushed screen on a phone.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <PageHeaderPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">Actions sit at the end, and wrap under the title when the header is narrow.</p>
<Example html={code('PageBasic')}><PageHeaderPageBasic /></Example>
<Example html={code('SectionBasic')}><PageHeaderSectionBasic /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">A page header:</p>
<CodeBlock html={code('FLUTTER_PAGE')} />
<p class="t-body t-muted">A section header:</p>
<CodeBlock html={code('FLUTTER_SECTION')} />
<GalleryShot id="header" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">PageHeader</h3>
<PropsTable rows={pageHeaderProps} />
<h3 class="t-title-s">SectionHeader</h3>
<PropsTable rows={sectionHeaderProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['PageHeader', 'SectionHeader']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  The title of a <code>PageHeader</code> is <code>display-s</code> on a phone and <code>display-m</code> from the
  desktop breakpoint; <code>large</code> makes it <code>display-l</code> from the desktop breakpoint, for a page that opens
  on it. Shown here at the width of this column, it only grows on a wide screen.
</p>
<Example html={code('Large')}><PageHeaderLarge /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: "Moves focus to the section header's action, or to a button in the page header's actions." },
    { keys: 'Enter / Space', action: 'Presses it.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Albums, heading level 1." A section reads "Recently added, heading level 2", then its count, then "See all, button".
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="one page header, then a section header for each section."
  dontCaption="use a second page header to title a section: it is a second h1."
>
  {#snippet doExample()}<PageHeaderDoOnePageHeader />{/snippet}
  {#snippet dontExample()}<PageHeaderDontTwoPageHeaders />{/snippet}
</DoDont>
