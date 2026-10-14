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

  import TabBarAmbient from '#lib/examples/tab-bar/Ambient.svelte';
  import TabBarDoFourItems from '#lib/examples/tab-bar/DoFourItems.svelte';
  import TabBarDontSixItems from '#lib/examples/tab-bar/DontSixItems.svelte';
  import TabBarPreview from '#lib/examples/tab-bar/Preview.svelte';
  import TabBarShell from '#lib/examples/tab-bar/Shell.svelte';

  import tabBarProps from '../../../../.generated/props/tab-bar.json' with { type: 'json' };
  import screenProps from '../../../../.generated/props/screen.json' with { type: 'json' };
</script>

<svelte:head>
  <title>TabBar — tsuya</title>
</svelte:head>

<PageHeader title="TabBar and Screen" subtitle="Disclosure and navigation" />

<p class="t-body-l">
  The phone shell. <code>Screen</code> is the surface of a screen: lit by the ambient background or the glow, with the
  grain, the content within the safe areas and the side margins, and a dock floating at the bottom. <code>TabBar</code> goes
  in that dock: glass, 3 to 5 items, an icon over a label. Use Sidebar from the desktop breakpoint, and Tabs for views of
  one piece of content.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <TabBarPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  A Screen is as tall as the window by default; here it sits in a fixed-size frame, so that it stays a part of this
  page. The page scrolls inside it, under the dock.
</p>
<Example html={code('Shell')}><TabBarShell /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">A tab bar:</p>
<CodeBlock html={code('FLUTTER_TAB_BAR')} />
<p class="t-body t-muted">The shell, with the tab bar in its dock:</p>
<CodeBlock html={code('FLUTTER_SCREEN')} />
<GalleryShot id="tab-bar" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">TabBar</h3>
<PropsTable rows={tabBarProps} />
<h3 class="t-title-s">Screen</h3>
<PropsTable rows={screenProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['TabBar', 'TabBarItem', 'TabBarBadge', 'Screen']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  A <code>TabBar</code> item is <code>&#123; value, label, icon, badge? &#125;</code>, where the badge is
  <code>&#123; count?, dot?, label &#125;</code>: it is pinned on the icon, and its <code>label</code> ("3 new") is read
  after the item's own. Without a <code>value</code>, the first tab is current. A <code>Screen</code> without an
  <code>ambient</code>
  image is lit by the neutral glow; with one, by that image, at the safe opacity unless <code>ambientOpacity</code>
  gives the <code>ambient</code> of the accent pair of that image.
</p>
<Example html={code('Ambient')}><TabBarAmbient /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the bar: one tab stop, on the current tab.' },
    {
      keys: '← / →',
      action: 'Moves between the tabs in visual order (mirrored in right-to-left), wrapping, without choosing one.',
    },
    { keys: 'Home / End', action: 'Moves to the first or last tab.' },
    { keys: 'Enter / Space', action: 'Chooses the focused tab. On the current tab, scrolls the page to the top.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Library, tab, selected." A badge is read after the label: "Inbox, 3 new, tab".</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont doCaption="3 to 5 items." dontCaption="put six items in the bar: each label gets too narrow.">
  {#snippet doExample()}<TabBarDoFourItems />{/snippet}
  {#snippet dontExample()}<TabBarDontSixItems />{/snippet}
</DoDont>
