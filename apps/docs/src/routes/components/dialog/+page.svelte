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

  import DialogDoConfirm from '#lib/examples/dialog/DoConfirm.svelte';
  import DialogDontInform from '#lib/examples/dialog/DontInform.svelte';
  import DialogLarge from '#lib/examples/dialog/Large.svelte';
  import DialogPreview from '#lib/examples/dialog/Preview.svelte';
  import DialogRename from '#lib/examples/dialog/Rename.svelte';
  import DialogRequired from '#lib/examples/dialog/Required.svelte';

  import rootProps from '../../../../.generated/props/dialog-root.json' with { type: 'json' };
  import triggerProps from '../../../../.generated/props/dialog-trigger.json' with { type: 'json' };
  import contentProps from '../../../../.generated/props/dialog-content.json' with { type: 'json' };
  import titleProps from '../../../../.generated/props/dialog-title.json' with { type: 'json' };
  import descriptionProps from '../../../../.generated/props/dialog-description.json' with { type: 'json' };
  import actionsProps from '../../../../.generated/props/dialog-actions.json' with { type: 'json' };
  import closeProps from '../../../../.generated/props/dialog-close.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Dialog — tsuya</title>
</svelte:head>

<PageHeader title="Dialog" subtitle="Overlays and feedback" />

<p class="t-body-l">
  A decision that needs an answer, or a short focused task. A modal box over a scrim, on a native <code
    >&lt;dialog&gt;</code
  >: focus is trapped inside, starts on the least destructive action, and returns to what opened it. Use Sheet for
  content that rises from an edge and can always be dismissed, Banner for a state that lasts, and Toast for a message
  that needs no answer.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')} sizes={['md', 'lg']}>
  {#snippet children({ size })}
    <DialogPreview {size} />
  {/snippet}
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  A short focused task. Open it from any element: <code>Dialog.Trigger</code> and <code>Dialog.Close</code> take a snippet
  that hands over the props to spread.
</p>
<Example html={code('Rename')}><DialogRename /></Example>
<p class="t-body t-muted">
  <code>dismissible=&#123;false&#125;</code> makes the decision required: Escape and a press on the scrim no longer
  close it, an explicit <code>Dialog.Close</code> still does. <code>alert</code> gives it the alert dialog role, for a dialog
  that interrupts.
</p>
<Example html={code('Required')}><DialogRequired /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  <code>Dialog.show</code> opens it above everything, over a scrim, and completes with what <code>Dialog.close</code>
  gives, or null once dismissed. Focus starts on the first of <code>actions</code>, so put the least destructive first
  (or pass <code>initialFocus</code>); the main action goes last.
</p>
<CodeBlock html={code('FLUTTER_DIALOG')} />
<p class="t-body t-muted">
  <code>dismissible: false</code> makes the decision required: only an action's <code>Dialog.close</code> ends it.
  <code>alert</code>
  gives it the alert dialog role, and <code>size: DialogSize.lg</code> makes it 560 wide:
</p>
<CodeBlock html={code('FLUTTER_REQUIRED')} />
<GalleryShot id="dialog" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Dialog.Root</h3>
<PropsTable rows={rootProps} />
<h3 class="t-title-s">Dialog.Trigger</h3>
<PropsTable rows={triggerProps} />
<h3 class="t-title-s">Dialog.Content</h3>
<PropsTable rows={contentProps} />
<h3 class="t-title-s">Dialog.Title</h3>
<PropsTable rows={titleProps} />
<h3 class="t-title-s">Dialog.Description</h3>
<PropsTable rows={descriptionProps} />
<h3 class="t-title-s">Dialog.Actions</h3>
<PropsTable rows={actionsProps} />
<h3 class="t-title-s">Dialog.Close</h3>
<PropsTable rows={closeProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Dialog', 'DialogSize']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  The box is at most 420 wide; <code>size="lg"</code> makes it 560. It is 16 from the screen edges and fades in, growing
  from 0.98; nothing moves under reduced motion. Put the main action last in <code>Dialog.Actions</code>. Initial focus
  goes to the first element marked <code>autofocus</code>, else to <code>Dialog.Close</code>: mark the least destructive
  action, or leave the default.
</p>
<Example html={code('Large')}><DialogLarge /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    {
      keys: 'Tab / Shift + Tab',
      action: 'Moves focus between the elements of the dialog, and wraps: it never leaves.',
    },
    {
      keys: 'Escape',
      action: 'Closes the dialog, unless it is not dismissible. A menu or a popover opened from inside closes first.',
    },
    { keys: 'Enter / Space', action: 'Presses the focused action.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Delete photo?, dialog", then its description. An alert dialog reads "alert dialog" instead.</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="ask a question that needs an answer, with the main action last."
  dontCaption="interrupt to inform: a message that needs no answer is a toast."
>
  {#snippet doExample()}<DialogDoConfirm />{/snippet}
  {#snippet dontExample()}<DialogDontInform />{/snippet}
</DoDont>
