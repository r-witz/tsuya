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

  import SheetDoOptional from '#lib/examples/sheet/DoOptional.svelte';
  import SheetDontRequired from '#lib/examples/sheet/DontRequired.svelte';
  import SheetPreview from '#lib/examples/sheet/Preview.svelte';
  import SheetSide from '#lib/examples/sheet/Side.svelte';

  import rootProps from '../../../../.generated/props/sheet-root.json' with { type: 'json' };
  import contentProps from '../../../../.generated/props/sheet-content.json' with { type: 'json' };
  import titleProps from '../../../../.generated/props/sheet-title.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Sheet — tsuya</title>
</svelte:head>

<PageHeader title="Sheet" subtitle="Overlays and feedback" />

<p class="t-body-l">
  Content that rises from the bottom of the screen, or a panel from the end edge on a desktop. Like Dialog it is modal,
  on a native <code>&lt;dialog&gt;</code>, with focus trapped and restored; unlike it, a sheet is always dismissible, so
  it is never the only way to settle a required decision. Use Dialog for that, and Popover for something anchored to a
  control.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <SheetPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  <code>side="end"</code> is a 400 wide panel from the end edge, full height, for a desktop: it mirrors in a right-to-left
  page.
</p>
<Example html={code('Side')}><SheetSide /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  <code>Sheet.show</code> opens it above everything, over a scrim, and completes with what <code>Sheet.close</code>
  gives, or null once dismissed (Escape, a press on the scrim, a drag down on touch). <code>Sheet</code> draws the box
  and its handle: <code>label</code> names it for a screen reader, and its title is yours to draw in the content.
</p>
<CodeBlock html={code('FLUTTER_SHEET')} />
<p class="t-body t-muted"><code>SheetSide.end</code> is a 400 wide panel from the end edge, for a desktop:</p>
<CodeBlock html={code('FLUTTER_SIDE')} />
<GalleryShot id="sheet" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Sheet.Root</h3>
<PropsTable rows={rootProps} />
<h3 class="t-title-s">Sheet.Content</h3>
<PropsTable rows={contentProps} />
<h3 class="t-title-s">Sheet.Title</h3>
<PropsTable rows={titleProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Sheet', 'SheetSide']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  A bottom sheet has a handle, is at most the tablet width and the height of the screen less 48, and slides over the
  sheet duration. It takes glass when it opens from a glass surface. On touch, a drag down from the handle past a third
  of its height, or a fling, closes it. A sheet has no trigger or close part: your own button sets <code>open</code>.
</p>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab / Shift + Tab', action: 'Moves focus between the elements of the sheet, and wraps: it never leaves.' },
    { keys: 'Escape', action: 'Closes the sheet; focus returns to what opened it.' },
    { keys: 'Enter / Space', action: 'Presses the focused control.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Share, dialog": the sheet is named by its title.</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="offer optional choices, which Escape or a press outside can leave."
  dontCaption="put a decision that must be made in a sheet: it is always dismissible, use a dialog."
>
  {#snippet doExample()}<SheetDoOptional />{/snippet}
  {#snippet dontExample()}<SheetDontRequired />{/snippet}
</DoDont>
