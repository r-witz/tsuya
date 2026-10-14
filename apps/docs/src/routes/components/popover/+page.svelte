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

  import PopoverBasic from '#lib/examples/popover/Basic.svelte';
  import PopoverChild from '#lib/examples/popover/Child.svelte';
  import PopoverDoSmall from '#lib/examples/popover/DoSmall.svelte';
  import PopoverDontActions from '#lib/examples/popover/DontActions.svelte';
  import PopoverPlacement from '#lib/examples/popover/Placement.svelte';

  import popoverRootProps from '../../../../.generated/props/popover-root.json' with { type: 'json' };
  import popoverTriggerProps from '../../../../.generated/props/popover-trigger.json' with { type: 'json' };
  import popoverContentProps from '../../../../.generated/props/popover-content.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Popover — tsuya</title>
</svelte:head>

<PageHeader title="Popover" subtitle="Overlays and feedback" />

<p class="t-body-l">
  A non-modal panel anchored to a trigger, for small interactive content such as filters, a colour picker or details.
  Composed from parts, <code>Popover.Root</code>, <code>Popover.Trigger</code> and <code>Popover.Content</code>. It is
  named by its opener, and closes on Escape, on a press outside and when focus leaves it. Use Menu for a list of
  actions, Dialog for a decision that must be made, and Tooltip for a short label.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <PopoverBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  Bind <code>open</code> on the root to read or set it. The trigger is a secondary button; the content holds whatever controls
  it needs.
</p>
<Example html={code('Basic')}><PopoverBasic /></Example>
<p class="t-body t-muted">Use your own opener, such as an icon button, through <code>child</code>:</p>
<Example html={code('Child')}><PopoverChild /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  <code>Popover</code> is the secondary button together with its panel: <code>label</code> names both,
  <code>builder</code> draws the content. Opened from the keyboard, focus moves into the panel; Escape closes it and gives
  the focus back to the button.
</p>
<CodeBlock html={code('FLUTTER_POPOVER')} />
<p class="t-body t-muted">
  For an opener of your own, <code>Popover.show</code> anchors the panel to the render box of the context it gets:
</p>
<CodeBlock html={code('FLUTTER_SHOW')} />
<GalleryShot id="popover" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Popover.Root</h3>
<PropsTable rows={popoverRootProps} />
<h3 class="t-title-s">Popover.Trigger</h3>
<PropsTable rows={popoverTriggerProps} />
<h3 class="t-title-s">Popover.Content</h3>
<PropsTable rows={popoverContentProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Popover', 'AnchorSide', 'AnchorAlign']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  <code>side</code> and <code>align</code> place the panel: under its opener at its start edge by default, with no arrow.
  It follows the accent and the glass of what opened it.
</p>
<Example html={code('Placement')}><PopoverPlacement /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    {
      keys: 'Enter / Space (on the trigger)',
      action: 'Opens the popover and moves focus to its first control, or to the panel.',
    },
    { keys: 'Click (on the trigger)', action: 'Opens or closes it; focus stays where the press put it.' },
    { keys: 'Tab', action: 'Moves between its controls; leaving the panel closes it.' },
    { keys: 'Escape', action: 'Closes it and returns focus to the trigger.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  The trigger reads "Filters, button, collapsed, has popup dialog". The panel is a dialog named by its opener: "Filters,
  dialog".
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="keep a popover for small interactive content, such as a few filters."
  dontCaption="fill it with a list of actions; that is a Menu."
>
  {#snippet doExample()}<PopoverDoSmall />{/snippet}
  {#snippet dontExample()}<PopoverDontActions />{/snippet}
</DoDont>
