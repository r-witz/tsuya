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

  import AccordionControlled from '#lib/examples/accordion/Controlled.svelte';
  import AccordionDisabled from '#lib/examples/accordion/Disabled.svelte';
  import AccordionDoShortHeaders from '#lib/examples/accordion/DoShortHeaders.svelte';
  import AccordionDontHideAction from '#lib/examples/accordion/DontHideAction.svelte';
  import AccordionMultiple from '#lib/examples/accordion/Multiple.svelte';
  import AccordionPreview from '#lib/examples/accordion/Preview.svelte';

  import rootProps from '../../../../.generated/props/accordion-root.json' with { type: 'json' };
  import itemProps from '../../../../.generated/props/accordion-item.json' with { type: 'json' };
  import triggerProps from '../../../../.generated/props/accordion-trigger.json' with { type: 'json' };
  import contentProps from '../../../../.generated/props/accordion-content.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Accordion — tsuya</title>
</svelte:head>

<PageHeader title="Accordion" subtitle="Disclosure and navigation" />

<p class="t-body-l">
  Rows that open their content below, one at a time or several: a header, a chevron that turns over, and the content.
  Composed from <code>Accordion.Root</code>, <code>Accordion.Item</code>, <code>Accordion.Trigger</code> and
  <code>Accordion.Content</code>. Use Tabs to switch between views of one thing, and a List for rows that lead to
  another screen.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <AccordionPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted"><code>value</code> holds the values of the open items, and is bound.</p>
<Example html={code('Controlled')}><AccordionControlled /></Example>
<p class="t-body t-muted">With <code>type="multiple"</code>, opening one item leaves the others open.</p>
<Example html={code('Multiple')}><AccordionMultiple /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_BASIC')} />
<GalleryShot id="accordion" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Accordion.Root</h3>
<PropsTable rows={rootProps} />
<h3 class="t-title-s">Accordion.Item</h3>
<PropsTable rows={itemProps} />
<h3 class="t-title-s">Accordion.Trigger</h3>
<PropsTable rows={triggerProps} />
<h3 class="t-title-s">Accordion.Content</h3>
<PropsTable rows={contentProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Accordion', 'AccordionItemData']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  <code>type="single"</code> (the default) closes the open item when another opens; <code>type="multiple"</code> does
  not. An item can be <code>disabled</code>. Each header sits in a heading: <code>level</code> (3 by default) sets which one,
  so that it fits the outline of the page. The height opens and closes over the base duration, at once under reduced motion.
</p>
<Example html={code('Disabled')}><AccordionDisabled /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the next header; each one is a tab stop.' },
    { keys: 'Enter / Space', action: 'Opens or closes the focused item.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Shipping, button, collapsed", and "expanded" once open. The content is a region named by its header.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont doCaption="short headers that name what is inside." dontCaption="hide the only way to go on in a closed item.">
  {#snippet doExample()}<AccordionDoShortHeaders />{/snippet}
  {#snippet dontExample()}<AccordionDontHideAction />{/snippet}
</DoDont>
