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

  import SidebarBasic from '#lib/examples/sidebar/Basic.svelte';
  import SidebarCollapsible from '#lib/examples/sidebar/Collapsible.svelte';
  import SidebarCurrent from '#lib/examples/sidebar/Current.svelte';
  import SidebarDoOneCurrent from '#lib/examples/sidebar/DoOneCurrent.svelte';
  import SidebarDontManyCurrent from '#lib/examples/sidebar/DontManyCurrent.svelte';
  import SidebarPreview from '#lib/examples/sidebar/Preview.svelte';

  import sidebarProps from '../../../../.generated/props/sidebar.json' with { type: 'json' };
  import groupProps from '../../../../.generated/props/sidebar-group.json' with { type: 'json' };
  import itemProps from '../../../../.generated/props/sidebar-item.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Sidebar — tsuya</title>
</svelte:head>

<PageHeader title="Sidebar" subtitle="Disclosure and navigation" />

<p class="t-body-l">
  The navigation of a desktop shell: 240 wide, groups of items under their labels, an icon and a label on each, a count
  at the end. It replaces the tab bar from the desktop breakpoint; below it, use TabBar. This site's own page tree, on
  the left of this page, is one.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <SidebarPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  An item is a link with <code>href</code>, a button without. The current one takes <code>aria-current</code> and a stronger
  fill.
</p>
<Example html={code('Basic')}><SidebarBasic /></Example>
<p class="t-body t-muted">
  Collapsed, it shows the icons only, 72 wide, and each label becomes a tooltip at the item's end.
</p>
<Example html={code('Collapsible')}><SidebarCollapsible /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_BASIC')} />
<GalleryShot id="sidebar" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Sidebar</h3>
<PropsTable rows={sidebarProps} />
<h3 class="t-title-s">SidebarGroup</h3>
<PropsTable rows={groupProps} />
<h3 class="t-title-s">SidebarItem</h3>
<PropsTable rows={itemProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Sidebar', 'SidebarGroup', 'SidebarItem']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  An item is <code>--t-size-control-sm</code> tall, and <code>--t-size-target</code> on touch. Collapsed, a group label stays
  for screen readers only and a count is hidden; the item keeps its element, so focus stays where it was when an item collapses
  the sidebar.
</p>
<Example html={code('Current')}><SidebarCurrent /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus through the items; each one is a tab stop.' },
    { keys: 'Enter', action: 'Follows a link item, or presses a button item.' },
    { keys: 'Space', action: 'Presses a button item.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Library, 12, link, current page", or "Library, 12, button" without an <code>href</code>. A group is read as a group
  named by its label; collapsed, an item is read by its label alone.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont doCaption="one current item, the page that is shown." dontCaption="mark several items as current.">
  {#snippet doExample()}<SidebarDoOneCurrent />{/snippet}
  {#snippet dontExample()}<SidebarDontManyCurrent />{/snippet}
</DoDont>
