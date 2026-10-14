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

  import TooltipBasic from '#lib/examples/tooltip/Basic.svelte';
  import TooltipDoHint from '#lib/examples/tooltip/DoHint.svelte';
  import TooltipDontEssential from '#lib/examples/tooltip/DontEssential.svelte';
  import TooltipIconButton from '#lib/examples/tooltip/IconButton.svelte';
  import TooltipSides from '#lib/examples/tooltip/Sides.svelte';

  import tooltipProps from '../../../../.generated/props/tooltip.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Tooltip — tsuya</title>
</svelte:head>

<PageHeader title="Tooltip" subtitle="Overlays and feedback" />

<p class="t-body-l">
  A short label for a control, shown on fine pointers and on keyboard focus, never on touch and never as the only place
  where something is said. It describes its trigger, or, for an icon button, it is the label itself. Use a Popover for
  content people interact with, and write what is essential in the interface.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <TooltipBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  The <code>trigger</code> snippet gets the props to spread on the trigger: an <code>aria-describedby</code> and the listeners.
  The tooltip shows after a short delay on hover, and at once on keyboard focus.
</p>
<Example html={code('Basic')}><TooltipBasic /></Example>
<p class="t-body t-muted">An IconButton does this for you, with its label:</p>
<Example html={code('IconButton')}><TooltipIconButton /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  <code>Tooltip</code> wraps its trigger: on a mouse or a pen after a short delay, on keyboard focus at once, never on
  touch. <code>message</code> is its text and <code>side</code> the preferred side. It sets <code>message</code> as the
  trigger's semantics <code>tooltip</code>; pass <code>describe: false</code> when the trigger already carries it, as
  <code>IconButton</code> does.
</p>
<CodeBlock html={code('FLUTTER_TOOLTIP')} />
<GalleryShot id="tooltip" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={tooltipProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Tooltip']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  <code>side</code> puts it above (the default), below, or at the start or end of its trigger, and it stays inside the
  screen. With <code>label</code> it repeats the trigger's own name, as an IconButton does, and stays out of the accessibility
  tree.
</p>
<Example html={code('Sides')}><TooltipSides /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    {
      keys: 'Tab',
      action: 'Moves focus to the trigger: the tooltip shows at once (for a keyboard focus, not a press).',
    },
    {
      keys: 'Escape',
      action:
        'Hides it. The key stops there only while its trigger has the focus; otherwise a panel or dialog around it gets it.',
    },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Save draft, button, Saves a draft. Nothing is published." The tooltip is the trigger's description. With <code
    >label</code
  >, it only repeats the trigger's name, so it is hidden from assistive technology.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="write what people need before they act in the interface, as a hint."
  dontCaption="hide it in a tooltip: it never shows on touch."
>
  {#snippet doExample()}<TooltipDoHint />{/snippet}
  {#snippet dontExample()}<TooltipDontEssential />{/snippet}
</DoDont>
