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

  import IconButtonBasic from '#lib/examples/icon-button/Basic.svelte';
  import IconButtonDoFamiliar from '#lib/examples/icon-button/DoFamiliar.svelte';
  import IconButtonDontUnclear from '#lib/examples/icon-button/DontUnclear.svelte';
  import IconButtonGlass from '#lib/examples/icon-button/Glass.svelte';
  import IconButtonLarge from '#lib/examples/icon-button/Large.svelte';
  import IconButtonToggle from '#lib/examples/icon-button/Toggle.svelte';
  import IconButtonVariants from '#lib/examples/icon-button/Variants.svelte';

  import iconButtonProps from '../../../../.generated/props/icon-button.json' with { type: 'json' };
</script>

<svelte:head>
  <title>IconButton — tsuya</title>
</svelte:head>

<PageHeader title="IconButton" subtitle="Actions" />

<p class="t-body-l">
  An icon-only action, or a toggle: round, and always named by its label, which also shows as a tooltip on fine
  pointers. <code>filled</code> is the default, <code>plain</code> sits in a toolbar, <code>accent</code> is the
  icon-only primary action and <code>glass</code> is for artwork. Use Button when there is room for a label, and Chip for
  a filter or a sort option.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')} sizes={['sm', 'md', 'lg']}>
  {#snippet children({ size })}
    <IconButtonBasic {size} />
  {/snippet}
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">The label is required: it names the button, and shows as a tooltip on a mouse or a pen.</p>
<Example html={code('Basic')}><IconButtonBasic /></Example>
<p class="t-body t-muted">Filled is the default; plain for a toolbar; accent for the one icon-only primary action.</p>
<Example html={code('Variants')}><IconButtonVariants /></Example>
<p class="t-body t-muted">As a toggle, <code>pressed</code> turns it accent-filled.</p>
<Example html={code('Toggle')}><IconButtonToggle /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  Material also has a <code>IconButton</code>: an app that imports it too imports tsuya with a prefix (<code
    >import 'package:tsuya/tsuya.dart' as t;</code
  >).
</p>
<CodeBlock html={code('FLUTTER_ICON_BUTTON')} />
<p class="t-body t-muted">
  The label also shows as a tooltip, as on the web: the button wraps a <code>Tooltip</code> with it, and
  <code>tooltip: false</code> turns that off. A toggle sets <code>toggled</code>; the large primary action takes
  <code>IconButtonSize.custom</code>.
</p>
<CodeBlock html={code('FLUTTER_TOGGLE')} />
<GalleryShot id="icon-button" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={iconButtonProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['IconButton', 'IconButtonKind', 'IconButtonSize']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  Sizes are <code>sm</code>, <code>md</code> and <code>lg</code> (32, 44 and 56), or a number from 40 to 72 for the
  large primary action. <code>glass</code> is control glass: it only reads over artwork, never a flat background (DESIGN.md,
  rule 3).
</p>
<Example html={code('Large')}><IconButtonLarge /></Example>
<Example html={code('Glass')}><IconButtonGlass /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the button; its tooltip shows at once.' },
    { keys: 'Enter / Space', action: 'Presses the button, or toggles it.' },
    { keys: 'Escape', action: 'Hides the tooltip, while the button has the focus.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Share, button." A toggle reads "Edit, toggle button, pressed". The tooltip repeats the label, so it stays out of the
  accessibility tree.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="keep the icon-only button for a familiar icon, such as delete or share."
  dontCaption="rely on an icon alone for an action people cannot guess; use a Button with its label."
>
  {#snippet doExample()}<IconButtonDoFamiliar />{/snippet}
  {#snippet dontExample()}<IconButtonDontUnclear />{/snippet}
</DoDont>
