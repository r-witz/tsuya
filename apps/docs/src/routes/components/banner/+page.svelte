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

  import BannerActions from '#lib/examples/banner/Actions.svelte';
  import BannerClosable from '#lib/examples/banner/Closable.svelte';
  import BannerDoLastingState from '#lib/examples/banner/DoLastingState.svelte';
  import BannerDontTransient from '#lib/examples/banner/DontTransient.svelte';
  import BannerPreview from '#lib/examples/banner/Preview.svelte';
  import BannerTones from '#lib/examples/banner/Tones.svelte';
  import BannerWarning from '#lib/examples/banner/Warning.svelte';

  import bannerProps from '../../../../.generated/props/banner.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Banner — tsuya</title>
</svelte:head>

<PageHeader title="Banner" subtitle="Overlays and feedback" />

<p class="t-body-l">
  A lasting state: offline, a sync error, a trial that is ending. A status icon, a title, a message and actions, in one
  of four tones. Use Toast for something that just happened and then passes, and Dialog for a decision that needs an
  answer.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <BannerPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Tones')}><BannerTones /></Example>
<p class="t-body t-muted">Actions sit at the end, and under the message when the banner is narrow.</p>
<Example html={code('Actions')}><BannerActions /></Example>
<p class="t-body t-muted">
  <code>onclose</code> adds a close button; leave it out for a banner that cannot be dismissed.
</p>
<Example html={code('Closable')}><BannerClosable /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  <code>Banner</code> is a widget you place in the page, not an overlay: show or hide it with your own state.
  <code>tone</code>
  is one of <code>BannerTone.info</code>, <code>success</code>, <code>warning</code> and <code>danger</code>.
  <code>package:flutter/widgets.dart</code> has a <code>Banner</code> too (the debug ribbon), which every Flutter app imports:
  hide it, as below, or import tsuya with a prefix.
</p>
<CodeBlock html={code('FLUTTER_BANNER')} />
<p class="t-body t-muted"><code>onClose</code> adds a close button:</p>
<CodeBlock html={code('FLUTTER_CLOSABLE')} />
<GalleryShot id="banner" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={bannerProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Banner', 'BannerTone']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  The tones are <code>info</code>, <code>success</code>, <code>warning</code> and <code>danger</code>: a fill at 13 %
  with a 1 px ring at 32 %, never a coloured side stripe. The icon follows the tone (<code>warning</code> and
  <code>danger</code> share a glyph, so the title's wording tells them apart).
</p>
<Example html={code('Warning')}><BannerWarning /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to its actions and its close button; the banner itself is not a tab stop.' },
    { keys: 'Enter / Space', action: 'Presses the focused action or the close button.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"You are offline, group", then its message. A close button reads "Close, button".</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="a lasting state, with the action that settles it."
  dontCaption="confirm something that just happened: it will pass, use a toast."
>
  {#snippet doExample()}<BannerDoLastingState />{/snippet}
  {#snippet dontExample()}<BannerDontTransient />{/snippet}
</DoDont>
