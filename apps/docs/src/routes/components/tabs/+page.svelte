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

  import TabsControlled from '#lib/examples/tabs/Controlled.svelte';
  import TabsDoShortLabels from '#lib/examples/tabs/DoShortLabels.svelte';
  import TabsDontLongLabels from '#lib/examples/tabs/DontLongLabels.svelte';
  import TabsManual from '#lib/examples/tabs/Manual.svelte';
  import TabsPreview from '#lib/examples/tabs/Preview.svelte';

  import rootProps from '../../../../.generated/props/tabs-root.json' with { type: 'json' };
  import listProps from '../../../../.generated/props/tabs-list.json' with { type: 'json' };
  import triggerProps from '../../../../.generated/props/tabs-trigger.json' with { type: 'json' };
  import contentProps from '../../../../.generated/props/tabs-content.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Tabs — tsuya</title>
</svelte:head>

<PageHeader title="Tabs" subtitle="Disclosure and navigation" />

<p class="t-body-l">
  A row of text tabs, each with a panel: switch between views of one piece of content without leaving the page. Composed
  from <code>Tabs.Root</code>, <code>Tabs.List</code>, <code>Tabs.Trigger</code> and <code>Tabs.Content</code>. Use
  SegmentedControl for a setting that changes how the same content is shown, and TabBar for the sections of a phone app.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <TabsPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">The selected value is bound; the first tab is selected while it is undefined.</p>
<Example html={code('Controlled')}><TabsControlled /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_BASIC')} />
<GalleryShot id="tabs" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Tabs.Root</h3>
<PropsTable rows={rootProps} />
<h3 class="t-title-s">Tabs.List</h3>
<PropsTable rows={listProps} />
<h3 class="t-title-s">Tabs.Trigger</h3>
<PropsTable rows={triggerProps} />
<h3 class="t-title-s">Tabs.Content</h3>
<PropsTable rows={contentProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Tabs', 'TabItem', 'TabView']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  By default the arrows select as they move. With <code>manual</code>, they only move focus, and Enter or Space selects:
  for a panel that is slow to show. A trigger can be <code>disabled</code>. The row scrolls sideways when the tabs do
  not fit.
</p>
<Example html={code('Manual')}><TabsManual /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the selected tab, then to its panel.' },
    {
      keys: '← / →',
      action:
        'Moves to the previous or next tab in visual order (mirrored in right-to-left), wrapping, and selects it, except in manual mode.',
    },
    { keys: 'Home / End', action: 'Moves to the first or last tab.' },
    { keys: 'Enter / Space', action: 'Selects the focused tab; in manual mode, this is the only way.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Reviews, tab, selected, 2 of 3." The panel is a tab panel named by its tab: "Reviews, tab panel".</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="short labels that fit in the row."
  dontCaption="long labels: the row scrolls sideways and hides the other tabs."
>
  {#snippet doExample()}<TabsDoShortLabels />{/snippet}
  {#snippet dontExample()}<TabsDontLongLabels />{/snippet}
</DoDont>
