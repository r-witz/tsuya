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

  import ToastDoShort from '#lib/examples/toast/DoShort.svelte';
  import ToastDontLasting from '#lib/examples/toast/DontLasting.svelte';
  import ToastPreview from '#lib/examples/toast/Preview.svelte';
  import ToastWithAction from '#lib/examples/toast/WithAction.svelte';
  import ToastWithIcon from '#lib/examples/toast/WithIcon.svelte';

  import optionsProps from '../../../../.generated/props/toast-options.json' with { type: 'json' };
  import actionProps from '../../../../.generated/props/toast-action.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Toast — tsuya</title>
</svelte:head>

<PageHeader title="Toast" subtitle="Overlays and feedback" />

<p class="t-body-l">
  A short message about something that just happened, at the bottom centre of the screen: one at a time, announced
  politely, gone after a moment. It is shown with the <code>toast()</code> function, from anywhere in the app; the
  <code>TsuyaProvider</code> at the root of this site holds its region. Use Banner for a state that lasts, and Dialog when
  the user must answer.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <ToastPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  An icon, one of the glyphs tsuya draws: <code>check</code>, <code>minus</code>, <code>chevron-down</code>,
  <code>chevron-right</code>, <code>back</code>, <code>close</code>, <code>search</code>, <code>alert</code>,
  <code>info</code>, <code>eye</code> and <code>eye-off</code>.
</p>
<Example html={code('WithIcon')}><ToastWithIcon /></Example>
<p class="t-body t-muted">
  With an action, a toast also has a close button, and stays until the action is used, Escape, or another toast replaces
  it.
</p>
<Example html={code('WithAction')}><ToastWithAction /></Example>
<p class="t-body t-muted">
  The HTML under these examples is their button: <code>toast()</code> adds the toast itself. Without a framework, the
  page adds it and shows it as a manual popover: a
  <code>&lt;div role="status" aria-live="off" tabindex="-1" class="t-toast t-glass" data-shadow="md"&gt;</code> holding
  the icon and a <code>&lt;p class="t-toast-message"&gt;</code>, whose text <code>announce</code> of
  <code>@tsuya/core/primitives</code> reads out.
</p>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  <code>Toast.show</code> shows one at the bottom centre, above everything. A new one replaces the current one. Without
  an action it leaves after a few seconds, paused while hovered or focused; with an <code>actionLabel</code> and an
  <code>onAction</code> it also has a close button and stays until the action is used, Escape, a swipe down on touch, or another
  toast replaces it.
</p>
<CodeBlock html={code('FLUTTER_TOAST')} />
<p class="t-body t-muted">An icon shows in the accent before the message:</p>
<CodeBlock html={code('FLUTTER_ICON')} />
<GalleryShot id="toast" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">toast(message, options)</h3>
<PropsTable rows={optionsProps} />
<h3 class="t-title-s">options.action</h3>
<PropsTable rows={actionProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Toast']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  A new toast replaces the one shown. Without an action it leaves after the toast duration, 4 seconds even under reduced
  motion since it is reading time, and the timer is paused while it is hovered or focused. It always shows above an open
  dialog or sheet. On touch, a swipe down dismisses it.
</p>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    {
      keys: 'F6',
      action: 'Moves focus to the toast while one is shown; focus returns to where it was when the toast goes.',
    },
    { keys: 'Escape', action: 'Dismisses the toast.' },
    { keys: 'Tab', action: 'Moves between its action and its close button.' },
    { keys: 'Enter / Space', action: 'Presses the focused button.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Saved." The message is announced politely through the live announcer, once: the toast itself is a status that is not
  live, so it is not read twice.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="a short message about what just happened, with at most one action."
  dontCaption="put a lasting state in a toast: it disappears. Use a banner."
>
  {#snippet doExample()}<ToastDoShort />{/snippet}
  {#snippet dontExample()}<ToastDontLasting />{/snippet}
</DoDont>
